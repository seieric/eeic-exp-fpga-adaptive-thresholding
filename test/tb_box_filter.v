`timescale 1ns / 1ps

module tb_box_filter;
  parameter WIDTH_BITS = 8;
  parameter HEIGHT_BITS = 8;
  parameter WIDTH = 2**WIDTH_BITS;
  parameter HEIGHT = 2**HEIGHT_BITS;

  reg clock;
  reg reset;

  // 画像メモリとの接続
  wire [WIDTH_BITS-1:0] imageCol;
  wire [HEIGHT_BITS-1:0] imageRow;
  wire [7:0] imageData;

  // 結果（中間）メモリとの接続
  wire [WIDTH_BITS-1:0] resultCol;
  wire [HEIGHT_BITS-1:0] resultRow;
  wire [7:0] resultData;
  wire resultWren;

  // 結果（中間）メモリからの読み出し確認用
  wire [WIDTH_BITS-1:0] iCol;
  wire [HEIGHT_BITS-1:0] iRow;
  wire [7:0] oData;

  // box_filterが終了したかどうか
  wire finished;

  box_filter box_filter0 (
    .clock(clock),
    .not_reset(~reset),
    .oImageCol(imageCol),
    .oImageRow(imageRow),
    .iImageData(imageData),
    .oResultCol(resultCol),
    .oResultRow(resultRow),
    .oResultData(resultData),
    .oResultWren(resultWren),
    .finished(finished)
  );

  input_rom_reader input_rom_reader0 (
    .clock(clock),
    .iCol(imageCol),
    .iRow(imageRow),
    .oData(imageData)
  );

  middle_ram_controller middle_ram_controller0 (
    .clock(clock),
    .iWrcol(resultCol),
    .iWrrow(resultRow),
    .iWrdata(resultData),
    .iWren(resultWren),
    .iRdcol(iCol),
    .iRdrow(iRow),
    .oRddata(oData)
  );

  initial clock = 0;
  always #5 clock = ~clock; // 10ns周期

  // テストに必要な変数
  reg verification_started;
  reg [WIDTH_BITS-1:0] rdCol;
  reg [HEIGHT_BITS-1:0] rdRow;
  wire [7:0] rdData;
  integer i, j;

  assign iCol = rdCol;
  assign iRow = rdRow;
  assign rdData = oData;

  initial begin
    reset = 1;
    verification_started = 0;
    rdCol = 0;
    rdRow = 0;
    #20;
    reset = 0;

    $display("Starting box filter processing...");
    
    // finishedシグナルを待つ
    wait(finished == 1);
    #20;
    $display("Box filter finished! Starting memory verification...");
    
    // 少し待ってからメモリ読み出し開始
    #20;
    verification_started = 1;
    
    // 全ピクセルの結果を読み出して表示
    for (i = 0; i < HEIGHT; i = i + 1) begin
      for (j = 0; j < WIDTH; j = j + 1) begin
        rdRow = i;
        rdCol = j;
        #10; // 1クロック待機してデータを安定させる
        $display("middle_ram[%3d,%3d] = %3d (0x%02h)", j, i, rdData, rdData);
      end
    end
    
    $display("Memory verification completed!");
    #100;
    $finish;
  end

  // finishedシグナルの立ち上がりを監視
  always @(posedge finished) begin
    $display("*** Box filter processing completed at time %t ***", $time);
  end

  // 書き込み動作の監視
  always @(posedge clock) begin
    if (resultWren) begin
      $display("Writing to [%3d,%3d]: %3d at time %t", resultCol, resultRow, resultData, $time);
    end
  end

endmodule