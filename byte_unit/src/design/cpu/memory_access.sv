module memory_access (
  // global signals
  input clk,
  input rstn,
  input suspend_cpu,
  output phase_done,

  // sema inputs
  input sema_valid,
  input sema_data_in,
  input sema_is_empty,

  // sema outputs
  output reg sema_ready,
  output reg sema_write,
  output reg sema_data_out,

  // inputs
  input [15:0] ex_alu_result,
  input  [7:0] ex_branch_target_address,
  input        ex_branch_taken,
  input  [3:0] ex_rd_id,
  input        ex_mem_branch,
  input        ex_mem_write,
  input        ex_mem_read,
  input        ex_reg_write,
  input        ex_mem_to_reg,
  input        ex_sema_read,
  input        ex_sema_write,
  input  [7:0] ex_mem_addr,
  input [15:0] ex_mem_write_data,

  // input  [15:0] data_memory_read_data, // to writeback

  // outputs to data memory
  output  [7:0] data_memory_address,
  output        data_memory_write_en,
  output [15:0] data_memory_write_data,
  output        data_memory_read_en,

  // outputs
  output reg [15:0] mem_alu_result,
  output reg  [3:0] mem_rd_id,
  output reg        mem_reg_write,
  output reg        mem_mem_to_reg,
  output            mem_take_branch,
  output      [7:0] mem_branch_target_address,

  output reg mem_sema_read_performed,
  output reg mem_sema_writeback
);

assign data_memory_address = ex_mem_addr;
assign data_memory_write_en = ex_mem_write;
assign data_memory_read_en = ex_mem_read;
assign data_memory_write_data = ex_mem_write_data;

assign mem_take_branch = ((ex_branch_taken == 1'b1) & (ex_mem_branch == 1'b1)) ? 1'b1 : 1'b0;
assign mem_branch_target_address = ex_branch_target_address;

reg sema_phase_done;

always @(posedge clk or negedge rstn) begin
  if (rstn == 1'b0) begin
    sema_data_out <= 1'b0;
    sema_write <= 1'b0;
    sema_ready <= 1'b0;
    sema_phase_done <= 1'b0;
  end else if (suspend_cpu == 1'b0) begin
    if (ex_sema_write == 1'b1 && sema_is_empty == 1'b1) begin
      sema_data_out <= ex_mem_write_data[0];
      sema_write    <= 1'b1;
      sema_phase_done    <= 1'b1;
    end
    if (ex_sema_read == 1'b1 && sema_valid == 1'b1) begin
      mem_sema_read_performed <= ex_sema_read;
      mem_sema_writeback <= sema_data_in;
      sema_ready     <= 1'b1;
      sema_phase_done     <= 1'b1;
    end
  end else begin
    mem_sema_read_performed <= 1'b0;
    mem_sema_writeback <= 1'b0;
    sema_ready <= 1'b0;
    sema_write <= 1'b0;
    sema_phase_done <= 1'b0;
  end
end

always @(posedge clk or negedge rstn) begin
  if (rstn == 1'b0) begin
    mem_alu_result <= 1'b0;
    mem_rd_id      <= 1'b0;
    mem_reg_write  <= 1'b0;
    mem_mem_to_reg <= 1'b0;
  end else if (suspend_cpu == 1'b0) begin
    mem_alu_result <= ex_alu_result;
    mem_rd_id      <= ex_rd_id;
    mem_reg_write  <= ex_reg_write;
    mem_mem_to_reg <= ex_mem_to_reg;
  end
end

assign phase_done = (ex_sema_read == 1'b1 || ex_sema_write == 1'b1) ? sema_phase_done : 1'b1;

endmodule