# Tang Nano 9k UART Rx, Tx Simulation and Programming

We adapt the article [Tang Nano 9K: Debugging & UART](https://learn.lushaylabs.com/tang-nano-9k-debugging/) to work with Icaros Verilog for simulation on the Rx side and with Gowin IDE to program the Tang nano 9k board on the Tx side. To program both sides on the Tang nano is not implemented yet.

## Icaros Verilog Simulation of the Rx side

The steps are as follows:

1. Create the files uart_rx.v and uart_rx_tb.v in VS code.
2. In `TERMINAL` type the command

```Verilog
iverilog -o uart_rx.o uart_rx_tb.v
vvp uart_rx.o
gtkwave
```

   3. In the GTKWave windo that pops up select `File` -> `Open New Tab` -> `uart_rx.vcd`. Expand `tb` tab in the SST panel to see a list of the signal waves that you want displayed and then click `Insert`. An example is shown below.

![Rx_Wave](./images/uart_rx_wave.jpg)

## Tang Nano 9k Programming with Gowin IDE

The steps are as follows:

1. Start a new Gowing project.
2. In the `Design window, add a verilog file.
3. Copy the file uart_tx.v and paste in the new file.
4. Run `Synthesis` -> `Floor Planner`, accept `create a cst file` and make the following connections:

```CST
IO_LOC "uart_tx" 17;
IO_PORT "uart_tx" IO_TYPE=LVCMOS33 PULL_MODE=UP DRIVE=8 BANK_VCCIO=3.3;
IO_LOC "btn1" 3;
IO_PORT "btn1" IO_TYPE=LVCMOS18 PULL_MODE=UP BANK_VCCIO=1.8;
IO_LOC "clk" 52;
IO_PORT "clk" IO_TYPE=LVCMOS18 PULL_MODE=UP BANK_VCCIO=1.8;
```

5. Run `Place and Rout`
6. Run `Programmer` and upload the program to the board.
7. Go to VS code and open `Serial Monitor` Select the serial port to which the Tang nano is connected (e.g. COM12) and `Start Monitoring`. Each time you press the left button on the board you should see message "Gowin IDE Demo" printed on the montor.

 An alternative to the last step is to install the serial port library, run the script files "list-devices.js" and "tc.js" from the `TERMINAL`. See the reference listed above for detailed discussion.