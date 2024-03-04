/*
 * @Design: wb2byteout
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Description: A wishbone-slave to write/read a 8-bits memory
 */
`timescale 1ns/10ps

module wb2byteout #(
  parameter DSIZE = 8
)(
  input                i_clk  ,
  input                i_rst_n,
  // wishbone interface
  input                i_stb  ,
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

  // write/read
  reg [DSIZE-1:0] S, o_dat;
  always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_dat <= 0;
      S     <= 0;
    end else begin
      S     <= S;
      o_dat <= o_dat;
      case (wb_state)
        WB_IDLE: ;
        WB_ACK: begin
          if (i_we) S     <= i_dat; // write          
          else      o_dat <= S;     // read
        end
        default: ;
      endcase
    end 
  end

endmodule