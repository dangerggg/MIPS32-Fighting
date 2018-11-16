`timescale 1ns / 1ps
module sim_id(
);
wire        rst;
wire[31:0]  pc_i;
wire[31:0]  reg1_data_i;
wire[31:0]  reg2_data_i;
wire[31:0]  inst_i;

wire          reg1_re_o;
wire          reg2_re_o;
wire[4:0]     reg1_raddr_o;
wire[4:0]     reg2_raddr_o;
wire[7:0]     aluop_o; // alu运算类型
wire[2:0]     alusel_o; //????
    
        // 寄存器输???
wire[31:0]    reg1_data_o;
wire[31:0]    reg2_data_o;
wire          reg_we_o; // 写入目的寄存器使???
wire[4:0]     reg_waddr_o;   // 写入目的寄存器地???

assign rst = 0;
assign pi_i = 32'h00000000;
assign reg1_data_i = 32'h00001111;
assign reg2_data_i = 32'h00000000;
assign inst_i = 32'b001101_00000_00001_0001010101010101;

reg clk = 0;
always #10 clk <= ~clk;


wire[7:0]     ex_aluop;
wire[2:0]     ex_alusel;
wire[31:0]    ex_reg1_data;
wire[31:0]    ex_reg2_data;
wire[4:0]     ex_reg_waddr;
wire          ex_reg_we;
    
id id0(
    .rst(rst),
    .pc_i(pc_i),
    .inst_i(inst_i),
    .reg1_data_i(reg1_data_i),
    .reg2_data_i(reg2_data_i),

    .reg1_re_o(reg1_re_o),
    .reg2_re_o(reg2_re_o),
    .aluop_o(aluop_o),
    .alusel_o(alusel_o),
    .reg1_raddr_o(reg1_raddr_o),
    .reg2_raddr_o(reg2_raddr_o),
    .reg1_data_o(reg1_data_o),
    .reg2_data_o(reg2_data_o),
    .reg_we_o(reg_we_o),
    .reg_waddr_o(reg_waddr_o)
);

id_ex id_ex0(
    rst,
    clk,
    aluop_o,
    alusel_o,
    reg1_data_o,
    reg2_data_o,
    reg_waddr_o,
    reg_we_o,
    ex_aluop,
    ex_alusel,
    ex_reg1_data,
    ex_reg2_data,
    ex_reg_waddr,
    ex_reg_we
);
endmodule
