// メモリからデータを読み込むモジュール
module input_rom_reader (
    clock,
    iCol,
    iRow,
    oData
);
  parameter WIDTH_BITS = 8;  // width=256
  parameter HEIGHT_BITS = 8;  // height=256
  parameter ADDR_WIDTH = 16;  // log2(WIDTH * HEIGHT)

  input wire clock;
  input wire [WIDTH_BITS-1:0] iCol;  // 画像のX座標
  input wire [HEIGHT_BITS-1:0] iRow;  // 画像のY座標
  output reg [7:0] oData;  // ピクセル値

  wire [ADDR_WIDTH-1:0] address;
  wire [7:0] mem_data;

  // 座標からメモリアドレスを計算
  assign address = (iRow << WIDTH_BITS) + iCol;

  // メモリからデータを読み込む
  input_rom64k rom (
      .clock(clock),
      .address(address),
      .q(mem_data)
  );

  always @(posedge clock) begin
    oData <= mem_data;
  end
endmodule
