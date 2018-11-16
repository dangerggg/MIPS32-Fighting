//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  pc_reg
// File:    pc_reg.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 指令指针寄存器PC
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module pc_reg(

	input wire clk,     //时钟信号
	input wire rst,     //复位信号

	//来自控制模块的信息
	input wire[5:0] stall,    //取值地址PC是否保持不变

	//来自译码阶段的信息
	input wire                    branch_flag_i,             //是否发生转移信号 branch指令
	input wire[`RegBus]           branch_target_address_i,   //转移到的目标地址 32位宽
	
	output reg[`InstAddrBus]      pc,                        //要读取的指令地址 32位宽
	output reg                    ce                         //指令寄存器ROM的使能信号
	
);

	always @ (posedge clk) begin
		if (ce == `ChipDisable) begin
			pc <= 32'h00000000;                     //指令寄存器禁用时PC为0
		end else if(stall[0] == `NoStop) begin      //取值地址PC可以改变
		  	if(branch_flag_i == `Branch) begin      //若需要发生转移
					pc <= branch_target_address_i;  //PC为转移地址
				end else begin
		  		pc <= pc + 4'h4;                    //正常情况，PC = PC + 4
		  	end
		end
	end

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;         //复位时指令存储器禁用
		end else begin
			ce <= `ChipEnable;          //复位结束后指令寄存器使能
		end
	end

endmodule