//////////////////////////////////////////////////
//  Projekt: CPU 1 bit PBL
//  Jednoskta: tb top
//
//
//////////////////////////////////////////////////

`include "definy.v"



module top();
reg clk;
reg rst;

//reg [`DATA_WIDTH-1:0] ext_registers_in [`EXT_REGS_No];
reg [`DATA_WIDTH-1:0] R0 = 0;
reg [`DATA_WIDTH-1:0] R1 = 0;
reg [`DATA_WIDTH-1:0] R2 = 0;
reg [`DATA_WIDTH-1:0] R3 = 0;


reg [`DATA_WIDTH-1:0] sem_data_in = 0;
reg sem_data_valid_in = 0;
reg sem_data_read;

reg [`DATA_WIDTH-1:0] sem_data_out;
reg sem_data_valid_out;
reg sem_data_empty = 0;

reg [3:0] state;

wire [`DATA_WIDTH-1:0] ext_registers_in [`EXT_REGS_No];
wire [`DATA_WIDTH-1:0] int_registers_out [`INT_REGS_No]; 

assign ext_registers_in = {{R3},{R2}};
assign int_registers_out = {{R1},{R0}};


cpu #() cpu_uut(
.clk(clk),
.rst(rst),

.ext_registers_in(ext_registers_in),
.int_registers_out(int_registers_out), 

.sem_data_in(sem_data_in),
.sem_data_valid_in(sem_data_valid_in),
.sem_data_read(sem_data_read),

.sem_data_out(sem_data_out),
.sem_data_valid_out(sem_data_valid_out),
.sem_data_empty(sem_data_empty),

.state(state)
);


initial begin 
clk = 0;
rst = 0;
#10
rst = 1;


#300
$finish;
end

always #5 clk = ~clk;


endmodule

