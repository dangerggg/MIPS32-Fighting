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


module testmips(
    );
    
    reg clock_50;
    reg rst;
    
    wire[5:0] int;
    wire timer_int;
    
    assign int = {5'b00000, timer_int};
    
    initial begin
        clock_50 = 1'b0;
        forever #10 clock_50 = ~clock_50;
    end
    initial begin
        rst = `RstEnable;  
        #100 rst = `RstDisable;  
        #5100 $stop;
    end  
    
    wire ce_n;
    wire oe_n;
    wire we_n;
    wire[3:0] sel = 4'b1111;
    wire[19:0] addr;
    wire[31:0] data;

    mips32_top top0(
        .clk(clock_50),
        .rst(rst),
        .int_i(int),
        .timer_int_o(timer_int),
        
        .base_ram_data(data),
        .base_ram_addr(addr),
        .base_ram_ce_n(ce_n),
        .base_ram_oe_n(oe_n),
        .base_ram_we_n(we_n)
    );
    
    fake_ram fake_ram0(
        .ce_n(ce_n),
        .we_n(we_n),                
        .oe_n(oe_n),
        .sel(sel),
        .addr(addr),
        .data_i(data),
        .data_o(data)
        

    );
endmodule
