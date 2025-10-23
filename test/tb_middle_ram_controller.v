`timescale 1ns / 1ps

module tb_middle_ram_writer_reader;
  reg clock;
  reg [7:0] iCol_w, iRow_w;
  reg [7:0] iData_w;
  reg iWren;
  reg [7:0] iCol_r, iRow_r;
  wire [7:0] oData_r;

  reg [7:0] expected_data;
  integer error_count = 0;

  // controller
  middle_ram_controller middle_ram_controller0 (
      .clock  (clock),
      // writer
      .iWren  (iWren),
      .iWrcol (iCol_w),
      .iWrrow (iRow_w),
      .iWrdata(iData_w),
      // reader
      .iRdcol (iCol_r),
      .iRdrow (iRow_r),
      .oRddata(oData_r)
  );

  initial clock = 0;
  always #5 clock = ~clock;  // 10ns周期

  initial begin
    // 初期化
    iCol_w  = 0;
    iRow_w  = 0;
    iData_w = 0;
    iWren   = 0;
    iCol_r  = 0;
    iRow_r  = 0;

    #20;  // 初期待機

    $display("=== Starting Write Operation ===");
    // メモリへの書き込みテスト
    iWren = 1;  // 書き込み有効

    for (integer row = 0; row < 256; row = row + 1) begin
      for (integer col = 0; col < 256; col = col + 1) begin
        iCol_w = col;
        iRow_w = row;
        iData_w = (row + col) & 8'hFF; // テストデータ（座標の和をデータとして使用）

        if (row < 5 && col < 5)  // 最初の5x5のみ表示
          $display("Writing: iCol=%d, iRow=%d, iData=%h", iCol_w, iRow_w, iData_w);
        #10;
      end
    end

    iWren = 0;
    $display("Write operation completed");

    #20;  // 書き込み完了後の待機

    $display("=== Starting Read Operation ===");
    // メモリからの読み込みテスト
    for (integer row = 0; row < 128; row = row + 1) begin
      for (integer col = 0; col < 128; col = col + 1) begin
        iCol_r = col;
        iRow_r = row;
        #10;  // クロック1サイクル待機（読み込み結果が出るまで）

        // 期待値と実際の値を比較
        expected_data = (row + col) & 8'hFF;
        if (oData_r !== expected_data) begin
          $display("ERROR: iCol=%d, iRow=%d, Expected=%h, Got=%h", col, row, expected_data,
                   oData_r);
          error_count = error_count + 1;
        end else if (row < 5 && col < 5) begin  // 最初の5x5のみ表示
          $display("OK: iCol=%d, iRow=%d, Expected=%h, Got=%h", col, row, expected_data, oData_r);
        end
      end
    end

    $display("=== Test Completed ===");
    if (error_count == 0) begin
      $display("All tests PASSED!");
    end else begin
      $display("FAILED: %d errors found", error_count);
    end

    #10;
    $finish;
  end

endmodule
