//////////////////////////////////////////////////
//  Projekt: CPU 1 bit PBL
//  Jednoskta: top module cpu
//
//
//////////////////////////////////////////////////

`include "definy.v"

module cpu #(
parameter ADDRESS_WIDTH = `ADDRESS_WIDTH, 
parameter DATA_WIDTH = `DATA_WIDTH, 
parameter INSTR_WORD_WIDTH = `INSTR_WORD_WIDTH,
parameter OPCODE_WIDTH = `OPCODE_WIDTH
)(
input clk,
input rst,

input [DATA_WIDTH-1:0] ext_registers_in [`EXT_REGS_No],
output reg [DATA_WIDTH-1:0] int_registers_out [`INT_REGS_No], 

input [DATA_WIDTH-1:0] sem_data_in,
input sem_data_valid_in,
output reg sem_data_read,

output reg [DATA_WIDTH-1:0] sem_data_out,
output reg sem_data_valid_out,
input sem_data_empty,

output reg [3:0] state
);

wire [ADDRESS_WIDTH-1:0] pc_in;
wire [ADDRESS_WIDTH-1:0] pc_out;
wire pc_ce;
wire pc_wr;

wire [INSTR_WORD_WIDTH-1:0] pm_data_in;
wire [ADDRESS_WIDTH-1:0] pm_addr;

wire [DATA_WIDTH-1:0] dm_data_in;
wire [DATA_WIDTH-1:0] dm_data_out;
wire [ADDRESS_WIDTH-1:0] dm_addr_out; 
wire dm_wr;

wire [DATA_WIDTH-1:0] reg_data_in;
wire [DATA_WIDTH-1:0] reg_data_out;
wire [1:0] register_addr_out;
wire wr_reg;

wire [DATA_WIDTH-1:0] alu_data_in;
wire [DATA_WIDTH-1:0] alu_data_out;
wire [INSTR_WORD_WIDTH-1:OPCODE_WIDTH] alu_op;
wire wr_cr;
wire alu_zero_flag;


controller #() ctrl_inst(
.rst(rst),
.clk(clk),

.pc_in(pc_in),
.pc_out(pc_out),
.pc_ce(pc_ce),
.pc_wr(pc_wr),

.pm_data_in(pm_data_in),
.pm_addr(pm_addr),

.dm_data_in(dm_data_in),
.dm_data_out(dm_data_out),
.dm_addr_out(dm_addr_out), 
.dm_wr(dm_wr),

.reg_data_in(reg_data_in),
.reg_data_out(reg_data_out),
.register_addr_out(register_addr_out),
.wr_reg(wr_reg),

.alu_data_in(alu_data_in),
.alu_data_out(alu_data_out),
.alu_op(alu_op),
.wr_cr(wr_cr),
.alu_zero_flag(alu_zero_flag),

.sem_data_in(sem_data_in),
.sem_data_valid_in(sem_data_valid_in),
.sem_data_read(sem_data_read),

.sem_data_out(sem_data_out),
.sem_data_valid_out(sem_data_valid_out),
.sem_data_empty(sem_data_empty),

.cs(state)
);


program_counter #() pc_inst (
.clk(clk),
.WE(pc_wr),
.EN(pc_ce),
.rst(rst),
.data_in(pc_out),
.data_out(pc_in)
);


block_alu #() alu_inst(
.rst(rst),
.clk(clk),
.data_in(alu_data_out),
.wr_cr(wr_cr),
.alu_op(alu_op),
.data_out(alu_data_in),
.zero_flag(alu_zero_flag)

,.CR()

);

register_file #() rf_inst(
.clk(clk),
.register_addr(register_addr_out),
.rst(rst),
.wr(wr_reg),
.int_register_in(reg_data_out),
.registers_out(reg_data_in),

.ext_registers_in(ext_registers_in), 
.int_registers_out(int_registers_out)
);

program_memory #() pm_inst(
.clk(clk),
//.mode(),
.address(pm_addr),
//.data_in(),
.data_out(pm_data_in)
);


data_memory #() dm_inst(
.clk(clk),
.wr(dm_wr),
.address(dm_addr_out),
.data_in(dm_data_out),
.data_out(dm_data_in)
);

endmodule