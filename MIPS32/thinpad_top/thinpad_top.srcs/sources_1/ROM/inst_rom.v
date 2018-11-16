`include "defines.h"
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/28 20:35:51
// Design Name: 
// Module Name: inst_rom
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

module inst_rom(  
  
    input wire          ce,  
    input wire[`InstAddrBus]    addr,  
    output reg[`InstBus]        inst  
      
);  
       // 
    reg[`InstBus]  inst_mem[0:`InstMemNum-1];  
  
       // 
    initial $readmemh ( "inst_rom.data", inst_mem );  
  
       // when chipDIsable is on, give ZeroWord,else, give what it saves.
    always @ (*) begin  
      if (ce == `ChipDisable) begin  
        inst <= `ZeroWord;  
      end else begin  
        inst <= inst_mem[addr[`InstMemNumLog2+1:2]];  
      end  
    end  
  
endmodule  