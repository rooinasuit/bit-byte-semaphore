module instruction_execute (
  // Global signals
  input  clk,
  input  rstn,
  input  suspend_cpu,
  output phase_done,

  // inputs
  input [4:0] id_opcode,

  input id_alu_src,
  input id_mem_branch,
  input id_mem_write,
  input id_mem_read,
  input id_reg_write,
  input id_mem_to_reg,
  input id_sema_read,
  input id_sema_write,

  input [3:0]  id_rd_id,
  input [15:0] id_rs1,
  input [15:0] id_rs2,
  input [15:0] id_imm,

  // Outputs to memory access phase
  output     [15:0] alu_result,
  output reg  [7:0] branch_target_address,
  output reg        branch_taken,
  output reg  [3:0] ex_rd_id, 
  output reg        ex_mem_branch,
  output reg        ex_mem_write,
  output reg        ex_mem_read,
  output reg        ex_reg_write,
  output reg        ex_mem_to_reg,
  output reg        ex_sema_read,
  output reg        ex_sema_write,
  output reg  [7:0] ex_mem_addr,
  output reg [15:0] ex_mem_write_data
);

localparam ADD = 5'd0;
localparam SUB = 5'd1;
localparam MUL = 5'd2;
localparam DIV = 5'd3;
localparam AND = 5'd4;
localparam OR = 5'd5;
localparam XOR = 5'd6;
localparam NOT = 5'd7;
localparam ADDI = 5'd8;
localparam SUBI = 5'd9;
localparam MULI = 5'd10;
localparam DIVI = 5'd11;
localparam ANDI = 5'd12;
localparam ORI = 5'd13;
localparam XORI = 5'd14;
localparam SHL = 5'd15;
localparam SHR = 5'd16;
localparam SHLI = 5'd17;
localparam SHRI = 5'd18;
localparam BEQ = 5'd19;
localparam BNE = 5'd20;
localparam BGT = 5'd21;
localparam BLT = 5'd22;
localparam CEQ = 5'd23;
localparam CNE = 5'd24;
localparam CGT = 5'd25;
localparam CLT = 5'd26;

wire [15:0] alu_in1;
wire [15:0] alu_in2;
reg [15:0] alu_single_cycle_out;
reg [15:0] alu_multi_cycle_out;

reg comp_result;

assign alu_in1 = id_rs1;
assign alu_in2 = (id_alu_src == 1'b1) ? id_imm : id_rs2;

// arithmetic operations except mul(i)/div(i)
always @(*) begin
  case (id_opcode)
    ADD, ADDI: alu_single_cycle_out = alu_in1 + alu_in2; // ADD or ADDI
    SUB, SUBI: alu_single_cycle_out = alu_in1 - alu_in2; // SUB or SUBI
    AND, ANDI: alu_single_cycle_out = alu_in1 & alu_in2; // AND or ANDI
    OR, ORI: alu_single_cycle_out = alu_in1 | alu_in2; // OR or ORI
    XOR, XORI: alu_single_cycle_out = alu_in1 ^ alu_in2; // XOR or XORI
    NOT: alu_single_cycle_out = ~alu_in1; // NOT
    SHL, SHLI: alu_single_cycle_out = alu_in1 << alu_in2[3:0]; // SHL or SHLI
    SHR, SHRI: alu_single_cycle_out = alu_in1 >> alu_in2[3:0]; // SHR or SHRI
    default:  alu_single_cycle_out = 16'b0;
  endcase
end

always @(*) begin
  case (id_opcode)
    BEQ: branch_taken = (alu_in1 == alu_in2); // BEQ
    BNE: branch_taken = (alu_in1 != alu_in2); // BNE
    BGT: branch_taken = (alu_in1 > alu_in2);  // BGT
    BLT: branch_taken = (alu_in1 < alu_in2);  // BLT
    CEQ: comp_result = (alu_in1 == alu_in2); // CEQ
    CNE: comp_result = (alu_in1 != alu_in2); // CNE
    CGT: comp_result = (alu_in1 > alu_in2);  // CGT
    CLT: comp_result = (alu_in1 < alu_in2);  // CLT
    default: begin
      branch_taken = 1'b0;
      comp_result = 1'b0;
    end
  endcase
end

// Target address calculation for branch
assign branch_target_address = id_imm[7:0]; // Offset calculation for branches

// pass control signals to the next phase
always @(posedge clk or negedge rstn) begin
  if (rstn == 1'b0) begin
    ex_rd_id      <= 4'b0;
    ex_mem_branch <= 1'b0;
    ex_mem_write  <= 1'b0;
    ex_mem_read   <= 1'b0;
    ex_reg_write  <= 1'b0;
    ex_mem_to_reg <= 1'b0;
    ex_sema_read  <= 1'b0;
    ex_sema_write <= 1'b0;
    ex_mem_addr   <= 8'd0;
    ex_mem_write_data <= 16'd0;
  end else if (suspend_cpu == 1'b0) begin
    ex_rd_id      <= id_rd_id;
    ex_mem_branch <= id_mem_branch;
    ex_mem_write  <= id_mem_write;
    ex_mem_read   <= id_mem_read;
    ex_reg_write  <= id_reg_write;
    ex_mem_to_reg <= id_mem_to_reg;
    ex_sema_read  <= id_sema_read;
    ex_sema_write <= id_sema_write;
    ex_mem_addr   <= id_imm[7:0];
    ex_mem_write_data <= (id_opcode == CEQ || id_opcode == CNE ||
                          id_opcode == CGT || id_opcode == CLT) ? {15'd0, comp_result} : id_rs1;
  end
end

reg [15:0] mul_acc;
reg [16:0] div_temp;
reg [15:0] dividend;
reg [15:0] divisor;

reg [4:0] cycle_count;

// States for multiplication and division
typedef enum logic [1:0] {
  IDLE = 2'b00,
  MULT = 2'b01,
  DIVD = 2'b10,
  DONE = 2'b11
} state_t;

state_t multi_cycle_state;

reg multi_cycle_phase_done;

always @(posedge clk or negedge rstn) begin
  if (rstn == 1'b0) begin
    multi_cycle_state <= IDLE;
    mul_acc <= 16'd0;
    div_temp <= 16'd0;
    dividend <= 16'd0;
    divisor <= 16'd0;
    cycle_count <= 5'd0;
    alu_multi_cycle_out <= 16'd0;
    multi_cycle_phase_done <= 1'b0;
  end else if (suspend_cpu == 1'b0) begin
    case (multi_cycle_state)
      IDLE: begin
        cycle_count <= 5'd0;
        alu_multi_cycle_out <= 16'd0;
        multi_cycle_phase_done <= 1'b0;
        if (id_opcode == MUL || id_opcode == MULI) begin
          mul_acc <= 16'd0;
          multi_cycle_state <= MULT;
        end else if (id_opcode == DIV || id_opcode == DIVI) begin
          div_temp <= 16'd0;
          dividend <= alu_in1;
          divisor <= alu_in2;
          multi_cycle_state <= DIVD;
        end
      end
      MULT: begin
        if (cycle_count < 16) begin
          if (alu_in2[cycle_count]) begin
            mul_acc <= mul_acc + (alu_in1 << cycle_count);
          end
          cycle_count <= cycle_count + 1;
        end else begin
          alu_multi_cycle_out <= mul_acc;
          multi_cycle_state <= DONE;
        end
      end
      DIVD: begin
        if (cycle_count < 16) begin
          div_temp = {div_temp[16-2:0],dividend[16-1]};
          dividend[16-1:1] = dividend[16-2:0];
          div_temp = div_temp-divisor;
          if(div_temp[16-1] == 1) begin
            dividend[0] = 0;
            div_temp = div_temp + divisor;
          end else begin
            dividend[0] = 1;
          end
          cycle_count <= cycle_count + 1;
        end else begin
          alu_multi_cycle_out = dividend;
          multi_cycle_state <= DONE;
        end
      end
      DONE: begin
        multi_cycle_phase_done <= 1'b1;
      end
    endcase
  end else begin
    multi_cycle_state <= IDLE;
    multi_cycle_phase_done <= 1'b0;
  end
end

assign alu_result = (id_opcode == MUL || id_opcode == MULI || 
                     id_opcode == DIV || id_opcode == DIVI) ? alu_multi_cycle_out : alu_single_cycle_out;

assign phase_done = (id_opcode == MUL || id_opcode == MULI || 
                     id_opcode == DIV || id_opcode == DIVI) ? multi_cycle_phase_done : 1'b1;

endmodule
