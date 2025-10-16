// only for testbench
// テストベンチのための計算済みしきい値ROMリーダ
module threshold_rom_reader(clock, iCol, iRow, oData);
    parameter WIDTH_BITS = 7; // width=128
    parameter HEIGHT_BITS = 7; // height=128
    parameter ADDR_WIDTH = 14; // log2(WIDTH * HEIGHT)

    input wire clock;
    input wire [WIDTH_BITS-1:0] iCol; // 画像のX座標
    input wire [HEIGHT_BITS-1:0] iRow; // 画像のY座標
    output reg [7:0] oData; // ピクセル値

    wire [ADDR_WIDTH-1:0] address;
    wire [7:0] mem_data;

    // 座標からメモリアドレスを計算
    assign address = (iRow << WIDTH_BITS) + iCol;

    // メモリからデータを読み込む
    threshold_rom rom (
        .clock(clock),
        .address(address),
        .q(mem_data)
    );

    always @(posedge clock) begin
        oData <= mem_data;
    end
endmodule