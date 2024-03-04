/*
 * @Design: wb2sram32
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Description: A wishbone-slave to read/write SRAM
 */
`timescale 1ns/10ps

module wb2sram32 #(
  parameter ASIZE = 14,
            DSIZE = 32
)(
  input                i_clk  ,
  input                i_rst_n,
  // wishbone interface
  input  [ASIZE-1:0]   i_adr  ,
  input                i_stb  ,
  input  [DSIZE/8-1:0] i_sel  ,
  input                i_we   ,
  input  [DSIZE-1:0]   i_dat  ,
  output               o_ack  ,
  output [DSIZE-1:0]   o_dat
);
  // * -----------------
  // * state encode
  // * -----------------
  localparam WB_IDLE = 1'b0,
             WB_ACK  = 1'b1;

  // * -----------------
  // * wishbone FSM
  // * -----------------
  reg wb_state, wb_state_next;

  // state update
  always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) wb_state <= WB_IDLE;
    else          wb_state <= wb_state_next;
  end

  // next state logic
  always @ (wb_state or i_stb) begin
    case (wb_state)
      WB_IDLE:
        if (i_stb) wb_state_next = WB_ACK;
        else       wb_state_next = WB_IDLE;
      WB_ACK:      wb_state_next = WB_IDLE;
      default:     wb_state_next = WB_IDLE;
    endcase
  end

  // FSM output
  assign o_ack = wb_state;
  
  // * -----------------
  // * write/read sram
  // * -----------------
  wire [3:0] ena = i_we ? ({4{i_stb}} & i_sel) : {4{i_stb}};
  // wire [3:0] ena = {4{o_ack}} & i_sel;
  sram16kx8 sram16kx8a(
    .clka  ( i_clk        ), // input wire clka
    .ena   ( ena[0]       ), // input wire ena
    .wea   ( i_we         ), // input wire [0 : 0] wea
    .addra ( i_adr[13:0]  ), // input wire [13 : 0] addra
    .dina  ( i_dat[7:0]   ), // input wire [7 : 0] dina
    .douta ( o_dat[7:0]   )  // output wire [7 : 0] douta
  );
  sram16kx8 sram16kx8b(
    .clka  ( i_clk        ), // input wire clka
    .ena   ( ena[1]       ), // input wire ena
    .wea   ( i_we         ), // input wire [0 : 0] wea
    .addra ( i_adr[13:0]  ), // input wire [13 : 0] addra
    .dina  ( i_dat[15:8]  ), // input wire [7 : 0] dina
    .douta ( o_dat[15:8]  )  // output wire [7 : 0] douta
  );
  sram16kx8 sram16kx8c(
    .clka  ( i_clk        ), // input wire clka
    .ena   ( ena[2]       ), // input wire ena
    .wea   ( i_we         ), // input wire [0 : 0] wea
    .addra ( i_adr[13:0]  ), // input wire [13 : 0] addra
    .dina  ( i_dat[23:16] ), // input wire [7 : 0] dina
    .douta ( o_dat[23:16] )  // output wire [7 : 0] douta
  );
  sram16kx8 sram16kx8d(
    .clka  ( i_clk        ), // input wire clka
    .ena   ( ena[3]       ), // input wire ena
    .wea   ( i_we         ), // input wire [0 : 0] wea
    .addra ( i_adr[13:0]  ), // input wire [13 : 0] addra
    .dina  ( i_dat[31:24] ), // input wire [7 : 0] dina
    .douta ( o_dat[31:24] )  // output wire [7 : 0] douta
  );

endmodule