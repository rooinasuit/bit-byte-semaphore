`include "sem_mem_connector.sv"

module sema(
  // Naming is inherited after CPU
  // The output/input should be INVERTED compared to the 'i'/'o' letters in the sema signals

 input logic clk_s,
 input logic rstn_s,

 input logic sema_write_o_s_A,
 input logic sema_data_o_s_A,
 output logic sema_is_empty_i_s_A,

 input logic sema_write_o_s_B,
 input logic sema_data_o_s_B,
 output logic sema_is_empty_i_s_B,

 output logic sema_data_i_s_A,
 output logic sema_valid_i_s_A,
 input logic sema_ready_o_s_A,

 output logic sema_data_i_s_B,
 output logic sema_valid_i_s_B,
 input logic sema_ready_o_s_B);


  logic wire_wr_A;
  logic wire_wr_B; 
  assign wire_wr_A = sema_write_o_s_A;
  assign wire_wr_B = ~sema_write_o_s_A & sema_write_o_s_B;

  sem_mem_connector connector_cpuA_2_cpuB( // Connector: A->B; Connection A->B
    .clk_s(clk_s),
    .rstn_s(rstn_s),
    .sema_write_o_s_A(wire_wr_A),
    .sema_data_o_s_A(sema_data_o_s_A),
    .sema_is_empty_i_s_A(sema_is_empty_i_s_A),
    .sema_valid_i_s_B(sema_valid_i_s_B),
    .sema_data_i_s_B(sema_data_i_s_B),
    .sema_ready_o_s_B(sema_ready_o_s_B)
  );

  sem_mem_connector connector_cpuB_2_cpuA( // Connector: A->B; Connection B->A
    .clk_s(clk_s),
    .rstn_s(rstn_s),
    .sema_write_o_s_A(wire_wr_B),
    .sema_data_o_s_A(sema_data_o_s_B),
    .sema_is_empty_i_s_A(sema_is_empty_i_s_B),
    .sema_valid_i_s_B(sema_valid_i_s_A),
    .sema_data_i_s_B(sema_data_i_s_A),
    .sema_ready_o_s_B(sema_ready_o_s_A)
  );

endmodule





