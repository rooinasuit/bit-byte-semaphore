/* WHAT IS THIS? 
// This module is a synchronous RS-flip-flop.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
*/


module RSff(
    input logic set,
    input logic reset,
    input logic clk,
    
    output logic out);

    always @(posedge clk) begin
        if(reset)
            out = 1'b0;
        else begin
            if(set)
                out = 1'b1;
            else
                out = out;
        end 
    end
endmodule