//////////////////////////////////////////////////
//  Projekt: CPU 1 bit PBL
//  Jednoskta: data memory
//
//
//////////////////////////////////////////////////

`include "definy.v"

module data_memory #(parameter ADDRESS_WIDTH = `INSTR_WORD_WIDTH, parameter DATA_WIDTH = `DATA_WIDTH)(
input clk,
input wr,
input [ADDRESS_WIDTH-1:0] address,
input [DATA_WIDTH-1:0] data_in,
output reg [DATA_WIDTH-1:0] data_out
);
reg [DATA_WIDTH-1:0] mem [2**ADDRESS_WIDTH];

always @(*) data_out <= mem[address];

//always @(posedge clk) if(wr) mem[address] <= data_in;
always @(posedge clk) if(wr) mem[address] = data_in;


reg [DATA_WIDTH-1:0] dm_data [] =  
`include "../memory_files/data_mem_file.v";
initial begin
  foreach (dm_data[i]) begin
    mem[i] = dm_data[i];
  end
  $display("Data memory initialized");
end


endmodule