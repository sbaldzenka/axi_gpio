# axi_gpio

## Description

GPIO IP-core with the AXI4-Lite interface.
- Supports configurable channel width for GPIO pins from 1 to 32 bits.
- Supports dynamic programming of each GPIO bit as input or output

### Catalogs structure:
- sim - .do-files and .sh scripts for Modelsim/Questasim;
- src - source files;
- tb - testbenches;

> **axi_gpio.sv** - top file;

### Register Space:

| Address Space | Register Name | Access | Description                                     |
| Offset        |               | Type   |                                                 |
|---------------|---------------|--------|-------------------------------------------------|
| 0x00          | GPIO_TRI      | R/W    | GPIO 3-state control register. 0 - in, 1 - out. |
| 0x04          | GPIO_DATA_OUT | R/W    | GPIO data out register.                         |
| 0x08          | GPIO_DATA_IN  | R      | GPIO data in register.                          |