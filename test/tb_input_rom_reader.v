`timescale 1ns / 1ps

module tb_input_rom_reader;
    reg clock;
    wire [6:0] iCol;
    wire [6:0] iRow;
    reg [7:0] col;
    reg [7:0] row;
    wire [7:0] oData;

    input_rom_reader input_rom_reader0 (
        .clock(clock),
        .iCol(iCol),
        .iRow(iRow),
        .oData(oData)
    );

    initial clock = 0;
    always #5 clock = ~clock; // 10ns周期

    assign iCol = col[6:0];
    assign iRow = row[6:0];

    initial begin
        col = 0;
        row = 0;

        for (row = 0; row < 128; row = row + 1) begin
            for (col = 0; col < 128; col = col + 1) begin
                $display("iCol=%d, iRow=%d, oData=%h", col, row, oData);
                #10; // クロック1サイクル待機
            end
        end
        
        #10;
        $finish;
    end

endmodule