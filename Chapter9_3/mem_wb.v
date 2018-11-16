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
// Module:  mem_wb
// File:    mem_wb.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: MEM/WB阶段的寄存器
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module mem_wb(

	input	wire										clk, //时钟信号
	input wire										rst,     //复位信号

  //来自控制模块的信息
	input wire[5:0]               stall,	                 //访存阶段是否暂停

	//来自访存阶段的信息	
	input wire[`RegAddrBus]       mem_wd,                    //5bits， 访存阶段的指令最终要写入的目的寄存器地址  
	input wire                    mem_wreg,                  //访存阶段的指令最终是否有要写入的目的寄存器
	input wire[`RegBus]					 mem_wdata,          //32bits， 访存阶段的指令最终要写入目的寄存器的值
	input wire[`RegBus]           mem_hi,                    //32bits， 访存阶段的指令要写入HI寄存器的值
	input wire[`RegBus]           mem_lo,                    //32bits， 访存阶段的指令要写入LO寄存器的值
	input wire                    mem_whilo,	             //访存阶段的指令是否要写HI，LO
	
	input wire                  mem_LLbit_we,                //访存阶段的指令是否要写LLbit寄存器
	input wire                  mem_LLbit_value,	         //访存阶段的指令是否要写入LLbit寄存器的

	//送到回写阶段的信息
	output reg[`RegAddrBus]      wb_wd,						//5bits，回写阶段的指令要写入的目的寄存器地址
	output reg                   wb_wreg,                   //回写阶段的指令是否有要写入的目的寄存器
	output reg[`RegBus]					 wb_wdata,          //32bits，回写阶段的指令要写入目的寄存器的值
	output reg[`RegBus]          wb_hi,						//32bits，回写阶段的指令要写入HI寄存器的值
	output reg[`RegBus]          wb_lo,						//32bits，回写阶段的指令要写入LO寄存器的值
	output reg                   wb_whilo,					//回写阶段的指令是否要写HI，LO寄存器

	output reg                  wb_LLbit_we,				//回写阶段的指令是否要写LLbit寄存器
	output reg                  wb_LLbit_value			    //回写阶段的指令是否要写入LLbit寄存器的值
	
);


	always @ (posedge clk) begin
		if(rst == `RstEnable) begin                                     //复位使能
			wb_wd <= `NOPRegAddr; 										//回写阶段的指令要写入的目的寄存器地址 5'b00000
			wb_wreg <= `WriteDisable; 									//回写阶段的指令是否有要写入的目的寄存器 否
		  wb_wdata <= `ZeroWord;										//回写阶段的指令要写入目的寄存器的值 32'h00000000
		  wb_hi <= `ZeroWord;											//回写阶段的指令要写入HI寄存器的值 32'h00000000
		  wb_lo <= `ZeroWord;											//回写阶段的指令要写入LO寄存器的值 32'h00000000
		  wb_whilo <= `WriteDisable;									//回写阶段的指令是否要写HI，LO寄存器 否
		  wb_LLbit_we <= 1'b0;											//回写阶段的指令是否要写LLbit寄存器 0否
		  wb_LLbit_value <= 1'b0;			  							//回写阶段的指令是否要写入LLbit寄存器的值 0
		end else if(stall[4] == `Stop && stall[5] == `NoStop) begin		//暂停
			wb_wd <= `NOPRegAddr;										//回写阶段的指令要写入的目的寄存器地址 5'b00000
			wb_wreg <= `WriteDisable;									//回写阶段的指令是否有要写入的目的寄存器 否
		  wb_wdata <= `ZeroWord;										//回写阶段的指令要写入目的寄存器的值 32'h00000000
		  wb_hi <= `ZeroWord;											//回写阶段的指令要写入HI寄存器的值 32'h00000000
		  wb_lo <= `ZeroWord;											//回写阶段的指令要写入LO寄存器的值 32'h00000000
		  wb_whilo <= `WriteDisable;									//回写阶段的指令是否要写HI，LO寄存器 否
		  wb_LLbit_we <= 1'b0;											//回写阶段的指令是否要写LLbit寄存器 0否
		  wb_LLbit_value <= 1'b0;			  	  	  					//回写阶段的指令是否要写入LLbit寄存器的值 0
		end else if(stall[4] == `NoStop) begin							//不暂停
			wb_wd <= mem_wd;											//访问内存阶段要写入的目的寄存器地址赋给回写阶段
			wb_wreg <= mem_wreg;										//访存阶段的指令最终是否有要写入的目的寄存器赋给回写阶段
			wb_wdata <= mem_wdata;										//访存阶段的指令最终要写入目的寄存器的值赋给回写阶段
			wb_hi <= mem_hi;											//访存阶段的指令要写入HI寄存器的值赋给阶段
			wb_lo <= mem_lo;											//访存阶段的指令要写入LO寄存器的值赋给回写阶段
			wb_whilo <= mem_whilo;										//访存阶段的指令是否要写HI，LO， 则回写阶段也一样
		  wb_LLbit_we <= mem_LLbit_we;									//访存阶段的指令是否要写LLbit寄存器，则回写阶段也一样
		  wb_LLbit_value <= mem_LLbit_value;							//回写阶段的指令是否要写入LLbit寄存器的值，则回写阶段也一样
		end    //if
	end      //always
			

endmodule