// 7segに6桁の16進数を表示するモジュール
module display_7seg (
    input  [23:0] value,
    output [ 6:0] HEX0,
    output [ 6:0] HEX1,
    output [ 6:0] HEX2,
    output [ 6:0] HEX3,
    output [ 6:0] HEX4,
    output [ 6:0] HEX5
);
  // 7セグのパターン
  function [6:0] segment_map;
    input [3:0] digit;
    begin
      case (digit)
        4'h0: segment_map = 7'b1000000;  // 0
        4'h1: segment_map = 7'b1111001;  // 1
        4'h2: segment_map = 7'b0100100;  // 2
        4'h3: segment_map = 7'b0110000;  // 3
        4'h4: segment_map = 7'b0011001;  // 4
        4'h5: segment_map = 7'b0010010;  // 5
        4'h6: segment_map = 7'b0000010;  // 6
        4'h7: segment_map = 7'b1111000;  // 7
        4'h8: segment_map = 7'b0000000;  // 8
        4'h9: segment_map = 7'b0010000;  // 9
        4'hA: segment_map = 7'b0001000;  // A
        4'hB: segment_map = 7'b0000011;  // B
        4'hC: segment_map = 7'b1000110;  // C
        4'hD: segment_map = 7'b0100001;  // D
        4'hE: segment_map = 7'b0000110;  // E
        4'hF: segment_map = 7'b0001110;  // F
        default: segment_map = 7'b1111111;
      endcase
    end
  endfunction

  // 各桁に対応するセグメントパターンを割り当てる
  assign HEX0 = segment_map(value[3:0]);
  assign HEX1 = segment_map(value[7:4]);
  assign HEX2 = segment_map(value[11:8]);
  assign HEX3 = segment_map(value[15:12]);
  assign HEX4 = segment_map(value[19:16]);
  assign HEX5 = segment_map(value[23:20]);
endmodule
