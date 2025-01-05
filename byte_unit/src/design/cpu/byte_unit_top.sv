`timescale 1ns/1ps

`include "instruction_memory.sv"
`include "instruction_fetch.sv"
`include "instruction_decode.sv"
`include "instruction_execute.sv"
`include "data_memory.sv"
`include "memory_access.sv"
`include "register_writeback.sv"


module byte_unit_top (
  input clk,
  input rstn,

  // from bit to byte unit (semaphore memory)
  input  sema_valid_i, // signalling data written from bit to byte unit is valid
  input  sema_data_i, // data from bit to byte unit
  output sema_ready_o, // signalling byte unit is not busy with recent sema operation anymore

  // from byte to bit unit (semaphore memory)
  input  sema_is_empty_i, // signalling, that semaphore memory is empty (ready for another write)
  output sema_write_o, // signalling data is to be written from byte to bit unit
  output sema_data_o // data from byte to bit unit
);

// instruction_fetch
wire [7:0]  if_instruction_address_o;
wire [20:0] imem_instruction_o;
wire        imem_addr_exceeded_o;
wire        imem_end_of_program_o;

// instruction decode
wire [4:0]  id_opcode_o;
wire        id_alu_src_o;
wire        id_mem_branch_o;
wire        id_mem_write_o;
wire        id_mem_read_o;
wire        id_reg_write_o;
wire        id_mem_to_reg_o;
wire        id_sema_read_o;
wire        id_sema_write_o;
wire [3:0]  id_rd_id_o;
wire [15:0] id_rs1_o;
wire [15:0] id_rs2_o;
wire [15:0] id_imm_o;

// instruction execute
wire        ex_phase_done_o;
wire [15:0] ex_alu_result_o;
wire  [7:0] ex_branch_target_address_o;
wire        ex_branch_taken_o;
wire  [3:0] ex_rd_id_o; 
wire        ex_mem_branch_o;
wire        ex_mem_write_o;
wire        ex_mem_read_o;
wire        ex_reg_write_o;
wire        ex_mem_to_reg_o;
wire        ex_sema_read_o;
wire        ex_sema_write_o;
wire  [7:0] ex_mem_addr_o;
wire [15:0] ex_mem_write_data_o;

// memory access
wire        mem_phase_done_o;
wire  [7:0] mem_data_memory_address_o;
wire        mem_data_memory_write_en_o;
wire [15:0] mem_data_memory_write_data_o;
wire        mem_data_memory_read_en_o;
wire [15:0] mem_alu_result_o;
wire [3:0]  mem_rd_id_o;
wire        mem_reg_write_o;
wire        mem_mem_to_reg_o;
wire        mem_take_branch_o;
wire  [7:0] mem_branch_target_address_o;
wire        mem_sema_read_performed_o;
wire        mem_sema_writeback_o;
wire [15:0] dmem_data_memory_read_data_o;

// registers writeback
wire [15:0] wb_regfile_writeback_o;
wire  [3:0] wb_rd_id_o;
wire        wb_reg_write_o;

typedef enum logic [2:0] {IF, ID, EX, MEM, WB} cpu_phase_t;

cpu_phase_t cpu_phase;
// reg [2:0] cpu_state;

reg if_suspend_cpu_i;
reg id_suspend_cpu_i;
reg ex_suspend_cpu_i;
reg mem_suspend_cpu_i;
reg wb_suspend_cpu_i;

always @(posedge clk or negedge rstn) begin
  if (rstn == 1'b0) begin
    cpu_phase <= IF;
    if_suspend_cpu_i <= 1'b0;
    id_suspend_cpu_i <= 1'b1;
    ex_suspend_cpu_i <= 1'b1;
    mem_suspend_cpu_i <= 1'b1;
    wb_suspend_cpu_i <= 1'b1;
  end else if ((imem_end_of_program_o == 1'b0) && (imem_addr_exceeded_o == 1'b0)) begin
    case (cpu_phase)
      IF: begin
        cpu_phase <= ID;
        if_suspend_cpu_i <= 1'b1;
        id_suspend_cpu_i <= 1'b0;
        ex_suspend_cpu_i <= 1'b1;
        mem_suspend_cpu_i <= 1'b1;
        wb_suspend_cpu_i <= 1'b1;
      end
      ID: begin
        cpu_phase <= EX;
        if_suspend_cpu_i <= 1'b1;
        id_suspend_cpu_i <= 1'b1;
        ex_suspend_cpu_i <= 1'b0;
        mem_suspend_cpu_i <= 1'b1;
        wb_suspend_cpu_i <= 1'b1;
      end
      EX: begin
        if (ex_phase_done_o) begin
          cpu_phase <= MEM;
          if_suspend_cpu_i <= 1'b1;
          id_suspend_cpu_i <= 1'b1;
          ex_suspend_cpu_i <= 1'b1;
          mem_suspend_cpu_i <= 1'b0;
          wb_suspend_cpu_i <= 1'b1;
        end
      end
      MEM: begin
        if (mem_phase_done_o) begin
          cpu_phase <= WB;
          if_suspend_cpu_i <= 1'b1;
          id_suspend_cpu_i <= 1'b1;
          ex_suspend_cpu_i <= 1'b1;
          mem_suspend_cpu_i <= 1'b1;
          wb_suspend_cpu_i <= 1'b0;
        end
      end
      WB: begin
        cpu_phase <= IF;
        if_suspend_cpu_i <= 1'b0;
        id_suspend_cpu_i <= 1'b1;
        ex_suspend_cpu_i <= 1'b1;
        mem_suspend_cpu_i <= 1'b1;
        wb_suspend_cpu_i <= 1'b1;
      end
      default: begin
        if_suspend_cpu_i <= 1'b1;
        id_suspend_cpu_i <= 1'b1;
        ex_suspend_cpu_i <= 1'b1;
        mem_suspend_cpu_i <= 1'b1;
        wb_suspend_cpu_i <= 1'b1;
      end
    endcase
  end else begin
    cpu_phase <= IF;
    if_suspend_cpu_i <= 1'b1;
    id_suspend_cpu_i <= 1'b1;
    ex_suspend_cpu_i <= 1'b1;
    mem_suspend_cpu_i <= 1'b1;
    wb_suspend_cpu_i <= 1'b1;
  end
end

instruction_memory instruction_memory_inst (
  // global signals
  .clk (clk),
  .rstn (rstn),
  .suspend_cpu (if_suspend_cpu_i),

  // if/id signals
  .instruction_memory_address (if_instruction_address_o),
  .instruction (imem_instruction_o),
  .instruction_memory_address_exceeded (imem_addr_exceeded_o),
  .instruction_end_of_program (imem_end_of_program_o)

);

instruction_fetch instruction_fetch_inst (
  // global signals
  .clk (clk),
  .rstn (rstn),
  .suspend_cpu (if_suspend_cpu_i),

  // branch signals
  .pc_take_branch (mem_take_branch_o),
  .pc_branch_target (mem_branch_target_address_o),

  // memory addr
  .pc_instruction_address (if_instruction_address_o)
);

instruction_decode instruction_decode_inst (
  // global signals
  .clk (clk),
  .rstn (rstn),
  .suspend_cpu (id_suspend_cpu_i),

  // inputs
  .instruction (imem_instruction_o),
  .wb_regfile_writeback (wb_regfile_writeback_o),
  .wb_reg_write (wb_reg_write_o),
  .wb_rd_id (wb_rd_id_o),
  
  // outputs
  .opcode (id_opcode_o),
  .alu_src (id_alu_src_o),
  .mem_branch (id_mem_branch_o),
  .mem_write (id_mem_write_o),
  .mem_read (id_mem_read_o),
  .reg_write (id_reg_write_o),
  .mem_to_reg (id_mem_to_reg_o),
  .sema_read (id_sema_read_o),
  .sema_write (id_sema_write_o),
  .rd_id (id_rd_id_o),
  .rs1 (id_rs1_o),
  .rs2 (id_rs2_o),
  .imm (id_imm_o)
);

instruction_execute instruction_execute_inst (
  // global signals
  .clk (clk),
  .rstn (rstn),
  .suspend_cpu (ex_suspend_cpu_i),
  .phase_done (ex_phase_done_o),

  // inputs
  .id_opcode (id_opcode_o),
  .id_alu_src (id_alu_src_o),
  .id_mem_branch (id_mem_branch_o),
  .id_mem_write (id_mem_write_o),
  .id_mem_read (id_mem_read_o),
  .id_reg_write (id_reg_write_o),
  .id_mem_to_reg (id_mem_to_reg_o),
  .id_sema_read (id_sema_read_o),
  .id_sema_write (id_sema_write_o),
  .id_rd_id (id_rd_id_o),
  .id_rs1 (id_rs1_o),
  .id_rs2 (id_rs2_o),
  .id_imm (id_imm_o),

  // outputs
  .alu_result (ex_alu_result_o),
  .branch_target_address (ex_branch_target_address_o),
  .branch_taken (ex_branch_taken_o),
  .ex_rd_id (ex_rd_id_o),
  .ex_mem_branch (ex_mem_branch_o),
  .ex_mem_write (ex_mem_write_o),
  .ex_mem_read (ex_mem_read_o),
  .ex_reg_write (ex_reg_write_o),
  .ex_mem_to_reg (ex_mem_to_reg_o),
  .ex_sema_read (ex_sema_read_o),
  .ex_sema_write (ex_sema_write_o),
  .ex_mem_addr (ex_mem_addr_o),
  .ex_mem_write_data (ex_mem_write_data_o)
);

memory_access memory_access_inst (
  // global signals
  .clk (clk),
  .rstn (rstn),
  .suspend_cpu (mem_suspend_cpu_i),
  .phase_done (mem_phase_done_o),

  // inputs
  .ex_alu_result (ex_alu_result_o),
  .ex_branch_target_address (ex_branch_target_address_o),
  .ex_branch_taken (ex_branch_taken_o),
  .ex_rd_id (ex_rd_id_o),
  .ex_mem_branch (ex_mem_branch_o),
  .ex_mem_write (ex_mem_write_o),
  .ex_mem_read (ex_mem_read_o),
  .ex_reg_write (ex_reg_write_o),
  .ex_mem_to_reg (ex_mem_to_reg_o),
  .ex_sema_read (ex_sema_read_o),
  .ex_sema_write (ex_sema_write_o),
  .ex_mem_addr (ex_mem_addr_o),
  .ex_mem_write_data (ex_mem_write_data_o),

  // outputs
  .data_memory_address (mem_data_memory_address_o),
  .data_memory_write_en (mem_data_memory_write_en_o),
  .data_memory_write_data (mem_data_memory_write_data_o),
  .data_memory_read_en (mem_data_memory_read_en_o),
  .mem_alu_result (mem_alu_result_o),
  .mem_rd_id (mem_rd_id_o),
  .mem_reg_write (mem_reg_write_o),
  .mem_mem_to_reg (mem_mem_to_reg_o),
  .mem_take_branch (mem_take_branch_o),
  .mem_branch_target_address (mem_branch_target_address_o),
  .mem_sema_read_performed (mem_sema_read_performed_o),
  .mem_sema_writeback (mem_sema_writeback_o)
);

register_writeback register_writeback_inst (
  // global signals
  .rstn (rstn),
  .suspend_cpu (wb_suspend_cpu_i),

  // inputs
  .mem_alu_result (mem_alu_result_o),
  .mem_rd_id (mem_rd_id_o),
  .mem_reg_write (mem_reg_write_o),
  .mem_mem_to_reg (mem_mem_to_reg_o),
  .mem_sema_read_performed (mem_sema_read_performed_o),
  .mem_sema_writeback (mem_sema_writeback_o),
  .dmem_data_memory_read_data (dmem_data_memory_read_data_o),

  // outputs
  .wb_regfile_writeback (wb_regfile_writeback_o),
  .wb_rd_id (wb_rd_id_o),
  .wb_reg_write (wb_reg_write_o)
);

data_memory data_memory_inst (
  .clk (clk),
  .rstn (rstn),
  .suspend_cpu (mem_suspend_cpu_i),

  .data_memory_address (mem_data_memory_address_o),
  .data_memory_write (mem_data_memory_write_data_o),
  .data_memory_write_en (mem_data_memory_write_en_o),
  .data_memory_read_en (mem_data_memory_read_en_o),

  // outputs
  .data_memory_read (dmem_data_memory_read_data_o)
);

endmodule