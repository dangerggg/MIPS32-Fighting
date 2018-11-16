`timescale 1ns / 1ps
`include "defines.h"

module id_ex(
    input wire          clk,
    input wire          rst,
    input wire[7:0]     id_alu_op,
    input wire[2:0]     id_alu_op_type,
    input wire[31:0]    id_reg1_data,
    input wire[31:0]    id_reg2_data,
    input wire[4:0]     id_reg_waddr,
    input wire          id_reg_we,
    //for ram
    input wire[`RegBus]   id_inst, // instruction from id module
   

    // from ctrl
    input wire[5:0]     stall,
    // jump and branch input
    input wire[31:0]    id_link_addr,
    input wire          id_is_in_delayslot,
    input wire          next_inst_in_delayslot_i,

    //for exception 
    input wire flush,
    input wire[`RegBus]           id_current_inst_address,
	input wire[31:0]              id_excepttype,

    output reg[7:0]     ex_alu_op,
    output reg[2:0]     ex_alu_op_type,
    output reg[31:0]    ex_reg1_data,
    output reg[31:0]    ex_reg2_data,
    output reg[4:0]     ex_reg_waddr,
    output reg          ex_reg_we,
// for ram 
     output reg[`RegBus]   ex_inst,//  instruction send to Ex module
    // jump and branch output
    output reg[31:0]    ex_link_addr,
    output reg          ex_is_in_delayslot,
    output reg          is_in_delayslot_o ,// to id
//for exception
    output reg[31:0]              ex_excepttype,
	output reg[`RegBus]          ex_current_inst_address	
);




    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ex_alu_op       <= `ALU_OP_NOP;
            ex_alu_op_type  <= `ALU_OP_TYPE_NOP;
            ex_reg1_data    <= 32'h0;
            ex_reg2_data    <= 32'h0;
            ex_reg_waddr    <= `NOPRegAddr;
            ex_reg_we       <= `WriteDisable;
            ex_link_addr <= 32'h0;
            ex_is_in_delayslot <= `NotInDelaySlot;
            is_in_delayslot_o <= `NotInDelaySlot;
            ex_inst <= `ZeroWord;
            ex_current_inst_address <= `ZeroWord;
            ex_excepttype <= `ZeroWord;	
        end else if (flush == 1'b1) begin
            ex_alu_op <= `ALU_OP_NOP;
			ex_alu_op_type <= `ALU_OP_TYPE_NOP;
			ex_reg1_data <= `ZeroWord;
			ex_reg2_data <= `ZeroWord;
			ex_reg_waddr <= `NOPRegAddr;
			ex_reg_we <= `WriteDisable;	
			ex_link_addr <= `ZeroWord;
			ex_is_in_delayslot <= `NotInDelaySlot;
            is_in_delayslot_o <= `NotInDelaySlot;
            ex_inst <= `ZeroWord;
	        ex_current_inst_address <= `ZeroWord;
            ex_excepttype <= `ZeroWord;	  
        
        end else if (stall[2] == `Stop&& stall[3] == `NoStop)begin
            ex_alu_op       <= `ALU_OP_NOP;
            ex_alu_op_type  <= `ALU_OP_TYPE_NOP;
            ex_reg1_data    <= 32'h0;
            ex_reg2_data    <= 32'h0;
            ex_reg_waddr    <= `NOPRegAddr;
            ex_reg_we       <= `WriteDisable;
            ex_link_addr <= 32'h0;
            ex_is_in_delayslot <= `NotInDelaySlot;

            ex_inst <= `ZeroWord;
            ex_current_inst_address <= `ZeroWord;
            ex_excepttype <= `ZeroWord;	
            // is_in_delayslot_o reserved
        end else if (stall[2] == `NoStop) begin
            ex_alu_op       <= id_alu_op;
            ex_alu_op_type  <= id_alu_op_type;
            ex_reg1_data    <= id_reg1_data;
            ex_reg2_data    <= id_reg2_data;
            ex_reg_waddr    <= id_reg_waddr;
            ex_reg_we       <= id_reg_we;
            ex_link_addr <= id_link_addr;
            ex_is_in_delayslot <= id_is_in_delayslot;
            is_in_delayslot_o <= next_inst_in_delayslot_i;
            ex_inst <= id_inst;  // if  ID module doesnt stop , send "id_inst" signal ,else send Zeroword
            ex_current_inst_address <= id_current_inst_address;
            ex_excepttype <= id_excepttype;	
        end
    end
endmodule
