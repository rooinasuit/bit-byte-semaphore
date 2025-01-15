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

`define LD   4'h0
`define LDN  4'h1
`define AND  4'h2
`define OR   4'h3
`define XOR  4'h4
`define NOT  4'h5
`define ST   4'h6
`define STN  4'h7

`define JMP  4'h8
`define JMA  4'h9
`define RET  4'hA

`define NOP  4'hF



//data source:
`define instant   2'b00
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






