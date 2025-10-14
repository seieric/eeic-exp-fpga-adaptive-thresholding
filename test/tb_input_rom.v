`timescale 1ns / 1ps

module tb_input_rom;
    reg clk;
    reg [13:0] addr;
    wire [7:0] data;

    input_rom input_rom0 (
        .clock(clk),
        .address(addr),
        .q(data)
    );

    initial clk = 0;
    always #5 clk = ~clk; // 10ns周期

    initial begin
        $monitor("addr=%d, data=%h", addr, data);
        addr = 0;
        repeat(50) begin
            #10;  // クロック1サイクル待機
            addr = addr + 1;
        end
        
        #10;
        $finish;
    end

endmodule