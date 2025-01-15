//////////////////////////////////////////////////
//  Projekt: CPU 1 bit PBL
//  Jednoskta: program memory
//
//
//////////////////////////////////////////////////

`include "definy.v"

module program_memory #(parameter ADDRESS_WIDTH = `ADDRESS_WIDTH, parameter DATA_WIDTH = `INSTR_WORD_WIDTH)(
input clk,
//input [1:0] mode,
input [ADDRESS_WIDTH-1:0] address,
//input [DATA_WIDTH-1:0] data_in,
output reg [DATA_WIDTH-1:0] data_out,
);
reg [DATA_WIDTH-1:0] mem [2**ADDRESS_WIDTH];

always @(*) begin                
//  if (mode == `MODE_PROG_PM) begin
//      mem[address] <= data_in;
//
//    end
//  else if (mode == `MODE_RUN) begin
      data_out <= mem[address];

   // end
end

endmodule