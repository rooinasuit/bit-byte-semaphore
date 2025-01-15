`include "sem_mem_connector.sv"

module sema(

 input logic clk_s,
 input logic rstn_s,

 output logic sema_valid_i_s_A,
 output logic sema_data_i_s_A,
 output logic sema_is_empty_i_s_A,

 output logic sema_valid_i_s_B,
 output logic sema_data_i_s_B,
 output logic sema_is_empty_i_s_B,

 input logic sema_ready_o_s_A,
 input logic sema_write_o_s_A,
 input logic sema_data_o_s_A,

 input logic sema_ready_o_s_B,
 input logic sema_write_o_s_B,
 input logic sema_data_o_s_B);

//============================================================================
//******************************** SIMULATION ********************************
//============================================================================

  logic wire_wr_A;
  logic wire_wr_B; 
  assign wire_wr_A = sema_write_o_s_A;
  assign wire_wr_B = ~sema_write_o_s_A & sema_write_o_s_B;

  sem_mem_connector connector_cpuA_2_cpuB(
    .sema_write_o_s(wire_wr_A),
    .sema_data_o_s(sema_data_o_s_A),
    .sema_is_empty_i_s(sema_is_empty_i_s_A),
    .sema_valid_i_s(sema_valid_i_s_B),
    .sema_data_i_s(sema_data_i_s_B),
    .sema_ready_o_s(sema_ready_o_s_B)
  );

  sem_mem_connector connector_cpuB_2_cpuA(
    .sema_write_o_s(wire_wr_B),
    .sema_data_o_s(sema_data_o_s_B),
    .sema_is_empty_i_s(sema_is_empty_i_s_B),
    .sema_valid_i_s(sema_valid_i_s_A),
    .sema_data_i_s(sema_data_i_s_A),
    .sema_ready_o_s(sema_ready_o_s_A)
  );

endmodule





