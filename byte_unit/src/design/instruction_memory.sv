module instruction_memory (
  // global signals
  input           clk,
  input           rstn,
  input           suspend_cpu,

  // inputs
  input      [7:0]  instruction_memory_address,

  // outputs
  output reg [20:0] instruction,
  output            instruction_memory_address_exceeded,
  output            instruction_end_of_program
);

localparam ROM_SIZE = 256;

reg [20:0] instruction_memory [0:(ROM_SIZE-1)];

initial begin
  #1ps;
  $readmemb("../src/design/memory_files/instruction_memory/test_instruction.bin", instruction_memory);
  $display("Loaded program into the instruction memory");
end

always @(posedge clk or negedge rstn) begin
  if (rstn == 1'b0) begin
    instruction <= {{16{1'b0}}, 5'b01111}; // NOP
  end else if (suspend_cpu == 1'b0) begin
    instruction <= instruction_memory[instruction_memory_address];
  end else begin
    instruction <= instruction;
  end
end

assign instruction_memory_address_exceeded = (instruction_memory_address > $size(instruction_memory)) ? 1'b1 : 1'b0;
assign instruction_end_of_program = (&instruction) ? 1'b1 : 1'b0;

endmodule