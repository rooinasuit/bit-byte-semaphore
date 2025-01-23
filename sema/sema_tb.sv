/* WHAT IS THIS? 
 This is a Testbench that tests all modules
*/
`define tb_path "tb_files/sema_tb.vcd"
`define simulationTime #100

`timescale  1ns/1ps


`include "sema.sv"

module sema_tb;

logic tb_clk_s;
logic tb_rstn_s;

logic tb_sema_write_o_s_A;
logic tb_sema_data_o_s_A;
logic tb_sema_is_empty_i_s_A;

logic tb_sema_write_o_s_B;
logic tb_sema_data_o_s_B;
logic tb_sema_is_empty_i_s_B;

logic tb_sema_data_i_s_A;
logic tb_sema_valid_i_s_A;
logic tb_sema_ready_o_s_A;

logic tb_sema_data_i_s_B;
logic tb_sema_valid_i_s_B;
logic tb_sema_ready_o_s_B;


sema sema1(
.clk_s(tb_clk_s),
.rstn_s(tb_rstn_s),

.sema_write_o_s_A(tb_sema_write_o_s_A),         //INPUT   write_AB
.sema_data_o_s_A(tb_sema_data_o_s_A),           //INPUT   write_AB
.sema_is_empty_i_s_A(tb_sema_is_empty_i_s_A),   //output  write_AB

.sema_data_i_s_B(tb_sema_data_i_s_B),           //output  write_AB
.sema_valid_i_s_B(tb_sema_valid_i_s_B),         //output  write_AB
.sema_ready_o_s_B(tb_sema_ready_o_s_B),         //INPUT   write_AB


.sema_write_o_s_B(tb_sema_write_o_s_B),         //INPUT   write_BA
.sema_data_o_s_B(tb_sema_data_o_s_B),           //INPUT   write_BA
.sema_is_empty_i_s_B(tb_sema_is_empty_i_s_B),   //output  write_BA

.sema_data_i_s_A(tb_sema_data_i_s_A),           //output  write_BA
.sema_valid_i_s_A(tb_sema_valid_i_s_A),         //output  write_BA
.sema_ready_o_s_A(tb_sema_ready_o_s_A)         //INPUT   write_BA
);

//============================================================================
//******************************* STATE MACHINE ******************************
//============================================================================

parameter st_AB_0 = 0;
parameter st_AB_1 = 1;
parameter st_AB_2 = 2;
parameter st_AB_3 = 3;
parameter st_AB_4 = 4;
parameter st_AB_5 = 5;

integer state = 100;
// We operate on 3 inputs to affect 3 outputs (6 signals)

always @(posedge tb_clk_s)
case(state) 
    st_AB_0: begin
        tb_sema_data_o_s_A = 1'b1;
        state <= st_AB_1;
    end
    st_AB_1: begin
        tb_sema_write_o_s_A = 1'b1;
        state <= st_AB_2;
    end
    st_AB_2: begin
        
        state <= st_AB_3;
    end
    st_AB_3: begin
        tb_sema_write_o_s_A = 1'b0;
        tb_sema_ready_o_s_B = 1'b1;
        state <= st_AB_4;
    end
    st_AB_4: begin

        state <= st_AB_5;
    end
    st_AB_5: begin
        tb_sema_ready_o_s_B = 1'b0;
        state <= st_AB_0;
    end

    default begin
        tb_sema_write_o_s_A = 1'bx;
        tb_sema_ready_o_s_B = 1'bx;
        tb_sema_data_o_s_A  = 1'bx;
    end
endcase

//============================================================================
//******************************** SIMULATION ********************************
//============================================================================

initial begin
    #20 state = 0;
end











//============================================================================
//***************************** SIMULATION BASICS ****************************
//============================================================================


initial begin //clk
forever begin
    #5 tb_clk_s = ~tb_clk_s;
end
end

initial begin // start values
tb_clk_s = 0;
tb_rstn_s = 0;
#6 tb_rstn_s = 1;

//`simulationTime $finish;
 #200 $finish;
end

initial begin // file save
   
    $dumpfile(`tb_path);
    $dumpvars;
    $dumpon;
end


endmodule





