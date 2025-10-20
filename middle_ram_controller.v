// 中間メモリに読み書きを行うモジュール
module middle_ram_controller(clock, iRdcol, iRdrow, oRddata, iWren, iWrcol, iWrrow, iWrdata);
    parameter WIDTH_BITS = 8; // width=256
    parameter HEIGHT_BITS = 8; // height=256
    parameter ADDR_WIDTH = WIDTH_BITS + HEIGHT_BITS;

    input wire clock;
    // reader input/output
    input wire [WIDTH_BITS-1:0] iRdcol; // 読み込み用X座標
    input wire [HEIGHT_BITS-1:0] iRdrow; // 読み込み用Y座標
    output wire [7:0] oRddata; // 読み込んだピクセル値
    // writer input
    input wire iWren; // 書き込み有効信号
    input wire [WIDTH_BITS-1:0] iWrcol; // 書き込み用X座標
    input wire [HEIGHT_BITS-1:0] iWrrow; // 書き込み用Y座標
    input wire [7:0] iWrdata; // 書き込むピクセル値

    wire [ADDR_WIDTH-1:0] rdaddress;
    wire [ADDR_WIDTH-1:0] wraddress;

    // 座標からメモリアドレスを計算
    assign rdaddress = (iRdrow << WIDTH_BITS) + iRdcol;
    assign wraddress = (iWrrow << WIDTH_BITS) + iWrcol;

    // メモリからデータを読み込む
    middle_ram middle_ram0 (
      .clock(clock),
      .data(iWrdata),
      .wraddress(wraddress),
      .wren(iWren),
      .rdaddress(rdaddress),
      .q(oRddata)
    );
endmodule
