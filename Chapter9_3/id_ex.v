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
// Module:  id_ex
// File:    id_ex.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: ID/EX阶段的寄存器
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module id_ex(

	input wire					  clk,             //时钟信号
	input wire					  rst,             //复位信号

	//来自控制模块的信息
	input wire[5:0]				  stall,
	
	//从译码阶段传递的信息
	input wire[`AluOpBus]         id_aluop,      	   			//译码阶段的指令要进行的运算的子类型    8位
	input wire[`AluSelBus]        id_alusel,    	   			//译码阶段的指令要进行的运算的类型      3位
	input wire[`RegBus]           id_reg1,       	   			//译码阶段的指令要进行的运算的源操作数1 32位
	input wire[`RegBus]           id_reg2,       	   			//译码阶段的指令要进行的运算的源操作数2 32位
	input wire[`RegAddrBus]       id_wd,               			//译码阶段的指令要写入的目的寄存器地址  5位
	input wire                    id_wreg,	           			//译码阶段的指令是否又要写入的目的寄存器 1位
	input wire[`RegBus]           id_link_address,     			//处于译码阶段的指令是否位于延迟槽中    32位
	input wire                    id_is_in_delayslot,  			//当前处于译码阶段的指令是否处于延迟槽中 
	input wire                    next_inst_in_delayslot_i, 	//下一条进入译码阶段的指令是否位于延迟槽中
	input wire[`RegBus]           id_inst,		                //当前处于译码阶段的指令
	
	//传递到执行阶段的信息
	output reg[`AluOpBus]         ex_aluop,   			  		//执行阶段的指令要进行的运算的子类型    8位
	output reg[`AluSelBus]        ex_alusel,    				//执行阶段的指令要进行的运算的类型      3位
	output reg[`RegBus]           ex_reg1,      				//执行阶段的指令要进行的运算的源操作数1 32位
	output reg[`RegBus]           ex_reg2,     		 			//执行阶段的指令要进行的运算的源操作数2 32位
	output reg[`RegAddrBus]       ex_wd,        				//执行阶段的指令要写入的目的寄存器地址  5位
	output reg                    ex_wreg,       				//执行阶段的指令是否又要写入的目的寄存器 1位
	output reg[`RegBus]           ex_link_address,         		//处于执行阶段的转移指令要保存的返回地址 32位
  	output reg                    ex_is_in_delayslot,			//当前处于执行阶段的指令是否位于延迟槽中
	output reg                    is_in_delayslot_o,			//当前处于译码阶段的指令是否位于延迟槽中
	output reg[`RegBus]           ex_inst						//当前处于执行阶段的指令 32位
	
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin                 //如果是复位信号
			ex_aluop <= `EXE_NOP_OP;                 //执行阶段指令运算子类型为NOP
			ex_alusel <= `EXE_RES_NOP;               //执行阶段运算的类型为NOP
			ex_reg1 <= `ZeroWord;                    //源操作数1为0
			ex_reg2 <= `ZeroWord;                    //源操作数2为0
			ex_wd <= `NOPRegAddr;                    //写回0号寄存器
			ex_wreg <= `WriteDisable;                //目的寄存器不可写
			ex_link_address <= `ZeroWord;            //转移指令返回地址为0
			ex_is_in_delayslot <= `NotInDelaySlot;   //当前处于执行阶段的指令不必处于延迟槽中
	    	is_in_delayslot_o <= `NotInDelaySlot;	 //当前处于译码阶段的指令不必处于延迟槽中
	    	ex_inst <= `ZeroWord;					 //执行阶段的指令为NOP
		end else if(stall[2] == `Stop && stall[3] == `NoStop) begin    //若此阶段暂停，同复位信号
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;	
			ex_link_address <= `ZeroWord;
	    	ex_is_in_delayslot <= `NotInDelaySlot;
	    	ex_inst <= `ZeroWord;			
			// is_in_delayslot_o reserved
		end else if(stall[2] == `NoStop) begin		 //此阶段不暂停，则传递数据
			ex_aluop <= id_aluop;
			ex_alusel <= id_alusel;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;		
			ex_link_address <= id_link_address;
			ex_is_in_delayslot <= id_is_in_delayslot;         //将此阶段译码阶段是否处于延迟槽传递给执行阶段
	    	is_in_delayslot_o <= next_inst_in_delayslot_i;    //将下一条进入译码阶段的指令是否处于延迟槽的信息传回译码阶段
	    	ex_inst <= id_inst;				
		end
	end
	
endmodule