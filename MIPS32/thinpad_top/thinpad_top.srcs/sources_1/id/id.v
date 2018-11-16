`timescale 1ns / 1ps
`include "defines.h"

module id(
    input wire          rst,
    input wire[31:0]          pc_i,
    input wire[31:0]    inst_i,
    
    // 寄存器读取数�???????
    input wire[31:0]    reg1_data_i,
    input wire[31:0]    reg2_data_i,

    // reg result from ex
    input wire              ex_reg_we_i,
    input wire[`RegBus]     ex_reg_wdata_i,
    input wire[`RegAddrBus] ex_reg_waddr_i,
    
    // reg result from mem
    input wire              mem_reg_we_i,
    input wire[`RegBus]     mem_reg_wdata_i,
    input wire[`RegAddrBus] mem_reg_waddr_i,

    // delayslot
    input wire              is_in_delayslot_i,
// for load-use
    input wire[`AluOpBus]   ex_aluop_i,
//for exception     
  output wire[31:0]             excepttype_o,// exception information 
  output wire[`RegBus]          current_inst_address_o, // the instruction's address which is on ID stage
	


    // 寄存器读取使�???????
    output reg          reg1_re_o,
    output reg          reg2_re_o,

    // 寄存器读取地�???????
    output reg[4:0]     reg1_raddr_o,
    output reg[4:0]     reg2_raddr_o,

    output reg[7:0]     alu_op_o, // alu 运算类型
    output reg[2:0]     alu_op_type_o, // alu 输出选择�???????

    // 寄存器输�???????
    output reg[31:0]    reg1_data_o,
    output reg[31:0]    reg2_data_o,
 
    output reg          reg_we_o, // 写入目的寄存器使�???????
    output reg[4:0]     reg_waddr_o,   // 写入目的寄存器地�???????

    // to ctrl
    output wire        stallreq,

    // delayslot 
    output reg          next_inst_in_delayslot_o,
    output reg          branch_flag_o,
    output reg[`RegBus] branch_target_addr_o,
    output reg[`RegBus] link_addr_o,
    output reg          is_in_delayslot_o,

    //For RAM
    output wire[`RegBus] inst_o   // output the instruction
);


 

    wire[5:0] op        = inst_i[31:26];
    wire[4:0] rs        = inst_i[25:21];
    wire[4:0] rt        = inst_i[20:16];
    wire[4:0] rd        = inst_i[15:11];
    wire[5:0] alu_funct = inst_i[5:0];
    
    
    wire[4:0] op2   = inst_i[10:6];
    wire[5:0] op3   = inst_i[5:0];
    wire[4:0] op4   = inst_i[20:16];

    reg[31:0] imm;

    wire[`RegBus] pc_plus_4;
    wire[`RegBus] pc_plus_8;
    wire[`RegBus] imm_sll2_signedext;  
    //for exception 
    reg excepttype_is_syscall;// whether the inst is syscall
    reg excepttype_is_eret; // whether the inst is eret
    reg instvalid;
    //end for
//    for load-use 
    reg stallreq_for_reg1_loadrelate;//whether reg1 has load-use hazard with last instruction
    reg stallreq_for_reg2_loadrelate; //whether reg2 .....
    wire pre_inst_is_load; // whether the last inst is load_inst;

    //for exception
    assign excepttype_o = {19'b0, excepttype_is_eret,2'b0,
                            /*instvalid*/1'b0, excepttype_is_syscall,8'b0};//lower 8 bit set for external interrupt, 8thbit means whether is syscall
                                                                   // 9 bit means whether is instvalid   (temporarily  set always 0)
    assign current_inst_address_o = pc_i;//


    //endfor


    assign pre_inst_is_load = ( (ex_aluop_i == `ALU_OP_LW )||
                                (ex_aluop_i == `ALU_OP_LB )||
                                (ex_aluop_i == `ALU_OP_LBU)||
                                (ex_aluop_i == `ALU_OP_LH )||
                                (ex_aluop_i == `ALU_OP_LHU) )? 1'b1 : 1'b0;
    

    
    
    assign pc_plus_4 = pc_i + 4;
    assign pc_plus_8 = pc_i + 8;
    assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};
    //for ctrl
    assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;
    //for ram
    assign inst_o = inst_i;

    always @ (*) begin        
        if (rst == `RstEnable) begin
            alu_op_o        <= `ALU_OP_NOP;
            alu_op_type_o   <= `ALU_OP_TYPE_NOP;
            reg_waddr_o     <= `NOPRegAddr;
            reg_we_o        <= `WriteDisable;
            reg1_re_o       <= `ReadDisable;
            reg2_re_o       <= `ReadDisable;
            reg1_raddr_o    <= `NOPRegAddr;
            reg2_raddr_o    <= `NOPRegAddr;
            imm             <= 32'h0;
            link_addr_o     <= 32'h0;
            branch_target_addr_o <= 32'h0;
            branch_flag_o   <= `NotBranch;
            next_inst_in_delayslot_o <= `NotInDelaySlot;
            //for exception 
            excepttype_is_syscall <= `False_v;
			excepttype_is_eret <= `False_v;	
        end else begin
            alu_op_o        <= `ALU_OP_NOP;
            alu_op_type_o   <= `ALU_OP_TYPE_NOP;
            reg_waddr_o     <= rd; // 默认15:11???
            reg_we_o        <= `WriteDisable;
            reg1_re_o       <= `ReadDisable;
            reg2_re_o       <= `ReadDisable;
            reg1_raddr_o    <= rs;
            reg2_raddr_o    <= rt;
            imm             <= 32'h0;
            link_addr_o     <= 32'h0;
            branch_target_addr_o <= 32'h0;
            branch_flag_o   <= `NotBranch;
            next_inst_in_delayslot_o <= `NotInDelaySlot;

            excepttype_is_syscall <= `False_v;	
			excepttype_is_eret <= `False_v;		
            
            // CP0 INST
            if (inst_i[31:21] == `INST_MFC0 && inst_i[10:3] == 8'b00000000) begin
                alu_op_o        <= `ALU_OP_MFC0;
                alu_op_type_o   <= `ALU_OP_TYPE_MOVE;
                reg_waddr_o     <= inst_i[20:16];
                reg_we_o        <= `WriteEnable;
                reg1_re_o       <= `ReadDisable;
                reg2_re_o       <= `ReadDisable;   
                // instvalid
            end else if (inst_i[31:21] == `INST_MTC0 && inst_i[10:3] == 8'b00000000) begin
                alu_op_o        <= `ALU_OP_MTC0;
                alu_op_type_o   <= `ALU_OP_TYPE_MOVE;
                reg_we_o        <= `WriteDisable;
                reg1_re_o       <= `ReadEnable;
                reg1_raddr_o    <= inst_i[20:16];
                reg2_re_o       <= `ReadDisable;
                // instvalid

            end else if(inst_i == `INST_ERET) begin
                reg_we_o <= `WriteDisable;		alu_op_o <= `ALU_OP_ERET;
                alu_op_type_o <= `ALU_OP_TYPE_NOP;   reg1_re_o <= 1'b0;	reg1_re_o <= 1'b0;
                instvalid <= `InstValid; excepttype_is_eret<= `True_v;	
            end 
            case(op)
                `INST_SPECIAL: begin // special instruction
                    
                    case(op2)
                        5'b00000: begin // alu function
                            case(alu_funct)
                                `ALU_FUNCT_AND: begin
                                    alu_op_o        <= `ALU_OP_AND;
                                    alu_op_type_o   <= `ALU_OP_TYPE_LOGIC;
                                    reg_we_o        <= `WriteEnable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadEnable;
                                    // instvalid
                                end
                                //`ALU_FUNCT_JR: begin ???
                                //end
                                `ALU_FUNCT_OR: begin
                                    alu_op_o        <= `ALU_OP_OR;
                                    alu_op_type_o   <= `ALU_OP_TYPE_LOGIC;
                                    reg_we_o        <= `WriteEnable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadEnable;
                                    // instvalid
                                end
                                `ALU_FUNCT_XOR: begin
                                    alu_op_o        <= `ALU_OP_XOR;
                                    alu_op_type_o   <= `ALU_OP_TYPE_LOGIC;
                                    reg_we_o        <= `WriteEnable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadEnable;
                                    // instvalid
                                end
                                `ALU_FUNCT_NOR: begin
                                    alu_op_o        <= `ALU_OP_NOR;
                                    alu_op_type_o   <= `ALU_OP_TYPE_LOGIC;
                                    reg_we_o        <= `WriteEnable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadEnable;
                                    // instvalid
                                end
                                `ALU_FUNCT_SLLV: begin
                                    alu_op_o        <= `ALU_OP_SLL;
                                    alu_op_type_o   <= `ALU_OP_TYPE_SHIFT;
                                    reg_we_o        <= `WriteEnable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadEnable;
                                    // instvalid
                                end
                                `ALU_FUNCT_SRLV: begin
                                    alu_op_o        <= `ALU_OP_SRL;
                                    alu_op_type_o   <= `ALU_OP_TYPE_SHIFT;
                                    reg_we_o        <= `WriteEnable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadEnable;
                                    // instvalid
                                end
                                `ALU_FUNCT_SRAV: begin
                                    alu_op_o        <= `ALU_OP_SRA;
                                    alu_op_type_o   <= `ALU_OP_TYPE_SHIFT;
                                    reg_we_o        <= `WriteEnable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadEnable;
                                    // instvalid
                                end
                                // jump
                                `ALU_FUNCT_JR: begin
                                    alu_op_o        <= `ALU_OP_JR;
                                    alu_op_type_o   <= `ALU_OP_TYPE_JUMP_BRANCH;
                                    reg_we_o        <= `WriteDisable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadDisable;
                                    link_addr_o     <= 32'h0;
                                    branch_target_addr_o <= reg1_data_o;
                                    branch_flag_o   <= `Branch;
                                    next_inst_in_delayslot_o <= `InDelaySlot;
                                    // instvalid
                                end
                                `ALU_FUNCT_JALR: begin
                                    alu_op_o        <= `ALU_OP_JALR;
                                    alu_op_type_o   <= `ALU_OP_TYPE_JUMP_BRANCH;
                                    reg_we_o        <= `WriteEnable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadEnable;
                                    reg_waddr_o     <= rd;
                                    link_addr_o     <= pc_plus_8;
                                    branch_target_addr_o <= reg1_data_o;
                                    branch_flag_o   <= `Branch;
                                    next_inst_in_delayslot_o <= `InDelaySlot;
                                    // instvalid
                                end
    //2017.11.29 add 
                                
                                `ALU_FUNCT_SLT: begin
                                    alu_op_o <= `ALU_OP_SLT;
                                    alu_op_type_o <= `ALU_OP_TYPE_ARITHMETIC;
                                    reg_we_o <= `WriteEnable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadEnable;
                                end
                                `ALU_FUNCT_SLTU: begin
                                    alu_op_o <= `ALU_OP_SLTU;
                                    alu_op_type_o <= `ALU_OP_TYPE_ARITHMETIC;
                                    reg_we_o <= `WriteEnable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadEnable;
                                end
                                `ALU_FUNCT_ADD: begin
                                    alu_op_o <= `ALU_OP_ADD;
                                    alu_op_type_o <= `ALU_OP_TYPE_ARITHMETIC;
                                    reg_we_o <= `WriteEnable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadEnable;
                                end
                                `ALU_FUNCT_ADDU: begin 
                                    alu_op_o <= `ALU_OP_ADDU;
                                    alu_op_type_o <= `ALU_OP_TYPE_ARITHMETIC;
                                    reg_we_o <= `WriteEnable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadEnable;
                                end
                                `ALU_FUNCT_SUB: begin
                                    alu_op_o <= `ALU_OP_SUB;
                                    alu_op_type_o <= `ALU_OP_TYPE_ARITHMETIC;
                                    reg_we_o <= `WriteEnable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadEnable;
                                end
                                `ALU_FUNCT_SUBU: begin
                                    alu_op_o <= `ALU_OP_SUBU;
                                    alu_op_type_o <= `ALU_OP_TYPE_ARITHMETIC;
                                    reg_we_o <= `WriteEnable;
                                    reg1_re_o       <= `ReadEnable;
                                    reg2_re_o       <= `ReadEnable;
                                end
                                `ALU_FUNCT_MFHI: begin    //EXE_RES_MOVE
                                    alu_op_o <= `ALU_OP_MFHI;
                                    alu_op_type_o <= `ALU_OP_TYPE_MOVE;
                                    reg_we_o <= `WriteEnable;
                                    reg1_re_o <= 1'b0;
                                    reg2_re_o <= 1'b0;
                                    //instvalid
                                end
                                `ALU_FUNCT_MFLO: begin
                                    alu_op_o <= `ALU_OP_MFLO;
                                    alu_op_type_o <= `ALU_OP_TYPE_MOVE;
                                    reg_we_o <= `WriteEnable;
                                    reg1_re_o <= 1'b0;
                                    reg2_re_o <= 1'b0;
                                    //instvalid
                                end
                                `ALU_FUNCT_MTHI: begin
                                    alu_op_o <= `ALU_OP_MTHI;
                                    reg_we_o <= `WriteDisable;
                                    reg1_re_o <= 1'b1;
                                    reg2_re_o <= 1'b0;
                                    //instvalid
                                end
                                `ALU_FUNCT_MTLO: begin
                                    alu_op_o <= `ALU_OP_MTLO;
                                    reg_we_o <= `WriteDisable;
                                    reg1_re_o <= 1'b1;
                                    reg2_re_o <= 1'b0;
                                    //instvalid
                                end

                            
    //11.29 add end
                                default: begin
                                end
                            endcase
                        end
                        default: begin
                        end
                    endcase


                    case (op3)
                        `ALU_FUNCT_SYSCALL: begin
                            reg_we_o <= `WriteDisable;		alu_op_o <= `ALU_OP_SYSCALL;
                            alu_op_type_o <= `ALU_OP_TYPE_NOP;   reg1_re_o <= 1'b0;	reg2_re_o <= 1'b0;
                            instvalid <= `InstValid;
                            excepttype_is_syscall<= `True_v;
                        end
                        default: begin
                        end
                    endcase
                end



                `INST_ANDI: begin
                    alu_op_o        <= `ALU_OP_AND;
                    alu_op_type_o   <= `ALU_OP_TYPE_LOGIC;
                    reg_waddr_o     <= rt;
                    reg_we_o        <= `WriteEnable;
                    reg1_re_o       <= `ReadEnable;
                    reg2_re_o       <= `ReadDisable;
                    imm             <= {16'h0, inst_i[15:0]};
                    // instvalid
                end
                `INST_ORI: begin
                    alu_op_o        <= `ALU_OP_OR;
                    alu_op_type_o   <= `ALU_OP_TYPE_LOGIC;
                    reg_waddr_o     <= rt;
                    reg_we_o        <= `WriteEnable;
                    reg1_re_o       <= `ReadEnable;
                    reg2_re_o       <= `ReadDisable;
                    imm             <= {16'h0, inst_i[15:0]};
                    // instvalid
                end
                `INST_XORI: begin
                    alu_op_o        <= `ALU_OP_XOR;
                    alu_op_type_o   <= `ALU_OP_TYPE_LOGIC;
                    reg_waddr_o     <= rt;
                    reg_we_o        <= `WriteEnable;
                    reg1_re_o       <= `ReadEnable;
                    reg2_re_o       <= `ReadDisable;
                    imm             <= {16'h0, inst_i[15:0]};
                    // instvalid
                end
                `INST_LUI: begin
                    alu_op_o        <= `ALU_OP_OR;
                    alu_op_type_o   <= `ALU_OP_TYPE_LOGIC;
                    reg_waddr_o     <= rt;
                    reg_we_o        <= `WriteEnable;
                    reg1_re_o       <= `ReadEnable;
                    reg2_re_o       <= `ReadDisable;
                    imm             <= {inst_i[15:0], 16'h0};
                    // instvalid
                
                end
                                
                `INST_ADDI: begin
                    alu_op_o <= `ALU_OP_ADDI;
                    alu_op_type_o <= `ALU_OP_TYPE_ARITHMETIC;
                    reg_we_o   <= `WriteEnable;
                    reg1_re_o       <= `ReadEnable;
                    reg2_re_o       <= `ReadDisable;
                    reg_waddr_o     <= rt;
                    imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                end

                `INST_ADDIU: begin
                    alu_op_o <= `ALU_OP_ADDIU;
                    alu_op_type_o <= `ALU_OP_TYPE_ARITHMETIC;
                    reg_we_o   <= `WriteEnable;
                    reg1_re_o       <= `ReadEnable;
                    reg2_re_o       <= `ReadDisable;
                    reg_waddr_o     <= rt;
                    imm <= {{16{inst_i[15]}}, inst_i[15:0]};

                end
                `INST_SLTI: begin
                    alu_op_o <= `ALU_OP_SLT;//ALU_OP_SLTI
                    alu_op_type_o <= `ALU_OP_TYPE_ARITHMETIC;
                    reg_we_o   <= `WriteEnable;
                    reg1_re_o       <= `ReadEnable;
                    reg2_re_o       <= `ReadDisable;
                    reg_waddr_o     <= rt;
                    imm <= {{16{inst_i[15]}}, inst_i[15:0]};

                end
                `INST_SLTIU: begin
                    alu_op_o <= `ALU_OP_SLTU;//ALU_OP_SLTIU
                    alu_op_type_o <= `ALU_OP_TYPE_ARITHMETIC;
                    reg_we_o   <= `WriteEnable;
                    reg1_re_o       <= `ReadEnable;
                    reg2_re_o       <= `ReadDisable;
                    reg_waddr_o     <= rt;
                    imm <= {{16{inst_i[15]}}, inst_i[15:0]};

                end



                
                `INST_BEQ: begin
                    alu_op_o        <= `ALU_OP_BEQ;
                    alu_op_type_o   <= `ALU_OP_TYPE_JUMP_BRANCH;
                    reg_we_o        <= `WriteDisable;
                    reg1_re_o       <= `ReadEnable;
                    reg2_re_o       <= `ReadEnable;
                    if (reg1_data_o == reg2_data_o) begin
                        branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o   <= `Branch;
                        next_inst_in_delayslot_o <= `InDelaySlot;
                    end
                    // instvalid
                end
                `INST_BGTZ: begin
                    alu_op_o        <= `ALU_OP_BGTZ;
                    alu_op_type_o   <= `ALU_OP_TYPE_JUMP_BRANCH;
                    reg_we_o        <= `WriteDisable;
                    reg1_re_o       <= `ReadEnable;
                    reg2_re_o       <= `ReadDisable;
                    if ((reg1_data_o[31] == 1'b0) && (reg1_data_o != 32'h0)) begin
                        branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o   <= `Branch;
                        next_inst_in_delayslot_o <= `InDelaySlot;
                    end
                    // instvalid
                end
                `INST_BLEZ: begin
                    alu_op_o        <= `ALU_OP_BLEZ;
                    alu_op_type_o   <= `ALU_OP_TYPE_JUMP_BRANCH;
                    reg_we_o        <= `WriteDisable;
                    reg1_re_o       <= `ReadEnable;
                    reg2_re_o       <= `ReadDisable;
                    if ((reg1_data_o[31] == 1'b1) || (reg1_data_o == 32'h0)) begin
                        branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o   <= `Branch;
                        next_inst_in_delayslot_o <= `InDelaySlot;
                    end
                    // instvalid
                end
                `INST_BNE: begin
                    alu_op_o        <= `ALU_OP_BNE;
                    alu_op_type_o   <= `ALU_OP_TYPE_JUMP_BRANCH;
                    reg_we_o        <= `WriteDisable;
                    reg1_re_o       <= `ReadEnable;
                    reg2_re_o       <= `ReadEnable;
                    if (reg1_data_o != reg2_data_o) begin
                        branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o   <= `Branch;
                        next_inst_in_delayslot_o <= `InDelaySlot;
                    end
                    // instvalid
                end
                // ERET ?????
                `INST_J: begin
                    alu_op_o        <= `ALU_OP_J;
                    alu_op_type_o   <= `ALU_OP_TYPE_JUMP_BRANCH;
                    reg_we_o        <= `WriteDisable;
                    reg1_re_o       <= `ReadDisable;
                    reg2_re_o       <= `ReadDisable;
                    link_addr_o     <= 32'h0;
                    branch_target_addr_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
                    branch_flag_o   <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                    // instvalid
                end
                `INST_JAL: begin
                    alu_op_o        <= `ALU_OP_JAL;
                    alu_op_type_o   <= `ALU_OP_TYPE_JUMP_BRANCH;
                    reg_we_o        <= `WriteEnable;
                    reg1_re_o       <= `ReadDisable;
                    reg2_re_o       <= `ReadDisable;
                    reg_waddr_o     <= 5'b11111; // reg no.31
                    link_addr_o     <= pc_plus_8;
                    branch_target_addr_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
                    branch_flag_o   <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                    // instvalid
                end
                `INST_LB: begin
                    reg_we_o  <= `WriteEnable;
                    alu_op_o  <= `ALU_OP_LB;
                    alu_op_type_o <= `ALU_OP_TYPE_LOAD_STORE;
                    reg1_re_o <= `ReadEnable;
                    reg2_re_o <= `ReadDisable;
                    reg_waddr_o <= inst_i[20:16];
                    //instvalid
                end
                `INST_LBU: begin
                    reg_we_o  <= `WriteEnable;
                    alu_op_o  <= `ALU_OP_LBU;
                    alu_op_type_o <= `ALU_OP_TYPE_LOAD_STORE;
                    reg1_re_o <= `ReadEnable;
                    reg2_re_o <= `ReadDisable;
                    reg_waddr_o <= inst_i[20:16];
                end
                `INST_LH: begin
                    reg_we_o  <= `WriteEnable;
                    alu_op_o  <= `ALU_OP_LH;
                    alu_op_type_o <= `ALU_OP_TYPE_LOAD_STORE;
                    reg1_re_o <= `ReadEnable;
                    reg2_re_o <= `ReadDisable;
                    reg_waddr_o <= inst_i[20:16];
                end
                `INST_LHU: begin
                    reg_we_o  <= `WriteEnable;
                    alu_op_o  <= `ALU_OP_LHU;
                    alu_op_type_o <= `ALU_OP_TYPE_LOAD_STORE;
                    reg1_re_o <= `ReadEnable;
                    reg2_re_o <= `ReadDisable;
                    reg_waddr_o <= inst_i[20:16];
                end
                `INST_LW: begin
                    reg_we_o  <= `WriteEnable;
                    alu_op_o  <= `ALU_OP_LW;
                    alu_op_type_o <= `ALU_OP_TYPE_LOAD_STORE;
                    reg1_re_o <= `ReadEnable;
                    reg2_re_o <= `ReadDisable;
                    reg_waddr_o <= inst_i[20:16];
                end
                `INST_SB: begin
                    reg_we_o  <= `WriteDisable;
                    alu_op_o  <= `ALU_OP_SB;
                    alu_op_type_o <= `ALU_OP_TYPE_LOAD_STORE;
                    reg1_re_o <= `ReadEnable;
                    reg2_re_o <= `ReadEnable;
                    // reg_waddr_o <= inst_i[20:16];
                end
                `INST_SH: begin
                    reg_we_o  <= `WriteDisable;
                    alu_op_o  <= `ALU_OP_SH;
                    alu_op_type_o <= `ALU_OP_TYPE_LOAD_STORE;
                    reg1_re_o <= `ReadEnable;
                    reg2_re_o <= `ReadEnable;
                end
                `INST_SW: begin
                    reg_we_o  <= `WriteDisable;
                    alu_op_o  <= `ALU_OP_SW;
                    alu_op_type_o <= `ALU_OP_TYPE_LOAD_STORE;
                    reg1_re_o <= `ReadEnable;
                    reg2_re_o <= `ReadEnable;
                end

                // MFC0 ?????
                `INST_NOP: begin
                end
                `INST_REGIMM: begin
                    case(op4)
                        `INST_BGEZ: begin
                            alu_op_o        <= `ALU_OP_BGEZ;
                            alu_op_type_o   <= `ALU_OP_TYPE_JUMP_BRANCH;
                            reg_we_o        <= `WriteDisable;
                            reg1_re_o       <= `ReadEnable;
                            reg2_re_o       <= `ReadDisable;
                            if (reg1_data_o[31] == 1'b0) begin
                                branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o <= `Branch;
                                next_inst_in_delayslot_o <= `InDelaySlot;
                            end
                            //instvalid
                        end
                        `INST_BGEZAL: begin
                            alu_op_o        <= `ALU_OP_BGEZAL;
                            alu_op_type_o   <= `ALU_OP_TYPE_JUMP_BRANCH;
                            reg_we_o        <= `WriteEnable;
                            reg1_re_o       <= `ReadEnable;
                            reg2_re_o       <= `ReadDisable;
                            link_addr_o     <= pc_plus_8;
                            reg_waddr_o     <= 5'b11111;
                            if (reg1_data_o[31] == 1'b0) begin
                                branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o <= `Branch;
                                next_inst_in_delayslot_o <= `InDelaySlot;
                            end
                            //instvalid
                        end
                        `INST_BLTZ: begin
                            alu_op_o        <= `ALU_OP_BGEZAL;
                            alu_op_type_o   <= `ALU_OP_TYPE_JUMP_BRANCH;
                            reg1_re_o       <= `ReadEnable;
                            reg2_re_o       <= `ReadDisable;
                            if (reg1_data_o[31] == 1'b1) begin
                                branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o <= `Branch;
                                next_inst_in_delayslot_o <= `InDelaySlot;
                            end
                            //instvalid
                        end
                        `INST_BLTZAL: begin
                            alu_op_o        <= `ALU_OP_BGEZAL;
                            alu_op_type_o   <= `ALU_OP_TYPE_JUMP_BRANCH;
                            reg_we_o        <= `WriteEnable;
                            reg1_re_o       <= `ReadEnable;
                            reg2_re_o       <= `ReadDisable;
                            link_addr_o     <= pc_plus_8;
                            reg_waddr_o     <= 5'b11111;
                            if (reg1_data_o[31] == 1'b1) begin
                                branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o <= `Branch;
                                next_inst_in_delayslot_o <= `InDelaySlot;
                            end
                            //instvalid
                        end
                        default: begin
                        end
                    endcase
                end
                //`EXE_SPECIAL2_INST
                default:begin
                end
            endcase
            if (inst_i[31:21] == 11'b0) begin
                case (alu_funct)
                    `ALU_FUNCT_SLL: begin
                        alu_op_o        <= `ALU_OP_SLL;
                        alu_op_type_o   <= `ALU_OP_TYPE_SHIFT;
                        reg_waddr_o     <= rd;
                        reg_we_o        <= `WriteEnable;
                        reg1_re_o       <= `ReadDisable;
                        reg2_re_o       <= `ReadEnable;
                        imm[4:0]        <= inst_i[10:6];
                        // instvalid
                    end
                    `ALU_FUNCT_SRL: begin
                        alu_op_o        <= `ALU_OP_SRL;
                        alu_op_type_o   <= `ALU_OP_TYPE_SHIFT;
                        reg_waddr_o     <= rd;
                        reg_we_o        <= `WriteEnable;
                        reg1_re_o       <= `ReadDisable;
                        reg2_re_o       <= `ReadEnable;
                        imm[4:0]        <= inst_i[10:6];
                        // instvalid
                    end
                    `ALU_FUNCT_SRA: begin
                        alu_op_o        <= `ALU_OP_SRA;
                        alu_op_type_o   <= `ALU_OP_TYPE_SHIFT;
                        reg_waddr_o     <= rd;
                        reg_we_o        <= `WriteEnable;
                        reg1_re_o       <= `ReadDisable;
                        reg2_re_o       <= `ReadEnable;
                        imm[4:0]        <= inst_i[10:6];
                        // instvalid
                    end
                    default: begin
                    end
                endcase
            end
			
            // end else if(inst_i[31:21] == 11'b01000000000 && 
            //         inst_i[10:0] == 11'b00000000000) begin
            //         aluop_o <= `EXE_MFC0_OP;
            //         alusel_o <= `EXE_RES_MOVE;
            //         wd_o <= inst_i[20:16];
            //         wreg_o <= `WriteEnable;
            //         instvalid <= `InstValid;	   
            //         reg1_read_o <= 1'b0;
            //         reg2_read_o <= 1'b0;		
            // end else if(inst_i[31:21] == 11'b01000000100 && 
            //                             inst_i[10:0] == 11'b00000000000) begin
            //         aluop_o <= `EXE_MTC0_OP;
            //         alusel_o <= `EXE_RES_NOP;
            //         wreg_o <= `WriteDisable;
            //         instvalid <= `InstValid;	   
            //         reg1_read_o <= 1'b1;
            //         reg1_addr_o <= inst_i[20:16];
            //         reg2_read_o <= 1'b0;					

        end
    end

        // 确定�???????要输出的操作�???????1
    always @ (*) begin
        stallreq_for_reg1_loadrelate <= `NoStop;
        if (rst == `RstEnable) begin
            reg1_data_o <= 32'h0;
        end else if ((pre_inst_is_load == 1'b1) && (ex_reg_waddr_i == reg1_raddr_o) &&(reg1_re_o==1'b1) )begin
            stallreq_for_reg1_loadrelate <= `Stop;
        
        end else if ((reg1_re_o == `ReadEnable) && (ex_reg_we_i == `WriteEnable) && (ex_reg_waddr_i == reg1_raddr_o)) begin
            reg1_data_o <= ex_reg_wdata_i;
        end else if ((reg1_re_o == `ReadEnable) && (mem_reg_we_i == `WriteEnable) && (mem_reg_waddr_i == reg1_raddr_o)) begin
            reg1_data_o <= mem_reg_wdata_i;
        end else if (reg1_re_o == `ReadEnable) begin
            reg1_data_o <= reg1_data_i;
        end else if (reg1_re_o == `ReadDisable) begin
            reg1_data_o <= imm; // 操作数为立即�???????
        end else begin
            reg1_data_o <= 32'h0;
        end
    end

    // 确定�???????要输出的操作�???????2
    always @ (*) begin
        stallreq_for_reg2_loadrelate <= `NoStop;
        if (rst == `RstEnable) begin
            reg2_data_o <= 32'h0;
        end else if ((pre_inst_is_load == 1'b1) && (ex_reg_waddr_i == reg2_raddr_o) &&(reg2_re_o==1'b1) )begin
            stallreq_for_reg2_loadrelate <= `Stop;
        end else if ((reg2_re_o == `ReadEnable) && (ex_reg_we_i == `WriteEnable) && (ex_reg_waddr_i == reg2_raddr_o)) begin
            reg2_data_o <= ex_reg_wdata_i;
        end else if ((reg2_re_o == `ReadEnable) && (mem_reg_we_i == `WriteEnable) && (mem_reg_waddr_i == reg2_raddr_o)) begin
            reg2_data_o <= mem_reg_wdata_i;
        end else if (reg2_re_o == `ReadEnable) begin
            reg2_data_o <= reg2_data_i;
        end else if (reg2_re_o == `ReadDisable) begin
            reg2_data_o <= imm; // 操作数为立即�???????
        end else begin
            reg2_data_o <= 32'h0;
        end
    end


    // is in delayslot
    always @ (*) begin
        if (rst == `RstEnable) begin
            is_in_delayslot_o <= `NotInDelaySlot;
        end else begin
            is_in_delayslot_o <= is_in_delayslot_i;
        end
    end

endmodule
