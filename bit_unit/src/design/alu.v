//////////////////////////////////////////////////
//  Projekt: CPU 1 bit PBL
//  Jednoskta: ALU
//
//
//////////////////////////////////////////////////

`include "definy.v"

module block_alu #(parameter DATA_WIDTH = `DATA_WIDTH)(
input rst,
input clk,
input [DATA_WIDTH-1:0] data_in,
input wr_cr,
input [3:0] alu_op,
output reg [DATA_WIDTH-1:0] data_out,
output reg zero_flag

,output [1:0] CR

);

reg [DATA_WIDTH-1:0] current_result = 0;

assign CR = current_result;

always @(*) begin
    case (alu_op)
      `LD   : data_out  <= data_in;
      `LDN  : data_out  <= ~data_in;
      `AND  : data_out  <= current_result & data_in;
      `OR   : data_out  <= current_result | data_in;
      `XOR  : data_out  <= current_result ^ data_in;
      `NOT  : data_out  <= ~data_in;
      
      `ST   : data_out  <= current_result;
      `STN  : data_out  <= ~current_result;

      default : data_out <= data_in;
    endcase 
end



always @(posedge clk or negedge rst) begin
  if(!rst) begin
    current_result <= 0;
    data_out <= 0;
   end
  else if (wr_cr) begin
    $display("cr val set to: %0.d",data_out);
    current_result <= data_out;
  end
end

assign zero_flag = ~|current_result;

endmodule