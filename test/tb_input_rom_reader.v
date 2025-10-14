`timescale 1ns / 1ps

module tb_input_rom_reader;
    reg clock;
    reg [7:0] iCol;
    reg [7:0] iRow;
    wire [7:0] oData;

    input_rom_reader input_rom_reader0 (
        .clock(clock),
        .iCol(iCol),
        .iRow(iRow),
        .oData(oData)
    );

    initial clock = 0;
    always #5 clock = ~clock; // 10ns周期

    initial begin
        iCol = 0;
        iRow = 0;

        for (iRow = 0; iRow < 128; iRow = iRow + 1) begin
            for (iCol = 0; iCol < 128; iCol = iCol + 1) begin
                $display("iCol=%d, iRow=%d, oData=%h", iCol, iRow, oData);
                #10; // クロック1サイクル待機
            end
        end
        
        #10;
        $finish;
    end

endmodule