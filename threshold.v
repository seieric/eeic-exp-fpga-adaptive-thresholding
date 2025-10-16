// あらかじめ計算されたしきい値で二値化を行うモジュール
module threshold #(
  parameter WIDTH_BITS = 7,
  parameter HEIGHT_BITS = 7,
  parameter WIDTH = 2**WIDTH_BITS,
  parameter HEIGHT = 2**HEIGHT_BITS,
  parameter C = 2 // しきい値から引く定数
)(
  input wire clock,
  input wire reset,
  output wire [WIDTH_BITS-1:0] oImageCol, // 画像メモリのピクセルのX座標
  output wire [HEIGHT_BITS-1:0] oImageRow, // 画像メモリのピクセルのY座標
  input wire [7:0] iImageData,
  output wire [WIDTH_BITS-1:0] oThresholdCol, // しきい値メモリのピクセルのX座標
  output wire [HEIGHT_BITS-1:0] oThresholdRow, // しきい値メモリのピクセルのY座標
  input wire [7:0] iThresholdData,
  output wire [WIDTH_BITS-1:0] oResultCol, // 結果メモリのピクセルのX座標
  output wire [HEIGHT_BITS-1:0] oResultRow, // 結果メモリのピクセルのY座標
  output reg [7:0] oResultData,
  output reg oResultWren, // 結果メモリの書き込み有効信号
  output reg finished
);
  // 現在の位置
  reg [WIDTH_BITS+HEIGHT_BITS-1:0] pos;
  wire [WIDTH_BITS+HEIGHT_BITS-1:0] write_address = pos - 1;

  assign oImageCol = pos[WIDTH_BITS-1:0];
  assign oImageRow = pos[WIDTH_BITS+HEIGHT_BITS-1:WIDTH_BITS];
  assign oThresholdCol = pos[WIDTH_BITS-1:0];
  assign oThresholdRow = pos[WIDTH_BITS+HEIGHT_BITS-1:WIDTH_BITS];
  assign oResultCol = write_address[WIDTH_BITS-1:0];
  assign oResultRow = write_address[WIDTH_BITS+HEIGHT_BITS-1:WIDTH_BITS];

  always @(posedge clock or posedge reset) begin
    if (reset) begin
      pos <= 0;
      oResultWren <= 0;
      finished <= 0;
    end else begin
      if (!finished) begin
        if (iImageData > (iThresholdData - C)) begin
          oResultData <= 255; // 白
        end else begin
          oResultData <= 0; // 黒
        end

        oResultWren <= 1;
        pos <= pos + 1;
        if (pos == (WIDTH * HEIGHT - 1 )) begin
          oResultWren <= 0;
          finished <= 1;
        end
      end
    end
  end
endmodule