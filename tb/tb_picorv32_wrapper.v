/*
 * @Design: tb_picorv32_wrapper
 * @Author: Zhao Siwei
 * @Email:  cheems@foxmail.com
 * @Description: Testbench of picorv32_wrapper
 */
`timescale 1ns/10ps

module tb_picorv32_wrapper;

// Parameters
parameter PERIOD  = 10;

// Inputs & Outputs
reg           i_clk   = 1;
reg           i_rst_n = 0;
wire          o_trap;
wire          o_trace_valid;
wire  [35:0]  o_trace_data;
// Inout
wire  [7:0 ]  o_iobuf;

// clk & rst
initial forever #(PERIOD/2) i_clk = ~i_clk;
initial         #(PERIOD*2) i_rst_n = 1;

picorv32_wrapper  u_picorv32_wrapper (
    .i_clk                   ( i_clk                 ),
    .i_rst_n                 ( i_rst_n               ),
    .o_trap                  ( o_trap                ),
    .o_trace_valid           ( o_trace_valid         ),
    .o_trace_data            ( o_trace_data   [35:0] ),

    .o_iobuf                 ( o_iobuf        [7:0]  )
);

initial begin
    $readmemh("/home/chms/Workbench/Verilog/picorv32_soc/software/obj/firmware1.verilog", u_picorv32_wrapper.u_wb_interconnect.u_wb2sram32.sram16kx8a.inst.mem);
    $readmemh("/home/chms/Workbench/Verilog/picorv32_soc/software/obj/firmware2.verilog", u_picorv32_wrapper.u_wb_interconnect.u_wb2sram32.sram16kx8b.inst.mem);
    $readmemh("/home/chms/Workbench/Verilog/picorv32_soc/software/obj/firmware3.verilog", u_picorv32_wrapper.u_wb_interconnect.u_wb2sram32.sram16kx8c.inst.mem);
    $readmemh("/home/chms/Workbench/Verilog/picorv32_soc/software/obj/firmware4.verilog", u_picorv32_wrapper.u_wb_interconnect.u_wb2sram32.sram16kx8d.inst.mem);
    // $readmemh("/home/chms/Workbench/Verilog/picorv32_soc/software/test_ram.verilog", u_picorv32_wrapper.u_wb_ram.mem);
    #(100000*PERIOD) $finish;
end

// dump wave
initial begin            
    $dumpfile("sim/picorv32_wrapper.vcd");
    $dumpvars(0, tb_picorv32_wrapper);
end

endmodule