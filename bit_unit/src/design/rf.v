//////////////////////////////////////////////////
//  Projekt: CPU 1 bit PBL
//  Jednoskta: registers
//
//
//////////////////////////////////////////////////

`include "definy.v"

module register_file #(parameter EXT_REGS_No = `EXT_REGS_No, parameter INT_REGS_No = `INT_REGS_No, parameter DATA_WIDTH = `DATA_WIDTH)(
input clk,
input rst,
input [1:0] register_addr, //TODO constant foo call with calculated bitwise of addr signal
//input [3:0] int_register_addr, //TODO constant foo call with calculated bitwise of addr signal
input wr,
input [DATA_WIDTH-1:0] ext_registers_in [EXT_REGS_No-1:0],    //ext in
input [DATA_WIDTH-1:0] int_register_in,

output reg [DATA_WIDTH-1:0] int_registers_out [INT_REGS_No-1:0],  // ext out
output reg [DATA_WIDTH-1:0] registers_out
//output reg [DATA_WIDTH-1:0] int_register_out,

);

//wire [1:0] addr;
//assign addr = register_addr [1:0];

assign int_registers_out = int_register_mem;

reg [DATA_WIDTH-1:0] ext_register_mem [EXT_REGS_No-1:0];
reg [DATA_WIDTH-1:0] int_register_mem [INT_REGS_No-1:0];

always @(*) begin
  if (register_addr[1]) registers_out <= ext_register_mem [register_addr[0]];
  else registers_out <= int_register_mem [register_addr[0]];
end

int i;
always @(posedge clk or negedge rst) begin
  if(!rst) begin
    for (i = 0; i < EXT_REGS_No; i = i + 1) ext_register_mem[i] <= {DATA_WIDTH{1'b0}};
    for (i = 0; i < INT_REGS_No; i = i + 1) int_register_mem[i] <= {DATA_WIDTH{1'b0}};
  end
  else begin
    ext_register_mem <= ext_registers_in;
    if(wr) int_register_mem [register_addr[0]] <= int_register_in;
  end
end


endmodule