`include "defines.h"
`timescale 1ns / 1ps
module pc_reg(
	input wire 					clk,
	input wire 					rst,
	//from stall ctrl
	input wire[5:0] 			stall,
	// branch info from ID
	input wire 					branch_flag_i,
	input wire[`RegBus]			branch_target_addr_i,
	// for exception
	input wire flush,	// flush pipeline signal
	input wire[`RegBus]   new_pc, // exception handler entrance
//end for
	output reg[`InstAddrBus] 	pc,
	output reg 					ce
);

	always @ (posedge clk) begin //于时钟上升沿触发
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;	//复位�???? 指令存储器禁�????
		end else begin
			ce <= `ChipEnable;	//复位�???? 指令存储器使�????
		end
	end

	always @ (posedge clk) begin //时钟上升沿触�????
		if (ce == `ChipDisable) begin
			pc <= 32'h80000000;	//指令存储器禁用时，PC = 0
		end else begin
			if (flush == 1'b1) begin
				pc <= new_pc;// exception happens , get exception hanler in new_pc from ctrl module;
			end else if (stall[0] == `NoStop) begin
				if (branch_flag_i == `Branch) begin
					pc <= branch_target_addr_i;
				end else begin
					pc <= pc + 4'h4;	//指令存储器使能，PC 值每时钟周期 + 4
				end
			end
		end
	end	
endmodule