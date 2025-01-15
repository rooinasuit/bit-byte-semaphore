//////////////////////////////////////////////////
//  Projekt: CPU 1 bit PBL
//  Jednoskta: Licznik rozkazów
//
//
//////////////////////////////////////////////////

`include "definy.v"


module program_counter #(parameter WIDTH = `INSTR_WORD_WIDTH)(
input clk,
input WE,
input EN,
input rst,
input [WIDTH-1:0] data_in,
output reg [WIDTH-1:0] data_out
);

always @(posedge clk or negedge rst) begin
  if (rst) data_out <= 0;
  else begin
    if (WE) data_out <= data_in;
    else if (EN) data_out <= data_out + 1;
  end
end


endmodule