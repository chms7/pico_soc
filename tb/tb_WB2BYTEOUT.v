//--------------------------------------------------------------------
//
//	Design		:	tb_WB2BYTEOUT
//
//	File name	:	tb_WB2BYTEOUT.v
//
//	Purpose		:	test bench for WB2BYTEOUT, a wishbone
//				client device, 8 bits output
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
//							work with WB2BYTEOUT v1.1
//
//--------------------------------------------------------------------

`timescale 1ns/10ps

module tb_WB2BYTEOUT;

reg	CLK,
	RSTN;

reg	STB_O;
reg	WE_O;
reg	[ 7 : 0]	DAT_O;
wire	[ 7 : 0]	DAT_I;
wire	ACK_I;

wire	[ 7 : 0]	S;

// 10MHz, Clock period is 100ns.
always #50 CLK = ~ CLK;

WB2BYTEOUT
	INST_B
	(
	.CLK_I		(CLK),
	.RSTN_I		(RSTN),
	
	// Wishbone
	.STB_I		(STB_O),
	.WE_I		(WE_O),
	.DAT_I		(DAT_O),
	.DAT_O		(DAT_I),
	.ACK_O		(ACK_I),
	
	// peripheral IO
	.S		(S)
	
);

initial begin
	CLK	= 1'b0;		// initial values
	RSTN	= 1'b1;
	STB_O	= 1'b0;
	WE_O	= 1'b0;
	DAT_O	= 8'h00;
	
#520	RSTN	= 1'b0;		// reset.
#500	RSTN	= 1'b1;		// avoid clock edges.

#200
	$display(
		"%12.4f  %s!\tAfter reset : S %b, W %b, ACK %b", $time,
		((S === 8'h00) && (INST_B.W_STAT === INST_B.W_IDLE) &&
		 (ACK_I === 1'b0)
		) ?
		"Ok" : "Fail",
		S, INST_B.W_STAT, ACK_I);

#300	// read request
	STB_O	= 1'b1;
	DAT_O	= 8'h3F;
	WE_O	= 1'b0;
	$display("%12.4f\t \tRead Request.", $time);

#100
	$display(
		"%12.4f  %s!\tAck to read reqest : S %b, W %b, ACK %b", $time,
		((S === 8'h00) && (INST_B.W_STAT === INST_B.W_ACK) &&
		 (ACK_I === 1'b1)
		) ?
		"Ok" : "Fail",
		S, INST_B.W_STAT, ACK_I);

#100	// write request
	WE_O	= 1'b1;
	$display(
		"%12.4f  %s!\tReturn to IDLE : S %b, W %b, ACK %b", $time,
		((S === 8'h00) && (INST_B.W_STAT === INST_B.W_IDLE) &&
		 (ACK_I === 1'b0)
		) ?
		"Ok" : "Fail",
		S, INST_B.W_STAT, ACK_I);
	$display("%12.4f\t \tWrite Request.", $time);

// ref : S. Vijayaraghavan, etc. A Practical Guide for SystemVerilog Assertions, Springer 2005.
	repeat (1) @(posedge CLK);
	fork: STB_WE_to_ACK
	begin
	@(posedge ACK_I)
	$display(
		"%12.4f  Great!\tAck detected.", $time);
	disable STB_WE_to_ACK;
	end
	begin
	repeat (3) @(posedge CLK);
	$display(
		"%12.4f  Error!\tAck not detected so far.", $time);
	disable STB_WE_to_ACK;
	end
	join
	#70;

#100	// finish simple read and write tests.
	STB_O	= 1'b0;
	WE_O	= 1'b0;
	$display(
		"%12.4f  %s!\tReturn to IDLE : S %b, W %b, ACK %b", $time,
		((S === 8'h3f) && (INST_B.W_STAT === INST_B.W_IDLE) &&
		 (ACK_I === 1'b0)
		) ?
		"Ok" : "Fail",
		S, INST_B.W_STAT, ACK_I);
	
#500	$finish ;

end

// dump wave
initial begin            
    $dumpfile("sim/WB2BYTEOUT.vcd");
    $dumpvars(0, tb_WB2BYTEOUT);
end

endmodule
