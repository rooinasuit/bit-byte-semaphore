module instruction_decode (
  // global signals
  input clk,
  input rstn,

  // phase-specific control
  input suspend_cpu,

  // inputs
  input [20:0] instruction,
  input [15:0] wb_regfile_writeback, // value to write into reg from wb phase
  input  [3:0] wb_rd_id, // rd_id from wb phase
  input        wb_reg_write, // reg_write signal from wb phase


  // outputs
  output [4:0] opcode,

  output reg alu_src,
  output reg mem_branch,
  output reg mem_write,
  output reg mem_read,
  output reg reg_write,
  output reg mem_to_reg,
  output reg sema_read,
  output reg sema_write,

  output [3:0] rd_id,
  output reg [15:0] rs1,
  output reg [15:0] rs2,
  output reg [15:0] imm
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
localparam LD = 5'd27;
localparam ST = 5'd28;
localparam SEMA_RD = 5'd29;
localparam SEMA_WR = 5'd30;
localparam JALR = 5'd31;

wire [3:0] rs1_id;
wire [3:0] rs2_id;

reg [15:0] regfile [15:0];

wire [7:0] i_imm;
wire [7:0] b_imm;
wire [7:0] mem_imm;

assign opcode = instruction[4:0];

always @(posedge clk or negedge rstn) begin
  if (rstn == 1'b0) begin
    alu_src <= 1'b0;
    mem_branch <= 1'b0;
    mem_write <= 1'b0;
    mem_read <= 1'b0;
    reg_write <= 1'b0;
    mem_to_reg <= 1'b0;
    sema_read <= 1'b0;
    sema_write <= 1'b0;
  end else if (suspend_cpu == 1'b0) begin
    case (opcode)
      ADD, SUB, MUL, DIV, AND, OR, XOR, NOT, SHL, SHR: begin
        alu_src <= 1'b0;
        mem_branch <= 1'b0;
        mem_write <= 1'b0;
        mem_read <= 1'b0;
        reg_write <= 1'b1;
        mem_to_reg <= 1'b0;
        sema_read <= 1'b0;
        sema_write <= 1'b0;
      end
      ADDI, SUBI, MULI, DIVI, ANDI, ORI, XORI, SHLI, SHRI: begin
        alu_src <= 1'b1;
        mem_branch <= 1'b0;
        mem_write <= 1'b0;
        mem_read <= 1'b0;
        reg_write <= 1'b1;
        mem_to_reg <= 1'b0;
        sema_read <= 1'b0;
        sema_write <= 1'b0;
      end
      BEQ, BNE, BGT, BLT: begin
        alu_src <= 1'b0;
        mem_branch <= 1'b1;
        mem_write <= 1'b0;
        mem_read <= 1'b0;
        reg_write <= 1'b0;
        mem_to_reg <= 1'b0;
        sema_read <= 1'b0;
        sema_write <= 1'b0;
      end
      CEQ, CNE, CGT, CLT: begin
        alu_src <= 1'b0;
        mem_branch <= 1'b0;
        mem_write <= 1'b0;
        mem_read <= 1'b0;
        reg_write <= 1'b0;
        mem_to_reg <= 1'b0;
        sema_read <= 1'b0;
        sema_write <= 1'b1;
      end
      LD: begin
        alu_src <= 1'b0;
        mem_branch <= 1'b0;
        mem_write <= 1'b0;
        mem_read <= 1'b1;
        reg_write <= 1'b1;
        mem_to_reg <= 1'b1;
        sema_read <= 1'b0;
        sema_write <= 1'b0;
      end
      ST: begin
        alu_src <= 1'b0;
        mem_branch <= 1'b0;
        mem_write <= 1'b1;
        mem_read <= 1'b0;
        reg_write <= 1'b0;
        mem_to_reg <= 1'b0;
        sema_read <= 1'b0;
        sema_write <= 1'b0;
      end
      SEMA_RD: begin
        alu_src <= 1'b0;
        mem_branch <= 1'b0;
        mem_write <= 1'b0;
        mem_read <= 1'b0;
        reg_write <= 1'b1;
        mem_to_reg <= 1'b0;
        sema_read <= 1'b1;
        sema_write <= 1'b0;
      end
      SEMA_WR: begin
        alu_src <= 1'b0;
        mem_branch <= 1'b0;
        mem_write <= 1'b0;
        mem_read <= 1'b0;
        reg_write <= 1'b0;
        mem_to_reg <= 1'b0;
        sema_read <= 1'b0;
        sema_write <= 1'b1;
      end
      JALR: begin
        alu_src <= 1'b0;
        mem_branch <= 1'b1;
        mem_write <= 1'b0;
        mem_read <= 1'b0;
        reg_write <= 1'b1;
        mem_to_reg <= 1'b0;
        sema_read <= 1'b0;
        sema_write <= 1'b0;
      end
      default: begin
        alu_src <= 1'b0;
        mem_branch <= 1'b0;
        mem_write <= 1'b0;
        mem_read <= 1'b0;
        reg_write <= 1'b0;
        mem_to_reg <= 1'b0;
        sema_read <= 1'b0;
        sema_write <= 1'b0;
      end
    endcase
  end
end


assign i_imm = instruction[20:13];
assign b_imm = {instruction[20:17], instruction[8:5]};

always @(posedge clk or negedge rstn) begin
  if (rstn == 1'b0) begin
    imm <= 0;
  end else if (suspend_cpu == 1'b0) begin
    case (opcode)
      ADDI, SUBI, MULI, DIVI, ANDI, ORI, XORI, SHLI, SHRI, LD, ST: begin
        imm <= {15'd0, i_imm};
      end
      BEQ, BNE, BGT, BLT: begin
        imm <= {15'd0, b_imm};
      end
      default: begin
        imm <= 0;
      end
    endcase
  end
end

assign rd_id = instruction[8:5];
assign rs1_id = instruction[12:9];
assign rs2_id = instruction[16:13];

integer i_reg;

// cache registers block
always @(*) begin
  if (rstn == 1'b0) begin
    rs1 = 16'd0;
    rs2 = 16'd0;
    for (i_reg = 0; i_reg < $size(regfile); i_reg = i_reg+1) begin
      regfile[i_reg] = 16'd0;
    end
  end else if ((wb_reg_write == 1'b1) & (wb_rd_id != 0)) begin
    regfile[wb_rd_id] = wb_regfile_writeback;
  end else if (suspend_cpu == 1'b0) begin
    if ((opcode != LD) && (opcode != SEMA_RD)) begin
      rs1 = regfile[rs1_id];
    end
    case (opcode)
      ADD, SUB, MUL, DIV, AND, OR, XOR, SHL, SHR,
      BEQ, BNE, BGT, BLT, CEQ, CNE, CGT, CLT: begin
        rs2 = regfile[rs2_id];
      end
      default: begin
        rs2 = 16'd0;
      end
    endcase
  end
end

endmodule