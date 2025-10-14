module input_rom (clock, address, q);
   input clock;
   input [7:0] address; // 8bit address
   output [7:0] q;  // 8bit

   reg [7:0]    m[0:16383];

   initial begin
      $readmemh("data/red-blood-cells_128x128.hex", m);
   end

   assign q=m[address];
endmodule