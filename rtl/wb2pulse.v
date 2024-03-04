/*
 * @Author: Zhao Siwei 
 * @Email: cheems@foxmail.com
 * @Date: 2023-07-29 10:45:30 
 * @Last Modified by: Zhao Siwei
 * @Last Modified time: 2023-07-31 17:15:32
 * @Description: Wishbone to pulse
 */
`timescale 1ns/10ps

module wb2pulse #(
  parameter DSIZE = 8
)(
  input                i_clk  ,
  input                i_rst_n,
  input                i_stb  ,
  input                i_we   ,
  input  [DSIZE-1:0]   i_dat  ,
  input                i_e    ,
  output               o_ack  ,
  output [DSIZE-1:0]   o_dat  ,
  output               o_pulse
);
  // * -----------------
  // * state encode
  // * -----------------
  parameter       WB_IDLE   = 1'b0,
                  WB_ACCESS = 1'b1;
  parameter [2:0] CNT_LOAD  = 3'b00_0,
                  CNT_INCR  = 3'b01_0,
                  CNT_PULSE = 3'b11_1,
                  CNT_HOLD  = 3'b10_0;

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
  always @ (*) begin
    case (wb_state)
      WB_IDLE:
        if (i_stb) wb_state_next = WB_ACCESS;
        else       wb_state_next = WB_IDLE;
      WB_ACCESS:   wb_state_next = WB_IDLE;
      default:     wb_state_next = WB_IDLE;
    endcase
  end

  // FSM output
  reg [DSIZE-1:0] o_dat, D;

  assign o_ack = wb_state;
  always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_dat <= 0;
      D     <= 0;
    end else begin
      o_dat <= 0;
      D     <= D;
      case (wb_state)
        WB_IDLE: ;
        WB_ACCESS:
          if (i_we) D <= i_dat; // write          
          else      o_dat <= D; // read
        default: ;
      endcase
    end 
  end

  // * -----------------
  // * cnt control FSM
  // * -----------------
  reg [2:0] cntctl, cntctl_next;
  reg [DSIZE-1:0] cnt, cnt_next;

  // state update
  always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) cntctl <= CNT_LOAD;
    else          cntctl <= cntctl_next;
  end

  // next state logic
  always @ (*) begin
    if ((wb_state == WB_ACCESS) & i_we) begin
      cntctl_next = CNT_LOAD;                  // load
    end else if ((D != 0) & i_e) begin
      case (cnt)
        8'b0000_0001: cntctl_next = CNT_PULSE; // pulse
        default:      cntctl_next = CNT_INCR;  // count
      endcase
    end else begin
      cntctl_next = CNT_HOLD;                  // hold
    end
  end

  // FSM output
  assign o_pulse = cntctl[0];

  // * -------------
  // * counter FSM
  // * -------------
  
  // state update
  always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) cnt <= 8'b0;
    else          cnt <= cnt_next;
  end

  // next state logic
  always @ (*) begin
    case (cntctl)
      CNT_LOAD,
      CNT_PULSE: cnt_next = D;
      CNT_INCR:  cnt_next = cnt - 1;
      CNT_HOLD:  cnt_next = cnt;
      default:   cnt_next = 8'b0;
    endcase
  end

endmodule