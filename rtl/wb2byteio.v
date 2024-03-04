/*
 * @Design: wb2byteio
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Description: A wishbone-slave to control the tri-IOBUF
 */
`timescale 1ns/10ps

module wb2byteio #(
  parameter ASIZE = 2,
            DSIZE = 8
)(
  input                i_clk  ,
  input                i_rst_n,
  // wishbone interface
  input  [ASIZE-1:0]   i_adr  ,
  input                i_stb  ,
  input                i_we   ,
  input  [DSIZE-1:0]   i_dat  ,
  output               o_ack  ,
  output [DSIZE-1:0]   o_dat  ,
  // IOBUF
  inout  [DSIZE-1:0]   o_iobuf
);
  // * -----------------
  // * state encode
  // * -----------------
  localparam       WB_IDLE = 1'b0,
                   WB_ACK  = 1'b1;
  localparam [1:0] ADR_0   = 2'b00,
                   ADR_1   = 2'b01,
                   ADR_2   = 2'b10,
                   ADR_3   = 2'b11;

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
  reg  [DSIZE-1:0] C, S, o_dat;
  wire [DSIZE-1:0] A;

  always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_dat <= 0;
      C     <= 0;
      S     <= 0;
    end else if (o_ack) begin
      o_dat <= o_dat;
      S     <= S;
      C     <= C;
      case (i_adr)
        ADR_0: // get input
          if (~i_we) o_dat <= A;
        ADR_1: // drive output
          if (i_we)  S <= i_dat;
          else       o_dat <= S;
        ADR_2,
        ADR_3: // config in/out
          if (i_we)  C <= i_dat;
          else       o_dat <= C;
      endcase
    end else begin
      o_dat <= o_dat;
      S     <= S;
      C     <= C;
    end
  end
  
  // * -----------------
  // * generate IOBUF
  // * -----------------
  genvar gv_i;
  generate
    for (gv_i = 0; gv_i < DSIZE; gv_i = gv_i + 1) begin: GEN_IOBUF
      IOBUF #(
        .DRIVE      ( 8         ), // Specify the output drive strength
        .IOSTANDARD ( "DEFAULT" ), // Specify the I/O standard
        .SLEW       ( "FAST"    )  // Specify the output slew rate
      ) u_IOBUF (
        .O  ( A[gv_i]       ), // Buffer output
        .IO ( o_iobuf[gv_i] ), // Buffer inout port (connect directly to top-level port)
        .I  ( S[gv_i]       ), // Buffer input
        .T  ( C[gv_i]       )  // 3-state enable input, high=input, low=output
      );
    end
  endgenerate


endmodule