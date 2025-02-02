module register_writeback (
  // global signals
  input rstn,
  input suspend_cpu,

  // inputs
  input [15:0] mem_alu_result,
  input  [3:0] mem_rd_id,
  input        mem_reg_write,
  input        mem_mem_to_reg,
  input        mem_sema_read_performed,
  input        mem_sema_writeback,
  input [15:0] dmem_data_memory_read_data,

  // outputs
  output reg [15:0] wb_regfile_writeback,
  output reg [3:0]  wb_rd_id,
  output reg        wb_reg_write
);

//====================================
// Register File Data Write-Back Block

always @(*) begin
  if (rstn == 1'b0) begin
    wb_reg_write = 1'b0;
    wb_rd_id     = 4'b0;
    wb_regfile_writeback = 16'd0;
  end else if (suspend_cpu == 1'b0) begin
    wb_reg_write = mem_reg_write;
    wb_rd_id = mem_rd_id;
    if (mem_mem_to_reg == 1'b1) begin
      if (mem_sema_read_performed == 1'b1) begin
        wb_regfile_writeback = {15'd0, mem_sema_writeback};
      end else begin
        wb_regfile_writeback = dmem_data_memory_read_data;
      end
    end else begin
      wb_regfile_writeback = mem_alu_result;
    end
  end else begin
    wb_reg_write = 1'b0;
    wb_rd_id     = 4'b0;
    wb_regfile_writeback = 16'd0;
  end
end

endmodule