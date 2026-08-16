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

project     : axi_gpio
version     : 1.0
date        : 16.08.2026
author      : siarhei baldzenka
e-mail      : sbaldzenka@proton.me
description : https://github.com/sbaldzenka/axi_gpio

            0x00 - Control Tristate Buffer Reg
            0x04 - Output Value Reg
            0x08 - Input Value Reg

---------------------------------------------------------------------------------------
*/

`timescale 1ns/100ps

module axi_gpio_tb
#(
    // sim parameters
    parameter CLK_100_MHZ_PERIOD = 10,
    // axi-lite parameters
    parameter ADDR_WIDTH         = 32,
    parameter DATA_WIDTH         = 32,
    parameter WSTRB_WIDTH        = DATA_WIDTH/8,
    // gpio parameters
    parameter GPIO_WIDTH         = 32,
    parameter GPIO_INIT_VALUE    = {GPIO_WIDTH{1'b0}}
);

    // signals
    bit                    clk;
    bit                    resetn;

    bit                    s_axi_awvalid;
    bit  [ ADDR_WIDTH-1:0] s_axi_awaddr;
    bit                    s_axi_awready;
    bit                    s_axi_wvalid;
    bit  [ DATA_WIDTH-1:0] s_axi_wdata;
    bit  [WSTRB_WIDTH-1:0] s_axi_wstrb;
    bit                    s_axi_wready;
    bit                    s_axi_bvalid;
    bit  [            1:0] s_axi_bresp;
    bit                    s_axi_bready;
    bit                    s_axi_arvalid;
    bit  [ ADDR_WIDTH-1:0] s_axi_araddr;
    bit                    s_axi_arready;
    bit                    s_axi_rvalid;
    bit  [ DATA_WIDTH-1:0] s_axi_rdata;
    bit  [            1:0] s_axi_rresp;
    bit                    s_axi_rready;

    wire [ GPIO_WIDTH-1:0] io_gpio;

    bit  [ GPIO_WIDTH-1:0] gpio_en_value;
    bit  [ GPIO_WIDTH-1:0] gpio_out_value;
    bit  [ GPIO_WIDTH-1:0] gpio_in_value;

    // tasks
    task reset_n_generate;
        begin
            resetn = 1'b1;
            #(CLK_100_MHZ_PERIOD*2);
            resetn = 1'b0;
            #(CLK_100_MHZ_PERIOD*5);
            resetn = 1'b1;
        end
    endtask

    task write_axi_data(input logic [31:0] addr, input logic [31:0] data);
        begin
            s_axi_bready       <= 1'b0;
            s_axi_wvalid       <= 1'b0;
            s_axi_wdata        <= 'b0;
            s_axi_wstrb        <= 'b0;
            #100;
            @(posedge clk);
            s_axi_awvalid      <= 1'b1;
            s_axi_awaddr[31:0] <= addr;
            s_axi_wvalid       <= 1'b1;
            s_axi_wdata[31:0]  <= data;
            s_axi_wstrb[3:0]   <= 4'hF;
            @(posedge s_axi_awready) #CLK_100_MHZ_PERIOD;
            s_axi_awvalid      <= 1'b0;
            s_axi_awaddr       <= '0;
            @(posedge s_axi_wready) #CLK_100_MHZ_PERIOD;
            s_axi_wvalid       <= 1'b0;
            s_axi_wdata        <= 'b0;
            s_axi_wstrb        <= 'b0;
            @(posedge s_axi_bvalid) #(CLK_100_MHZ_PERIOD*3);
            s_axi_bready       <= 1'b1;
            #CLK_100_MHZ_PERIOD;
            s_axi_bready       <= 1'b0;
        end
    endtask

    task read_axi_data(input logic [31:0] addr);
        begin
            s_axi_arvalid      <= 1'b0;
            s_axi_araddr       <= '0;
            s_axi_rready       <= 1'b0;
            #100;
            s_axi_arvalid      <= 1'b1;
            s_axi_araddr[31:0] <= addr;
            @(posedge s_axi_arready) #CLK_100_MHZ_PERIOD;
            s_axi_arvalid      <= 1'b0;
            @(posedge s_axi_rvalid) #(CLK_100_MHZ_PERIOD*3);
            s_axi_rready       <= 1'b1;
            #CLK_100_MHZ_PERIOD;
            s_axi_rready       <= 1'b0;
        end
    endtask

    // test logic
    always #(CLK_100_MHZ_PERIOD/2) clk = ~clk;

    initial begin
        clk             <= 1'b0;
        resetn          <= 1'b1;
        s_axi_arvalid   <= 1'b0;
        s_axi_araddr    <= '0;
        s_axi_rready    <= 1'b0;
        s_axi_awvalid   <= 1'b0;
        s_axi_awaddr    <= '0;
        s_axi_bready    <= 1'b0;
        s_axi_wvalid    <= 1'b0;
        s_axi_wdata     <= 'b0;
        s_axi_wstrb     <= 'b0;
    end

    initial begin
        reset_n_generate();
        #100;
        write_axi_data(32'h80000000, 32'hFFFFFFFF);
        write_axi_data(32'h80000004, 32'hAAAAAAAA);
        #100;
        write_axi_data(32'h80000004, 32'h55555555);
        #100;
        read_axi_data(32'h80000008);
        #100;
        write_axi_data(32'h80000000, 32'h00000000);
        #100;
        gpio_en_value  = 32'hFFFFFFFF;
        gpio_out_value = 32'h12345678;
        #100;
        read_axi_data(32'h80000008);
        #100;
        write_axi_data(32'h80000000, 32'hAAAAAAAA);
        #100;
        gpio_out_value = 32'hFFFFFFFF;
        #100;
        read_axi_data(32'h80000008);
    end

    defparam DUT_inst.ADDR_WIDTH      = ADDR_WIDTH;
    defparam DUT_inst.DATA_WIDTH      = DATA_WIDTH;
    defparam DUT_inst.WSTRB_WIDTH     = WSTRB_WIDTH;
    defparam DUT_inst.GPIO_WIDTH      = GPIO_WIDTH;
    defparam DUT_inst.GPIO_INIT_VALUE = GPIO_INIT_VALUE;

    axi_gpio DUT_inst
    (
        .s_axi_aclk    ( clk    ),
        .s_axi_aresetn ( resetn ),
        .*
    );

    defparam tristate_buffer_inst.GPIO_WIDTH = GPIO_WIDTH;

    tristate_buffer tristate_buffer_inst
    (
        .en ( gpio_en_value  ),
        .i  ( gpio_out_value ),
        .o  ( gpio_in_value  ),
        .io ( io_gpio        )
    );

endmodule