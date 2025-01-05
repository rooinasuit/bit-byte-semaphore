`timescale 1ns/1ps

`include "byte_unit_top.sv"

module byte_unit_tb ();

logic clk_s;
logic rstn_s;

logic sema_valid_i_s;
logic sema_data_i_s;
logic sema_ready_o_s;

logic sema_is_empty_i_s;
logic sema_write_o_s;
logic sema_data_o_s;

byte_unit_top byte_unit_top_inst (
  // global signals
  .clk (clk_s),
  .rstn (rstn_s),

  // bit->byte semaphore signals
  .sema_valid_i (sema_valid_i_s),
  .sema_data_i (sema_data_i_s),
  .sema_ready_o (sema_ready_o_s),

  // byte->bit semaphore signals
  .sema_is_empty_i (sema_is_empty_i_s),
  .sema_write_o (sema_write_o_s),
  .sema_data_o (sema_data_o_s)
);

initial begin
  rstn_s = 0;
  #130ns;
  rstn_s = 1;
end

initial begin
  clk_s = 0;
  repeat(200) begin
    #50ns clk_s = !clk_s;
  end
  // forever #50ns clk_s = !clk_s;
end

endmodule