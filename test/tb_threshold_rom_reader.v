`timescale 1ns / 1ps

module tb_threshold_rom_reader;
    reg clock;
    wire [7:0] iCol;
    wire [7:0] iRow;
    reg [8:0] col;
    reg [8:0] row;
    wire [7:0] oData;

    threshold_rom_reader threshold_rom_reader0 (
        .clock(clock),
        .iCol(iCol),
        .iRow(iRow),
        .oData(oData)
    );

    initial clock = 0;
    always #5 clock = ~clock; // 10ns周期

    assign iCol = col[7:0];
    assign iRow = row[7:0];

    initial begin
        col = 0;
        row = 0;

        for (row = 0; row < 256; row = row + 1) begin
            for (col = 0; col < 256; col = col + 1) begin
                $display("iCol=%d, iRow=%d, oData=%h", col, row, oData);
                #10; // クロック1サイクル待機
            end
        end
        
        #10;
        $finish;
    end

endmodule