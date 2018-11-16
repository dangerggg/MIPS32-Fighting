`include "defines.h"

module ex_mem(
    input wire          clk,
    input wire          rst,
    
    input wire[4:0]     ex_reg_waddr,
    input wire          ex_reg_we,
    input wire[31:0]    ex_reg_wdata,
    // for ram
    input wire[`AluOpBus] ex_alu_op_i,
    input wire[`RegBus]   ex_mem_addr_i,
    input wire[`RegBus]   ex_reg2_data_i,


    input wire[4:0]     ex_cp0_reg_waddr,
    input wire          ex_cp0_reg_we,
    input wire[`RegBus] ex_cp0_reg_wdata,
    //for hilo
    input wire ex_whilo, //whether write hilo;
    input wire[`RegBus] ex_hi,
    input wire[`RegBus] ex_lo,
    //for exception
    input wire                   flush,
    input wire[31:0]             ex_excepttype,
	input wire                   ex_is_in_delayslot,
	input wire[`RegBus]          ex_current_inst_address,


    //from stallctrl
    input wire[5:0]     stall,

    //for hilo
    output reg mem_whilo,
    output reg[`RegBus] mem_hi,
    output reg[`RegBus] mem_lo,

    // for ram
    output reg[`AluOpBus] mem_alu_op_o,
    output reg[`RegBus]  mem_mem_addr_o,
    output reg[`RegBus] mem_reg2_data_o,
    //for wb
    output reg[4:0]     mem_reg_waddr,
    output reg          mem_reg_we,
    output reg[31:0]    mem_reg_wdata,
    
    output reg[4:0]     mem_cp0_reg_waddr,
    output reg          mem_cp0_reg_we,
    output reg[`RegBus] mem_cp0_reg_wdata,

    //for exception 
    output reg[31:0]            mem_excepttype,
    output reg                  mem_is_in_delayslot,
	output reg[`RegBus]         mem_current_inst_address
		
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            mem_reg_waddr   <= `NOPRegAddr;
            mem_reg_we      <= `WriteDisable;
            mem_reg_wdata   <= 32'h0;
            mem_cp0_reg_waddr   <= `NOPRegAddr;
            mem_cp0_reg_we      <= `WriteDisable;
            mem_cp0_reg_wdata   <= 32'h0;
            mem_alu_op_o<=  `ALU_OP_NOP;
            mem_mem_addr_o <= `ZeroWord;
            mem_reg2_data_o <= `ZeroWord;
            mem_hi <= `ZeroWord;
		    mem_lo <= `ZeroWord;
		    mem_whilo <= `WriteDisable;
            mem_excepttype <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
	        mem_current_inst_address <= `ZeroWord;
        end else if (flush == 1'b1) begin
            mem_reg_waddr   <= `NOPRegAddr;
            mem_reg_we      <= `WriteDisable;
            mem_reg_wdata   <= 32'h0;
            mem_cp0_reg_waddr   <= `NOPRegAddr;
            mem_cp0_reg_we      <= `WriteDisable;
            mem_cp0_reg_wdata   <= 32'h0;
            mem_alu_op_o<=  `ALU_OP_NOP;
            mem_mem_addr_o <= `ZeroWord;
            mem_reg2_data_o <= `ZeroWord;
            mem_hi <= `ZeroWord;
		    mem_lo <= `ZeroWord;
		    mem_whilo <= `WriteDisable;
            mem_excepttype <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
	        mem_current_inst_address <= `ZeroWord;
        end else if (stall[3] == `Stop && stall[4] == `NoStop) begin
            mem_reg_waddr   <= `NOPRegAddr;
            mem_reg_we      <= `WriteDisable;
            mem_reg_wdata   <= 32'h0;
            mem_cp0_reg_waddr   <= `NOPRegAddr;
            mem_cp0_reg_we      <= `WriteDisable;
            mem_cp0_reg_wdata   <= 32'h0;
             mem_alu_op_o<=   `ALU_OP_NOP;
            mem_mem_addr_o <= `ZeroWord;
            mem_reg2_data_o <= `ZeroWord;
            mem_hi <= `ZeroWord;
		  mem_lo <= `ZeroWord;
		  mem_whilo <= `WriteDisable;
             mem_excepttype <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
	        mem_current_inst_address <= `ZeroWord;
        end else if (stall[3] == `NoStop) begin 
            mem_reg_waddr   <= ex_reg_waddr;
            mem_reg_we      <= ex_reg_we;
            mem_reg_wdata   <= ex_reg_wdata;
            mem_cp0_reg_waddr   <= ex_cp0_reg_waddr;
            mem_cp0_reg_we      <= ex_cp0_reg_we;
            mem_cp0_reg_wdata   <= ex_cp0_reg_wdata;

             mem_alu_op_o<=   ex_alu_op_i;
            mem_mem_addr_o <= ex_mem_addr_i;
            mem_reg2_data_o <= ex_reg2_data_i;
            mem_hi <= ex_hi;
			mem_lo <= ex_lo;
			mem_whilo <= ex_whilo;	
            mem_excepttype <=ex_excepttype;
			mem_is_in_delayslot <= ex_is_in_delayslot;
	        mem_current_inst_address <= ex_current_inst_address;
        end
    end
endmodule