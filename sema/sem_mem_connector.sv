`include "DffPIPO_CE_SET.sv"
`include "RSff.sv"

module sem_mem_connector(
    input logic clk_s,
    input logic rstn_s,

    output logic sema_valid_i_s,
    output logic sema_data_i_s,
    input logic sema_ready_o_s,

    output logic sema_is_empty_i_s,
    input logic sema_write_o_s,
    input logic sema_data_o_s);

    wire wire_is_empty;

    DffPIPO_CE_SET #(.SIZE(1)) Dff1  (
        .CE(sema_write_o_s),
        .D(sema_data_o_s),
        .clk(clk_s),
        .nReset(rstn_s),

        .out(sema_data_i_s)
    );

    RSff RSff1(
        .set(sema_write_o_s),
        .reset(sema_ready_o_s & rstn_s),
        .clk(clk_s),
        .out(wire_is_empty)
    );


    assign sema_is_empty_i_s = ~wire_is_empty;
endmodule