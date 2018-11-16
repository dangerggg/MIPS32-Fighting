`timescale 1ns / 1ps
`include "defines.h"

module sim_idex(
);
wire                rst = 0;
// ============= ID ===============
wire[`InstAddrBus]  id_pc_i;
wire[`InstBus]      id_inst_i;

wire[`RegBus]       id_reg1_data_o;
wire[`RegBus]       id_reg2_data_o;
wire                id_reg_we_o; // д��Ŀ�ļĴ���ʹ???
wire[`RegAddrBus]   id_reg_waddr_o;   // д��Ŀ�ļĴ�����???
wire[`AluOpBus]     id_aluop_o; // alu��������
wire[`AluSelBus]    id_alusel_o; //????
// ============= EX ==============
wire[`AluOpBus]     ex_aluop_i;
wire[`AluSelBus]    ex_alusel_i;
wire[`RegBus]       ex_reg1_data_i;
wire[`RegBus]       ex_reg2_data_i;
wire[`RegAddrBus]   ex_reg_waddr_i;
wire                ex_reg_we_i;

wire[`RegAddrBus]   ex_reg_waddr_o;
wire                ex_reg_we_o;
wire[`RegBus]       ex_reg_wdata_o;

// ======================================
wire[`RegBus]       reg1_data_i;
wire[`RegBus]       reg2_data_i;

wire                reg1_re_o;
wire                reg2_re_o;
wire[`RegAddrBus]   reg1_raddr_o;
wire[`RegAddrBus]   reg2_raddr_o;
    
        // �Ĵ�����???
reg clk_reg = 0;
wire clk;
assign clk = clk_reg;
assign id_inst_i = 32'b001101_00000_00001_0001010101010101;
assign reg1_data_i = 32'h0000FF00;
assign reg2_data_i = 32'h00000000;
always #10 clk_reg <= ~clk_reg;

id id0(
    .rst(rst),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),
    
    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    .reg1_data_o(id_reg1_data_o),
    .reg2_data_o(id_reg2_data_o),
    .reg_we_o(id_reg_we_o),
    .reg_waddr_o(id_reg_waddr_o),
    // ��Regfile�ӿ�
    .reg1_data_i(reg1_data_i),
    .reg2_data_i(reg2_data_i),
    .reg1_re_o(reg1_re_o),
    .reg2_re_o(reg2_re_o),
    .reg1_raddr_o(reg1_raddr_o),
    .reg2_raddr_o(reg2_raddr_o)
);

id_ex id_ex0(
    .rst(rst),
    .clk(clk),
    .id_aluop(id_aluop_o),
    .id_alusel(id_alusel_o),
    .id_reg1_data(id_reg1_data_o),
    .id_reg2_data(id_reg2_data_o),
    .id_reg_waddr(id_reg_waddr_o),
    .id_reg_we(id_reg_we_o),
    .ex_aluop(ex_aluop_i),
    .ex_alusel(ex_alusel_i),
    .ex_reg1_data(ex_reg1_data_i),
    .ex_reg2_data(ex_reg2_data_i),
    .ex_reg_waddr(ex_reg_waddr_i),
    .ex_reg_we(ex_reg_we_i)
);

ex ex0(
    .rst(rst),
    .aluop_i(ex_aluop_i),
    .alusel_i(ex_alusel_i),
    .reg1_data_i(ex_reg1_data_i),
    .reg2_data_i(ex_reg2_data_i),

    .reg_waddr_o(ex_reg_waddr_o),
    .reg_we_o(ex_reg_we_o),
    .reg_wdata_o(ex_reg_wdata_o)

);
endmodule
