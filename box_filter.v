// 画像にBox Filterを適用して平均値を計算するモジュール
// カーネルは3x3に固定
module box_filter #(
    parameter WIDTH_BITS = 8,
    parameter HEIGHT_BITS = 8,
    parameter WIDTH = 2 ** WIDTH_BITS,
    parameter HEIGHT = 2 ** HEIGHT_BITS
) (
    input wire clock,
    input wire not_reset,
    output wire [WIDTH_BITS-1:0] oImageCol,  // 画像メモリのピクセルのX座標
    output wire [HEIGHT_BITS-1:0] oImageRow,  // 画像メモリのピクセルのY座標
    input wire [7:0] iImageData,
    output wire [WIDTH_BITS-1:0] oResultCol,  // 結果メモリのピクセルのX座標
    output wire [HEIGHT_BITS-1:0] oResultRow,  // 結果メモリのピクセルのY座標
    output reg [7:0] oResultData,
    output reg oResultWren,  // 結果メモリの書き込み有効信号
    input wire [2:0] global_state,  // 処理状態（1: box_filter実行中）
    output reg finished
);
  // 現在の位置
  reg  [WIDTH_BITS+HEIGHT_BITS-1:0] pos;
  // 1クロック前の位置（メモリ書き込み用）
  wire [WIDTH_BITS+HEIGHT_BITS-1:0] write_pos = pos - 1'b1;
  // カーネル内の位置 (krow, kcol)
  // |0,0|0,1|0,2|
  // |1,0|1,1|1,2|
  // |2,0|2,1|2,2|
  // (krow, kcol)=(2,2)で平均値計算と書き込みを行う
  reg [1:0] kcol, krow;

  initial begin
    pos  = 0;
    kcol = 0;
    krow = 0;
  end

  // 読み込むピクセルの座標を計算
  wire signed [8:0] raw_iCol = pos[WIDTH_BITS-1:0] + kcol - 1'b1;
  wire signed [8:0] raw_iRow = pos[WIDTH_BITS+HEIGHT_BITS-1:WIDTH_BITS] + krow - 1'b1;
  // 実際に読み込む座標はクランプして画像範囲内に収める
  assign oImageCol = (raw_iCol < 0) ? {WIDTH_BITS{1'b0}} :
                (raw_iCol >= WIDTH) ? WIDTH - 1 :
                raw_iCol[WIDTH_BITS-1:0];
  assign oImageRow = (raw_iRow < 0) ? {HEIGHT_BITS{1'b0}} :
                (raw_iRow >= HEIGHT) ? HEIGHT - 1 :
                raw_iRow[HEIGHT_BITS-1:0];

  // 結果メモリの座標をposから計算
  assign oResultCol = write_pos[WIDTH_BITS-1:0];
  assign oResultRow = write_pos[WIDTH_BITS+HEIGHT_BITS-1:WIDTH_BITS];

  reg [11:0] sum;  // 最大でも255*9=2295なので12ビットで十分

  always @(posedge clock or negedge not_reset) begin
    if (!not_reset) begin
      pos <= 0;
      kcol <= 0;
      krow <= 0;
      sum <= 0;
      oResultWren <= 0;
      finished <= 0;
    end else begin
      if (global_state == 1) begin
        oResultWren <= 0;

        if (!finished) begin
          if (krow != 3) begin
            // カーネル内の現在のピクセルの値をsumに加える
            sum <= sum + iImageData;
            // カーネル内の次のピクセルへ移動
            if (kcol == 2) begin
              kcol <= 0;
              krow <= krow + 1'b1;
            end else begin
              kcol <= kcol + 1'b1;
            end
          end else begin
            // 平均値を近似算出・メモリに書き込む
            oResultData <= (sum * 455) >> 12;
            oResultWren <= 1;

            // 次のピクセルへ移動
            pos <= pos + 1'b1;
            kcol <= 0;
            krow <= 0;
            sum <= 0;
            if (pos == (WIDTH * HEIGHT - 1)) begin
              // 処理完了
              finished <= 1;
            end
          end
        end
      end
    end
  end
endmodule
