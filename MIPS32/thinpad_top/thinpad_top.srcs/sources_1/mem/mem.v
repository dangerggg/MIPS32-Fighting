`timescale 1ns / 1ps
`include "defines.h"
/* Byte Select
be_n 3:0
sel 3:0
	 1000 0100  0010  0001     
byteAddr 1:0
	 11   10     01    00
*/
module mem(
    input wire  rst,
    
    // information  form  Exe  Stage 
    input wire[`RegAddrBus]     reg_waddr_i,
    input wire                  reg_we_i,
    input wire[`RegBus]         reg_wdata_i,
    // CP0 from ex
    input wire[`RegAddrBus]     cp0_reg_waddr_i,
    input wire                  cp0_reg_we_i,
    input wire[`RegBus]         cp0_reg_wdata_i,
    
	//for hilo
	input wire[`RegBus]           hi_i,
	input wire[`RegBus]           lo_i,
	input wire                    whilo_i,	
	//for exception 
	input wire[31:0]             excepttype_i,
	input wire                   is_in_delayslot_i,
	input wire[`RegBus]          current_inst_address_i,
	input wire[`RegBus]          cp0_status_i, // CP0's value, don't need to be the latest;
	input wire[`RegBus]          cp0_cause_i,
	input wire[`RegBus]          cp0_epc_i,
	// wether wb stage will write CP0's register
	input wire                    wb_cp0_reg_we,
	input wire[4:0]               wb_cp0_reg_write_addr,
	input wire[`RegBus]           wb_cp0_reg_data,
	

    // result of Mem Access
// for ram
    input wire[`AluOpBus]       alu_op_i,
    input wire[`RegBus]         mem_addr_i,
    input wire[`RegBus]         reg2_data_i,

    input wire[`RegBus]         mem_data_i,//fetch data from RAM
//for ram  send to RAM

    output reg[`RegBus]         mem_addr_o,
    output wire                 mem_we_o,
    output reg[3:0]             mem_sel_o,//Select which Byte to load or store
    output reg[`RegBus]         mem_data_o,
    output reg                  mem_ce_o,//Enable Ram
	//for exception
	output reg[31:0]             excepttype_o,
	output wire[`RegBus]          cp0_epc_o,
	output wire                  is_in_delayslot_o,
	
	output wire[`RegBus]         current_inst_address_o,
	//end for exception


    // result of Mem Access   send to WB
    output reg[`RegAddrBus]     reg_waddr_o,
    output reg                  reg_we_o,
    output reg[`RegBus]         reg_wdata_o,
    // CP0 out
    output reg[`RegAddrBus]     cp0_reg_waddr_o,
    output reg                  cp0_reg_we_o,
    output reg[`RegBus]         cp0_reg_wdata_o,
	//for hilo
	output reg[`RegBus]          hi_o,
	output reg[`RegBus]          lo_o,
	output reg                   whilo_o	
    
    );
    
	// for exception   store the latest in CP0
	reg[`RegBus]          cp0_status;
	reg[`RegBus]          cp0_cause;
	reg[`RegBus]          cp0_epc;	
	assign is_in_delayslot_o = is_in_delayslot_i;
	assign current_inst_address_o = current_inst_address_i;
	assign cp0_epc_o = cp0_epc;

    wire[`RegBus]   zero32;
    reg             mem_we;
    assign mem_we_o = mem_we & (~(|excepttype_o));// wether to write or read RAM
    assign zero32 = `ZeroWord; 

    always @(*) begin
        if (rst == `RstEnable) begin
            reg_waddr_o <= `NOPRegAddr;
            reg_we_o<=`WriteDisable;
            reg_wdata_o <=`ZeroWord;
            cp0_reg_waddr_o <= `NOPRegAddr;
            cp0_reg_we_o    <=`WriteDisable;
            cp0_reg_wdata_o <=`ZeroWord;
            mem_addr_o <= `ZeroWord;
            mem_we <= `WriteDisable;
            mem_sel_o <= 4'b0000;
            mem_data_o <= `ZeroWord;
            mem_ce_o <= `ChipDisable;
			hi_o <= `ZeroWord;
		  lo_o <= `ZeroWord;
		  whilo_o <= `WriteDisable;		  
        end 
        else begin
            reg_waddr_o <= reg_waddr_i;
            reg_we_o <= reg_we_i;
            reg_wdata_o <= reg_wdata_i;
            cp0_reg_waddr_o <= cp0_reg_waddr_i;
            cp0_reg_we_o    <= cp0_reg_we_i;
            cp0_reg_wdata_o <= cp0_reg_wdata_i;
            mem_addr_o <= `ZeroWord;
            mem_we <= `WriteDisable;
            mem_sel_o <= 4'b1111;
            mem_data_o <= `ZeroWord;
            mem_ce_o <= `ChipDisable;
			hi_o <= hi_i;
			lo_o <= lo_i;
			whilo_o <= whilo_i;	
            case (alu_op_i)
				`ALU_OP_LB:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							//reg_wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};//this will impact on big_Endian or little_Endian
							reg_wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
							mem_sel_o <= 4'b1111;//4'b0001;//4'b1000;
						end
						2'b01:	begin
						//	reg_wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
							reg_wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
							mem_sel_o <= 4'b1111;//4'b0010;//4'b0100;
						end
						2'b10:	begin
							// reg_wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
							reg_wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
							mem_sel_o <= 4'b1111;// 4'b0010;
						end
						2'b11:	begin
							//reg_wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
							reg_wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
							mem_sel_o <= 4'b1111;//4'b0001;
						end
						default:	begin
							reg_wdata_o <= `ZeroWord;
						end
					endcase
                end
				`ALU_OP_LBU:		begin//LBU didn't change as LB did , DON'T USE IT!
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							reg_wdata_o <= {{24{1'b0}},mem_data_i[31:24]};
							mem_sel_o <= 4'b1000;
						end
						2'b01:	begin
							reg_wdata_o <= {{24{1'b0}},mem_data_i[23:16]};
							mem_sel_o <= 4'b0100;
						end
						2'b10:	begin
							reg_wdata_o <= {{24{1'b0}},mem_data_i[15:8]};
							mem_sel_o <= 4'b0010;
						end
						2'b11:	begin
							reg_wdata_o <= {{24{1'b0}},mem_data_i[7:0]};
							mem_sel_o <= 4'b0001;
						end
						default:	begin
							reg_wdata_o <= `ZeroWord;
						end
					endcase				
				end
				`ALU_OP_LH:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							reg_wdata_o <= {{16{mem_data_i[31]}},mem_data_i[31:16]};
							mem_sel_o <= 4'b1100;
						end
						2'b10:	begin
							reg_wdata_o <= {{16{mem_data_i[15]}},mem_data_i[15:0]};
							mem_sel_o <= 4'b0011;
						end
						default:	begin
							reg_wdata_o <= `ZeroWord;
						end
					endcase					
				end
				`ALU_OP_LHU:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							reg_wdata_o <= {{16{1'b0}},mem_data_i[31:16]};
							mem_sel_o <= 4'b1100;
						end
						2'b10:	begin
							reg_wdata_o <= {{16{1'b0}},mem_data_i[15:0]};
							mem_sel_o <= 4'b0011;
						end
						default:	begin
							reg_wdata_o <= `ZeroWord;
						end
					endcase				
				end
				`ALU_OP_LW:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					reg_wdata_o <= mem_data_i;
					mem_sel_o <= 4'b1111;
					mem_ce_o <= `ChipEnable;		
				end
				
				`ALU_OP_SB:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteEnable;
					mem_data_o <= {reg2_data_i[7:0],reg2_data_i[7:0],reg2_data_i[7:0],reg2_data_i[7:0]};
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							mem_sel_o <= 4'b0001; //4'b1000;
						end
						2'b01:	begin
							mem_sel_o <= 4'b0010;//4'b0100;
						end
						2'b10:	begin
							mem_sel_o <= 4'b0100;//4'b0010;
						end
						2'b11:	begin
							mem_sel_o <= 4'b1000;//4'b0001;		
						end
						default:	begin
							mem_sel_o <= 4'b0000;
						end
					endcase				
				end
				`ALU_OP_SH:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteEnable;
					mem_data_o <= {reg2_data_i[15:0],reg2_data_i[15:0]};
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
				`ALU_OP_SW:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteEnable;
					mem_data_o <= reg2_data_i;
					mem_sel_o <= 4'b1111;	
					mem_ce_o <= `ChipEnable;		
				end
				
				default:		begin
          //do nothing
				end
			endcase			
        end
    end
    

	always@(*) begin
		if (rst == `RstEnable) begin
			cp0_status <= `ZeroWord;
		end else if ((wb_cp0_reg_we == `WriteEnable)&&
						(wb_cp0_reg_write_addr == `CP0_REG_STATUS)) begin
			cp0_status <= wb_cp0_reg_data;
		end else begin
			cp0_status <= cp0_status_i;
		end
	end

	always@(*) begin
		if(rst == `RstEnable) begin
			cp0_epc <= `ZeroWord;
		end else if((wb_cp0_reg_we == `WriteEnable) && 
								(wb_cp0_reg_write_addr == `CP0_REG_EPC ))begin
			cp0_epc <= wb_cp0_reg_data;
		end else begin
		  cp0_epc <= cp0_epc_i;
		end
	end
//
	always @ (*) begin
		if(rst == `RstEnable) begin
			cp0_cause <= `ZeroWord;
		end else if((wb_cp0_reg_we == `WriteEnable) && 
								(wb_cp0_reg_write_addr == `CP0_REG_CAUSE ))begin
			cp0_cause[9:8] <= wb_cp0_reg_data[9:8];//IP
			cp0_cause[22] <= wb_cp0_reg_data[22];//WP
			cp0_cause[23] <= wb_cp0_reg_data[23];//IV
		end else begin
		  cp0_cause <= cp0_cause_i;
		end
	end
//finally get type of ecxeption 
	always @ (*) begin
		if(rst == `RstEnable) begin
			excepttype_o <= `ZeroWord;
		end else begin
			excepttype_o <= `ZeroWord;
			
			if(current_inst_address_i != `ZeroWord) begin
				if(((cp0_cause[15:8] & (cp0_status[15:8])) != 8'h00) && (cp0_status[1] == 1'b0) && 
							(cp0_status[0] == 1'b1)) begin
					excepttype_o <= 32'h00000001;        //interrupt
				end else if(excepttype_i[8] == 1'b1) begin
			  	excepttype_o <= 32'h00000008;        //syscall
				end else if(excepttype_i[9] == 1'b1) begin
					excepttype_o <= 32'h0000000a;        //inst_invalid
				end else if(excepttype_i[10] ==1'b1) begin
					excepttype_o <= 32'h0000000d;        //trap
				end else if(excepttype_i[11] == 1'b1) begin  //ov
					excepttype_o <= 32'h0000000c;
				end else if(excepttype_i[12] == 1'b1) begin  //eret
					excepttype_o <= 32'h0000000e;
				end
			end
				
		end
	end		
endmodule
