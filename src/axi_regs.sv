/*
---------------------------------------------------------------------------------------

MIT License

Copyright (c) 2026 Siarhei Baldzenka

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---------------------------------------------------------------------------------------

project     : axi_regs
version     : 1.0
date        : 22.01.2026
author      : siarhei baldzenka
e-mail      : sbaldzenka@proton.me
description : https://github.com/sbaldzenka/axi_regs

---------------------------------------------------------------------------------------
*/

`timescale 1ns/100ps

module axi_regs
#(
    // axi-lite parameters
    parameter ADDR_WIDTH  = 32,
    parameter DATA_WIDTH  = 32,
    parameter WSTRB_WIDTH = DATA_WIDTH/8,
    // register parameters
    parameter NUM_OF_REGS = 4,
    parameter OFFSET      = DATA_WIDTH/8
)
(
    // global signals
    input  logic                                    s_axi_aclk,
    input  logic                                    s_axi_aresetn,
    // axi-lite bus
    input  logic                                    s_axi_awvalid,
    input  logic                  [ ADDR_WIDTH-1:0] s_axi_awaddr,
    output logic                                    s_axi_awready,
    input  logic                                    s_axi_wvalid,
    input  logic                  [ DATA_WIDTH-1:0] s_axi_wdata,
    input  logic                  [WSTRB_WIDTH-1:0] s_axi_wstrb,
    output logic                                    s_axi_wready,
    output logic                                    s_axi_bvalid,
    output logic                  [            1:0] s_axi_bresp,
    input  logic                                    s_axi_bready,
    input  logic                                    s_axi_arvalid,
    input  logic                  [ ADDR_WIDTH-1:0] s_axi_araddr,
    output logic                                    s_axi_arready,
    output logic                                    s_axi_rvalid,
    output logic                  [ DATA_WIDTH-1:0] s_axi_rdata,
    output logic                  [            1:0] s_axi_rresp,
    input  logic                                    s_axi_rready,
    // registers
    input  logic [0:NUM_OF_REGS-1]                  i_reg_update,
    input  logic [0:NUM_OF_REGS-1][ DATA_WIDTH-1:0] i_reg_new_value,
    output logic [0:NUM_OF_REGS-1][ DATA_WIDTH-1:0] o_reg_current_value
);

    // enumerations
    enum
    {
        S_IDLE,
        S_GET_RADDR,
        S_CHECK_RADDR,
        S_LOAD_REG,
        S_WAIT_READY_REG,
        S_GET_WADDR,
        S_WAIT_WDATA,
        S_GET_WDATA,
        S_SEND_RESP,
        S_WAIT_RESP
    }
    states;

    // signals
    logic                  [ADDR_WIDTH-1:0] buffer_addr;
    logic                  [           3:0] state;
    logic [0:NUM_OF_REGS-1][DATA_WIDTH-1:0] registers;

    // logic

    always_ff @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            state <= S_IDLE;
        end else begin
            case (state)
                S_IDLE: begin
                    if (s_axi_arvalid) begin
                        state <= S_GET_RADDR;
                    end

                    if (s_axi_awvalid) begin
                        state <= S_GET_WADDR;
                    end
                end

                S_GET_RADDR: begin
                    state <= S_CHECK_RADDR;
                end

                S_CHECK_RADDR: begin
                    state <= S_LOAD_REG;
                end

                S_LOAD_REG: begin
                    state <= S_WAIT_READY_REG;
                end

                S_WAIT_READY_REG: begin
                    if (s_axi_rready) begin
                        state <= S_IDLE;
                    end
                end

                S_GET_WADDR: begin
                    state <= S_WAIT_WDATA;
                end

                S_WAIT_WDATA: begin
                    if (s_axi_wvalid) begin
                        state <= S_GET_WDATA;
                    end
                end

                S_GET_WDATA: begin
                    state <= S_SEND_RESP;
                end

                S_SEND_RESP: begin
                    state <= S_WAIT_RESP;
                end

                S_WAIT_RESP: begin
                    if (s_axi_bready) begin
                        state <= S_IDLE;
                    end
                end
            endcase
        end
    end

    always_ff @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            buffer_addr <= 'b0;
        end else if (state == S_GET_RADDR) begin
            buffer_addr <= s_axi_araddr;
        end else if (state == S_GET_WADDR) begin
            buffer_addr <= s_axi_awaddr;
        end
    end

    always_ff @(posedge s_axi_aclk) begin
        if (state == S_GET_RADDR) begin
            s_axi_arready <= 1'b1;
        end else begin
            s_axi_arready <= 1'b0;
        end
    end

    always_ff @(posedge s_axi_aclk) begin
        if (state == S_GET_WADDR) begin
            s_axi_awready <= 1'b1;
        end else begin
            s_axi_awready <= 1'b0;
        end
    end

    always_ff @(posedge s_axi_aclk) begin
        if (state == S_GET_WDATA) begin
            s_axi_wready <= 1'b1;
        end else begin
            s_axi_wready <= 1'b0;
        end
    end

    assign s_axi_rvalid = (state == S_WAIT_READY_REG) ? 1'b1 : 1'b0;
    assign s_axi_rresp  = 2'b00;
    assign s_axi_bvalid = (state == S_WAIT_RESP) ? 1'b1 : 1'b0;
    assign s_axi_bresp  = 2'b00;

    always_ff @(posedge s_axi_aclk) begin
        if(!s_axi_aresetn) begin
            registers <= 'b0;
        end else begin
            for (int index = 0; index < NUM_OF_REGS; index++) begin
                if (i_reg_update[index]) begin
                    registers[index] <= i_reg_new_value[index];
                end

                if (state == S_GET_WDATA) begin
                    if (buffer_addr[7:0] == index * OFFSET) begin
                        registers[index] <= s_axi_wdata;
                    end
                end
            end
        end
    end

    always_ff @(posedge s_axi_aclk) begin
        o_reg_current_value <= registers;
    end

    always_ff @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            s_axi_rdata <= 'b0;
        end else begin
            for (int index = 0; index < NUM_OF_REGS; index++) begin
                if (state == S_LOAD_REG) begin
                    if (buffer_addr[7:0] == index * OFFSET) begin
                        s_axi_rdata <= registers[index];
                    end
                end
            end
        end
    end

endmodule