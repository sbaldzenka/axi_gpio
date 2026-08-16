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

              0 - Control Tristate Buffer Reg
              1 - Output Value Reg
              2 - Input Value Reg

---------------------------------------------------------------------------------------
*/

module gpio_ctrl
#(
    // Register parameters
    parameter DATA_WIDTH      = 32,
    parameter NUM_OF_REGS     = 3,
    // GPIO parameters
    parameter GPIO_WIDTH      = 32,
    parameter GPIO_INIT_VALUE = {GPIO_WIDTH{1'b0}}
)
(
    // global signals
    input  logic                                   i_clk,
    input  logic                                   i_resetn,
    // registers
    output logic [0:NUM_OF_REGS-1]                 o_reg_update,
    output logic [0:NUM_OF_REGS-1][DATA_WIDTH-1:0] o_reg_new_value,
    input  logic [0:NUM_OF_REGS-1][DATA_WIDTH-1:0] i_reg_current_value,
    // gpio values
    output logic                  [GPIO_WIDTH-1:0] o_en_gpio,
    output logic                  [GPIO_WIDTH-1:0] o_gpio,
    input  logic                  [GPIO_WIDTH-1:0] i_gpio
);

    always_ff @(posedge i_clk) begin
        if (!i_resetn) begin
            o_reg_update[0:1]    <= 1'b0;
            o_reg_new_value[0:1] <= {DATA_WIDTH{1'b0}};
        end
    end

    always_ff @(posedge i_clk) begin
        if (!i_resetn) begin
            o_en_gpio <= {GPIO_WIDTH{1'b0}};
        end else begin
            o_en_gpio <= i_reg_current_value[0];
        end
    end

    always_ff @(posedge i_clk) begin
        if (!i_resetn) begin
            o_gpio <= GPIO_INIT_VALUE;
        end else begin
            o_gpio <= i_reg_current_value[1];
        end
    end

    always_ff @(posedge i_clk) begin
        o_reg_update[2]                    <= 1'b1;
        o_reg_new_value[2][GPIO_WIDTH-1:0] <= i_gpio & (~i_reg_current_value[0]);
    end

endmodule