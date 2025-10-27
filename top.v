// topモジュール
// 各処理とメモリはこのモジュール内で接続する
module top (
    //////////// CLOCK //////////
    input CLK,

    //////////// KEY //////////
    input [3:0] KEY,

    //////////// SW //////////
    input [9:0] SW,

    //////////// LED //////////
    output [9:0] LEDR,

    //////////// Seg7 //////////
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5,

    //////////// VGA //////////
    output       VGA_BLANK_N,
    output [7:0] VGA_B,
    output       VGA_CLK,
    output [7:0] VGA_G,
    output       VGA_HS,
    output [7:0] VGA_R,
    output       VGA_SYNC_N,
    output       VGA_VS
);
  wire [10:0] VGA_X;
  wire [10:0] VGA_Y;

  wire CLK40;

  assign NRST = KEY[0];
  assign VGA_CLK = CLK40;

  wire [7:0] posx, posy;
  wire [2:0] posr, posg, posb;

  wire [23:0] cycle_count;

  pll pll (
      .refclk(CLK),
      .rst(~NRST),
      .outclk_0(CLK40)
  );

  adaptive_threshold u8 (
      .clock(CLK40),
      .not_reset(NRST),
      .oX(posx),
      .oY(posy),
      .oR(posr),
      .oG(posg),
      .oB(posb),
      .LEDR(LEDR),
      .SW(SW),
      .cycle_count(cycle_count)
  );

  display_7seg display_7seg_inst (
      .value(cycle_count),
      .HEX0 (HEX0),
      .HEX1 (HEX1),
      .HEX2 (HEX2),
      .HEX3 (HEX3),
      .HEX4 (HEX4),
      .HEX5 (HEX5)
  );

  VGA_Ctrl u9 (
      //  Host Side
      .oCurrent_X(VGA_X),
      .oCurrent_Y(VGA_Y),
      .oRequest(VGA_Read),
      //  VGA Side
      .oVGA_HS(VGA_HS),
      .oVGA_VS(VGA_VS),
      .oVGA_SYNC(VGA_SYNC_N),
      .oVGA_BLANK(VGA_BLANK_N),
      .oVGA_R(VGA_R),
      .oVGA_G(VGA_G),
      .oVGA_B(VGA_B),

      //  Control Signal
      .iCLK  (CLK40),
      .iRST_N(NRST),

      .write_x(posx),
      .write_y(posy),
      .write_r(posr),
      .write_g(posg),
      .write_b(posb)
  );
endmodule
