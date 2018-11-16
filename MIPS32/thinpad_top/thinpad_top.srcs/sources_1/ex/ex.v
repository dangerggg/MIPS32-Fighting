`timescale 1ns / 1ps
`include "defines.h"

module ex(
    input wire                  rst,
    input wire[`AluOpBus]       alu_op_i,
    input wire[`AluOpTypeBus]   alu_op_type_i,
    input wire[`RegBus]         reg1_data_i,
    input wire[`RegBus]         reg2_data_i,
    input wire[`RegAddrBus]     reg_waddr_i,
    input wire                  reg_we_i,
    // jump and branch input
    input wire[`RegBus]         link_addr_i,
    input wire                  is_in_delayslot_i,
    // CP0
    input wire                  mem_cp0_reg_we_i,
    input wire[4:0]             mem_cp0_reg_waddr_i,
    input wire[`RegBus]         mem_cp0_reg_wdata_i,
    input wire                  wb_cp0_reg_we_i,
    input wire[4:0]             wb_cp0_reg_waddr_i,
    input wire[`RegBus]         wb_cp0_reg_wdata_i,
    input wire[`RegBus]         cp0_reg_rdata_i,

    
    //for hilo
    	//HI、LOreg's value
	input wire[`RegBus]           hi_i,
	input wire[`RegBus]           lo_i,

    	//whether instruction  in wb stage will write hi lo
	input wire[`RegBus]           wb_hi_i,
	input wire[`RegBus]           wb_lo_i,
	input wire                    wb_whilo_i,
	
	//whether instruction  in mem stage will write hi lo 
	input wire[`RegBus]           mem_hi_i,
	input wire[`RegBus]           mem_lo_i,
	input wire                    mem_whilo_i,
//for mult
	// input wire[`DoubleRegBus]     hilo_temp_i,
	// input wire[1:0]               cnt_i,

//for exception
    input wire[31:0]              excepttype_i,
	input wire[`RegBus]          current_inst_address_i,
    output wire[31:0]             excepttype_o,
	output wire                   is_in_delayslot_o,
	output wire[`RegBus]          current_inst_address_o,
//end for exception
    output reg[4:0]             cp0_reg_raddr_o,
    // pass to write CP0
    output reg                  cp0_reg_we_o,
    output reg[4:0]             cp0_reg_waddr_o,
    output reg[`RegBus]         cp0_reg_wdata_o,
    //for ram
    input wire[`RegBus]         inst_i,



    output reg[`RegAddrBus]     reg_waddr_o,
    output reg                  reg_we_o,
    output reg[`RegBus]         reg_wdata_o,
//to ctrl perhaps will be used later
    output reg		            stallreq,
    //for ram
    output wire[`AluOpBus]      alu_op_o,
    output wire[`RegBus]        mem_addr_o,
    output wire[`RegBus]        reg2_data_o,
// write hilo in ex stage
    output reg[`RegBus]           hi_o,
	output reg[`RegBus]           lo_o,
	output reg                    whilo_o	
    // 	output reg[`DoubleRegBus]     hilo_temp_o,
	// output reg[1:0]               cnt_o,


    
);

    reg[`RegBus] HI;//save latest hi
    reg[`RegBus] LO; // save latest lo

    // 逻辑输出
    reg[`RegBus] logic_out;
    reg[`RegBus] shift_out;
    reg[`RegBus] arith_out;
    reg[`RegBus] move_out;

    wire[`RegBus] reg2_cmpl; // Two's complement of reg2
    wire[`RegBus] sum_out;
    wire[`RegBus] sum_ov;
    wire reg1_lt_reg2;
    wire[`RegBus] reg1_i_not;
    reg trapassert; //wether there is trap exception
    reg ovassert; //wether this is overflow exception

    //for exception
    assign excepttype_o = {excepttype_i[31:12],ovassert,trapassert,excepttype_i[9:8],8'h00};
    assign is_in_delayslot_o = is_in_delayslot_i;
	assign current_inst_address_o = current_inst_address_i;



//send alu_op_i to MEM stage for RAM controller to use
    assign alu_op_o = alu_op_i;
    // get the address which equals GPR[base] + imm
    assign mem_addr_o = reg1_data_i + {{16{inst_i[15]}},inst_i[15:0]};
// the data to load in load instruction
    assign reg2_data_o = reg2_data_i;

    assign reg2_cmpl = ((alu_op_i == `ALU_OP_SUB) || (alu_op_i == `ALU_OP_SUBU) || (alu_op_i == `ALU_OP_SLT)) ? ((~reg2_data_i)+1) : reg2_data_i;
    assign sum_out = reg1_data_i + reg2_cmpl;
    assign sum_ov = (!reg1_data_i[31] && !reg2_cmpl[31] && sum_out[31]) || (reg1_data_i[31] && reg2_cmpl[31] && !sum_out[31]);
    assign reg1_lt_reg2 = (alu_op_i == `ALU_OP_SLT) ? ((reg1_data_i[31] && !reg2_data_i) || (!reg1_data_i && !reg2_data_i && sum_out[31]) || (reg1_data_i && reg2_data_i && sum_out[31])) : (reg1_data_i < reg2_data_i);
    assign reg1_i_not = ~reg1_data_i;

    always @ (*) begin
		if(rst == `RstEnable) begin
			trapassert <= `TrapNotAssert;
		end else begin
			trapassert <= `TrapNotAssert;
			case (alu_op_i)
				// `EXE_TEQ_OP, `EXE_TEQI_OP:		begin
				// 	if( reg1_i == reg2_i ) begin
				// 		trapassert <= `TrapAssert;
				// 	end
				// end
				// `EXE_TGE_OP, `EXE_TGEI_OP, `EXE_TGEIU_OP, `EXE_TGEU_OP:		begin
				// 	if( ~reg1_lt_reg2 ) begin
				// 		trapassert <= `TrapAssert;
				// 	end
				// end
				// `EXE_TLT_OP, `EXE_TLTI_OP, `EXE_TLTIU_OP, `EXE_TLTU_OP:		begin
				// 	if( reg1_lt_reg2 ) begin
				// 		trapassert <= `TrapAssert;
				// 	end
				// end
				// `EXE_TNE_OP, `EXE_TNEI_OP:		begin
				// 	if( reg1_i != reg2_i ) begin
				// 		trapassert <= `TrapAssert;
				// 	end
				// end
				default:				begin
					trapassert <= `TrapNotAssert;
				end
			endcase
		end
	end
    //get latest hi lo reg to solve data hazard
    always @ (*) begin
		if(rst == `RstEnable) begin
			{HI,LO} <= {`ZeroWord,`ZeroWord};
		end else if(mem_whilo_i == `WriteEnable) begin
			{HI,LO} <= {mem_hi_i,mem_lo_i};
		end else if(wb_whilo_i == `WriteEnable) begin
			{HI,LO} <= {wb_hi_i,wb_lo_i};
		end else begin
			{HI,LO} <= {hi_i,lo_i};			
		end
	end	





    // logic operation
    always @ (*) begin
        if (rst == `RstEnable) begin
            logic_out <= 32'h0;
        end else begin
            case (alu_op_i)
                `ALU_OP_AND: begin
                    logic_out <= reg1_data_i & reg2_data_i;
                end
                `ALU_OP_OR: begin
                    logic_out <= reg1_data_i | reg2_data_i;
                end
                `ALU_OP_XOR: begin
                    logic_out <= reg1_data_i ^ reg2_data_i;
                end
                `ALU_OP_NOR: begin
                    logic_out <= ~(reg1_data_i | reg2_data_i);
                end
                
                default: begin
                    logic_out <= 32'h0;
                end
            endcase
        end
    end

    // shift operation
    always @ (*) begin
        if (rst == `RstEnable) begin
            shift_out <= 32'h0;
        end else begin
            case (alu_op_i)
                `ALU_OP_SLL: begin
                    shift_out <= reg2_data_i << reg1_data_i[4:0];
                end
                `ALU_OP_SRL: begin
                    shift_out <= reg2_data_i >> reg1_data_i[4:0];
                end
                `ALU_OP_SRA: begin
                    shift_out <= ({32{reg2_data_i[31]}} << (6'd32-{1'b0,reg1_data_i[4:0]})) | reg2_data_i >> reg1_data_i[4:0];
                end
                default: begin
                    shift_out <= 32'h0;
                end
            endcase
        end
    end

    // arithmetic operation
    always @ (*) begin
        if (rst == `RstEnable) begin
            arith_out <= 32'h0;
        end else begin
            case (alu_op_i)
                `ALU_OP_SLT, `ALU_OP_SLTU: begin
                    arith_out <= reg1_lt_reg2;
                end
                `ALU_OP_ADD, `ALU_OP_ADDU, `ALU_OP_ADDI, `ALU_OP_ADDIU: begin
                    arith_out <= sum_out;
                end
                `ALU_OP_SUB, `ALU_OP_SUBU: begin
                    arith_out <= sum_out;
                end
                default: begin
                    arith_out <= 32'h0;
                end
            endcase
        end
    end

    // Move
    always @ (*) begin
        if (rst == `RstEnable) begin
            move_out <= 32'h0;
        end else begin
            move_out <= `ZeroWord;
            case (alu_op_i)
                `ALU_OP_MFHI: begin
                    move_out <= HI;
                end
                `ALU_OP_MFLO: begin
                    move_out <= LO;
                end
                `ALU_OP_MFC0: begin
                    cp0_reg_raddr_o <= inst_i[15:11];
                    move_out <= cp0_reg_rdata_i;
                    // data conflict in mem
                    if (mem_cp0_reg_we_i == `WriteEnable && mem_cp0_reg_waddr_i == inst_i[15:11]) begin
                        move_out <= mem_cp0_reg_wdata_i;
                    end else if ( wb_cp0_reg_we_i == `WriteEnable && wb_cp0_reg_waddr_i == inst_i[15:11]) begin
                        move_out <= wb_cp0_reg_wdata_i;
                    end
                end
                default: begin
                    move_out <= 32'h0;
                end
            endcase
        end
    end

    	always @ (*) begin
		if(rst == `RstEnable) begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;		
		// end else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin
		// 	whilo_o <= `WriteEnable;
		// 	hi_o <= mulres[63:32];
		// 	lo_o <= mulres[31:0];			
		// end else if((aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MADDU_OP)) begin
		// 	whilo_o <= `WriteEnable;
		// 	hi_o <= hilo_temp1[63:32];
		// 	lo_o <= hilo_temp1[31:0];
		// end else if((aluop_i == `EXE_MSUB_OP) || (aluop_i == `EXE_MSUBU_OP)) begin
		// 	whilo_o <= `WriteEnable;
		// 	hi_o <= hilo_temp1[63:32];
		// 	lo_o <= hilo_temp1[31:0];		
		// end else if((aluop_i == `EXE_DIV_OP) || (aluop_i == `EXE_DIVU_OP)) begin
		// 	whilo_o <= `WriteEnable;
		// 	hi_o <= div_result_i[63:32];
		// 	lo_o <= div_result_i[31:0];							
		end else if(alu_op_i == `ALU_OP_MTHI) begin
			whilo_o <= `WriteEnable;
			hi_o <= reg1_data_i;
			lo_o <= LO;
		end else if(alu_op_i == `ALU_OP_MTLO) begin
			whilo_o <= `WriteEnable;
			hi_o <= HI;
			lo_o <= reg1_data_i;
		end else begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
		end				
	end		

    // MTC0 Move reg data to CP0 reg
    always @ (*) begin
        if (rst == `RstEnable) begin
            cp0_reg_we_o    <= `WriteDisable;
            cp0_reg_waddr_o <= 5'b00000;
            cp0_reg_wdata_o <= 32'h0;
        end else if (alu_op_i == `ALU_OP_MTC0) begin
            cp0_reg_we_o    <= `WriteEnable;
            cp0_reg_waddr_o <= inst_i[15:11];
            cp0_reg_wdata_o <= reg1_data_i;
        end else begin
            cp0_reg_we_o    <= `WriteDisable;
            cp0_reg_waddr_o <= 5'b00000;
            cp0_reg_wdata_o <= 32'h0;
        end
    end

    // 选择�??
    always @ (*) begin
        reg_waddr_o <= reg_waddr_i;
        if (((alu_op_i == `ALU_OP_ADD) || (alu_op_i == `ALU_OP_ADDI) || 
              (alu_op_i == `ALU_OP_SUB))&&( sum_ov == 1'b1 )) begin
            reg_we_o <= `WriteDisable;
            ovassert <= 1'b1;
        end else begin
            reg_we_o <= reg_we_i;
            ovassert <= 1'b0;
        end
        case (alu_op_type_i)
            `ALU_OP_TYPE_LOGIC: begin
                reg_wdata_o <= logic_out;
            end
            `ALU_OP_TYPE_SHIFT: begin
                reg_wdata_o <= shift_out;
            end
            `ALU_OP_TYPE_ARITHMETIC: begin
                reg_wdata_o <= arith_out;
            end
            `ALU_OP_TYPE_JUMP_BRANCH: begin
                reg_wdata_o <= link_addr_i;
            end
            `ALU_OP_TYPE_MOVE: begin
                reg_wdata_o <= move_out;
            end
            default: begin
                reg_wdata_o <= 32'h00000000;
            end     
        endcase
    end
endmodule
