/*
 * @Author: Zhao Siwei 
 * @Email: cheems@foxmail.com
 * @Date: 2023-07-31 15:11:01 
 * @Last Modified by: Zhao Siwei
 * @Last Modified time: 2023-07-31 18:40:16
 * @Description: Input debounce
 */
`timescale 1ns/10ps

module debounce #(
  parameter ASIZE = 1,
            DSIZE = 8 
)(
  input                  i_clk   , // 10MHz
  input                  i_rst_n ,
  input      [ASIZE-1:0] i_wb_adr,
  input                  i_wb_stb,
  input                  i_wb_we ,
  input      [DSIZE-1:0] i_wb_dat,
  input                  i_key_n ,  // in
  output reg             o_wb_ack,
  output reg [DSIZE-1:0] o_wb_dat,
  output reg             o_key_n    // out
);
  // * -----------------
  // * state encode
  // * -----------------
  parameter ADR_WB2P_1 = 1'b0,
            ADR_WB2P_2 = 1'b1;
  parameter CNT_CLEAR  = 2'b00,
            CNT_HOLD   = 2'b01,
            CNT_INCR   = 2'b10,
            CNT_DONE   = 2'b11;

  // * -----------------
  // * synchronize
  // * -----------------
  reg  key_r1, key_r2, key_r3;
  wire key_change = key_r2 != key_r3;
  wire key_syn_n  = key_r2;

  always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) {key_r1, key_r2, key_r3} <= 3'b0;
    else          {key_r1, key_r2, key_r3} <= {i_key_n, key_r1, key_r2};
  end
  
  // * -----------------
  // * get 0.2ms pulse
  // * -----------------
  // wb2pulse input
  reg              wb2p1_i_stb,   wb2p2_i_stb;
  // wb2pulse output                   
  wire             wb2p1_o_ack,   wb2p2_o_ack;
  wire [DSIZE-1:0] wb2p1_o_dat,   wb2p2_o_dat;
  wire             wb2p1_o_pulse, wb2p2_o_pulse;

  // distribute by address
  always @ (*) begin
    case (i_wb_adr)
      ADR_WB2P_1: begin
        wb2p1_i_stb = i_wb_stb;
        wb2p2_i_stb = 1'b0;
        o_wb_ack    = wb2p1_o_ack;
        o_wb_dat    = wb2p1_o_dat;
      end
      ADR_WB2P_2: begin
        wb2p2_i_stb = i_wb_stb;
        wb2p1_i_stb = 1'b0;
        o_wb_ack    = wb2p2_o_ack;
        o_wb_dat    = wb2p2_o_dat;
      end
      default: begin
        wb2p1_i_stb = 1'b0;
        wb2p2_i_stb = 1'b0;
        o_wb_ack    = 1'b0;
        o_wb_dat    = {DSIZE{1'b0}};
      end
    endcase
  end

  // cascade 2 wb2pulse module
  wb2pulse #(
    .DSIZE   ( DSIZE          )
  ) u_wb2pulse_1 (
    .i_clk   ( i_clk          ),
    .i_rst_n ( i_rst_n        ),
    .i_stb   ( wb2p1_i_stb    ),
    .i_we    ( i_wb_we        ),
    .i_dat   ( i_wb_dat       ),
    .i_e     ( 1'b1           ),  // layer 1
    .o_ack   ( wb2p1_o_ack    ),
    .o_dat   ( wb2p1_o_dat    ),
    .o_pulse ( wb2p1_o_pulse  )
  );
  
  wb2pulse #(
    .DSIZE   ( DSIZE          )
  ) u_wb2pulse_2 (
    .i_clk   ( i_clk          ),
    .i_rst_n ( i_rst_n        ),
    .i_stb   ( wb2p2_i_stb    ),
    .i_we    ( i_wb_we        ),
    .i_dat   ( i_wb_dat       ),
    .i_e     ( wb2p1_o_pulse  ),  // layer 2
    .o_ack   ( wb2p2_o_ack    ),
    .o_dat   ( wb2p2_o_dat    ),
    .o_pulse ( wb2p2_o_pulse  )   // 0.2ms pulse
  );

  // get pulse's posedge
  reg wb2p2_o_pulse_r;
  always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) wb2p2_o_pulse_r <= 0;
    else          wb2p2_o_pulse_r <= wb2p2_o_pulse;
  end
  assign sample_pulse_rise = ~wb2p2_o_pulse_r & wb2p2_o_pulse;

  // * -------------
  // * sample & debounce
  // * -------------
  // cnt control FSM
  // state update
  reg [1:0] cntctl, cntctl_next;
  reg [6:0] cnt, cnt_next;

  always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) cntctl <= CNT_CLEAR;
    else          cntctl <= cntctl_next;
  end

  // next state logic
  always @ (*) begin
    if      (key_change)         cntctl_next = CNT_CLEAR; // clear
    else if (sample_pulse_rise)
      case (cntctl)
        CNT_CLEAR:               cntctl_next = CNT_INCR;
        CNT_HOLD,
        CNT_INCR:
          if (cnt == 7'b1100011) cntctl_next = CNT_DONE;  // stable
          else                   cntctl_next = CNT_INCR;
        CNT_DONE:                cntctl_next = CNT_DONE;
      endcase
    else                         cntctl_next = CNT_HOLD;
  end
  
  // count FSM
  // state update
  
  always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) cnt <= 7'b000_0000;
    else          cnt <= cnt_next;
  end

  // next state logic
  always @ (*) begin
    case (cntctl)
      CNT_CLEAR,
      CNT_DONE:  cnt_next = 7'b000_0000; // clear
      CNT_HOLD:  cnt_next = cnt;         // hold
      CNT_INCR:  cnt_next = cnt + 1;     // increase
    endcase
  end

  // FSM output
  always @ (posedge i_clk or negedge i_rst_n) begin
    if      (!i_rst_n)            o_key_n <= 1'b1;
    // output stable signal
    else if (cntctl == CNT_DONE)  o_key_n <= key_syn_n;
    else                          o_key_n <= o_key_n;
  end

endmodule