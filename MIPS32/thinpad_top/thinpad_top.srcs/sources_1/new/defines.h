//*******************         ȫ�ֵĺ궨��        ***************************  
`define RstEnable            1'b1               //��λ�ź���Ч  
`define RstDisable           1'b0               //��λ�ź���Ч  
`define ZeroWord             32'h00000000       //32λ����ֵ0  
`define WriteEnable          1'b1               //ʹ��д  
`define WriteDisable         1'b0               //��ֹд  
`define ReadEnable           1'b1               //ʹ�ܶ�  
`define ReadDisable          1'b0               //��ֹ��  
`define AluOpBus             7:0                //����׶ε����aluop_o�Ŀ��????  
`define AluOpTypeBus         2:0                //����׶ε����alusel_o�Ŀ��????  
`define InstValid            1'b0               //ָ����Ч  
`define InstInvalid          1'b1               //ָ����Ч  
`define True_v               1'b1               //�߼�"��"  
`define False_v              1'b0               //�߼�"��"  
`define ChipEnable           1'b1               //оƬʹ��  
`define ChipDisable          1'b0               //оƬ��ֹ  
`define InDelaySlot          1'b1
`define NotInDelaySlot       1'b0
`define Branch               1'b1
`define NotBranch            1'b0
`define InterruptAssert      1'b1
`define InterruptNotAssert   1'b0

`define TrapAssert 1'b1
`define TrapNotAssert 1'b0
`define True_v 1'b1
`define False_v 1'b0
  
//*************************For ram*********************
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum 131071
`define DataMemNumLog2 17
`define ByteWidth 7:0



//********************** OPCODE FOR PIPELINE STALL***************
`define   Stop  1'b1  //Pipeline stall
`define   NoStop 1'b0 

//====================== ALU Function Code ======================
`define ALU_FUNCT_ADD       6'b100000
`define ALU_FUNCT_ADDU      6'b100001
`define ALU_FUNCT_AND       6'b100100
// `define ALU_FUNCT_JR        6'b001000
`define ALU_FUNCT_OR        6'b100101
`define ALU_FUNCT_XOR       6'b100110
`define ALU_FUNCT_NOR       6'b100111

`define ALU_FUNCT_SLL       6'b000000
`define ALU_FUNCT_SRL       6'b000010
`define ALU_FUNCT_SRA       6'b000011
`define ALU_FUNCT_SLLV      6'b000100
`define ALU_FUNCT_SRLV      6'b000110
`define ALU_FUNCT_SRAV      6'b000111

`define ALU_FUNCT_JR        6'b001000
`define ALU_FUNCT_JALR      6'b001001

`define ALU_FUNCT_SUB       6'b100010
`define ALU_FUNCT_SUBU      6'b100011
`define ALU_FUNCT_SLT       6'b101010
`define ALU_FUNCT_SLTU      6'b101011
//MOV INSTRUCTION
`define ALU_FUNCT_MFHI       6'b010000
`define ALU_FUNCT_MTHI       6'b010001
`define ALU_FUNCT_MFLO       6'b010010
`define ALU_FUNCT_MTLO       6'b010011  

`define ALU_FUNCT_SYSCALL    6'b001100




// system call???

//====================== Instruction Code =======================
`define INST_ADDI            6'b001000
`define INST_ADDIU           6'b001001
`define INST_SLTI            6'b001010
`define INST_SLTIU           6'b001011 

`define INST_ANDI           6'b001100
`define INST_ORI            6'b001101          //ָ��ori��ָ���� 
`define INST_XORI           6'b001110
`define INST_LUI            6'b001111



// ERET instruction?????
`define INST_J              6'b000010
`define INST_JAL            6'b000011
`define INST_LW             6'b100011
`define INST_BEQ            6'b000100
`define INST_BNE            6'b000101
`define INST_BLEZ           6'b000110
`define INST_BGTZ           6'b000111

`define INST_BLTZ           5'b00000
`define INST_BGEZ           5'b00001
`define INST_BLTZAL         5'b10000
`define INST_BGEZAL         5'b10001

// MFC0 instruction ??? 
`define INST_NOP            6'b000000  
`define INST_SB             6'b101000
`define INST_SW             6'b101011
`define INST_SPECIAL        6'b000000

//instruction code for ram
`define INST_LB  6'b100000
`define INST_LBU  6'b100100
`define INST_LH  6'b100001
`define INST_LHU  6'b100101
`define INST_LW  6'b100011
`define INST_SB  6'b101000
`define INST_SH  6'b101001
`define INST_SW  6'b101011

`define INST_REGIMM         6'b000001



// CP0
`define INST_MFC0           11'b01000000000
`define INST_MTC0           11'b01000000100
`define INST_ERET           32'b01000010000000000000000000011000



// Alu op
`define ALU_OP_AND          8'b00100100
`define ALU_OP_OR           8'b00100101
`define ALU_OP_XOR          8'b00100110
`define ALU_OP_NOR          8'b00100111
`define ALU_OP_ANDI         8'b01011001
`define ALU_OP_ORI          8'b01011010
`define ALU_OP_XORI         8'b01011011
`define ALU_OP_LUI          8'b01011100   

`define ALU_OP_SLL          8'b01111100
`define ALU_OP_SLLV         8'b00000100
`define ALU_OP_SRL          8'b00000010
`define ALU_OP_SRLV         8'b00000110
`define ALU_OP_SRA          8'b00000011
`define ALU_OP_SRAV         8'b00000111
`define ALU_OP_SLT          8'b00101010
`define ALU_OP_SLTU         8'b00101011
`define ALU_OP_SLTI         8'b01010111
`define ALU_OP_SLTIU        8'b01011000   
`define ALU_OP_ADD          8'b00100000
`define ALU_OP_ADDU         8'b00100001
`define ALU_OP_SUB          8'b00100010
`define ALU_OP_SUBU         8'b00100011
`define ALU_OP_ADDI         8'b01010101
`define ALU_OP_ADDIU        8'b01010110

`define ALU_OP_J            8'b01001111
`define ALU_OP_JAL          8'b01010000
`define ALU_OP_JALR         8'b00001001
`define ALU_OP_JR           8'b00001000
`define ALU_OP_BEQ          8'b01010001
`define ALU_OP_BGEZ         8'b01000001
`define ALU_OP_BGEZAL       8'b01001011
`define ALU_OP_BGTZ         8'b01010100
`define ALU_OP_BLEZ         8'b01010011
`define ALU_OP_BLTZ         8'b01000000
`define ALU_OP_BLTZAL       8'b01001010
`define ALU_OP_BNE          8'b01010010


`define ALU_OP_LW     8'b11100011
`define ALU_OP_LB     8'b11100000
`define ALU_OP_LBU    8'b11100100
`define ALU_OP_LH     8'b11100001
`define ALU_OP_LHU    8'b11100101
`define ALU_OP_SB     8'b11101000
`define ALU_OP_SH     8'b11101001
`define ALU_OP_SW     8'b11101011

`define ALU_OP_MFC0 8'b01011101
`define ALU_OP_MTC0 8'b01100000

`define ALU_OP_NOP          8'b00000000
`define ALU_OP_MFHI  8'b00010000
`define ALU_OP_MTHI  8'b00010001
`define ALU_OP_MFLO  8'b00010010
`define ALU_OP_MTLO  8'b00010011

`define ALU_OP_SYSCALL 8'b00001100
`define ALU_OP_ERET 8'b01101011
`define ALU_OP_SYSCALL 8'b00001100
  
//Alu op type

`define ALU_OP_TYPE_LOGIC       3'b001
`define ALU_OP_TYPE_SHIFT       3'b010
`define ALU_OP_TYPE_ARITHMETIC  3'b100
`define ALU_OP_TYPE_JUMP_BRANCH 3'b110
`define ALU_OP_TYPE_LOAD_STORE  3'b111
`define ALU_OP_TYPE_MOVE        3'b011	
`define ALU_OP_TYPE_NOP         3'b000  
  
  
//*********************   ��ָ���????��ROM�йصĺ궨��   **********************  
`define InstAddrBus          31:0               //ROM�ĵ�ַ���߿��????  
`define InstBus              31:0               //ROM���������߿��????  
`define InstMemNum           131071             //ROM��ʵ�ʴ�СΪ128KB  
`define InstMemNumLog2       17                 //ROMʵ��ʹ�õĵ�ַ�߿��????  
  
  
//*********************  ��ͨ�üĴ���Regfile�йصĺ궨��   *******************  
`define RegAddrBus           4:0                //Regfileģ��ĵ�ַ�߿��  
`define RegBus               31:0               //Regfileģ��������߿��  
`define RegWidth             32                 //ͨ�üĴ����Ŀ��????  
`define DoubleRegWidth       64                 //������ͨ�üĴ����Ŀ��????  
`define DoubleRegBus         63:0               //������ͨ�üĴ����������߿��????  
`define RegNum               32                 //ͨ�üĴ���������  
`define RegNumLog2           5                  //Ѱַͨ�üĴ���ʹ�õĵ�ַλ��  
`define NOPRegAddr           5'b00000  

// CP0
`define CP0_REG_COUNT       5'b01001
`define CP0_REG_COMPARE     5'b01011
`define CP0_REG_STATUS      5'b01100
`define CP0_REG_CAUSE       5'b01101
`define CP0_REG_EPC         5'b01110
`define CP0_REG_PrId        5'b01111
`define CP0_REG_CONFIG      5'b10000

// Wishbone
`define WB_IDLE             2'b00
`define WB_BUSY             2'b01
`define WB_WAIT_FOR_STALL   2'b11

// SRAM
`define SRAM_IDLE           2'b00
`define SRAM_READ           2'b01
`define SRAM_WRITE          2'b10
`define SRAM_END            2'b11