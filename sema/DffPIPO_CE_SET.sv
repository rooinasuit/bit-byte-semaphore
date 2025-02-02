/* WHAT IS THIS? 
// This module is an D-flip-flop. 
   It can be set to a given value in SET.
   It size/width can be set to the size given in SIZE                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
*/

module DffPIPO_CE_SET #(parameter SET = 0, parameter SIZE = 8)(
    input CE,
    input [SIZE-1:0] D,
    input clk,
    input nReset,

    output reg [SIZE-1:0] out
);

always @(posedge clk ) begin
    if(nReset) begin
        if(CE==1)
            out <= D;
    end
    else 
        out <= SET;
end
endmodule