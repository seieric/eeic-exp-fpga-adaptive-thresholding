module adaptive_threshold (
  input wire clock,
  input wire not_reset,
  output wire [7:0] oX,
  output wire [7:0] oY,
  output wire [2:0] oR,
  output wire [2:0] oG,
  output wire [2:0] oB,
  output wire [9:0] LEDR,
  input wire [9:0] SW
);
  parameter WIDTH_BITS = 8;
  parameter HEIGHT_BITS = 8;
  parameter WIDTH = 2**WIDTH_BITS;
  parameter HEIGHT = 2**HEIGHT_BITS;

  // 画像メモリアクセス用の信号
  wire [WIDTH_BITS-1:0] imageCol;
  wire [HEIGHT_BITS-1:0] imageRow;
  wire [7:0] imageData;

  // box_filterから画像メモリへの信号
  wire [WIDTH_BITS-1:0] boxFilterImageCol;
  wire [HEIGHT_BITS-1:0] boxFilterImageRow;

  // thresholdから画像メモリへの信号
  wire [WIDTH_BITS-1:0] thresholdImageCol;
  wire [HEIGHT_BITS-1:0] thresholdImageRow;

  // box_filterとしきい値メモリの接続（書き込み）
  wire [WIDTH_BITS-1:0] thresholdWrCol;
  wire [HEIGHT_BITS-1:0] thresholdWrRow;
  wire [7:0] thresholdWrData;
  wire thresholdWren;

  // thresholdとしきい値メモリの接続（読み込み）
  wire [WIDTH_BITS-1:0] thresholdRdCol;
  wire [HEIGHT_BITS-1:0] thresholdRdRow;
  wire [7:0] thresholdRdData;

  // 状態管理
  wire box_filter_finished;
  wire threshold_finished;
  // 0: ready
  // 1: box_filter
  // 2: threshold
  // 3: finished
  reg [2:0] state;

  // 処理結果
  wire resultData;
  assign oR = {3{resultData}};
  assign oG = {3{resultData}};
  assign oB = {3{resultData}};

  // LEDR表示用
  reg [9:0] ledr;
  assign LEDR = ledr;

  // しきい値から引く定数
  reg [4:0] C;

  // 画像メモリアクセスのマルチプレクサ
  // box_filter実行中はbox_filterの信号を使用、threshold実行中はthresholdの信号を使用
  assign imageCol = (state == 2) ? thresholdImageCol : boxFilterImageCol;
  assign imageRow = (state == 2) ? thresholdImageRow : boxFilterImageRow;

  // 画像メモリ
  input_rom_reader input_rom_reader0 (
    .clock(clock),
    .iCol(imageCol),
    .iRow(imageRow),
    .oData(imageData)
  );

  // しきい値メモリ
  middle_ram_controller middle_ram_controller0 (
    .clock(clock),
    .iWrcol(thresholdWrCol),
    .iWrrow(thresholdWrRow),
    .iWrdata(thresholdWrData),
    .iWren(thresholdWren),
    .iRdcol(thresholdRdCol),
    .iRdrow(thresholdRdRow),
    .oRddata(thresholdRdData)
  );

  // box_filter
  box_filter box_filter0 (
    .clock(clock),
    .not_reset(not_reset),
    .oImageCol(boxFilterImageCol),
    .oImageRow(boxFilterImageRow),
    .iImageData(imageData),
    .oResultCol(thresholdWrCol),
    .oResultRow(thresholdWrRow),
    .oResultData(thresholdWrData),
    .oResultWren(thresholdWren),
    .global_state(state),
    .finished(box_filter_finished)
  );

  // threshold
  threshold threshold0 (
    .clock(clock),
    .not_reset(not_reset),
    .oImageCol(thresholdImageCol),
    .oImageRow(thresholdImageRow),
    .iImageData(imageData),
    .oThresholdCol(thresholdRdCol),
    .oThresholdRow(thresholdRdRow),
    .iThresholdData(thresholdRdData),
    .oResultCol(oY),
    .oResultRow(oX),
    .oResultData(resultData),
    .oResultWren(), // unused
    .global_state(state),
    .finished(threshold_finished),
    .C(C)
  );

  // controller
  always @(posedge clock or negedge not_reset) begin
    if (!not_reset) begin
      C <= SW[9:5]; // SWの上位5ビットをCに設定
      // ready状態に戻る
      ledr <= {C, 5'b00001};
      state <= 0;
    end else begin
      case (state)
        0: begin // ready
          // 状態遷移
          ledr <= {C, 5'b00010};
          state <= 1;
        end
        1: begin // box_filter
          // 状態遷移
          if (box_filter_finished) begin
            ledr <= {C, 5'b00100};
            state <= 2;
          end
        end
        2: begin // threshold
          // 状態遷移
          if (threshold_finished) begin
            ledr <= {C, 5'b01000};
            state <= 3;
          end
        end
      endcase
    end
  end
endmodule