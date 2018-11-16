`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/26 14:36:32
// Design Name: 
// Module Name: sim_mem
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


module sim_mem(
    
    );
    reg clk;
    reg rst;
    reg[4:0] wd_i;
    reg wreg_i;
    reg[31:0] wdata_i;
    
    wire mem_wreg;
    wire[31:0] mem_data;
    wire[4:0] wb_wd;
    
    wire[4:0] waddro;
    wire[31:0] wdatao;
    wire wrego;
    initial begin
        clk = 1'b0;
        forever #10 clk <= ~clk;
    end
    initial begin
        rst = 1'b1;
        #20 rst = 1'b0;
        #20 
            wreg_i = 1'b1;
            wd_i = 5'b00011;
            wdata_i = 32'h12345678;
        #60
            wreg_i = 1'b1;
            wd_i = 5'b00001;
            wdata_i = 32'h12345678;
        #60
            $stop;
     end
        mem mem0(.rst(rst), .wd_i(wd_i), .wreg_i(wreg_i), .wdata_i(wdata_i),.wd_o(waddro), .wreg_o(wrego), .wdata_o(wdatao));
        /* output reg[`RegAddrBus]   wd_o,
           output reg                wreg_o,
           output reg[`RegBus]       wdata_o*/
        mem_wb mwm_wb0(.clk(clk), .rst(rst), .mem_wd(waddro), .mem_wreg(wrego), .mem_wdata(wdatao),
             .wb_wd( wb_wd), .wb_wreg(mem_wreg), .wb_wdata(mem_data));
        /*
        input wire   clk,
            input wire  rst,
            
            // result of Mem Access
            input wire[`RegAddrBus] mem_wd,
            input wire             mem_wreg;
            input wire[`RegBus]    mem_wdata,
            //information  to send to WB stage
            output reg[`RegAddrBus]  wb_wd;
            output reg               wb_wreg,
            output reg[`RegBus]      wb_wdata
        */
     
        
            
           
        
        
    
    
    
endmodule
