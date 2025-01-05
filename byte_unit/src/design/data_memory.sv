module data_memory (
  // global signals
  input           clk,
  input           rstn,
  input           suspend_cpu,

  // cpu signals
  input      [7:0]  data_memory_address,
  input      [15:0] data_memory_write,
  input             data_memory_write_en,
  input             data_memory_read_en,
  output reg [15:0] data_memory_read
);

localparam RAM_SIZE = 256;

reg [15:0] data_memory [0:(RAM_SIZE-1)];

initial begin
  #1ps;
  $readmemb("../src/design/memory_files/data_memory/test_data.hex", data_memory);
  $display("Loaded initial data into the data memory");
end

// Write operation
always @(posedge clk or negedge rstn) begin
  if (rstn == 1'b0) begin
    data_memory_read <= 32'd0;
  end else if (suspend_cpu == 1'b0) begin
    // write access
    if ((data_memory_write_en == 1'b1) && (data_memory_read_en == 1'b0)) begin
      data_memory[data_memory_address] <= data_memory_write;
    end

    // read access
    if ((data_memory_read_en == 1'b1) && (data_memory_write_en == 1'b0)) begin
      data_memory_read <= data_memory[data_memory_address];
    end
  end
end

endmodule