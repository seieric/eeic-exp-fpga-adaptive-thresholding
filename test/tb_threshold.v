`timescale 1ns / 1ps

module tb_threshold;
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

  // しきい値メモリとの接続
  wire [WIDTH_BITS-1:0] thresholdCol;
  wire [HEIGHT_BITS-1:0] thresholdRow;
  wire [7:0] thresholdData;
  wire thresholdWren;

  // 結果メモリとの接続
  wire [WIDTH_BITS-1:0] resultCol;
  wire [HEIGHT_BITS-1:0] resultRow;
  wire [7:0] resultData;
  wire resultWren;

  // box_filterが終了したかどうか
  wire finished;

  input_rom_reader input_rom_reader0 (
    .clock(clock),
    .iCol(imageCol),
    .iRow(imageRow),
    .oData(imageData)
  );

  threshold_rom_reader threshold_rom_reader0 (
    .clock(clock),
    .iCol(thresholdCol),
    .iRow(thresholdRow),
    .oData(thresholdData)
  );

  threshold threshold0 (
    .clock(clock),
    .reset(reset),
    .oImageCol(imageCol),
    .oImageRow(imageRow),
    .iImageData(imageData),
    .oThresholdCol(thresholdCol),
    .oThresholdRow(thresholdRow),
    .iThresholdData(thresholdData),
    .oResultCol(resultCol),
    .oResultRow(resultRow),
    .oResultData(resultData),
    .oResultWren(resultWren),
    .finished(finished)
  );


  initial clock = 0;
  always #5 clock = ~clock; // 10ns周期

  initial begin
    reset = 1;
    #20;
    reset = 0;

    // $display("Starting thresholding...");
    
    // finishedシグナルを待つ
    wait(finished == 1);
    #20;
    // $display("Thresholding finished!");
    $finish;
  end

  // finishedシグナルの立ち上がりを監視
  // always @(posedge finished) begin
  //   $display("*** Thresholding processing completed at time %t ***", $time);
  // end

  // 書き込み動作の監視
  always @(posedge clock) begin
    if (resultWren) begin
      // $display("Writing to [%3d,%3d]: %3d at time %t", resultCol, resultRow, resultData, $time);
      $display("%d", resultData);
    end
  end

endmodule