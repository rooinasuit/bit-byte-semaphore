//////////////////////////////////////////////////
//  Projekt: CPU 1 bit PBL
//  Jednoskta: controller
//
//
//////////////////////////////////////////////////

`include "definy.v"

module controller #(parameter ADDRESS_WIDTH = `INSTR_WORD_WIDTH, parameter DATA_WIDTH = `DATA_WIDTH, parameter INSTR_WORD_WIDTH = `INSTR_WORD_WIDTH, parameter OPCODE_WIDTH = `OPCODE_WIDTH)(
input rst,
input clk,

input [ADDRESS_WIDTH-1:0] pc_in,
output reg [ADDRESS_WIDTH-1:0] pc_out,
output reg pc_ce,
output reg pc_wr,

input [INSTR_WORD_WIDTH-1:0] pm_data_in,
output reg [ADDRESS_WIDTH-1:0] pm_addr,

input [DATA_WIDTH-1:0] dm_data_in,
output reg [DATA_WIDTH-1:0] dm_data_out,
output reg [ADDRESS_WIDTH-1:0] dm_addr_out, 
output reg dm_wr,

input [DATA_WIDTH-1:0] reg_data_in,
output reg [DATA_WIDTH-1:0] reg_data_out,
output reg [1:0] register_addr_out,
output reg wr_reg,

input [DATA_WIDTH-1:0] alu_data_in,
output reg [DATA_WIDTH-1:0] alu_data_out,
output reg [INSTR_WORD_WIDTH-1:OPCODE_WIDTH] alu_op,
output reg wr_cr,
input alu_zero_flag,

input [DATA_WIDTH-1:0] sem_data_in,
input sem_data_valid_in,
output reg sem_data_read,

output reg [DATA_WIDTH-1:0] sem_data_out,
output reg sem_data_valid_out,
input sem_data_empty,
);

wire [INSTR_WORD_WIDTH-1:OPCODE_WIDTH] opcode;
assign opcode = pm_data_in [INSTR_WORD_WIDTH-1:OPCODE_WIDTH];


wire [1:0] data_src;
assign data_src = pm_data_in [INSTR_WORD_WIDTH-OPCODE_WIDTH-1:INSTR_WORD_WIDTH-OPCODE_WIDTH-2];

reg [3:0] state;
reg [INSTR_WORD_WIDTH-1:0] pc_mem_val;

always @(posedge clk or negedge rst) begin
  if(!rst) begin
    reset;
  end
  else begin
    reset_signals;
    if (state == `init) begin
      case (opcode)
        `NOP : i_NOP;
        `LD  : i_get_data_0; 
        `LDN : i_get_data_0;
        `AND : i_get_data_0;
        `OR  : i_get_data_0;
        `XOR : i_get_data_0;
        `NOT : i_get_data_0;
        
        `ST  : i_set_data_0;
        `STN : i_set_data_0;
        
        `JMP : i_JMP_0;
        `JMA : i_JMA_0;
        `RET : i_RET_0;
  
        default : i_OP_end;
      endcase 
    end
    else begin
      case (state)
        `i_get_sem_0 : i_get_sem_0;
        `i_get_mem_1 : i_get_mem_1;
        `i_set_sem_0 : i_set_sem_0;
        `i_JMP_1     : i_JMP_1;
        `i_set_mem_1 : i_set_mem_1;
        default : i_OP_end;
      endcase
    end
  end
end


`include "controller_taski.v"



endmodule