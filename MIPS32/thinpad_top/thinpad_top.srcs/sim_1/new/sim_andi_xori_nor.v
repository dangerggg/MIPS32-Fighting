`timescale 1ns / 1ps
`include "defines.h"
module sim_andi_xoir_nor(
    input wire clk,
    input wire rst
    );

    wire[`InstAddrBus] pc;
    // ============= ID ===============
    wire[`InstAddrBus]  id_pc_i;
    wire[`InstBus]      id_inst_i;

    wire[`RegBus]       id_reg1_data_o;
    wire[`RegBus]       id_reg2_data_o;
    wire                id_reg_we_o;
    wire[`RegAddrBus]   id_reg_waddr_o;
    wire[`AluOpBus]     id_alu_op_o;
    wire[`AluOpTypeBus] id_alu_op_type_o;

    wire[`RegBus]       reg1_data;
    wire[`RegBus]       reg2_data;
    wire                reg1_re;
    wire                reg2_re;
    wire[`RegAddrBus]   reg1_raddr;
    wire[`RegAddrBus]   reg2_raddr;
    // ============ EX ===============
    wire[`AluOpBus]     ex_alu_op_i;
    wire[`AluOpTypeBus] ex_alu_op_type_i;
    wire[`RegBus]       ex_reg1_data_i;
    wire[`RegBus]       ex_reg2_data_i;
    wire[`RegAddrBus]   ex_reg_waddr_i;
    wire                ex_reg_we_i;

    wire[`RegAddrBus]   ex_reg_waddr_o;
    wire                ex_reg_we_o;
    wire[`RegBus]       ex_reg_wdata_o;
    // ============ MEM ==============
    wire[`RegAddrBus]   mem_reg_waddr_i;
    wire                mem_reg_we_i;
    wire[`RegBus]       mem_reg_wdata_i;

    wire[`RegAddrBus]   mem_reg_waddr_o;
    wire                mem_reg_we_o;
    wire[`RegBus]       mem_reg_wdata_o;    
    // ============ WB ===============
    wire[`RegAddrBus]   wb_waddr_i;
    wire                wb_we_i;
    wire[`RegBus]       wb_wdata_i;
    
    reg clk_reg = 0;
    wire clk, rst;
    
    assign reg1_data = 32'b10101010_10101010_10101010_10101010;    
    assign reg2_data = 32'b00000000_00000000_11111111_11111111;
    assign rst = 0;
    assign clk = clk_reg;
    //assign id_inst_i = 32'b000000_00000_00001_00010_00000_100100; // and
    //assign id_inst_i = 32'b000000_00000_00001_00010_00000_100101; // or
    //assign id_inst_i = 32'b000000_00000_00001_00010_00000_100111; // nor
    //assign id_inst_i = 32'b001100_00000_00001_1111111100000000; // andi
    assign id_inst_i = 32'b001110_00000_00001_1111111100000000; // xori
                
   
            
    always #10 clk_reg <= ~clk_reg;
    
    id id0(
        .rst(rst),
        .pc_i(id_pc_i),
        .inst_i(id_inst_i),
        
        .alu_op_o(id_alu_op_o),
        .alu_op_type_o(id_alu_op_type_o),
        .reg1_data_o(id_reg1_data_o),
        .reg2_data_o(id_reg2_data_o),
        .reg_we_o(id_reg_we_o),
        .reg_waddr_o(id_reg_waddr_o),
        // read reg from regfile
        .reg1_data_i(reg1_data),
        .reg2_data_i(reg2_data),
        .reg1_re_o(reg1_re),
        .reg2_re_o(reg2_re),
        .reg1_raddr_o(reg1_raddr),
        .reg2_raddr_o(reg2_raddr)
    );
    
    /*
    regfile regfile0(
        .clk(clk),
        .rst(rst),
        // write back
        .we(wb_we_i), // ?????????????
        .waddr(wb_waddr_i),
        .wdata(wb_wdata_i),
        // read reg in ID
        .re1(reg1_re),
        .raddr1(reg1_raddr),
        .rdata1(reg1_data),
        .re2(reg2_re),
        .raddr2(reg2_raddr),
        .rdata2(reg2_data)
    );
    */
    id_ex id_ex0(
        .clk(clk),
        .rst(rst),
        .id_alu_op(id_alu_op_o),
        .id_alu_op_type(id_alu_op_type_o),
        .id_reg1_data(id_reg1_data_o),
        .id_reg2_data(id_reg2_data_o),
        .id_reg_waddr(id_reg_waddr_o),
        .id_reg_we(id_reg_we_o),
        .ex_alu_op(ex_alu_op_i),
        .ex_alu_op_type(ex_alu_op_type_i),
        .ex_reg1_data(ex_reg1_data_i),
        .ex_reg2_data(ex_reg2_data_i),
        .ex_reg_waddr(ex_reg_waddr_i),
        .ex_reg_we(ex_reg_we_i)
    );

    ex ex0(
        .rst(rst),
        .alu_op_i(ex_alu_op_i),
        .alu_op_type_i(ex_alu_op_type_i),
        .reg1_data_i(ex_reg1_data_i),
        .reg2_data_i(ex_reg2_data_i),
        .reg_waddr_i(ex_reg_waddr_i),
        .reg_we_i(ex_reg_we_i),

        .reg_waddr_o(ex_reg_waddr_o),
        .reg_we_o(ex_reg_we_o),
        .reg_wdata_o(ex_reg_wdata_o)

    );

    ex_mem ex_mem0(
        .clk(clk),
        .rst(rst),
        .ex_reg_waddr(ex_reg_waddr_o),
        .ex_reg_we(ex_reg_we_o),
        .ex_reg_wdata(ex_reg_wdata_o),
        .mem_reg_waddr(mem_reg_waddr_i),
        .mem_reg_we(mem_reg_we_i),
        .mem_reg_wdata(mem_reg_wdata_i)
    );

    mem mem0(
        .reg_waddr_i(mem_reg_waddr_i),
        .reg_we_i(mem_reg_we_i),
        .reg_wdata_i(mem_reg_wdata_i),
        .reg_waddr_o(mem_reg_waddr_o),
        .reg_we_o(mem_reg_we_o),
        .reg_wdata_o(mem_reg_wdata_o)
    );

    mem_wb mem_wb0(
        .clk(clk),
        .rst(rst),

        .mem_reg_waddr(mem_reg_waddr_o),
        .mem_reg_we(mem_reg_we_o),
        .mem_reg_wdata(mem_reg_wdata_o),

        .wb_waddr(wb_waddr_i),
        .wb_we(wb_we_i),
        .wb_wdata(wb_wdata_i)
    );





endmodule
