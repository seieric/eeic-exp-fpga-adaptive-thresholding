// only for testbench
// テストベンチのための計算済みしきい値ROM
module threshold_rom (clock, address, q);
   input clock;
   input [13:0] address; // 14bit address
   output [7:0] q;  // 8bit

   reg [7:0] m[0:16383];

   initial begin
      $readmemh("data/red-blood-cells_128x128_thresholds-iverilog.hex", m);
   end

   assign q=m[address];
endmodule