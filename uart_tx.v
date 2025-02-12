module uart_t #(
    parameter DELAY_FRAMES = 234    // 27Mhz/115200 Baud rate
) (
    input clk,
    // input uart_rx,
    input btn1,
    output uart_tx
);
reg [3:0] txState = 0;
reg [24:0] txCounter = 0;
reg [7:0] dataOut = 0;
reg txPinRegister = 1;
reg [2:0] txBitNumber = 0;
reg [3:0] txByteCounter = 0;

assign uart_tx = txPinRegister;

localparam TX_STATE_IDLE = 0;
localparam TX_STATE_START_BIT = 1;
localparam TX_STATE_WRITE = 2;
localparam TX_STATE_STOP_BIT = 3;
localparam TX_STATE_DEBOUNCE = 4;

localparam MEMORY_LENGTH = 15;
reg [7:0] testMemory [MEMORY_LENGTH-1:0];

initial begin
    testMemory[0] = "G";
    testMemory[1] = "o";
    testMemory[2] = "w";
    testMemory[3] = "i";
    testMemory[4] = "n";
    testMemory[5] = " ";
    testMemory[6] = "I";
    testMemory[7] = "D";
    testMemory[8] = "E";
    testMemory[9] = " ";
    testMemory[10] = "D";
    testMemory[11] = "e";
    testMemory[12] = "m";
    testMemory[13] = "o";
    testMemory[14] = " ";
end 
always @(posedge clk) begin
    case (txState)
        TX_STATE_IDLE: begin
            if (btn1 == 0) begin
                txState <= TX_STATE_START_BIT;
                txCounter <= 0;
                txByteCounter <= 0;
            end else begin
                txPinRegister <=1;
            end
        end
        TX_STATE_START_BIT: begin
            txPinRegister <= 0;
            if ((txCounter + 1) == DELAY_FRAMES) begin
                txState <= TX_STATE_WRITE;
                dataOut <= testMemory[txByteCounter];
                txBitNumber <= 0;
                txCounter <= 0;
            end else
                txCounter <= txCounter + 1;
        end
        TX_STATE_WRITE: begin
            txPinRegister <= dataOut[txBitNumber];
            if ((txCounter + 1) == DELAY_FRAMES) begin
                if (txBitNumber == 3'b111) begin
                    txState <= TX_STATE_STOP_BIT;
                end else begin
                    txState <= TX_STATE_WRITE;
                    txBitNumber <= txBitNumber + 1;
                end
                txCounter <= 0;
            end else 
                    txCounter =txCounter + 1;
        end
        TX_STATE_STOP_BIT: begin
            txPinRegister <= 1;
            if ((txCounter +1) == DELAY_FRAMES) begin
                if (txByteCounter == MEMORY_LENGTH-1) begin
                    txState <= TX_STATE_DEBOUNCE;
                end else begin
                    txByteCounter <= txByteCounter + 1;
                    txState <= TX_STATE_START_BIT;
                end
                txCounter <=0;
            end else
                txCounter <= txCounter + 1;
        end
        TX_STATE_DEBOUNCE: begin
            if (txCounter == 23'b111111111111111111) begin
                if (btn1 == 1)
                    txState <= TX_STATE_IDLE;
            end else
                    txCounter <= txCounter + 1;
        end
    endcase
    
end   
endmodule