/*
 * @Author: Zhao Siwei 
 * @Email: cheems@foxmail.com
 * @Date: 2023-07-29 17:07:28 
 * @Last Modified by: Zhao Siwei
 * @Last Modified time: 2023-07-31 18:42:37
 * @Description: Testbench of wb2pulse
 */
`timescale  1ns/10ps

module tb_wb2pulse;

// wb2pulse Parameters
parameter PERIOD    = 10  ;
parameter DSIZE     = 8   ;

// wb2pulse Inputs & Outputs
reg  i_clk = 1;
reg  i_rst = 0;
reg  i_we  = 0;
reg  i_stb = 0;
reg  i_e   = 0;
reg  [DSIZE-1:0] i_dat = 0 ;
wire o_ack;
wire o_pulse;
wire [DSIZE-1:0] o_dat;

// clk & rst
initial forever #(PERIOD/2) i_clk = ~i_clk;
initial         #(PERIOD/2) i_rst = 1;

// instantiate wb2pulse
wb2pulse #(
  .DSIZE   ( DSIZE   )
) u_wb2pulse (
  .i_clk   ( i_clk   ),
  .i_rst_n ( i_rst   ),
  .i_stb   ( i_stb   ),
  .i_we    ( i_we    ),
  .i_dat   ( i_dat   ),
  .i_e     ( i_e     ),
  .o_ack   ( o_ack   ),
  .o_dat   ( o_dat   ),
  .o_pulse ( o_pulse )
);

task wb_write(
  input [DSIZE-1:0] dat
);
  begin
    @(posedge i_clk);
      i_stb <= 1'b1;
      i_we  <= 1'b1;
      i_dat <= dat;
    @(posedge i_clk);
    @(posedge i_clk);
      i_stb <= 1'b0;
      i_dat <= 0;
  end
endtask

task wb_read;
  begin
    @(posedge i_clk);
      i_stb <= 1'b1;
      i_we  <= 1'b0;
    @(posedge i_clk);
    @(posedge i_clk);
      i_stb <= 1'b0;
  end
endtask

initial begin
  i_e = 1'b1;
  wb_write(100);
  wb_read;
  wb_write((1<<DSIZE)-1);
  wb_read;
  #30 wb_write(20);
  wb_read;
  wb_write(9);
  #330 i_e = 1'b0;
  #100 i_e = 1'b1;
  wb_read;
  wb_read;
  #100 wb_write((1<<DSIZE)-1);

  #10000 $finish;
end

// dump wave
initial begin            
    $dumpfile("sim/wb2pulse.vcd");
    $dumpvars(0, tb_wb2pulse);
end

endmodule