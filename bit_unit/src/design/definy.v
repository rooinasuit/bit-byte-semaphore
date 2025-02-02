//////////////////////////////////////////////////
//  Projekt: CPU 1 bit PBL
//  Jednoskta: Defines list
//
//
//////////////////////////////////////////////////

`define ADDRESS_WIDTH 8
`define DATA_WIDTH 1
`define INSTR_WORD_WIDTH 8
`define OPCODE_WIDTH 4
`define EXT_REGS_No 2
`define INT_REGS_No 2

`define LD   4'h0 //Load simple [OP + source (I/M/S/R(0-3))] if "I" variable after "I" e.g. {`LD, `I, 1'b1}. If M put data mem addr in next memory cell.
`define LDN  4'h1 //Load negated (like above)
`define AND  4'h2 //AND - ACC with [OP + source (I/M/S/R(0-3))] if "I" variable after "I" e.g. {`LD, `I, 1'b1}. If M put data mem addr in next memory cell.
`define OR   4'h3 //OR (like above)
`define XOR  4'h4 //XOR (like above)
`define NOT  4'h5 //NOT (like above)
`define ST   4'h6 //Store simple value [OP + destination (M/S/R(0-1)] if "I" variable after "I" e.g. {`ST, R0}. If M put data mem addr in next memory cell.
`define STN  4'h7 //Store negated value (like above)

//`define JMP  4'h8 //Jump, put addr val in next program memory cell
//`define JMA  4'h9 //Jump if accu == true, put addr val in next program memory cell
//`define RET  4'hA //Return at prev addr + 1
//
//`define NOP  4'hF //Empty, do nothing

`ifdef USE_INSTRUCTIONS
  `define JMP  8'h80 //Jump, put addr val in next program memory cell
  `define JMA  8'h90 //Jump if accu == true, put addr val in next program memory cell
  `define RET  8'hA0 //Return at prev addr + 1
  `define NOP  8'hF0 //Empty, do nothing
`else
  `define JMP  4'h8 //Jump, put addr val in next program memory cell
  `define JMA  4'h9 //Jump if accu == true, put addr val in next program memory cell
  `define RET  4'hA //Return at prev addr + 1
  `define NOP  4'hF //Empty, do nothing
`endif



`define I  3'b000
`define M  4'b1000
`define S  4'b1100

`define R0 4'b0100
`define R1 4'b0101
`define R2 4'b0110
`define R3 4'b0111

//data source:
`define imidiate  2'b00
`define regfile   2'b01
`define data_mem  2'b10
`define semaphore 2'b11


//cpu states:
`define init          4'h0
`define i_get_sem_0   4'h1
`define i_get_mem_1   4'h2
`define i_set_sem_0   4'h3
`define i_JMP_1       4'h4
`define i_set_mem_1   4'h5
`define i_get_mem_2   4'h6
`define i_get_reg_1   4'h7

`define i_OP_end      4'hF






