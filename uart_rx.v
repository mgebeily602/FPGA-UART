module uart
#(
    parameter DELAY_FRAMES = 234    // 27Mhz/115200 Baud rate
)
(
    input clk,
    input uart_rx,
    input btn1,
    output reg [5:0] led
);
    
    localparam HALF_DELAY_WAIT = (DELAY_FRAMES/2);

    reg [3:0] rxState =0;           // 4 states for the receiver
    reg [7:0] dataIn = 0;           // 8-bit data in
    reg [12:0] rxCounter = 0;       // suitable for 115200 as well as 9600 baud rates
    reg [2:0] rxBitNumber = 0;      // keeps track of how many bits are read so far
    reg byteReady = 0;              // flag to indicate that a byte is read

    localparam RX_STATE_IDLE = 0;
    localparam RX_STATE_START_BIT = 1;
    localparam RX_STATE_READ_WAIT = 2;
    localparam RX_STATE_READ = 3;
    localparam RX_STATE_STOP_BIT = 4;

    always @(posedge clk) begin
        case (rxState)
            RX_STATE_IDLE: begin    //0
                if (uart_rx == 0) begin
                    rxState <= RX_STATE_START_BIT;
                    rxCounter <= 1;
                    rxBitNumber <= 0;
                    byteReady <= 0;
                end
            end 
            RX_STATE_START_BIT: begin       //1
                if (rxCounter == HALF_DELAY_WAIT) begin
                    rxState <= RX_STATE_READ_WAIT;
                    rxCounter <= 1;
                end else 
                    rxCounter <= rxCounter + 1;
            end
            RX_STATE_READ_WAIT: begin       //2
                rxCounter <= rxCounter + 1;
                if ((rxCounter + 1) == DELAY_FRAMES) begin
                    rxState <= RX_STATE_READ;
                end
            end
            RX_STATE_READ: begin        //3
                rxCounter <= 1;
                dataIn <= {uart_rx, dataIn[7:1]};
                rxBitNumber <= rxBitNumber + 1;
                if (rxBitNumber == 3'b111)
                    rxState <= RX_STATE_STOP_BIT;
                else
                    rxState <= RX_STATE_READ_WAIT;
            end
            RX_STATE_STOP_BIT: begin        //4
                rxCounter <= rxCounter + 1;
                if ((rxCounter + 1) == DELAY_FRAMES) begin
                    rxState <= RX_STATE_IDLE;
                    rxCounter <= 0;
                    byteReady <= 1;
                end
            end
        endcase
    end

    always @(posedge clk) begin
        if (byteReady) begin
            led <= ~dataIn[5:0];
        end
    end
endmodule