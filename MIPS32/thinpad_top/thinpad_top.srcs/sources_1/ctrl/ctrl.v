`timescale 1ns / 1ps
`include "defines.h"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/05 21:32:34
// Design Name: 
// Module Name: ctrl
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


module ctrl(
    input wire   rst,
    input wire   stallreq_from_id, 
    input wire   stallreq_from_ex, //stall request from ex (MUL and Div)
    input wire   stallreq_from_if,
    input wire   stallreq_from_mem,

    // for exception 
    input wire[31:0]             excepttype_i,
	input wire[`RegBus]          cp0_epc_i,
    output reg[`RegBus]          new_pc,
	output reg                   flush,	
    //end for exception 
    output reg[5:0] stall
    /*
    1/ stall[0] == 1  means PC keep unchanged
    2) stall[1] == 1 IF statge stop
    3) stall[2] == 1 ID stop
    4) stall[3] == 1 EXE stop
    5) stall[4] == 1 MEM�?stop
    6) stall[5] == 1 WB stop
    */
    );

always @(*) begin
    if (rst == `RstEnable) begin 
        stall <= 6'b0;
        flush <= 1'b0;
        new_pc <= `ZeroWord;
    end else if(excepttype_i != `ZeroWord) begin
		  flush <= 1'b1;
		  stall <= 6'b000000;
			case (excepttype_i)
				32'h00000001:		begin   //interrupt
					new_pc <= 32'h80001180;
				end
				32'h00000008:		begin   //syscall
					new_pc <= 32'h80001180;
				end
				32'h0000000a:		begin   //inst_invalid
					new_pc <= 32'h80001180;
				end
				32'h0000000d:		begin   //trap
					new_pc <= 32'h80001180;
				end
				32'h0000000c:		begin   //ov
					new_pc <= 32'h80001180;
				end
				32'h0000000e:		begin   //eret
					new_pc <= cp0_epc_i;
				end
				default	: begin
				end
			endcase 	
    end else if (stallreq_from_mem == `Stop) begin
        stall <= 6'b011111;
        flush <= 1'b0;
    end else if (stallreq_from_ex == `Stop) begin
        stall <= 6'b001111;
        flush <= 1'b0;
    end else if (stallreq_from_id == `Stop) begin
        stall <= 6'b000111;
    end else if (stallreq_from_if == `Stop) begin
        stall <= 6'b000111;
        flush <= 1'b0;
    end else begin
        stall <= 6'b000000;
        flush <= 1'b0;
        new_pc <= `ZeroWord;
    end
end


endmodule



