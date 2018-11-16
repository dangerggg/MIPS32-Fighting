`include "defines.h"

module cp0_reg(
    input wire          clk,
    input wire          rst,
    
    input wire          we_i,
    input wire[4:0]     waddr_i,
    input wire[4:0]     raddr_i,
    input wire[`RegBus] wdata_i,
    input wire[5:0]     int_i,
//for exception
    input wire[31:0]              excepttype_i,
	input wire[`RegBus]           current_inst_addr_i,
	input wire                    is_in_delayslot_i,
//end for exception
    output reg[`RegBus] rdata_o,
    output reg[`RegBus] count_o,
    output reg[`RegBus] compare_o,
    output reg[`RegBus] status_o,
    output reg[`RegBus] cause_o,
    output reg[`RegBus] epc_o,
    output reg[`RegBus] config_o,
    output reg[`RegBus] prid_o,

    output reg          timer_int_o
);
    // ====== Write Reg ========
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            count_o     <= 0;
            compare_o   <= 32'h0;
            // CU = 4'b0001  === CP0 exist
            status_o    <= 32'b00010000000000000000000000000000;
            cause_o     <= 32'h0;
            epc_o       <= 32'h0;
            // BE = 1 === MSB da duan mo shi
            config_o    <= 32'b00000000000000001000000000000000;
            prid_o      <= 32'b00000000000000000000000000000010;
            timer_int_o <= `InterruptNotAssert;
        end else begin
            count_o <= count_o + 1;
            cause_o[15:10] <= int_i; // IP, Interrupt Pending
            // timer interrupt, ding shi zhong duan
            if (compare_o != 32'h0 && count_o == compare_o) begin
                timer_int_o <= `InterruptAssert;
            end 

            if (we_i == `WriteEnable) begin
                case (waddr_i)
                    `CP0_REG_COUNT: begin
                        count_o <= wdata_i;
                    end
                    `CP0_REG_COMPARE: begin
                        compare_o <= wdata_i;
                        timer_int_o <= `InterruptNotAssert;
                    end
                    `CP0_REG_COUNT: begin
                        count_o <= wdata_i;
                    end
                    `CP0_REG_STATUS: begin
                        status_o <= wdata_i;
                    end
                    `CP0_REG_EPC: begin
                        epc_o <= wdata_i;
                    end
                    `CP0_REG_CAUSE: begin
                        cause_o[23]     <= wdata_i[23]; // IV, interrupt Vector 0 normal, 1 special
                        cause_o[22]     <= wdata_i[22]; // WP, Watch Pending
                        cause_o[9:8]    <= wdata_i[9:8]; // IP[1:0], software interrupt pending
                    end
                    default: begin
                    end
                endcase
            end
            case (excepttype_i)
				32'h00000001:		begin
					if(is_in_delayslot_i == `InDelaySlot ) begin
						epc_o <= current_inst_addr_i - 4 ;
						cause_o[31] <= 1'b1;
					end else begin
					  epc_o <= current_inst_addr_i;
					  cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b00000;
					
				end
				32'h00000008:		begin
					if(status_o[1] == 1'b0) begin
						if(is_in_delayslot_i == `InDelaySlot ) begin
							epc_o <= current_inst_addr_i - 4 ;
							cause_o[31] <= 1'b1;
						end else begin
					  	epc_o <= current_inst_addr_i;
					  	cause_o[31] <= 1'b0;
						end
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01000;			
				end
				32'h0000000a:		begin
					if(status_o[1] == 1'b0) begin
						if(is_in_delayslot_i == `InDelaySlot ) begin
							epc_o <= current_inst_addr_i - 4 ;
							cause_o[31] <= 1'b1;
						end else begin
					  	epc_o <= current_inst_addr_i;
					  	cause_o[31] <= 1'b0;
						end
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01010;					
				end
				32'h0000000d:		begin
					if(status_o[1] == 1'b0) begin
						if(is_in_delayslot_i == `InDelaySlot ) begin
							epc_o <= current_inst_addr_i - 4 ;
							cause_o[31] <= 1'b1;
						end else begin
					  	epc_o <= current_inst_addr_i;
					  	cause_o[31] <= 1'b0;
						end
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01101;					
				end
				32'h0000000c:		begin
					if(status_o[1] == 1'b0) begin
						if(is_in_delayslot_i == `InDelaySlot ) begin
							epc_o <= current_inst_addr_i - 4 ;
							cause_o[31] <= 1'b1;
						end else begin
					  	epc_o <= current_inst_addr_i;
					  	cause_o[31] <= 1'b0;
						end
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01100;					
				end				
				32'h0000000e:   begin
					status_o[1] <= 1'b0;
				end
				default:				begin
				end
			endcase			
        end
    end

    // ======== Read Reg =========
    always @ (*) begin
        if (rst == `RstEnable) begin
            rdata_o <= 32'h0;
        end else begin
            case (raddr_i)
                `CP0_REG_COUNT: begin
                    rdata_o <= count_o;
                end
                `CP0_REG_COMPARE: begin
                    rdata_o <= compare_o;
                end
                `CP0_REG_STATUS: begin
                    rdata_o <= status_o;
                end
                `CP0_REG_CAUSE: begin
                    rdata_o <= cause_o;
                end
                `CP0_REG_EPC: begin
                    rdata_o <= epc_o;
                end
                `CP0_REG_PrId: begin
                    rdata_o <= prid_o;
                end
                `CP0_REG_CONFIG: begin
                    rdata_o <= config_o;
                end
                default: begin
                end
            endcase
        end
    end
endmodule
