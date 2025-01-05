module instruction_fetch (
  // global signals
  input clk,
  input rstn,

  // phase-specific control
  input suspend_cpu,

  // branch control signals
  input       pc_take_branch,   // Asserted to indicate branch should be taken
  input [7:0] pc_branch_target, // Branch target address

  // IO to instruction memory
  output [7:0] pc_instruction_address
);

// Internal registers
reg [7:0] pc;

always @(posedge clk or negedge rstn) begin
  if (rstn == 1'b0) begin
    pc <= 8'd0;
  end else if (pc_take_branch == 1'b1) begin
    // Update PC with branch target when branch is taken
    pc <= pc_branch_target;
  end else if (suspend_cpu == 1'b0) begin
    // Normal PC increment
    pc <= pc + 8'd1;
  end
end

assign pc_instruction_address = pc;

endmodule