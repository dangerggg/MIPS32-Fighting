`timescale 1ns / 1ps
`include "defines.h"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/26 14:15:06
// Design Name: 
// Module Name: mem_wb
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


module mem_wb(
    input wire   clk,
    input wire  rst,
    
    // result of Mem Access
    input wire[`RegAddrBus] mem_reg_waddr,
    input wire              mem_reg_we,
    input wire[`RegBus]     mem_reg_wdata,
    
    input wire[`RegAddrBus] mem_cp0_reg_waddr,
    input wire              mem_cp0_reg_we,
    input wire[`RegBus]     mem_cp0_reg_wdata,
    
    //from ctrl
    input wire[5:0]        stall,
//for exception 
    input wire flush,

    //for hilo
    input wire[`RegBus]           mem_hi,
	  input wire[`RegBus]           mem_lo,
	  input wire                    mem_whilo,
    output reg[`RegBus]          wb_hi,
    output reg[`RegBus]          wb_lo,
    output reg                   wb_whilo,
      
    
    //information  to send to WB stage
    output reg[`RegAddrBus]  wb_reg_waddr,
    output reg               wb_reg_we,
    output reg[`RegBus]      wb_reg_wdata,
    
    output reg[`RegAddrBus]  wb_cp0_reg_waddr,
    output reg               wb_cp0_reg_we,
    output reg[`RegBus]      wb_cp0_reg_wdata
    
    );
    
    always @ (posedge clk) begin  
          if(rst == `RstEnable) begin  
            wb_reg_waddr    <= `NOPRegAddr;  
            wb_reg_we       <= `WriteDisable;  
            wb_reg_wdata    <= `ZeroWord;   
            wb_cp0_reg_waddr    <= `NOPRegAddr;  
            wb_cp0_reg_we       <= `WriteDisable;  
            wb_cp0_reg_wdata    <= `ZeroWord;   
            wb_hi <= `ZeroWord;
		        wb_lo <= `ZeroWord;
            wb_whilo <= `WriteDisable;

          end else if (flush == 1'b1) begin
            wb_reg_waddr    <= `NOPRegAddr;  
            wb_reg_we       <= `WriteDisable;  
            wb_reg_wdata    <= `ZeroWord;   
            wb_cp0_reg_waddr    <= `NOPRegAddr;  
            wb_cp0_reg_we       <= `WriteDisable;  
            wb_cp0_reg_wdata    <= `ZeroWord;   
            wb_hi <= `ZeroWord;
		        wb_lo <= `ZeroWord;
            wb_whilo <= `WriteDisable;



          end else if (stall[4] == `Stop && stall[5] == `NoStop)begin
            wb_reg_waddr    <= `NOPRegAddr;  
            wb_reg_we       <= `WriteDisable;  
            wb_reg_wdata    <= `ZeroWord; 
            wb_cp0_reg_waddr    <= `NOPRegAddr;  
            wb_cp0_reg_we       <= `WriteDisable;  
            wb_cp0_reg_wdata    <= `ZeroWord;   
            wb_hi <= `ZeroWord;
            wb_lo <= `ZeroWord;
            wb_whilo <= `WriteDisable;
          end else if (stall[4] == `NoStop) begin  
            wb_reg_waddr  <= mem_reg_waddr;  
            wb_hi <= mem_hi;
            wb_lo <= mem_lo;
            wb_whilo <= mem_whilo;
            wb_reg_we     <= mem_reg_we;  
            wb_reg_wdata  <= mem_reg_wdata;
            wb_cp0_reg_waddr  <= mem_cp0_reg_waddr;  
            wb_cp0_reg_we     <= mem_cp0_reg_we;  
            wb_cp0_reg_wdata  <= mem_cp0_reg_wdata;  
          end      
        end        
endmodule
