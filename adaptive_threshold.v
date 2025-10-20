module adaptive_threshold (
  input wire clock,
  input wire not_reset,
  output wire [7:0] oX,
  output wire [7:0] oY,
  output wire [2:0] oR,
  output wire [2:0] oG,
  output wire [2:0] oB
);
  parameter WIDTH_BITS = 8;
  parameter HEIGHT_BITS = 8;
  parameter WIDTH = 2**WIDTH_BITS;
  parameter HEIGHT = 2**HEIGHT_BITS;

  // box_filterと画像メモリの接続
  wire [WIDTH_BITS-1:0] imageCol;
  wire [HEIGHT_BITS-1:0] imageRow;
  wire [7:0] imageData;

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

  // 処理開始フラグ
  reg box_filter_start;
  reg threshold_start;

  // 処理結果
  wire resultData;
  assign oR = {3{resultData}};
  assign oG = {3{resultData}};
  assign oB = {3{resultData}};

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
    .reset(box_filter_start),
    .oImageCol(imageCol),
    .oImageRow(imageRow),
    .iImageData(imageData),
    .oResultCol(thresholdWrCol),
    .oResultRow(thresholdWrRow),
    .oResultData(thresholdWrData),
    .oResultWren(thresholdWren),
    .finished(box_filter_finished)
  );

  threshold threshold0 (
    .clock(clock),
    .reset(threshold_start),
    .oImageCol(imageCol),
    .oImageRow(imageRow),
    .iImageData(imageData),
    .oThresholdCol(thresholdRdCol),
    .oThresholdRow(thresholdRdRow),
    .iThresholdData(thresholdRdData),
    .oResultCol(oX),
    .oResultRow(oY),
    .oResultData(resultData),
    .oResultWren(), // unused
    .finished(threshold_finished)
  );

  always @(posedge clock) begin
    if (!not_reset) begin
      box_filter_start <= 1;
      threshold_start <= 0;
    end else begin
      // box_filterが完了したらthresholdを開始
      if (box_filter_finished && !threshold_start) begin
        threshold_start <= 1;
      end else begin
        threshold_start <= 0;
      end
      box_filter_start <= 0;
    end
  end
endmodule