-- project     : axi_gpio
-- version     : 1.0
-- date        : 16.08.2026
-- author      : siarhei baldzenka
-- e-mail      : sbaldzenka@proton.me
-- description : https://github.com/sbaldzenka/axi_gpio

vlib work
vmap work work

vlog ../tb/axi_gpio_tb.sv

vlog ../src/axi_gpio.sv
vlog ../src/axi_regs.sv
vlog ../src/gpio_ctrl.sv
vlog ../src/tristate_buffer.sv

vsim -t 1ps -voptargs=+acc=lprn -lib work axi_gpio_tb

do wave_test.do
view wave
run 6 us