/*
 * @Design: wb_interconnect
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Description: Wishbone interconnection between core and peripheral
 */
`timescale 1ns/10ps

module wb_interconnect (
  input         i_clk,
  input         i_rst_n,
  // wishbone interface
  input         i_wbm_stb,
	input         i_wbm_cyc,
	input         i_wbm_we ,
	input  [3:0 ] i_wbm_sel,
	input  [31:0] i_wbm_adr,
	input  [31:0] i_wbm_dat,
	output        o_wbs_ack,
	output [31:0] o_wbs_dat,
  // IOBUF
  inout  [7:0 ] wb2byteio_o_iobuf
);
  // * address decode
  wire adr_sram = ~|i_wbm_adr[31:16];              // 0000_0000-0000_ffff
  wire adr_io   = i_wbm_adr[31:12] == 20'h0002_0 | // 0002_0000-0002_1fff
                  i_wbm_adr[31:12] == 20'h0002_1 ;
  wire adr_wb2byteout = i_wbm_adr       == 32'h0002_0300; // 0002_0300
  wire adr_wb2byteio  = i_wbm_adr[31:4] == 32'h0002_038;  // 0002_0380-0002_038f

  // * sram
  wire [13:0] sram_i_adr = i_wbm_adr[15:2]; // ? adr[1:0]-sel or only access aligned address
  wire        sram_i_stb = adr_sram & i_wbm_stb;
  wire [3:0]  sram_i_sel = i_wbm_sel;
  wire        sram_i_we  = i_wbm_we;
  wire [31:0] sram_i_dat = i_wbm_dat;
  wire        sram_o_ack;
  wire [31:0] sram_o_dat;

  wb2sram32 u_wb2sram32 (
    .i_clk   ( i_clk      ),
    .i_rst_n ( i_rst_n    ),
    .i_adr   ( sram_i_adr ),
    .i_stb   ( sram_i_stb ),
    .i_sel   ( sram_i_sel ),
    .i_we    ( sram_i_we  ),
    .i_dat   ( sram_i_dat ),
    .o_ack   ( sram_o_ack ),
    .o_dat   ( sram_o_dat )
  );

  // * wb2byteout
  wire       wb2byteout_i_stb = adr_wb2byteout & i_wbm_stb;
  wire       wb2byteout_i_we  = i_wbm_we;
  wire [7:0] wb2byteout_i_dat = i_wbm_dat;
  wire       wb2byteout_o_ack;
  wire [7:0] wb2byteout_o_dat;

  wb2byteout u_wb2byteout (
    .i_clk   ( i_clk            ),
    .i_rst_n ( i_rst_n          ),
    .i_stb   ( wb2byteout_i_stb ),
    .i_we    ( wb2byteout_i_we  ),
    .i_dat   ( wb2byteout_i_dat ),
    .o_ack   ( wb2byteout_o_ack ),
    .o_dat   ( wb2byteout_o_dat )
  );

  // * wb2byteio
  wire [1:0] wb2byteio_i_adr = i_wbm_adr[3:0] == 4'd0  ? 2'b00 :
                               i_wbm_adr[3:0] == 4'd4  ? 2'b01 :
                               i_wbm_adr[3:0] == 4'd8  ? 2'b10 :
                               i_wbm_adr[3:0] == 4'd12 ? 2'b11 :
                                                         2'b00 ;
  wire       wb2byteio_i_stb = adr_wb2byteio & i_wbm_stb;
  wire       wb2byteio_i_we  = i_wbm_we;
  wire [7:0] wb2byteio_i_dat = i_wbm_dat;
  wire       wb2byteio_o_ack;
  wire [7:0] wb2byteio_o_dat;

  wb2byteio u_wb2byteio (
    .i_clk   ( i_clk             ),
    .i_rst_n ( i_rst_n           ),
    .i_adr   ( wb2byteio_i_adr   ),
    .i_stb   ( wb2byteio_i_stb   ),
    .i_we    ( wb2byteio_i_we    ),
    .i_dat   ( wb2byteio_i_dat   ),
    .o_ack   ( wb2byteio_o_ack   ),
    .o_dat   ( wb2byteio_o_dat   ),
    .o_iobuf ( wb2byteio_o_iobuf )
  );

  // * output
  assign o_wbs_ack = adr_sram       ? sram_o_ack       :
                     adr_wb2byteout ? wb2byteout_o_ack :
                     adr_wb2byteio  ? wb2byteio_o_ack  :
                                      1'b0             ;
  assign o_wbs_dat = adr_sram       ? sram_o_dat                     :
                     adr_wb2byteout ? {{24{1'b0}}, wb2byteout_o_dat} :
                     adr_wb2byteio  ? {{24{1'b0}}, wb2byteio_o_dat } :
                                      32'd0                          ;

endmodule //wb_interconnect