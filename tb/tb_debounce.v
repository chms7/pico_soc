/*
 * @Author: Zhao Siwei 
 * @Email: cheems@foxmail.com
 * @Date: 2023-07-31 16:07:41 
 * @Last Modified by: Zhao Siwei
 * @Last Modified time: 2023-07-31 18:43:38
 * @Description: Testbench of debounce
 */
`timescale  1ns/10ps

module tb_debounce;

// debounce Parameters
parameter PERIOD = 100;
parameter ASIZE  = 1,
          DSIZE  = 8;

// debounce Inputs
reg   i_clk                 = 1 ;
reg   i_rst_n               = 0 ;
reg   [ASIZE-1:0]  i_wb_adr = 0 ;
reg   i_wb_stb              = 0 ;
reg   i_wb_we               = 0 ;
reg   [DSIZE-1:0]  i_wb_dat = 0 ;
reg   i_key_n               = 1 ;

// debounce Outputs
wire  o_wb_ack              ;
wire  [DSIZE-1:0]  o_wb_dat ;
wire  o_key_n               ;

// clk & rst
initial forever #(PERIOD/2) i_clk   = ~i_clk;
initial         #(PERIOD/2) i_rst_n = 1;

debounce #(
    .DSIZE ( DSIZE ))
 u_debounce (
    .i_clk    ( i_clk                 ),
    .i_rst_n  ( i_rst_n               ),
    .i_wb_adr ( i_wb_adr  [ASIZE-1:0] ),
    .i_wb_stb ( i_wb_stb              ),
    .i_wb_we  ( i_wb_we               ),
    .i_wb_dat ( i_wb_dat  [DSIZE-1:0] ),
    .i_key_n  ( i_key_n               ),
    .o_wb_ack ( o_wb_ack              ),
    .o_wb_dat ( o_wb_dat  [DSIZE-1:0] ),
    .o_key_n  ( o_key_n               )
);

task wb_write(
  input [ASIZE-1:0] adr,
  input [DSIZE-1:0] dat
);
  begin
    @(posedge i_clk);
      i_wb_adr <= adr;
      i_wb_stb <= 1'b1;
      i_wb_we  <= 1'b1;
      i_wb_dat <= dat;
    @(posedge i_clk);
    @(posedge i_clk);
      i_wb_stb <= 1'b0;
      i_wb_dat <= 0;
  end
endtask

task wb_read(
  input [ASIZE-1:0] adr
);
  begin
    @(posedge i_clk);
      i_wb_adr <= adr;
      i_wb_stb <= 1'b1;
      i_wb_we  <= 1'b0;
    @(posedge i_clk);
    @(posedge i_clk);
      i_wb_stb <= 1'b0;
  end
endtask

reg [18:0] toggle_delay;
task key_toggle(
  input type
);
  begin
    repeat(40) begin
      toggle_delay = {$random}%500000;
      #toggle_delay i_key_n = ~i_key_n;
    end
    i_key_n = type;
  end
endtask

initial
begin
  wb_write(1'b0, 99);
  wb_read(1'b0);
  wb_write(1'b1, 19);
  wb_read(1'b1);

  #10 key_toggle(0);
  #40000000 key_toggle(1);
  #40000000 key_toggle(0);
  #40000000 key_toggle(1);

  #100000000 $finish;
end

// dump wave
initial begin            
    $dumpfile("sim/debounce.vcd");
    $dumpvars(0, tb_debounce);
end

endmodule