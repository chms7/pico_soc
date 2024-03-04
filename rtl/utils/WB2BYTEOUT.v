//--------------------------------------------------------------------
//
//	Design		:	WB2BYTEOUT
//
//	File name	:	WB2BYTEOUT.v
//
//	Purpose		:	Wishbone client device, 8 bits output
//
//	Limitations	:	
//
//	Errors		:	None known
//
//	Include files	:	None
//
//	Author		:	Xiaofang Zhou
//
//	Simulator	:	ModulSim PC 10.4
//
//--------------------------------------------------------------------
//	Revision List
//	Version		Author		Date		Change
//	1.1		Xiaofang Zhou	Oct. 4, 2023	original
//
//--------------------------------------------------------------------

`timescale 1ns/10ps

module WB2BYTEOUT (
	CLK_I,
	RSTN_I,
	
	// Wishbone
	STB_I,
	WE_I,
	DAT_I,
	DAT_O,
	ACK_O,
	
	// peripheral IO
	S
	
);

input	CLK_I,
	RSTN_I;

input	STB_I;
input	WE_I;
input	[ 7 : 0]	DAT_I;
output	[ 7 : 0]	DAT_O;
output	ACK_O;

output	[ 7 : 0]	S;

// --- FSM
parameter
	W_IDLE	= 2'b00,
	W_ACK	= 2'b10,
	W_UPDS	= 2'b01;

reg	[ 1 : 0]	W_STAT;
reg	[ 1 : 0]	W_NEXT;
wire	ACK_O,
	UPD_S;

assign	{ACK_O, UPD_S} = W_STAT;

// synthesis attribute fsm_encoding of W_STAT is user;
always @(STB_I or WE_I or W_STAT)
case (W_STAT)
	W_IDLE:
		W_NEXT =	
			(STB_I == 1'b1) ? 
			((WE_I == 1'b1) ? W_UPDS : W_ACK) :
			W_IDLE;
	W_UPDS:	W_NEXT =
			W_ACK;
	W_ACK:	W_NEXT =
			W_IDLE;
	default:W_NEXT =
			W_IDLE;
endcase

// --- Peripheral
reg	[ 7 : 0]	S;
wire	[ 7 : 0]	S_NEXT;

parameter
	S_INIT = 8'h00;

assign	S_NEXT = (UPD_S == 1'b1) ?
		 DAT_I : S;

assign	DAT_O =	S;

// --- DFFs
always @(posedge CLK_I or negedge RSTN_I)
	if (RSTN_I == 1'b0) begin
		W_STAT	<= W_IDLE;
		S	<= S_INIT;
	end else begin
		W_STAT	<= W_NEXT;
		S	<= S_NEXT;
	end

endmodule
