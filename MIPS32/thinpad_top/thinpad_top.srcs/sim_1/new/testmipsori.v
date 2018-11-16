`timescale 1ns / 1ps
`include "defines.h"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/28 21:33:12
// Design Name: 
// Module Name: testmipsori
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


module testmipsori(
    );
    
    reg clock_50;
    reg rst;
    
    initial begin
        clock_50 = 1'b0;
        forever #10 clock_50 = ~clock_50;
    end
    initial begin
        rst = `RstEnable;  
        #100 rst = `RstDisable;  
        #1100 $stop;
    end  
    
    mips32_top top0(
        .clk(clock_50),
        .rst(rst)
    );
endmodule
