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
// Module:  mem
// File:    mem.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 访存阶段
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module mem(

	input wire										rst,        //复位信号
	
	//来自执行阶段的信息	
	input wire[`RegAddrBus]       wd_i,							//访存阶段的指令要写入的目的寄存器地址
	input wire                    wreg_i,						//访存阶段的指令是否有要写入的目的寄存器
	input wire[`RegBus]					  wdata_i,				//访存阶段的指令要写入目的寄存器的值
	input wire[`RegBus]           hi_i,							//访存阶段的指令要写入HI寄存器的值
	input wire[`RegBus]           lo_i,							//访存阶段的指令要写入LO寄存器的值
	input wire                    whilo_i,						//访存阶段的指令是否要写HI、LO寄存器

  input wire[`AluOpBus]        aluop_i,							//访存阶段的指令要进行的运算的子类型
	input wire[`RegBus]          mem_addr_i,					//访存阶段加载，存储指令对应的存储器地址
	input wire[`RegBus]          reg2_i,						//访存阶段的存储指令要存储的数据、或者lwl，lwr指令要写入的目的寄存器的原始值
	
	//来自memory的信息
	input wire[`RegBus]          mem_data_i,                    //从数据存储器读取的数据

	//LLbit_i是LLbit寄存器的值
	input wire                  LLbit_i,						//LLbit模块给出的LLbit寄存器的值
	//但不一定是最新值，回写阶段可能要写LLbit，所以还要进一步判断
	input wire                  wb_LLbit_we_i,					//回写阶段的指令是否要写LLbit寄存器
	input wire                  wb_LLbit_value_i,				//回写阶段的指令要入LLbit寄存器的值
	
	//送到回写阶段的信息
	output reg[`RegAddrBus]      wd_o,							//访存阶段的指令最终要写入的目的寄存器地址
	output reg                   wreg_o,						//访存阶段的指令最终是否有要写入的目的寄存器
	output reg[`RegBus]					 wdata_o,				//访存阶段的指令最终要写入目的寄存器的值
	output reg[`RegBus]          hi_o,							//访存阶段的指令最终要写入HI寄存器的值
	output reg[`RegBus]          lo_o,							//访存阶段的指令最终要写入LO寄存器的值
	output reg                   whilo_o,						//访存阶段的指令最终是否要写入HI，LO寄存器

	output reg                   LLbit_we_o,					//访存阶段的指令是否要写LLbit寄存器
	output reg                   LLbit_value_o,					//访存阶段的指令要写入LLbit寄存器的值
	
	//送到memory的信息
	output reg[`RegBus]          mem_addr_o,					//要访问的数据寄存器的地址
	output wire									 mem_we_o,		//是否要写操作，为1表示是1操作
	output reg[3:0]              mem_sel_o,						//字节选择信号
	output reg[`RegBus]          mem_data_o,					//要写入数据寄存器的值
	output reg                   mem_ce_o						//数据寄存器使能信号
	
);

  reg LLbit;													//LLbit
	wire[`RegBus] zero32;										//32位全零信号
	reg                   mem_we;								//是否要写操作，来自WriteDisable，传给mem_we

	assign mem_we_o = mem_we ;									//给mem_we_o使能信号赋值
	assign zero32 = `ZeroWord;									//给zero32赋全0

  //获取最新的LLbit的值
	always @ (*) begin
		if(rst == `RstEnable) begin								//复位使能
			LLbit <= 1'b0;										//LLbit初始化，赋0
		end else begin											
			if(wb_LLbit_we_i == 1'b1) begin						//如果回写阶段的指令要写LLbit寄存器
				LLbit <= wb_LLbit_value_i;						//LLbit赋值为回写阶段的指令要入LLbit寄存器的值
			end else begin
				LLbit <= LLbit_i;								//LLbit赋值为LLbit模块给出的LLbit寄存器的值
			end
		end
	end
	
	always @ (*) begin
		if(rst == `RstEnable) begin								//复位使能
			wd_o <= `NOPRegAddr;								//访存阶段的指令最终要写入的目的寄存器地址赋为全0
			wreg_o <= `WriteDisable;							//访存阶段的指令最终是否有要写入的目的寄存器使能信号赋值为不能
		  wdata_o <= `ZeroWord;									//访存阶段的指令最终要写入目的寄存器的值赋值为全0
		  hi_o <= `ZeroWord;									//访存阶段的指令最终要写入HI寄存器的值赋值为全0
		  lo_o <= `ZeroWord;									//访存阶段的指令最终要写入LO寄存器的值赋值为全0
		  whilo_o <= `WriteDisable;								//访存阶段的指令最终是否要写入HI，LO寄存器赋值为不能
		  mem_addr_o <= `ZeroWord;								//要访问的数据寄存器的地址赋值为全0
		  mem_we <= `WriteDisable;								//mem_we赋初始值0
		  mem_sel_o <= 4'b0000;									//字节选择信号赋初始值全0
		  mem_data_o <= `ZeroWord;								//要写入数据寄存器的值赋初始值全0
		  mem_ce_o <= `ChipDisable;								//数据寄存器使能信号赋初始值0
		  LLbit_we_o <= 1'b0;									//访存阶段的指令是否要写LLbit寄存器使能信号赋值为0
		  LLbit_value_o <= 1'b0;		      					//访存阶段的指令要写入LLbit寄存器的值赋初始值为0
		end else begin
		  wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;
			hi_o <= hi_i;
			lo_o <= lo_i;
			whilo_o <= whilo_i;		
			mem_we <= `WriteDisable;
			mem_addr_o <= `ZeroWord;
			mem_sel_o <= 4'b1111;
			mem_ce_o <= `ChipDisable;
		  LLbit_we_o <= 1'b0;
		  LLbit_value_o <= 1'b0;			
			case (aluop_i)
				`EXE_LB_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
							mem_sel_o <= 4'b1000;
						end
						2'b01:	begin
							wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
							mem_sel_o <= 4'b0100;
						end
						2'b10:	begin
							wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
							mem_sel_o <= 4'b0010;
						end
						2'b11:	begin
							wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
							mem_sel_o <= 4'b0001;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase
				end
				`EXE_LBU_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[31:24]};
							mem_sel_o <= 4'b1000;
						end
						2'b01:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[23:16]};
							mem_sel_o <= 4'b0100;
						end
						2'b10:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[15:8]};
							mem_sel_o <= 4'b0010;
						end
						2'b11:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[7:0]};
							mem_sel_o <= 4'b0001;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase				
				end
				`EXE_LH_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{16{mem_data_i[31]}},mem_data_i[31:16]};
							mem_sel_o <= 4'b1100;
						end
						2'b10:	begin
							wdata_o <= {{16{mem_data_i[15]}},mem_data_i[15:0]};
							mem_sel_o <= 4'b0011;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase					
				end
				`EXE_LHU_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{16{1'b0}},mem_data_i[31:16]};
							mem_sel_o <= 4'b1100;
						end
						2'b10:	begin
							wdata_o <= {{16{1'b0}},mem_data_i[15:0]};
							mem_sel_o <= 4'b0011;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase				
				end
				`EXE_LW_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					wdata_o <= mem_data_i;
					mem_sel_o <= 4'b1111;		
					mem_ce_o <= `ChipEnable;
				end
				`EXE_LWL_OP:		begin
					mem_addr_o <= {mem_addr_i[31:2], 2'b00};
					mem_we <= `WriteDisable;
					mem_sel_o <= 4'b1111;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= mem_data_i[31:0];
						end
						2'b01:	begin
							wdata_o <= {mem_data_i[23:0],reg2_i[7:0]};
						end
						2'b10:	begin
							wdata_o <= {mem_data_i[15:0],reg2_i[15:0]};
						end
						2'b11:	begin
							wdata_o <= {mem_data_i[7:0],reg2_i[23:0]};	
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase				
				end
				`EXE_LWR_OP:		begin
					mem_addr_o <= {mem_addr_i[31:2], 2'b00};
					mem_we <= `WriteDisable;
					mem_sel_o <= 4'b1111;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {reg2_i[31:8],mem_data_i[31:24]};
						end
						2'b01:	begin
							wdata_o <= {reg2_i[31:16],mem_data_i[31:16]};
						end
						2'b10:	begin
							wdata_o <= {reg2_i[31:24],mem_data_i[31:8]};
						end
						2'b11:	begin
							wdata_o <= mem_data_i;	
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase					
				end
				`EXE_LL_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					wdata_o <= mem_data_i;	
		  		LLbit_we_o <= 1'b1;
		  		LLbit_value_o <= 1'b1;
		  		mem_sel_o <= 4'b1111;			
		  		mem_ce_o <= `ChipEnable;						
				end				
				`EXE_SB_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteEnable;
					mem_data_o <= {reg2_i[7:0],reg2_i[7:0],reg2_i[7:0],reg2_i[7:0]};
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							mem_sel_o <= 4'b1000;
						end
						2'b01:	begin
							mem_sel_o <= 4'b0100;
						end
						2'b10:	begin
							mem_sel_o <= 4'b0010;
						end
						2'b11:	begin
							mem_sel_o <= 4'b0001;	
						end
						default:	begin
							mem_sel_o <= 4'b0000;
						end
					endcase				
				end
				`EXE_SH_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteEnable;
					mem_data_o <= {reg2_i[15:0],reg2_i[15:0]};
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							mem_sel_o <= 4'b1100;
						end
						2'b10:	begin
							mem_sel_o <= 4'b0011;
						end
						default:	begin
							mem_sel_o <= 4'b0000;
						end
					endcase						
				end
				`EXE_SW_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteEnable;
					mem_data_o <= reg2_i;
					mem_sel_o <= 4'b1111;			
					mem_ce_o <= `ChipEnable;
				end
				`EXE_SWL_OP:		begin
					mem_addr_o <= {mem_addr_i[31:2], 2'b00};
					mem_we <= `WriteEnable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin						  
							mem_sel_o <= 4'b1111;
							mem_data_o <= reg2_i;
						end
						2'b01:	begin
							mem_sel_o <= 4'b0111;
							mem_data_o <= {zero32[7:0],reg2_i[31:8]};
						end
						2'b10:	begin
							mem_sel_o <= 4'b0011;
							mem_data_o <= {zero32[15:0],reg2_i[31:16]};
						end
						2'b11:	begin
							mem_sel_o <= 4'b0001;	
							mem_data_o <= {zero32[23:0],reg2_i[31:24]};
						end
						default:	begin
							mem_sel_o <= 4'b0000;
						end
					endcase							
				end
				`EXE_SWR_OP:		begin
					mem_addr_o <= {mem_addr_i[31:2], 2'b00};
					mem_we <= `WriteEnable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin						  
							mem_sel_o <= 4'b1000;
							mem_data_o <= {reg2_i[7:0],zero32[23:0]};
						end
						2'b01:	begin
							mem_sel_o <= 4'b1100;
							mem_data_o <= {reg2_i[15:0],zero32[15:0]};
						end
						2'b10:	begin
							mem_sel_o <= 4'b1110;
							mem_data_o <= {reg2_i[23:0],zero32[7:0]};
						end
						2'b11:	begin
							mem_sel_o <= 4'b1111;	
							mem_data_o <= reg2_i[31:0];
						end
						default:	begin
							mem_sel_o <= 4'b0000;
						end
					endcase											
				end 
				`EXE_SC_OP:		begin
					if(LLbit == 1'b1) begin
						LLbit_we_o <= 1'b1;
						LLbit_value_o <= 1'b0;
						mem_addr_o <= mem_addr_i;
						mem_we <= `WriteEnable;
						mem_data_o <= reg2_i;
						wdata_o <= 32'b1;
						mem_sel_o <= 4'b1111;	
						mem_ce_o <= `ChipEnable;					
					end else begin
						wdata_o <= 32'b0;
					end
				end				
				default:		begin
          //什么也不做
				end
			endcase							
		end    //if
	end      //always
			

endmodule