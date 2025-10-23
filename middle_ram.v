// Box Filterの結果を保持するためのRAM
module middle_ram (
    clock,
    data,
    wraddress,
    wren,
    rdaddress,
    q
);
  input clock, wren;
  input [15:0] wraddress, rdaddress;
  input [7:0] data;
  output [7:0] q;

  reg [7:0] m[0:65535];

  assign q = m[rdaddress];
  always @(posedge clock) begin
    if (wren == 1) begin
      m[wraddress] <= data;
    end
  end
endmodule
