`timescale 1ns / 1ps

module tb_middle_ram;
    reg clk, wren;
    reg [15:0] addr;
    reg [7:0] wData;
    wire [7:0] rData;

    middle_ram middle_ram0 (
        .clock(clk),
        .rdaddress(addr),
        .wraddress(addr),
        .wren(wren),
        .data(wData),
        .q(rData)
    );

    initial clk = 0;
    always #5 clk = ~clk; // 10ns周期

    initial begin
        wren = 1;
        $display("Writing to RAM");
        addr = 0;
        repeat(50) begin
            wData = addr; // 書き込むデータはアドレスと同じ値
            $display("addr=%d, wData=%h", addr, wData);
            #10;  // クロック1サイクル待機
            addr = addr + 1;
        end
        #10;

        wren = 0;
        $display("Reading from RAM");
        addr = 0;
        repeat(50) begin
            $display("addr=%d, rData=%h", addr, rData);
            #10;  // クロック1サイクル待機
            addr = addr + 1;
        end
        
        #10;
        $finish;
    end

endmodule