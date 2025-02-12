// Test bench for UART_RX module
// Rule of thumb: wire outputs,  register inputs (wori).
`include "uart_rx.v"
module tb;
  reg clk = 0;
  reg uart_rx = 1;
  wire [5:0] led;
  wire btn=1;

  uart #(8'd8) u(
    .clk(clk),
    .uart_rx(uart_rx),
    .led(led),
    .btn1(btn)
  );

    always #1 clk = ~clk;

    initial begin
        $display("Starting UART RX");
        $monitor("LED Value: %b", led);
        #10 uart_rx = 0;
        #16 uart_rx = 1;
        #16 uart_rx = 0;
        #16 uart_rx = 0;
        #16 uart_rx = 0;
        #16 uart_rx = 0;
        #16 uart_rx = 1;
        #16 uart_rx = 1;
        #16 uart_rx = 0;
        #16 uart_rx = 1;
        #1000 $finish;
    end

    initial begin
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, tb);
    end

endmodule