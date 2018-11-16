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
// Description: ID/EX�׶εļĴ���
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module id_ex(

	input wire					  clk,             //ʱ���ź�
	input wire					  rst,             //��λ�ź�

	//���Կ���ģ�����Ϣ
	input wire[5:0]				  stall,
	
	//������׶δ��ݵ���Ϣ
	input wire[`AluOpBus]         id_aluop,      	   			//����׶ε�ָ��Ҫ���е������������    8λ
	input wire[`AluSelBus]        id_alusel,    	   			//����׶ε�ָ��Ҫ���е����������      3λ
	input wire[`RegBus]           id_reg1,       	   			//����׶ε�ָ��Ҫ���е������Դ������1 32λ
	input wire[`RegBus]           id_reg2,       	   			//����׶ε�ָ��Ҫ���е������Դ������2 32λ
	input wire[`RegAddrBus]       id_wd,               			//����׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ  5λ
	input wire                    id_wreg,	           			//����׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ��� 1λ
	input wire[`RegBus]           id_link_address,     			//��������׶ε�ָ���Ƿ�λ���ӳٲ���    32λ
	input wire                    id_is_in_delayslot,  			//��ǰ��������׶ε�ָ���Ƿ����ӳٲ��� 
	input wire                    next_inst_in_delayslot_i, 	//��һ����������׶ε�ָ���Ƿ�λ���ӳٲ���
	input wire[`RegBus]           id_inst,		                //��ǰ��������׶ε�ָ��
	
	//���ݵ�ִ�н׶ε���Ϣ
	output reg[`AluOpBus]         ex_aluop,   			  		//ִ�н׶ε�ָ��Ҫ���е������������    8λ
	output reg[`AluSelBus]        ex_alusel,    				//ִ�н׶ε�ָ��Ҫ���е����������      3λ
	output reg[`RegBus]           ex_reg1,      				//ִ�н׶ε�ָ��Ҫ���е������Դ������1 32λ
	output reg[`RegBus]           ex_reg2,     		 			//ִ�н׶ε�ָ��Ҫ���е������Դ������2 32λ
	output reg[`RegAddrBus]       ex_wd,        				//ִ�н׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ  5λ
	output reg                    ex_wreg,       				//ִ�н׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ��� 1λ
	output reg[`RegBus]           ex_link_address,         		//����ִ�н׶ε�ת��ָ��Ҫ����ķ��ص�ַ 32λ
  	output reg                    ex_is_in_delayslot,			//��ǰ����ִ�н׶ε�ָ���Ƿ�λ���ӳٲ���
	output reg                    is_in_delayslot_o,			//��ǰ��������׶ε�ָ���Ƿ�λ���ӳٲ���
	output reg[`RegBus]           ex_inst						//��ǰ����ִ�н׶ε�ָ�� 32λ
	
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin                 //����Ǹ�λ�ź�
			ex_aluop <= `EXE_NOP_OP;                 //ִ�н׶�ָ������������ΪNOP
			ex_alusel <= `EXE_RES_NOP;               //ִ�н׶����������ΪNOP
			ex_reg1 <= `ZeroWord;                    //Դ������1Ϊ0
			ex_reg2 <= `ZeroWord;                    //Դ������2Ϊ0
			ex_wd <= `NOPRegAddr;                    //д��0�żĴ���
			ex_wreg <= `WriteDisable;                //Ŀ�ļĴ�������д
			ex_link_address <= `ZeroWord;            //ת��ָ��ص�ַΪ0
			ex_is_in_delayslot <= `NotInDelaySlot;   //��ǰ����ִ�н׶ε�ָ��ش����ӳٲ���
	    	is_in_delayslot_o <= `NotInDelaySlot;	 //��ǰ��������׶ε�ָ��ش����ӳٲ���
	    	ex_inst <= `ZeroWord;					 //ִ�н׶ε�ָ��ΪNOP
		end else if(stall[2] == `Stop && stall[3] == `NoStop) begin    //���˽׶���ͣ��ͬ��λ�ź�
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
		end else if(stall[2] == `NoStop) begin		 //�˽׶β���ͣ���򴫵�����
			ex_aluop <= id_aluop;
			ex_alusel <= id_alusel;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;		
			ex_link_address <= id_link_address;
			ex_is_in_delayslot <= id_is_in_delayslot;         //���˽׶�����׶��Ƿ����ӳٲ۴��ݸ�ִ�н׶�
	    	is_in_delayslot_o <= next_inst_in_delayslot_i;    //����һ����������׶ε�ָ���Ƿ����ӳٲ۵���Ϣ��������׶�
	    	ex_inst <= id_inst;				
		end
	end
	
endmodule