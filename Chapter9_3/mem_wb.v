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
// Description: MEM/WB�׶εļĴ���
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module mem_wb(

	input	wire										clk, //ʱ���ź�
	input wire										rst,     //��λ�ź�

  //���Կ���ģ�����Ϣ
	input wire[5:0]               stall,	                 //�ô�׶��Ƿ���ͣ

	//���Էô�׶ε���Ϣ	
	input wire[`RegAddrBus]       mem_wd,                    //5bits�� �ô�׶ε�ָ������Ҫд���Ŀ�ļĴ�����ַ  
	input wire                    mem_wreg,                  //�ô�׶ε�ָ�������Ƿ���Ҫд���Ŀ�ļĴ���
	input wire[`RegBus]					 mem_wdata,          //32bits�� �ô�׶ε�ָ������Ҫд��Ŀ�ļĴ�����ֵ
	input wire[`RegBus]           mem_hi,                    //32bits�� �ô�׶ε�ָ��Ҫд��HI�Ĵ�����ֵ
	input wire[`RegBus]           mem_lo,                    //32bits�� �ô�׶ε�ָ��Ҫд��LO�Ĵ�����ֵ
	input wire                    mem_whilo,	             //�ô�׶ε�ָ���Ƿ�ҪдHI��LO
	
	input wire                  mem_LLbit_we,                //�ô�׶ε�ָ���Ƿ�ҪдLLbit�Ĵ���
	input wire                  mem_LLbit_value,	         //�ô�׶ε�ָ���Ƿ�Ҫд��LLbit�Ĵ�����

	//�͵���д�׶ε���Ϣ
	output reg[`RegAddrBus]      wb_wd,						//5bits����д�׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ
	output reg                   wb_wreg,                   //��д�׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
	output reg[`RegBus]					 wb_wdata,          //32bits����д�׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ
	output reg[`RegBus]          wb_hi,						//32bits����д�׶ε�ָ��Ҫд��HI�Ĵ�����ֵ
	output reg[`RegBus]          wb_lo,						//32bits����д�׶ε�ָ��Ҫд��LO�Ĵ�����ֵ
	output reg                   wb_whilo,					//��д�׶ε�ָ���Ƿ�ҪдHI��LO�Ĵ���

	output reg                  wb_LLbit_we,				//��д�׶ε�ָ���Ƿ�ҪдLLbit�Ĵ���
	output reg                  wb_LLbit_value			    //��д�׶ε�ָ���Ƿ�Ҫд��LLbit�Ĵ�����ֵ
	
);


	always @ (posedge clk) begin
		if(rst == `RstEnable) begin                                     //��λʹ��
			wb_wd <= `NOPRegAddr; 										//��д�׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ 5'b00000
			wb_wreg <= `WriteDisable; 									//��д�׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ��� ��
		  wb_wdata <= `ZeroWord;										//��д�׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ 32'h00000000
		  wb_hi <= `ZeroWord;											//��д�׶ε�ָ��Ҫд��HI�Ĵ�����ֵ 32'h00000000
		  wb_lo <= `ZeroWord;											//��д�׶ε�ָ��Ҫд��LO�Ĵ�����ֵ 32'h00000000
		  wb_whilo <= `WriteDisable;									//��д�׶ε�ָ���Ƿ�ҪдHI��LO�Ĵ��� ��
		  wb_LLbit_we <= 1'b0;											//��д�׶ε�ָ���Ƿ�ҪдLLbit�Ĵ��� 0��
		  wb_LLbit_value <= 1'b0;			  							//��д�׶ε�ָ���Ƿ�Ҫд��LLbit�Ĵ�����ֵ 0
		end else if(stall[4] == `Stop && stall[5] == `NoStop) begin		//��ͣ
			wb_wd <= `NOPRegAddr;										//��д�׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ 5'b00000
			wb_wreg <= `WriteDisable;									//��д�׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ��� ��
		  wb_wdata <= `ZeroWord;										//��д�׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ 32'h00000000
		  wb_hi <= `ZeroWord;											//��д�׶ε�ָ��Ҫд��HI�Ĵ�����ֵ 32'h00000000
		  wb_lo <= `ZeroWord;											//��д�׶ε�ָ��Ҫд��LO�Ĵ�����ֵ 32'h00000000
		  wb_whilo <= `WriteDisable;									//��д�׶ε�ָ���Ƿ�ҪдHI��LO�Ĵ��� ��
		  wb_LLbit_we <= 1'b0;											//��д�׶ε�ָ���Ƿ�ҪдLLbit�Ĵ��� 0��
		  wb_LLbit_value <= 1'b0;			  	  	  					//��д�׶ε�ָ���Ƿ�Ҫд��LLbit�Ĵ�����ֵ 0
		end else if(stall[4] == `NoStop) begin							//����ͣ
			wb_wd <= mem_wd;											//�����ڴ�׶�Ҫд���Ŀ�ļĴ�����ַ������д�׶�
			wb_wreg <= mem_wreg;										//�ô�׶ε�ָ�������Ƿ���Ҫд���Ŀ�ļĴ���������д�׶�
			wb_wdata <= mem_wdata;										//�ô�׶ε�ָ������Ҫд��Ŀ�ļĴ�����ֵ������д�׶�
			wb_hi <= mem_hi;											//�ô�׶ε�ָ��Ҫд��HI�Ĵ�����ֵ�����׶�
			wb_lo <= mem_lo;											//�ô�׶ε�ָ��Ҫд��LO�Ĵ�����ֵ������д�׶�
			wb_whilo <= mem_whilo;										//�ô�׶ε�ָ���Ƿ�ҪдHI��LO�� ���д�׶�Ҳһ��
		  wb_LLbit_we <= mem_LLbit_we;									//�ô�׶ε�ָ���Ƿ�ҪдLLbit�Ĵ��������д�׶�Ҳһ��
		  wb_LLbit_value <= mem_LLbit_value;							//��д�׶ε�ָ���Ƿ�Ҫд��LLbit�Ĵ�����ֵ�����д�׶�Ҳһ��
		end    //if
	end      //always
			

endmodule