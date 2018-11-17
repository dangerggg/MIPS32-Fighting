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
// Description: �ô�׶�
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module mem(

	input wire										rst,        //��λ�ź�
	
	//����ִ�н׶ε���Ϣ	
	input wire[`RegAddrBus]       wd_i,							//�ô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ
	input wire                    wreg_i,						//�ô�׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
	input wire[`RegBus]					  wdata_i,				//�ô�׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ
	input wire[`RegBus]           hi_i,							//�ô�׶ε�ָ��Ҫд��HI�Ĵ�����ֵ
	input wire[`RegBus]           lo_i,							//�ô�׶ε�ָ��Ҫд��LO�Ĵ�����ֵ
	input wire                    whilo_i,						//�ô�׶ε�ָ���Ƿ�ҪдHI��LO�Ĵ���

  input wire[`AluOpBus]        aluop_i,							//�ô�׶ε�ָ��Ҫ���е������������
	input wire[`RegBus]          mem_addr_i,					//�ô�׶μ��أ��洢ָ���Ӧ�Ĵ洢����ַ
	input wire[`RegBus]          reg2_i,						//�ô�׶εĴ洢ָ��Ҫ�洢�����ݡ�����lwl��lwrָ��Ҫд���Ŀ�ļĴ�����ԭʼֵ
	
	//����memory����Ϣ
	input wire[`RegBus]          mem_data_i,                    //�����ݴ洢����ȡ������

	//LLbit_i��LLbit�Ĵ�����ֵ
	input wire                  LLbit_i,						//LLbitģ�������LLbit�Ĵ�����ֵ
	//����һ��������ֵ����д�׶ο���ҪдLLbit�����Ի�Ҫ��һ���ж�
	input wire                  wb_LLbit_we_i,					//��д�׶ε�ָ���Ƿ�ҪдLLbit�Ĵ���
	input wire                  wb_LLbit_value_i,				//��д�׶ε�ָ��Ҫ��LLbit�Ĵ�����ֵ
	
	//�͵���д�׶ε���Ϣ
	output reg[`RegAddrBus]      wd_o,							//�ô�׶ε�ָ������Ҫд���Ŀ�ļĴ�����ַ
	output reg                   wreg_o,						//�ô�׶ε�ָ�������Ƿ���Ҫд���Ŀ�ļĴ���
	output reg[`RegBus]					 wdata_o,				//�ô�׶ε�ָ������Ҫд��Ŀ�ļĴ�����ֵ
	output reg[`RegBus]          hi_o,							//�ô�׶ε�ָ������Ҫд��HI�Ĵ�����ֵ
	output reg[`RegBus]          lo_o,							//�ô�׶ε�ָ������Ҫд��LO�Ĵ�����ֵ
	output reg                   whilo_o,						//�ô�׶ε�ָ�������Ƿ�Ҫд��HI��LO�Ĵ���

	output reg                   LLbit_we_o,					//�ô�׶ε�ָ���Ƿ�ҪдLLbit�Ĵ���
	output reg                   LLbit_value_o,					//�ô�׶ε�ָ��Ҫд��LLbit�Ĵ�����ֵ
	
	//�͵�memory����Ϣ
	output reg[`RegBus]          mem_addr_o,					//Ҫ���ʵ����ݼĴ����ĵ�ַ
	output wire									 mem_we_o,		//�Ƿ�Ҫд������Ϊ1��ʾ��1����
	output reg[3:0]              mem_sel_o,						//�ֽ�ѡ���ź�
	output reg[`RegBus]          mem_data_o,					//Ҫд�����ݼĴ�����ֵ
	output reg                   mem_ce_o						//���ݼĴ���ʹ���ź�
	
);

  reg LLbit;													//LLbit
	wire[`RegBus] zero32;										//32λȫ���ź�
	reg                   mem_we;								//�Ƿ�Ҫд����������WriteDisable������mem_we

	assign mem_we_o = mem_we ;									//��mem_we_oʹ���źŸ�ֵ
	assign zero32 = `ZeroWord;									//��zero32��ȫ0

  //��ȡ���µ�LLbit��ֵ
	always @ (*) begin
		if(rst == `RstEnable) begin								//��λʹ��
			LLbit <= 1'b0;										//LLbit��ʼ������0
		end else begin											
			if(wb_LLbit_we_i == 1'b1) begin						//�����д�׶ε�ָ��ҪдLLbit�Ĵ���
				LLbit <= wb_LLbit_value_i;						//LLbit��ֵΪ��д�׶ε�ָ��Ҫ��LLbit�Ĵ�����ֵ
			end else begin
				LLbit <= LLbit_i;								//LLbit��ֵΪLLbitģ�������LLbit�Ĵ�����ֵ
			end
		end
	end
	
	always @ (*) begin
		if(rst == `RstEnable) begin								//��λʹ��
			wd_o <= `NOPRegAddr;								//�ô�׶ε�ָ������Ҫд���Ŀ�ļĴ�����ַ��Ϊȫ0
			wreg_o <= `WriteDisable;							//�ô�׶ε�ָ�������Ƿ���Ҫд���Ŀ�ļĴ���ʹ���źŸ�ֵΪ����
		  wdata_o <= `ZeroWord;									//�ô�׶ε�ָ������Ҫд��Ŀ�ļĴ�����ֵ��ֵΪȫ0
		  hi_o <= `ZeroWord;									//�ô�׶ε�ָ������Ҫд��HI�Ĵ�����ֵ��ֵΪȫ0
		  lo_o <= `ZeroWord;									//�ô�׶ε�ָ������Ҫд��LO�Ĵ�����ֵ��ֵΪȫ0
		  whilo_o <= `WriteDisable;								//�ô�׶ε�ָ�������Ƿ�Ҫд��HI��LO�Ĵ�����ֵΪ����
		  mem_addr_o <= `ZeroWord;								//Ҫ���ʵ����ݼĴ����ĵ�ַ��ֵΪȫ0
		  mem_we <= `WriteDisable;								//mem_we����ʼֵ0
		  mem_sel_o <= 4'b0000;									//�ֽ�ѡ���źŸ���ʼֵȫ0
		  mem_data_o <= `ZeroWord;								//Ҫд�����ݼĴ�����ֵ����ʼֵȫ0
		  mem_ce_o <= `ChipDisable;								//���ݼĴ���ʹ���źŸ���ʼֵ0
		  LLbit_we_o <= 1'b0;									//�ô�׶ε�ָ���Ƿ�ҪдLLbit�Ĵ���ʹ���źŸ�ֵΪ0
		  LLbit_value_o <= 1'b0;		      					//�ô�׶ε�ָ��Ҫд��LLbit�Ĵ�����ֵ����ʼֵΪ0
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
          //ʲôҲ����
				end
			endcase							
		end    //if
	end      //always
			

endmodule