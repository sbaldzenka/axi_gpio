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

---------------------------------------------------------------------------------------
*/

`timescale 1ns/100ps

module axi_gpio
#(
    // AXI4-Lite parameters
    parameter ADDR_WIDTH      = 32,
    parameter DATA_WIDTH      = 32,
    parameter WSTRB_WIDTH     = DATA_WIDTH/8,
    // GPIO parameters
    parameter GPIO_WIDTH      = 32,
    parameter GPIO_INIT_VALUE = {GPIO_WIDTH{1'b0}}
)
(
    // global signals
    input  logic                   s_axi_aclk,
    input  logic                   s_axi_aresetn,
    // axi-lite bus
    input  logic                   s_axi_awvalid,
    input  logic [ ADDR_WIDTH-1:0] s_axi_awaddr,
    output logic                   s_axi_awready,
    input  logic                   s_axi_wvalid,
    input  logic [ DATA_WIDTH-1:0] s_axi_wdata,
    input  logic [WSTRB_WIDTH-1:0] s_axi_wstrb,
    output logic                   s_axi_wready,
    output logic                   s_axi_bvalid,
    output logic [            1:0] s_axi_bresp,
    input  logic                   s_axi_bready,
    input  logic                   s_axi_arvalid,
    input  logic [ ADDR_WIDTH-1:0] s_axi_araddr,
    output logic                   s_axi_arready,
    output logic                   s_axi_rvalid,
    output logic [ DATA_WIDTH-1:0] s_axi_rdata,
    output logic [            1:0] s_axi_rresp,
    input  logic                   s_axi_rready,
    // gpio
    inout  wire  [ GPIO_WIDTH-1:0] io_gpio

);

    // local parameters
    localparam NUM_OF_REGS = 3;
    localparam OFFSET      = DATA_WIDTH/8;

    // signals
    logic [0:NUM_OF_REGS-1]                 i_reg_update;
    logic [0:NUM_OF_REGS-1][DATA_WIDTH-1:0] i_reg_new_value;
    logic [0:NUM_OF_REGS-1][DATA_WIDTH-1:0] o_reg_current_value;

    logic                  [GPIO_WIDTH-1:0] o_gpio_en_value;
    logic                  [GPIO_WIDTH-1:0] o_gpio_out_value;
    logic                  [GPIO_WIDTH-1:0] i_gpio_in_value;

    // instances
    defparam axi_regs_inst.ADDR_WIDTH  = ADDR_WIDTH;
    defparam axi_regs_inst.DATA_WIDTH  = DATA_WIDTH;
    defparam axi_regs_inst.WSTRB_WIDTH = WSTRB_WIDTH;
    defparam axi_regs_inst.NUM_OF_REGS = NUM_OF_REGS;
    defparam axi_regs_inst.OFFSET      = OFFSET;

    axi_regs axi_regs_inst
    (
        .*
    );

    defparam gpio_ctrl_inst.GPIO_WIDTH      = GPIO_WIDTH;
    defparam gpio_ctrl_inst.GPIO_INIT_VALUE = GPIO_INIT_VALUE;
    defparam gpio_ctrl_inst.NUM_OF_REGS     = NUM_OF_REGS;

    gpio_ctrl gpio_ctrl_inst
    (
        .i_clk               ( s_axi_aclk          ),
        .i_resetn            ( s_axi_aresetn       ),
        .o_reg_update        ( i_reg_update        ),
        .o_reg_new_value     ( i_reg_new_value     ),
        .i_reg_current_value ( o_reg_current_value ),
        .o_en_gpio           ( o_gpio_en_value     ),
        .o_gpio              ( o_gpio_out_value    ),
        .i_gpio              ( i_gpio_in_value     )
    );

    defparam tristate_buffer_inst.GPIO_WIDTH = GPIO_WIDTH;

    tristate_buffer tristate_buffer_inst
    (
        .en ( o_gpio_en_value  ),
        .i  ( o_gpio_out_value ),
        .o  ( i_gpio_in_value  ),
        .io ( io_gpio          )
    );

endmodule