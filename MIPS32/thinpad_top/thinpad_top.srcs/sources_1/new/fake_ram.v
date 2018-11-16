`timescale 1ns / 1ps
`include "defines.h"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/06 20:15:00
// Design Name: 
// Module Name: ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// ram mock          
module fake_ram(
    input wire   ce_n,
    input wire   we_n,
    input wire   oe_n,
    input wire[19:0]  addr,
    input wire[3:0]   be_n,
    input wire[`DataBus]  data_i,
    output reg[`DataBus]  data_o
    );

    reg[`ByteWidth]  data_mem0[0:103];
    reg[`ByteWidth]  data_mem1[0:103];//`DataMemNum-1
    reg[`ByteWidth]  data_mem2[0:103];
    reg[`ByteWidth]  data_mem3[0:103];
    
    wire ce = ~ce_n;
    wire oe = ~oe_n;
    wire we = ~we_n;
	wire[3:0] sel = ~be_n;
    
	always @ (*) begin
		if (ce == `ChipDisable) begin
			//data_o <= ZeroWord;
		end else if(we == `WriteEnable) begin
			  if (sel[3] == 1'b1) begin
		      data_mem3[addr[`DataMemNumLog2+1:2]] <= data_i[31:24];
		    end
			  if (sel[2] == 1'b1) begin
		      data_mem2[addr[`DataMemNumLog2+1:2]] <= data_i[23:16];
		    end
		    if (sel[1] == 1'b1) begin
		      data_mem1[addr[`DataMemNumLog2+1:2]] <= data_i[15:8];
		    end
			  if (sel[0] == 1'b1) begin
		      data_mem0[addr[`DataMemNumLog2+1:2]] <= data_i[7:0];
		    end			   	    
		end
	end
	
	always @ (*) begin
		if (ce == `ChipDisable) begin
		////	data_o <= `ZeroWord;
	  end else if(we == `WriteDisable) begin
		    data_o <= {data_mem3[addr[`DataMemNumLog2+1:2]],
		               data_mem2[addr[`DataMemNumLog2+1:2]],
		               data_mem1[addr[`DataMemNumLog2+1:2]],
		               data_mem0[addr[`DataMemNumLog2+1:2]]};
		end else begin
				data_o <= `ZeroWord;
		end
	end		

endmodule
