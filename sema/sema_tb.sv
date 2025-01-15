/* WHAT IS THIS? 
 This is a Testbench that tests all modules
*/
`define tb_path "tb_files/sema_tb.vcd"

`timescale  1ns/1ps

`include "sema.sv"

module sema_tb;

logic clk_s;
logic rstn_s;



top top1(.clk(clk_tb),.nReset(nReset_tb));

//============================================================================
//******************************** SIMULATION ********************************
//============================================================================

initial begin //clk
forever begin
    #5 clk_tb = ~clk_tb;
end
end

initial begin // start values
clk_tb = 0;
nReset_tb = 0;
#6 nReset_tb = 1;

#1000 $finish;
end

initial begin // file save
    $dumpfile(`tb_path);
    $dumpvars;
    $dumpon;
end


endmodule





