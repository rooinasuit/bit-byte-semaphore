//////////////////////////////////////////////////
//  Projekt: CPU 1 bit PBL
//  Jednoskta: controller taski
//
//
//////////////////////////////////////////////////

`include "definy.v"


/////////////////////////// get data for alu op tasks

task i_get_data_0;
  alu_op <= opcode;
  case(data_src)
    `instant   : i_get_instant;
    `regfile   : i_get_reg_0; 
    `data_mem  : i_get_mem_0;
    `semaphore : i_get_sem_0;
    default : i_OP_end;
  endcase
endtask

task i_get_reg_0;
  register_addr_out <= pm_data_in[1:0];
  alu_data_out <= reg_data_in;
  wr_cr <= 1'b1;
  i_OP_end;
endtask

task i_get_instant;
  alu_data_out <= pm_data_in[DATA_WIDTH-1:0]; 
  wr_cr <= 1'b1;
  i_OP_end;
endtask

task i_get_mem_0;
  state <= `i_get_mem_1; 
  //pc_ce <= 1'b0;
  //here get 2 bit if dm will be resized to 10bit addr
endtask

task i_get_mem_1;
  dm_addr_out <= pm_data_in;
  alu_data_out <= dm_data_in;
  wr_cr <= 1'b1;
  i_OP_end;
endtask

task i_get_sem_0;
  if(sem_data_valid_in) begin
    alu_data_out <= sem_data_in;
    wr_cr <= 1'b1;
    sem_data_read <= 1'b1;
    i_OP_end;
  end
  else begin
    pc_ce <= 1'b0;
    state <= `i_get_sem_0; 
  end
endtask

/////////////////////////// Store data tasks

task i_set_data_0;
  alu_op <= opcode;
  case(data_src)
    //`instant   : alu_data_out <= pm_data_in[DATA_WIDTH:0];
    `regfile   : i_set_reg_0; //zmienic rejestry zeby sie miescili na 2 bitach albo rozszerzyc o adresowanie w 2 taktach
    `data_mem  : i_set_mem_0;
    `semaphore : i_set_sem_0;
    default : ;
  endcase
endtask

task i_set_reg_0;
  register_addr_out <= pm_data_in[1:0];
  reg_data_out <= alu_data_in;
  wr_reg <= 1'b1;
  i_OP_end;
endtask

task i_set_mem_0;
  state <= `i_set_mem_1; 
endtask

task i_set_mem_1;
  dm_data_out <= alu_data_in;
  dm_addr_out <= pm_data_in;
  dm_wr <= 1'b1;
  //pc_ce <= 1'b0;
  i_OP_end;
endtask


task i_set_sem_0;
  if(sem_data_empty) begin
    sem_data_out <= alu_data_in;
    sem_data_valid_out <= 1'b1;
    i_OP_end;
  end
  else begin
    pc_ce <= 1'b0;
    state <= `i_set_sem_0; 
  end
endtask

/////////////////////////// Jump tasks
task i_JMP_0;
  state <= `i_JMP_1;
endtask

task i_JMP_1;
  pc_mem_val <= pc_in;
  pc_wr <= 1'b1;
  pc_out <= pm_data_in;
  i_OP_end;
endtask

task i_RET_0;
  pc_wr <= 1'b1;
  pc_out <= pc_mem_val;
  i_OP_end;
endtask

task i_JMA_0;
  if(!alu_zero_flag) state <= `i_JMP_1;
endtask

/////////////////////////// other tasks

task reset_signals;
  begin
    pc_wr <= 1'b0;
    wr_cr <= 1'b0;
    sem_data_read <=1'b0;
    dm_wr <= 1'b0;
    wr_reg <= 1'b0;
  end
endtask

task i_OP_end;
  begin
    pc_ce <= 1;
    state <= `init;
  end
endtask

task i_NOP;
  begin
    i_OP_end;
  end 
endtask

task reset;
  begin
    pc_ce   <= 1;
    state <= `init;
  end
endtask