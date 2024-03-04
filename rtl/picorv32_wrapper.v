/*
 * @Design: picorv32_wrapper
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Description: Top module of picorv32 soc
 */
`timescale 1ns/10ps

module picorv32_wrapper (
	input  i_clk,
	input  i_rst_n,
	output        o_trap,
	output        o_trace_valid,
	output [35:0] o_trace_data,
  inout  [7:0]  o_iobuf
);
  wire wb_m2s_stb, wb_m2s_cyc, wb_m2s_we, wb_s2m_ack;
  wire [3:0]  wb_m2s_sel;
  wire [31:0] wb_m2s_adr;
  wire [31:0] wb_m2s_dat, wb_s2m_dat;

  // * picorv32
  picorv32_wb #(
    .ENABLE_MUL   ( 1              ),
    .ENABLE_IRQ   ( 1              ),
	  .PROGADDR_IRQ ( 32'h 0000_0020 )
  ) u_picorv32 (
		.wb_clk_i    ( i_clk        ),
		.wb_rst_i    ( ~i_rst_n     ), // ?
    // wishbone interface
		.wbm_stb_o   ( wb_m2s_stb   ),
		.wbm_cyc_o   ( wb_m2s_cyc   ),
		.wbm_we_o    ( wb_m2s_we    ),
		.wbm_sel_o   ( wb_m2s_sel   ),
		.wbm_adr_o   ( wb_m2s_adr   ),
		.wbm_dat_o   ( wb_m2s_dat   ),
		.wbm_ack_i   ( wb_s2m_ack   ),
		.wbm_dat_i   ( wb_s2m_dat   ),
    // trace interface
		.trap        ( trap         ),
		.trace_valid ( trace_valid  ),
		.trace_data  ( o_trace_data ),
    //
		.mem_instr   ( mem_instr    ),
		.irq         ( 0            )
	);

  // * wishbone interconnect
  wb_interconnect  u_wb_interconnect (
    .i_clk             ( i_clk      ),
    .i_rst_n           ( i_rst_n    ),
    // wishbone interface
    .i_wbm_stb         ( wb_m2s_stb ),
    .i_wbm_cyc         ( wb_m2s_cyc ),
    .i_wbm_we          ( wb_m2s_we  ),
    .i_wbm_sel         ( wb_m2s_sel ),
    .i_wbm_adr         ( wb_m2s_adr ),
    .i_wbm_dat         ( wb_m2s_dat ),
    .o_wbs_ack         ( wb_s2m_ack ),
    .o_wbs_dat         ( wb_s2m_dat ),
    // IOBUF
    .wb2byteio_o_iobuf ( o_iobuf    )
  );

endmodule //picorv32_wrapper