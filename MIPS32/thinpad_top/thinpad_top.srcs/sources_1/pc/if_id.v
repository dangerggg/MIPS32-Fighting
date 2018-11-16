`timescale 1ns / 1ps
`include "defines.h"

module if_id(
	input wire clk,
	input wire rst,


	input wire [`InstAddrBus]	if_pc,
	input wire [`InstBus]		if_inst,

	input wire[5:0] stall,//from stall controller 

	input wire flush, // for flush

	output reg[`InstAddrBus]	id_pc,
	output reg [`InstBus]		id_inst
);
	//1) stall[1] == STOP; stall[2] == NoStop  IF stage stop, id stage doesnt stop;  the instruction fetched in ID in next cycle is NOP
	// 2) stall[1] == Nostop    IF keeps going on without stopping,  fetch instruction and send it to ID;
	//3) else don't change the output()
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			id_pc <= `ZeroWord;	
			id_inst <= `ZeroWord;
		end else if (flush == 1'b1) begin
			//exception happens ,flush pipeline, reset id_pc, id_inst
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;	
		end else if (stall[1] == `Stop && stall[2] == `NoStop) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end else if (stall[1] == `NoStop) begin
			id_pc <= if_pc;	
			id_inst <= if_inst;
		end
	end
endmodule