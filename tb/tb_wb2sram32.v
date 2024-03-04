/*
 * @Author: Zhao Siwei 
 * @Email: cheems@foxmail.com
 * @Date: 2023-08-04 22:28:12 
 * @Last Modified by:   undefined 
 * @Last Modified time: 2023-08-04 23:03:32
 * @Description: A wishbone-slave to read/write sram
 */
`timescale  1ns/10ps

module tb_wb2sram32;

// Parameters
parameter       PERIOD = 100; // 10MHz
parameter       ASIZE  = 14,
                DSIZE  = 32;

// Inputs & Outputs
reg                i_clk = 1;
reg                i_rst = 0;
reg  [ASIZE-1:0]   i_adr = 0 ;
reg                i_stb = 0;
reg  [DSIZE/8-1:0] i_sel = 4'b1111;
reg                i_we  = 0;
reg  [DSIZE-1:0]   i_dat = 0 ;
reg  [DSIZE-1:0]   w_dat = 0 ;
wire               o_ack;
wire [DSIZE-1:0]   o_dat;

// clk & rst
initial forever #(PERIOD/2) i_clk = ~i_clk;
initial         #(PERIOD/2) i_rst = 1;

// instantiate
wb2sram32 #(
  .ASIZE   ( ASIZE   ),
  .DSIZE   ( DSIZE   )
) u_wb2sram32 (
  .i_clk   ( i_clk   ),
  .i_rst_n ( i_rst   ),
  .i_adr   ( i_adr   ),
  .i_stb   ( i_stb   ),
  .i_sel   ( i_sel   ),
  .i_we    ( i_we    ),
  .i_dat   ( i_dat   ),
  .o_ack   ( o_ack   ),
  .o_dat   ( o_dat   )
);

task wb_write(
  input [ASIZE-1:0]   adr,
  input [DSIZE-1:0]   dat,
  input [DSIZE/8-1:0] sel
);
  begin
    @(posedge i_clk);
      $display("%12.4f\tWrite Request", $time);
      i_adr <= adr;
      i_stb <= 1'b1;
      i_we  <= 1'b1;
      i_dat <= dat;
      i_sel <= sel;
      $strobe("%12.4f\t%s!\twb_state = %s", $time, 
        u_wb2sram32.wb_state  === u_wb2sram32.WB_IDLE ? "OK" : "Fail",
        (u_wb2sram32.wb_state === u_wb2sram32.WB_IDLE ? "IDLE" :
         u_wb2sram32.wb_state === u_wb2sram32.WB_ACK  ? "ACK"  : "IDLE"));
    @(posedge i_clk);
      $strobe("%12.4f\t%s!\twb_state = %s", $time, 
        u_wb2sram32.wb_state  === u_wb2sram32.WB_ACK ? "OK" : "Fail",
        (u_wb2sram32.wb_state === u_wb2sram32.WB_IDLE ? "IDLE" :
         u_wb2sram32.wb_state === u_wb2sram32.WB_ACK  ? "ACK"  : "IDLE"));
    @(posedge i_clk);
      i_stb <= 1'b0;
      i_dat <= 0;
      $strobe("%12.4f\t%s!\twb_state = %s\n\t\t\ti_adr = 0x%x, i_sel = %b, i_dat = %x\n", $time, 
        u_wb2sram32.wb_state === u_wb2sram32.WB_IDLE  ? "OK" : "Fail",
        (u_wb2sram32.wb_state === u_wb2sram32.WB_IDLE ? "IDLE" :
          u_wb2sram32.wb_state === u_wb2sram32.WB_ACK  ? "ACK" : "IDLE"),
        u_wb2sram32.i_adr, sel, dat);
  end
endtask

task wb_read(
  input [ASIZE-1:0] adr
);
  begin
    @(posedge i_clk);
      $display("%12.4f\tRead Request", $time);
      i_adr <= adr;
      i_stb <= 1'b1;
      i_we  <= 1'b0;
      i_sel <= 4'b1111;
      $strobe("%12.4f\t%s!\twb_state = %s", $time, 
        u_wb2sram32.wb_state  === u_wb2sram32.WB_IDLE ? "OK" : "Fail",
        (u_wb2sram32.wb_state === u_wb2sram32.WB_IDLE ? "IDLE" :
         u_wb2sram32.wb_state === u_wb2sram32.WB_ACK  ? "ACK"  : "IDLE"));
    @(posedge i_clk);
      $strobe("%12.4f\t%s!\twb_state = %s", $time, 
        u_wb2sram32.wb_state  === u_wb2sram32.WB_ACK ? "OK" : "Fail",
        (u_wb2sram32.wb_state === u_wb2sram32.WB_IDLE ? "IDLE" :
         u_wb2sram32.wb_state === u_wb2sram32.WB_ACK  ? "ACK"  : "IDLE"));
    @(posedge i_clk);
      i_stb <= 1'b0;
      #1 $strobe("%12.4f\t%s!\twb_state = %s\n\t\t\ti_adr = 0x%x, o_dat = %x\n", $time, 
        u_wb2sram32.wb_state  === u_wb2sram32.WB_IDLE ? "OK" : "Fail",
        (u_wb2sram32.wb_state === u_wb2sram32.WB_IDLE ? "IDLE" :
         u_wb2sram32.wb_state === u_wb2sram32.WB_ACK  ? "ACK"  : "IDLE"),
        u_wb2sram32.i_adr, u_wb2sram32.o_dat);
  end
endtask

initial begin
  // write
  #1 wb_write(14'b00_0000_0000_0000, 32'hABCDABCD, 4'b1111);
  #1 wb_write(14'b11_1111_1111_1111, 32'hDCBADCBA, 4'b1111);
  #1 wb_write(14'b01_0010_0110_0010, 32'hFFFFFFFF, 4'b1111);

  // read
  wb_read(14'b00_0000_0000_0000);
  wb_read(14'b11_1111_1111_1111);
  wb_read(14'b01_0010_0110_0010);
  
  // write with byte enable
  #1 wb_write(14'b00_0000_0000_0000, 32'hFFFFFFFF, 4'b0001);
  #1 wb_write(14'b11_1111_1111_1111, 32'hFFFFFFFF, 4'b0011);
  #1 wb_write(14'b01_0010_0110_0010, 32'h00000000, 4'b0111);

  // read
  wb_read(14'b00_0000_0000_0000);
  wb_read(14'b11_1111_1111_1111);
  wb_read(14'b01_0010_0110_0010);

  #10000 $finish;
end

// dump wave
initial begin            
    $dumpfile("sim/wb2sram32.vcd");
    $dumpvars(0, tb_wb2sram32);
end

endmodule