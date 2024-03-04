/*
 * @Design: tb_wb_interconnect
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Description: Testbench of wb_interconnect
 */
`timescale 1ns/10ps

module tb_wb_interconnect;

// Parameters
parameter PERIOD = 100; // 10MHz
parameter SRAM_ADR_BASE       = 32'h0000_0000,
          WB2BYTEOUT_ADR_BASE = 32'h0002_0300,
          WB2BYTEIO_ADR_BASE  = 32'h0002_0380;

// Inputs & Outputs
reg         i_clk      = 1;
reg         i_rst_n    = 0;
reg         wb_m2s_stb = 0;
reg         wb_m2s_cyc = 0;
reg         wb_m2s_we  = 0;
reg  [3:0 ] wb_m2s_sel = 4'b1111;
reg  [31:0] wb_m2s_adr = 0;
reg  [31:0] wb_m2s_dat = 0;
reg  [31:0] w_dat      = 0;
wire        wb_s2m_ack;
wire [31:0] wb_s2m_dat;
wire [7:0 ] o_iobuf;

// clk & rst
initial forever #(PERIOD/2) i_clk = ~i_clk;
initial         #(PERIOD/2) i_rst_n = 1;

// instantiate
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

task wb_write(
  input [31:0]   adr,
  input [31:0]   dat,
  input [3:0] sel
);
  begin
    @(posedge i_clk);
      $display("%12.4f\tWrite Request", $time);
      wb_m2s_adr <= adr;
      wb_m2s_stb <= 1'b1;
      wb_m2s_we  <= 1'b1;
      wb_m2s_dat <= dat;
      wb_m2s_sel <= sel;
      $strobe("%12.4f\t%s", $time, 
        u_wb_interconnect.o_wbs_ack === 0 ? "OK!\tIDLE" : "Fail!");
    @(posedge i_clk);
      $strobe("%12.4f\t%s", $time, 
        u_wb_interconnect.o_wbs_ack === 1 ? "OK!\tACK" : "Fail!");
    @(posedge i_clk);
      wb_m2s_stb <= 1'b0;
      wb_m2s_dat <= 0;
      $strobe("%12.4f\t%s\tadr = 0x%x, sel = %b, dat = %x\n", $time, 
        u_wb_interconnect.o_wbs_ack === 0 ? "OK!\tIDLE" : "Fail!",
        u_wb_interconnect.i_wbm_adr, sel, dat);
  end
endtask

task wb_read(
  input [31:0] adr
);
  begin
    @(posedge i_clk);
      $display("%12.4f\tRead Request", $time);
      wb_m2s_adr <= adr;
      wb_m2s_stb <= 1'b1;
      wb_m2s_we  <= 1'b0;
      wb_m2s_sel <= 4'b1111;
      $strobe("%12.4f\t%s", $time, 
        u_wb_interconnect.o_wbs_ack === 0 ? "OK!\tIDLE" : "Fail!");
    @(posedge i_clk);
      $strobe("%12.4f\t%s", $time, 
        u_wb_interconnect.o_wbs_ack === 1 ? "OK!\tACK" : "Fail!");
    @(posedge i_clk);
      wb_m2s_stb <= 1'b0;
      #1 $strobe("%12.4f\t%s\tadr = 0x%x, dat = %x\n", $time, 
        u_wb_interconnect.o_wbs_ack  === 0 ? "OK!\tIDLE" : "Fail!",
        u_wb_interconnect.i_wbm_adr, u_wb_interconnect.o_wbs_dat);
  end
endtask

initial begin
  $display("\n\t---- SRAM: Write & Read ----\n");
  // write
  #1 wb_write(SRAM_ADR_BASE+0,     32'hABCD_0000, 4'b1111);
  #1 wb_write(SRAM_ADR_BASE+4,     32'hABCD_0004, 4'b1111);
  #1 wb_write(SRAM_ADR_BASE+8,     32'hABCD_0008, 4'b1111);
  #1 wb_write(SRAM_ADR_BASE+65536, 32'hABCD_FFFF, 4'b1111);

  // read
  wb_read(SRAM_ADR_BASE+0    );
  wb_read(SRAM_ADR_BASE+4    );
  wb_read(SRAM_ADR_BASE+8    );
  wb_read(SRAM_ADR_BASE+65536);

  // byte enable
  #1 $display("\n\t---- SRAM: Byte Enable ----\n");
  #1 wb_write(SRAM_ADR_BASE+0, 32'hFFFF_FFFF, 4'b1001);
  #1 wb_write(SRAM_ADR_BASE+4, 32'hFFFF_ffff, 4'b0110);
  wb_read(SRAM_ADR_BASE+0);
  wb_read(SRAM_ADR_BASE+4);

  // wb2byteout
  #1 $display("\n\t---- wb2byteout: Write & Read ----\n");
  #1 wb_write(WB2BYTEOUT_ADR_BASE, 32'h0000_FFAB, 4'b1111);
  wb_read(WB2BYTEOUT_ADR_BASE);

  // wb2byteio
  #1 $display("\n\t---- wb2byteio: Write & Read ----\n");

  #1 $display("\twb2byteio: configure C as all output\n");
  #1 wb_write(WB2BYTEIO_ADR_BASE+8, 32'h0000_0000, 4'b1111);
  wb_read(WB2BYTEIO_ADR_BASE+8);

  #1 $display("\twb2byteio: drive S\n");
  #1 wb_write(WB2BYTEIO_ADR_BASE+4, 32'h0000_00AB, 4'b1111);
  wb_read(WB2BYTEIO_ADR_BASE+4);
  wb_read(WB2BYTEIO_ADR_BASE+0);

  #1 $display("\twb2byteio: configure C as all input\n");
  #1 wb_write(WB2BYTEIO_ADR_BASE+12, 32'h0000_0011, 4'b1111);
  wb_read(WB2BYTEIO_ADR_BASE+12);
  wb_read(WB2BYTEIO_ADR_BASE+0);

  #1 $display("\twb2byteio: configure C as half input/output\n");
  #1 wb_write(WB2BYTEIO_ADR_BASE+12, 32'h0000_0010, 4'b1111);
  wb_read(WB2BYTEIO_ADR_BASE+12);
  wb_read(WB2BYTEIO_ADR_BASE+0);

  #10000 $finish;
end

// dump wave
initial begin            
    $dumpfile("sim/wb_interconnect.vcd");
    $dumpvars(0, tb_wb_interconnect);
end

endmodule