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
// Module:  if_id
// File:    if_id.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: IF/ID阶段的寄存器
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module if_id(

	input wire clk,                      //时钟信号
	input wire rst,                      //复位信号

	//来自控制模块的信息
	input wire[5:0]           stall,     //取值阶段是否暂停	

	input wire[`InstAddrBus]  if_pc,     //32位宽度 取指阶段取得的指令对应的地址
	input wire[`InstBus]      if_inst,   //32位宽度 取指阶段取得的指令
	output reg[`InstAddrBus]  id_pc,     //32位宽度 译码阶段的指令对应的地址
	output reg[`InstBus]      id_inst    //32位宽度 译妈阶段取得的指令
	
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			id_pc <= `ZeroWord;          //复位时PC为0
			id_inst <= `ZeroWord;        //复位时instruction为0
		end else if(stall[1] == `Stop && stall[2] == `NoStop) begin
			id_pc <= `ZeroWord;          //若此阶段暂停，PC为0
			id_inst <= `ZeroWord;	     //若此阶段暂停，instruction为0
	  end else if(stall[1] == `NoStop) begin
		  id_pc <= if_pc;                //其余时刻向下传递取指阶段的值
		  id_inst <= if_inst;
		end
	end

endmodule