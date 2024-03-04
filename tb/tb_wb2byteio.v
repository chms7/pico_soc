/*
 * @Design: tb_wb2byteio
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Description: Testbench of wb2byteio
 */
`timescale  1ns/10ps

module tb_wb2byteio;

// Parameters
parameter       PERIOD = 100; // 10MHz
parameter       ASIZE  = 2,
                DSIZE  = 8;
parameter [1:0] ADR_A  = 2'b00,
                ADR_S  = 2'b01,
                ADR_C  = 2'b10,
                ADR_CC = 2'b11;

// Inputs & Outputs
reg              i_clk = 1;
reg              i_rst = 0;
reg  [ASIZE-1:0] i_adr = 0 ;
reg              i_we  = 0;
reg              i_stb = 0;
reg  [DSIZE-1:0] i_dat = 0 ;
reg  [DSIZE-1:0] w_dat = 0 ;
wire             o_ack;
wire [DSIZE-1:0] o_dat;
wire [DSIZE-1:0] o_iobuf;

reg  [DSIZE-1:0] iobuf = 0;
reg  [DSIZE-1:0] w_iobuf = 0;
reg              iobuf_tri = 1'b0;
assign o_iobuf = iobuf_tri ? iobuf : 8'bz;

// clk & rst
initial forever #(PERIOD/2) i_clk = ~i_clk;
initial         #(PERIOD/2) i_rst = 1;

// instantiate
wb2byteio #(
  .ASIZE   ( ASIZE   ),
  .DSIZE   ( DSIZE   )
) u_wb2byteio (
  .i_clk   ( i_clk   ),
  .i_rst_n ( i_rst   ),
  .i_adr   ( i_adr   ),
  .i_stb   ( i_stb   ),
  .i_we    ( i_we    ),
  .i_dat   ( i_dat   ),
  .o_ack   ( o_ack   ),
  .o_dat   ( o_dat   ),
  .o_iobuf ( o_iobuf )
);

task wb_write(
  input [ASIZE-1:0] adr,
  input [DSIZE-1:0] dat
);
  begin
    @(posedge i_clk);
      $display("%12.4f\tWrite Request", $time);
      i_adr <= adr;
      i_stb <= 1'b1;
      i_we  <= 1'b1;
      i_dat <= dat;
      $strobe("%12.4f\t%s!\twb_state = %s", $time, 
        u_wb2byteio.wb_state  === u_wb2byteio.WB_IDLE ? "OK" : "Fail",
        (u_wb2byteio.wb_state === u_wb2byteio.WB_IDLE ? "IDLE" :
         u_wb2byteio.wb_state === u_wb2byteio.WB_ACK  ? "ACK"  : "IDLE"));
    @(posedge i_clk);
      $strobe("%12.4f\t%s!\twb_state = %s", $time, 
        u_wb2byteio.wb_state  === u_wb2byteio.WB_ACK ? "OK" : "Fail",
        (u_wb2byteio.wb_state === u_wb2byteio.WB_IDLE ? "IDLE" :
         u_wb2byteio.wb_state === u_wb2byteio.WB_ACK  ? "ACK"  : "IDLE"));
    @(posedge i_clk);
      i_stb <= 1'b0;
      i_dat <= 0;
      $strobe("%12.4f\t%s!\twb_state = %s, S/C = %x, i_dat = %2x\n", $time, 
        // state
        (u_wb2byteio.wb_state === u_wb2byteio.WB_IDLE &
          // data
          ((adr === ADR_S) ? u_wb2byteio.S : (adr === ADR_C | adr === ADR_CC) ? u_wb2byteio.C : 0) === dat)
          ? "OK" : "Fail",
        (u_wb2byteio.wb_state === u_wb2byteio.WB_IDLE ? "IDLE" :
          u_wb2byteio.wb_state === u_wb2byteio.WB_ACK  ? "ACK"  : "IDLE"),
        ((adr === ADR_S) ? u_wb2byteio.S : (adr === ADR_C | adr === ADR_CC) ? u_wb2byteio.C : 8'hAB),
        dat);
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
      $strobe("%12.4f\t%s!\twb_state = %s", $time, 
        u_wb2byteio.wb_state  === u_wb2byteio.WB_IDLE ? "OK" : "Fail",
        (u_wb2byteio.wb_state === u_wb2byteio.WB_IDLE ? "IDLE" :
         u_wb2byteio.wb_state === u_wb2byteio.WB_ACK  ? "ACK"  : "IDLE"));
    @(posedge i_clk);
      $strobe("%12.4f\t%s!\twb_state = %s", $time, 
        u_wb2byteio.wb_state  === u_wb2byteio.WB_ACK ? "OK" : "Fail",
        (u_wb2byteio.wb_state === u_wb2byteio.WB_IDLE ? "IDLE" :
         u_wb2byteio.wb_state === u_wb2byteio.WB_ACK  ? "ACK"  : "IDLE"));
    @(posedge i_clk);
      i_stb <= 1'b0;
      $strobe("%12.4f\t%s!\twb_state = %s, o_dat = %x\n", $time, 
        u_wb2byteio.wb_state  === u_wb2byteio.WB_IDLE ? "OK" : "Fail",
        (u_wb2byteio.wb_state === u_wb2byteio.WB_IDLE ? "IDLE" :
         u_wb2byteio.wb_state === u_wb2byteio.WB_ACK  ? "ACK"  : "IDLE"),
        u_wb2byteio.o_dat);
    // #1 $display("w_dat = %h, r_dat = %h\niobuf = %h, iobuf_tri = %h\no_iobuf = %h\n", w_dat, o_dat, iobuf, iobuf_tri, o_iobuf);
  end
endtask

initial begin
  // check reset
  #(PERIOD*3/4)
    $display("Reset Check");
    $display("%12.4f\t%s!\twb_state = %s, C = %x, S = %x\n", $time, 
      ((u_wb2byteio.wb_state  === u_wb2byteio.WB_IDLE) & (u_wb2byteio.C === 0) & u_wb2byteio.S === 0)
        ? "OK" : "Fail",
      (u_wb2byteio.wb_state === u_wb2byteio.WB_IDLE ? "IDLE" :
       u_wb2byteio.wb_state === u_wb2byteio.WB_ACK  ? "ACK"  : "IDLE"),
       u_wb2byteio.C, u_wb2byteio.S);

  // config C as output
  #1 $display("Configure C");
  wb_write(ADR_C, 8'b0000_0000);
  wb_read (ADR_C);

  // drive S
  #1 $display("Output");
  w_dat = {$random}%256;
  wb_write(ADR_S, w_dat);
  wb_read (ADR_S);

  w_dat = {$random}%256;
  wb_write(ADR_S, w_dat);
  wb_read (ADR_S);

  w_dat = {$random}%256;
  wb_write(ADR_S, w_dat);
  wb_read (ADR_S);

  // config C as input
  #1 $display("Configure C");
  wb_write(ADR_C, 8'b1111_1111);
  wb_read (ADR_A);
  #100 wb_read (ADR_C);

  // drive iobuf
  #1 $display("Input");
  @(posedge i_clk)
    w_iobuf = {$random}%256; iobuf = w_iobuf; iobuf_tri = 1'b1;
    wb_read (ADR_A);
  @(posedge i_clk)
    w_iobuf = {$random}%256; iobuf = w_iobuf;
    wb_read (ADR_A);
  @(posedge i_clk)
    w_iobuf = {$random}%256; iobuf = w_iobuf;
    wb_read (ADR_A);
  @(posedge i_clk)
    w_iobuf = {$random}%256; iobuf = w_iobuf;
    wb_read (ADR_A);
  @(posedge i_clk)
    w_iobuf = {$random}%256; iobuf = w_iobuf; iobuf_tri = 1'b0;
    wb_read (ADR_A);

  // config C as output
  #1 $display("Configure C");
  wb_write(ADR_C, 8'b1111_0000);
  wb_read (ADR_C);

  // drive S
  #1 $display("Input & Output");
  w_dat = {$random}%256;
  wb_write(ADR_S, w_dat);
  wb_read (ADR_S);
  wb_read (ADR_A);

  w_dat = {$random}%256;
  wb_write(ADR_S, w_dat);
  wb_read (ADR_S);

  #1000 $finish;
end

// dump wave
initial begin            
    $dumpfile("sim/wb2byteio.vcd");
    $dumpvars(0, tb_wb2byteio);
end

endmodule