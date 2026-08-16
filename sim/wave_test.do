-- project     : axi_gpio
-- version     : 1.0
-- date        : 16.08.2026
-- author      : siarhei baldzenka
-- e-mail      : sbaldzenka@proton.me
-- description : https://github.com/sbaldzenka/axi_gpio

-- Waves
add wave -noupdate -divider testbench
add wave -noupdate -format Logic -radix HEXADECIMAL -group {testbench} /axi_gpio_tb/*

add wave -noupdate -divider DUT
add wave -noupdate -format Logic -radix HEXADECIMAL -group {DUT} /axi_gpio_tb/DUT_inst/*

add wave -noupdate -divider axi_regs
add wave -noupdate -format Logic -radix HEXADECIMAL -group {axi_regs} /axi_gpio_tb/DUT_inst/axi_regs_inst/*

add wave -noupdate -divider gpio_ctrl
add wave -noupdate -format Logic -radix HEXADECIMAL -group {gpio_ctrl} /axi_gpio_tb/DUT_inst/gpio_ctrl_inst/*

add wave -noupdate -divider tristate_buffer
add wave -noupdate -format Logic -radix HEXADECIMAL -group {tristate_buffer} /axi_gpio_tb/DUT_inst/tristate_buffer_inst/*

-- Toggle leaf names command
config wave -signalnamewidth 1