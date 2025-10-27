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
  parameter WIDTH = 2 ** WIDTH_BITS;
  parameter HEIGHT = 2 ** HEIGHT_BITS;
  parameter NUM_PARALLEL_BITS = 2;
  parameter NUM_PARALLEL = 2 ** NUM_PARALLEL_BITS;

  // 画像メモリアクセス用の信号
  wire [WIDTH_BITS-1:0] imageCol[NUM_PARALLEL];
  wire [HEIGHT_BITS-1:0] imageRow[NUM_PARALLEL];
  wire [7:0] imageData[NUM_PARALLEL];

  // 状態管理
  reg [NUM_PARALLEL-1:0] processing_enable;  // 各モジュールを起動しているかどうか
  reg [NUM_PARALLEL_BITS:0] processing_counter; // 起動しているモジュール数をカウント
  wire [NUM_PARALLEL-1:0] finished;
  wire box_filter_finished = &finished;
  // 0: ready
  // 1: box_filter
  // 2: threshold
  // 3: finished
  reg [2:0] state;

  // 処理結果
  wire resultData[NUM_PARALLEL];
  wire [WIDTH_BITS-1:0] resultCol[NUM_PARALLEL];
  wire [HEIGHT_BITS-1:0] resultRow[NUM_PARALLEL];
  wire resultWren[NUM_PARALLEL];

  // 書き込み有効かどうかで出力を切り替える
  wire [NUM_PARALLEL_BITS-1:0] output_index;
  assign output_index = resultWren[0] ? 2'd0 :
                        resultWren[1] ? 2'd1 :
                        resultWren[2] ? 2'd2 :
                        resultWren[3] ? 2'd3 : 2'd0;

  assign oX = resultRow[output_index];
  assign oY = resultCol[output_index];
  assign oR = {3{resultData[output_index]}};
  assign oG = {3{resultData[output_index]}};
  assign oB = {3{resultData[output_index]}};

  // LEDR表示用
  reg [9:0] ledr;
  assign LEDR = ledr;

  // しきい値から引く定数
  reg [4:0] C;

  genvar i;
  generate
    for (i = 0; i < NUM_PARALLEL; i = i + 1) begin : gen_parallel_modules
      // 画像メモリ
      input_rom_reader input_rom_reader_inst (
          .clock(clock),
          .iCol (imageCol[i]),
          .iRow (imageRow[i]),
          .oData(imageData[i])
      );

      // box_filter
      box_filter #(
          .START_POS(i * (WIDTH * HEIGHT / NUM_PARALLEL)),
          .END_POS  ((i + 1) * (WIDTH * HEIGHT / NUM_PARALLEL) - 1)
      ) box_filter_inst (
          .clock(clock),
          .not_reset(not_reset),
          .oImageCol(imageCol[i]),
          .oImageRow(imageRow[i]),
          .iImageData(imageData[i]),
          .oResultCol(resultCol[i]),
          .oResultRow(resultRow[i]),
          .oResultData(resultData[i]),
          .oResultWren(resultWren[i]),
          .processing(processing_enable[i]),
          .finished(finished[i]),
          .C(C)
      );
    end
  endgenerate

  // controller
  always @(posedge clock or negedge not_reset) begin
    if (!not_reset) begin
      C <= SW[9:5];  // SWの上位5ビットをCに設定
      // ready状態に戻る
      ledr <= {SW[9:5], 5'b00001};
      processing_enable <= 0;
      processing_counter <= 0;
      state <= 0;
    end else begin
      case (state)
        0: begin  // ready
          // 状態遷移
          ledr  <= {C, 5'b00010};
          state <= 1;
        end
        1: begin  // box_filter
          // 状態遷移
          if (processing_counter != NUM_PARALLEL) begin
            processing_enable[processing_counter] <= 1;
            processing_counter <= processing_counter + 1;
          end
          if (box_filter_finished) begin
            ledr  <= {C, 5'b00100};
            state <= 2;
          end
        end
        2: begin  // unused
          // 状態遷移
          ledr  <= {C, 5'b01000};
          state <= 3;
        end
      endcase
    end
  end
endmodule
