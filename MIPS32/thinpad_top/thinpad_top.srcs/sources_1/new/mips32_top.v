`timescale 1ns / 1ps
`include "defines.h"
module mips32_top(
    input wire              clk_uart,
    input wire              pclk,
    input wire              clk,
    input wire              rst,
    
   
    // output wire             timer_int_o,
    // base sram
    inout wire[31:0]        base_ram_data,
    output wire[19:0]       base_ram_addr,
    output wire             base_ram_ce_n,
    output wire             base_ram_oe_n,
    output wire             base_ram_we_n,
    output wire[3:0]        base_ram_be_n,
    
    // ext sram
    inout wire[31:0]        ext_ram_data,
    output wire[19:0]       ext_ram_addr,
    output wire             ext_ram_ce_n,
    output wire             ext_ram_oe_n,
    output wire             ext_ram_we_n,
    output wire[3:0]        ext_ram_be_n,
    // uart
    output TxD,
    input RxD,
    output wire[15:0]       leds,
    // touch button
    input wire[5:0]     touch_btn,
    // vga
    output wire[7:0]        video_pixel,
    output wire             video_hsync,
    output wire             video_vsync,
    output wire             video_clk,
    output wire             video_de
    );
    //=========== Interrupt ===========
    wire[5:0]           int;
    wire                timer_int;
    //=========== VGA =================
    wire                vga_ce;
    wire                vga_we;
    wire[23:0]          vga_waddr;
    wire[31:0]          vga_wdata;
    wire[18:0]          vga_pos;
    assign video_clk = pclk;
    //=========== IF =================
    wire[`InstAddrBus]  if_pc;
    wire                if_ce;
    wire[`InstBus]      if_inst;
    //============== CP0 ==============
    wire[4:0]           cp0_reg_raddr_i;
    wire[`RegBus]       cp0_reg_rdata_o;
    //========== Jump & Branch =========
    wire                is_in_delayslot;
	wire                branch_flag;
	wire[`RegBus]       branch_target_addr;
    
    //============== CTRL ==============
    wire[5:0]  stall;
    wire       stallreq_from_id;
    wire       stallreq_from_ex;
    wire       stallreq_from_mem;
    wire       stallreq_from_if;

    // ============= ID ===============
    wire[`InstAddrBus]  id_pc_i;
    wire[`InstBus]      id_inst_i;

    wire[`RegBus]       id_reg1_data_o;
    wire[`RegBus]       id_reg2_data_o;
    wire                id_reg_we_o;
    wire[`RegAddrBus]   id_reg_waddr_o;
    wire[`AluOpBus]     id_alu_op_o;
   
    wire[`AluOpTypeBus] id_alu_op_type_o;

    wire                id_next_inst_in_delayslot_o;
    wire[`RegBus]       id_link_addr_o;
    wire                id_is_in_delayslot_o;

    wire[`RegBus]       reg1_data;
    wire[`RegBus]       reg2_data;
    wire                reg1_re;
    wire                reg2_re;
    wire[`RegAddrBus]   reg1_raddr;
    wire[`RegAddrBus]   reg2_raddr;
    //for ram 
    wire[`InstBus]      id_idex_inst;
    wire[`RegBus]       idex_ex_inst;
    //for load-use
     wire[`AluOpBus]     ex_exmem_id_alu_op;
    // ============ EX ===============
    wire[`AluOpBus]     ex_alu_op_i;
    wire[`AluOpTypeBus] ex_alu_op_type_i;
    wire[`RegBus]       ex_reg1_data_i;
    wire[`RegBus]       ex_reg2_data_i;
    wire[`RegAddrBus]   ex_reg_waddr_i;
    wire                ex_reg_we_i;
    wire[`RegBus]       ex_link_addr_i;
    wire                ex_is_in_delayslot_i;
    
    wire[`RegAddrBus]   ex_reg_waddr_o;
    wire                ex_reg_we_o;
    wire[`RegBus]       ex_reg_wdata_o;

    // pass CP0
    wire[4:0]           ex_cp0_reg_waddr_o;
    wire                ex_cp0_reg_we_o;
    wire[`RegBus]       ex_cp0_reg_wdata_o;
    //for ram
    wire[7:0]  ex_exmem_alu_op;
    wire[31:0] ex_exmem_mem_addr;
    wire[31:0] ex_exmem_reg2_data;
    
    wire[7:0]  exmem_mem_alu_op;
    wire[31:0] exmem_mem_mem_addr;
    wire[31:0] exmem_mem_reg2_data;
    // ============ MEM ==============
    wire[`RegAddrBus]   mem_reg_waddr_i;
    wire                mem_reg_we_i;
    wire[`RegBus]       mem_reg_wdata_i;
    wire[`RegAddrBus]   mem_reg_waddr_o;
    wire                mem_reg_we_o;
    wire[`RegBus]       mem_reg_wdata_o;
    // CP0 conflict
    wire[4:0]           mem_cp0_reg_waddr_i;
    wire                mem_cp0_reg_we_i;
    wire[`RegBus]       mem_cp0_reg_wdata_i;
    wire[4:0]           mem_cp0_reg_waddr_o;
    wire                mem_cp0_reg_we_o;
    wire[`RegBus]       mem_cp0_reg_wdata_o;
    //for ram
    wire[`RegBus]       ram_mem_data_intomem;
    //for ram
    wire[`RegBus]       mem_ram_addr;
    wire                mem_ram_we;
    wire[3:0]           mem_ram_sel;
    wire[`RegBus]       mem_ram_data_intoram;
    wire                mem_ram_ce;
    
    // ============ WB ===============
    wire[`RegAddrBus]   wb_reg_waddr_i;
    wire                wb_reg_we_i;
    wire[`RegBus]       wb_reg_wdata_i;
    // CP0 conflict
    wire[4:0]           wb_cp0_reg_waddr_i;
    wire                wb_cp0_reg_we_i;
    wire[`RegBus]       wb_cp0_reg_wdata_i;
   //=======================HILO======================
    wire                ex_exmem_whilo;
    wire[`RegBus]       ex_exmem_hi;
    wire[`RegBus]       ex_exmem_lo;

    wire                exmem_mem_whilo;
    wire[`RegBus]       exmem_mem_hi;
    wire[`RegBus]       exmem_mem_lo;
    
    wire                mem_ex_memwb_hilo_we;
    wire[`RegBus]       mem_ex_memwb_hi;
    wire[`RegBus]       mem_ex_memwb_lo;
    
    wire                memwb_ex_hilo_we;
    wire[`RegBus]       memwb_ex_hilo_hi;
    wire[`RegBus]       memwb_ex_hilo_lo;

    wire[`RegBus]       hilo_ex_hi;
    wire[`RegBus]       hilo_ex_lo;
    //for exception handler;
    wire flush;
    wire [`RegBus]      ctrl_pcreg_new_pc;
    
    wire [31:0]         id_idex_excepttype;
    wire [`RegBus]      id_idex_current_inst_addr;
    wire [31:0]         idex_ex_excepttype;
    wire [`RegBus]      idex_ex_current_inst_addr;
    wire [31:0]         ex_exmem_excepttype;
    wire [`RegBus]      ex_exmem_current_inst_addr;
    wire                ex_exmem_is_in_delayslot;

    wire[31:0]          exmem_mem_excepttype;
    wire[`RegBus]       exmem_mem_current_inst_address;
    wire                exmem_mem_is_in_delayslot;

    wire[`RegBus]       cp0_cause;
    wire[`RegBus]       cp0_status;
    wire[`RegBus]       cp0_epc;
    wire[`RegBus]       latest_epc;
    wire[31:0]          mem_excepttype_o;
    wire[`RegBus]       mem_current_inst_address_o;
    wire                mem_is_in_delayslot_o;
    //============== UART ==============
    wire                uart_RxD_data_ready;
    wire[7:0]           uart_RxD_data;
    wire                uart_rdn;
    wire                uart_TxDready;
    wire                uart_TxD_start;
    wire[7:0]           uart_TxD_data;
    //============= MMU ================  
    wire[31:0]          mmu_if_addr;
    wire[31:0]          mmu_mem_addr;

    
//      ila_0 ila(
//              .clk(clk_ila),
//               .probe0(id_pc_i),
//               .probe1(id_inst_i)
//              );

/*
    wire uart_RxD_data_ready;
wire[7:0] uart_RxD_data;
wire uart_rdn;
wire uart_TxDready;
wire uart_TxD_start;
wire[7:0] uart_TxD_data;


 .mem_ce_i(mem_ram_ce),
        .mem_data_i(mem_ram_data_intoram),
        .mem_addr_i(mmu_mem_addr),
        .mem_we_i(mem_ram_we),
        .mem_sel_i(mem_ram_sel),
        .mem_data_o(ram_mem_data_intomem),
        .mem_stallreq_o(stallreq_from_mem),
*/

/*
 wire                vga_ce;
    wire                vga_we;
    wire[23:0]          vga_addr;
    wire[7:0]           vga_rdata;
    wire[7:0]           vga_wdata;
*/
    wire[31:0] video_data;
    wire[20:0] btnbuff;
//    vio_0 vio(
//        .clk(pclk),
//        .probe_in0(id_pc_i),
//        .probe_in1(id_inst_i),
//        .probe_in2(wb_reg_waddr_i),
//        .probe_in3(wb_reg_wdata_i),
//        .probe_in4(vga_ce),
//        .probe_in5(vga_we),
//        .probe_in6(vga_waddr),
//        .probe_in8(vga_wdata),
//        .probe_in9(mem_ram_sel),
//        .probe_in10(mem_ram_data_intoram),
//        .probe_in11(mmu_mem_addr),
//        .probe_in12(ram_mem_data_intomem),
//        .probe_in13(vga_pos),
//        .probe_in14(video_pixel),
//        .probe_in15(video_hsync),
//        .probe_in16(video_vsync),
//        .probe_in17(video_de),
//        .probe_in18(btnbuff)
//    );
//    output wire[7:0]        video_pixel,
//    output wire             video_hsync,
//    output wire             video_vsync,
//    output wire             video_clk,
//    output wire             video_de
    pc_reg pc_reg0(
        .clk(clk),
        .rst(rst),
        .pc(if_pc),
        .ce(if_ce),
        .stall(stall),
        .branch_flag_i(branch_flag),
        .branch_target_addr_i(branch_target_addr),

        .new_pc(ctrl_pcreg_new_pc),
        .flush(flush)
        );
    
    ctrl ctrl0(
        .rst(rst),
        .stall(stall),
        .stallreq_from_id(stallreq_from_id),
        .stallreq_from_ex(stallreq_from_ex),
        .stallreq_from_if(stallreq_from_if),
        .stallreq_from_mem(stallreq_from_mem),

        .new_pc(ctrl_pcreg_new_pc),
        .flush(flush),
        .cp0_epc_i(latest_epc),
        .excepttype_i(mem_excepttype_o)

    );
    /*
    inst_rom inst_rom0(
        .ce(pc_ce_rom),
        .addr(pc_if_pc),
        .inst(rom_if_inst)
    );*/
    
    if_id if_id0(
        .if_pc(if_pc),
        .if_inst(if_inst),
        .rst(rst),
        .clk(clk),
        .id_pc(id_pc_i),
        .id_inst(id_inst_i),
        .stall(stall),
        .flush(flush)

    );
    
    wire ram_data;
    assign ram_data = base_ram_data;
    /*
    ila_1 ila1_0(
        .clk(clk),
        .probe0(id_pc_i),
        .probe1(id_inst_i),
        .probe2(wb_reg_waddr_i),
        .probe3(wb_reg_wdata_i)
    );*/
    id id0(
        .rst(rst),
        .pc_i(id_pc_i),
        .inst_i(id_inst_i),
        
        .alu_op_o(id_alu_op_o),
        .alu_op_type_o(id_alu_op_type_o),
        .reg1_data_o(id_reg1_data_o),
        .reg2_data_o(id_reg2_data_o),
        // reg result from ex
        .ex_reg_we_i(ex_reg_we_o),
        .ex_reg_wdata_i(ex_reg_wdata_o),
        .ex_reg_waddr_i(ex_reg_waddr_o),
        // reg result from mem
        .mem_reg_we_i(mem_reg_we_o),
        .mem_reg_wdata_i(mem_reg_wdata_o),
        .mem_reg_waddr_i(mem_reg_waddr_o),
        // delay slot
        .is_in_delayslot_i(is_in_delayslot),

        .reg_we_o(id_reg_we_o),
        .reg_waddr_o(id_reg_waddr_o),
        // read reg from regfile
        .reg1_data_i(reg1_data),
        .reg2_data_i(reg2_data),
        .reg1_re_o(reg1_re),
        .reg2_re_o(reg2_re),
        .reg1_raddr_o(reg1_raddr),
        .reg2_raddr_o(reg2_raddr),
        //stall
        .stallreq(stallreq_from_id),
        // delay slot
        .next_inst_in_delayslot_o(id_next_inst_in_delayslot_o),
        .branch_flag_o(branch_flag),
        .branch_target_addr_o(branch_target_addr),
        .link_addr_o(id_link_addr_o),
        .is_in_delayslot_o(id_is_in_delayslot_o),
        //for ram
        .inst_o(id_idex_inst),
        .ex_aluop_i(ex_exmem_id_alu_op),

        .current_inst_address_o(id_idex_current_inst_addr),
        .excepttype_o(id_idex_excepttype)
    );

    regfile regfile0(
        .clk(clk),
        .rst(rst),
        // write back
        .we(wb_reg_we_i), // ?????????????
        .waddr(wb_reg_waddr_i),
        .wdata(wb_reg_wdata_i),
        // read reg in ID
        .re1(reg1_re),
        .raddr1(reg1_raddr),
        .rdata1(reg1_data),
        .re2(reg2_re),
        .raddr2(reg2_raddr),
        .rdata2(reg2_data)
    );

    id_ex id_ex0(
        .clk(clk),
        .rst(rst),
        .id_alu_op(id_alu_op_o),
        .id_alu_op_type(id_alu_op_type_o),
        .id_reg1_data(id_reg1_data_o),
        .id_reg2_data(id_reg2_data_o),
        .id_reg_waddr(id_reg_waddr_o),
        .id_reg_we(id_reg_we_o),
        .stall(stall),
        .id_link_addr(id_link_addr_o),
        .id_is_in_delayslot(id_is_in_delayslot_o),
        .next_inst_in_delayslot_i(id_next_inst_in_delayslot_o),

        .ex_alu_op(ex_alu_op_i),
        .ex_alu_op_type(ex_alu_op_type_i),
        .ex_reg1_data(ex_reg1_data_i),
        .ex_reg2_data(ex_reg2_data_i),
        .ex_reg_waddr(ex_reg_waddr_i),
        .ex_reg_we(ex_reg_we_i),
        .ex_link_addr(ex_link_addr_i),
        .ex_is_in_delayslot(ex_is_in_delayslot_i),
        .is_in_delayslot_o(is_in_delayslot),
        
        //for ram
        .id_inst(id_idex_inst),
        .ex_inst(idex_ex_inst),
        
        .id_excepttype(id_idex_excepttype),
        .id_current_inst_address(id_idex_current_inst_addr),
        .flush(flush),
        .ex_excepttype(idex_ex_excepttype),
        .ex_current_inst_address(idex_ex_current_inst_addr)


    );

    ex ex0(
        .rst(rst),
        .alu_op_i(ex_alu_op_i),
        .alu_op_type_i(ex_alu_op_type_i),
        .reg1_data_i(ex_reg1_data_i),
        .reg2_data_i(ex_reg2_data_i),
        .reg_waddr_i(ex_reg_waddr_i),
        .reg_we_i(ex_reg_we_i),
        .link_addr_i(ex_link_addr_i),
        .is_in_delayslot_i(ex_is_in_delayslot_i),

        .reg_waddr_o(ex_reg_waddr_o),
        .reg_we_o(ex_reg_we_o),
        .reg_wdata_o(ex_reg_wdata_o),

        // CP0 conflict
        .mem_cp0_reg_waddr_i(mem_cp0_reg_waddr_o),
        .mem_cp0_reg_we_i(mem_cp0_reg_we_o),
        .mem_cp0_reg_wdata_i(mem_cp0_reg_wdata_o),
        .wb_cp0_reg_waddr_i(wb_cp0_reg_waddr_i),
        .wb_cp0_reg_we_i(wb_cp0_reg_we_i),
        .wb_cp0_reg_wdata_i(wb_cp0_reg_wdata_i),

        .cp0_reg_rdata_i(cp0_reg_rdata_o),
        .cp0_reg_raddr_o(cp0_reg_raddr_i),

        .cp0_reg_waddr_o(ex_cp0_reg_waddr_o),
        .cp0_reg_we_o(ex_cp0_reg_we_o),
        .cp0_reg_wdata_o(ex_cp0_reg_wdata_o),

        //CTRL
        .stallreq(stallreq_from_ex),
        //for ram
        .inst_i(idex_ex_inst),
        .alu_op_o(ex_exmem_id_alu_op),
        .mem_addr_o(ex_exmem_mem_addr),
        .reg2_data_o(ex_exmem_reg2_data),
      
        //for hilo
        .hi_i(hilo_ex_hi),
        .lo_i(hilo_ex_lo),

        .wb_whilo_i(memwb_ex_hilo_we),
        .wb_hi_i(memwb_ex_hilo_hi),
        .wb_lo_i(memwb_ex_hilo_lo),

        .mem_whilo_i(mem_ex_memwb_hilo_we),
        .mem_hi_i(mem_ex_memwb_hi),
	    .mem_lo_i(mem_ex_memwb_lo),
        .hi_o(ex_exmem_hi),
	    .lo_o(ex_exmem_lo),
	    .whilo_o(ex_exmem_whilo),

        .excepttype_i(idex_ex_excepttype),
        .current_inst_address_i(idex_ex_current_inst_addr),
        .excepttype_o(ex_exmem_excepttype),
        .current_inst_address_o(ex_exmem_current_inst_addr),
        .is_in_delayslot_o(ex_exmem_is_in_delayslot)
	    

    );

    ex_mem ex_mem0(
        .clk(clk),
        .rst(rst),
        .ex_reg_waddr(ex_reg_waddr_o),
        .ex_reg_we(ex_reg_we_o),
        .ex_reg_wdata(ex_reg_wdata_o),
        .mem_reg_waddr(mem_reg_waddr_i),
        .mem_reg_we(mem_reg_we_i),
        .mem_reg_wdata(mem_reg_wdata_i),

        .ex_cp0_reg_waddr(ex_cp0_reg_waddr_o),
        .ex_cp0_reg_we(ex_cp0_reg_we_o),
        .ex_cp0_reg_wdata(ex_cp0_reg_wdata_o),
        .mem_cp0_reg_waddr(mem_cp0_reg_waddr_i),
        .mem_cp0_reg_we(mem_cp0_reg_we_i),
        .mem_cp0_reg_wdata(mem_cp0_reg_wdata_i),
        //Ctrl
        .stall(stall),
        //for ram
        .ex_alu_op_i(ex_exmem_id_alu_op),
        .ex_mem_addr_i(ex_exmem_mem_addr),
        .ex_reg2_data_i(ex_exmem_reg2_data),
        .mem_alu_op_o(exmem_mem_alu_op),
        .mem_mem_addr_o(exmem_mem_mem_addr),
        .mem_reg2_data_o(exmem_mem_reg2_data),
    
        //for hilo
        .ex_whilo(ex_exmem_whilo), //whether write hilo;
        .ex_hi(ex_exmem_hi),
        .ex_lo(ex_exmem_lo),
        .mem_whilo(exmem_mem_whilo),
        .mem_hi(exmem_mem_hi),
        .mem_lo(exmem_mem_lo),
        .flush(flush),
        .ex_excepttype(ex_exmem_excepttype),
        .ex_current_inst_address(ex_exmem_current_inst_addr),
        .ex_is_in_delayslot(ex_exmem_is_in_delayslot),
        .mem_excepttype(exmem_mem_excepttype),
        .mem_current_inst_address(exmem_mem_current_inst_address),
        .mem_is_in_delayslot(exmem_mem_is_in_delayslot)
        
        
    );

    mem mem0(
        .rst(rst),
        .reg_waddr_i(mem_reg_waddr_i),
        .reg_we_i(mem_reg_we_i),
        .reg_wdata_i(mem_reg_wdata_i),
        .reg_waddr_o(mem_reg_waddr_o),
        .reg_we_o(mem_reg_we_o),
        .reg_wdata_o(mem_reg_wdata_o),

        .cp0_reg_waddr_i(mem_cp0_reg_waddr_i),
        .cp0_reg_we_i(mem_cp0_reg_we_i),
        .cp0_reg_wdata_i(mem_cp0_reg_wdata_i),
        .cp0_reg_waddr_o(mem_cp0_reg_waddr_o),
        .cp0_reg_we_o(mem_cp0_reg_we_o),
        .cp0_reg_wdata_o(mem_cp0_reg_wdata_o),
        
        .alu_op_i(exmem_mem_alu_op),
        .mem_addr_i(exmem_mem_mem_addr),
        .reg2_data_i(exmem_mem_reg2_data),
        .mem_data_i(ram_mem_data_intomem),
        .mem_addr_o(mem_ram_addr),
        .mem_we_o(mem_ram_we),
        .mem_sel_o(mem_ram_sel),
        .mem_data_o(mem_ram_data_intoram),
        .mem_ce_o(mem_ram_ce),

        //for hilo
        .hi_i(exmem_mem_hi),
	    .lo_i(exmem_mem_lo),
	    .whilo_i(exmem_mem_whilo),
        .hi_o(mem_ex_memwb_hi),
	    .lo_o(mem_ex_memwb_lo),
	    .whilo_o(mem_ex_memwb_hilo_we),

        .excepttype_i(exmem_mem_excepttype),
        .current_inst_address_i(exmem_mem_current_inst_address),
        .is_in_delayslot_i(exmem_mem_is_in_delayslot),
        .cp0_status_i(cp0_status),
        .cp0_cause_i(cp0_cause),
        .cp0_epc_i(cp0_epc),

        .wb_cp0_reg_write_addr(wb_cp0_reg_waddr_i),
        .wb_cp0_reg_we(wb_cp0_reg_we_i),
        .wb_cp0_reg_data(wb_cp0_reg_wdata_i),
        .cp0_epc_o(latest_epc),
        .excepttype_o(mem_excepttype_o),
        .is_in_delayslot_o(mem_is_in_delayslot_o),
		.current_inst_address_o(mem_current_inst_address_o)    
    );
    
    wire sram1_ce;
    wire sram1_we;
    wire[19:0] sram1_addr;
    wire[31:0] sram1_data_o;
    wire[31:0] sram1_data_i;
    wire[3:0] sram1_sel;
    
    wire sram2_ce;
    wire sram2_we;
    wire[19:0] sram2_addr;
    wire[31:0] sram2_data_o;
    wire[31:0] sram2_data_i;
    wire[3:0] sram2_sel;



    
    
    mmu mmu_if(
        .addr_i(if_pc),
        .addr_o(mmu_if_addr)
    );
    
    mmu mmu_mem(
        .addr_i(mem_ram_addr),
        .addr_o(mmu_mem_addr)
    );

    bus bus0(
        .clk(clk),
        .rst(rst),

        .stall_i(stall),
        .flush_i(flush),

        .if_ce_i(if_ce),
        .if_addr_i(mmu_if_addr),
        .if_data_o(if_inst),
        .if_stallreq_o(stallreq_from_if),
        
        .mem_ce_i(mem_ram_ce),
        .mem_data_i(mem_ram_data_intoram),
        .mem_addr_i(mmu_mem_addr),
        .mem_we_i(mem_ram_we),
        .mem_sel_i(mem_ram_sel),
        .mem_data_o(ram_mem_data_intomem),
        .mem_stallreq_o(stallreq_from_mem),

        .sram1_ce_o(sram1_ce),
        .sram1_we_o(sram1_we),
        .sram1_addr_o(sram1_addr),
        .sram1_sel_o(sram1_sel),
        .sram1_data_o(sram1_data_o),
        .sram1_data_i(sram1_data_i),
        .sram2_ce_o(sram2_ce),
        .sram2_we_o(sram2_we),
        .sram2_addr_o(sram2_addr),
        .sram2_sel_o(sram2_sel),
        .sram2_data_o(sram2_data_o),
        .sram2_data_i(sram2_data_i),
        
        .vga_data_o(vga_wdata),
        .vga_ce_o(vga_ce),
        .vga_we_o(vga_we),
        .vga_addr_o(vga_waddr),
        .touch_btn(touch_btn),
        // ======= debug ===========
        .pc(if_pc),
        .button_buff(btnbuff),
        .leds(leds),


        .uart_RxD_dataready_i(uart_RxD_data_ready),
        .uart_RxD_data_i(uart_RxD_data),
        .uart_RxD_rdn_o(uart_rdn),
        .uart_TxD_ready_i(uart_TxDready),
        .uart_TxD_start_o(uart_TxD_start),
        .uart_TxD_data_o(uart_TxD_data)

    );
    sram_controller ext_sram_controller(
            .clk(clk),
            .addr_i(sram2_addr),
            .data_i(sram2_data_o),
            .ce_i(sram2_ce),
            .we_i(sram2_we),
            .sel_i(sram2_sel),
            .data_o(sram2_data_i),
    
            .sram_data(ext_ram_data),
            .sram_addr(ext_ram_addr),
            .sram_ce_n(ext_ram_ce_n),
            .sram_oe_n(ext_ram_oe_n),
            .sram_we_n(ext_ram_we_n),
            .sram_be_n(ext_ram_be_n),
            
            // ====== debug ======
            .pc(if_pc),
            .inst(if_inst),
            .stall(stall)
                    
        );
    
    sram_controller base_sram_controller(
        .clk(clk),
        .addr_i(sram1_addr),
        .data_i(sram1_data_o),
        .ce_i(sram1_ce),
        .we_i(sram1_we),
        .sel_i(sram1_sel),
        .data_o(sram1_data_i),

        .sram_data(base_ram_data),
        .sram_addr(base_ram_addr),
        .sram_ce_n(base_ram_ce_n),
        .sram_oe_n(base_ram_oe_n),
        .sram_we_n(base_ram_we_n),
        .sram_be_n(base_ram_be_n),
        // ====== debug ======
        .pc(if_pc),
        .inst(if_inst),
        .stall(stall)
                
    );
    async_transmitter #(.ClkFrequency(10000000),.Baud(9600))
        async_transmitter0(
        .clk(clk_uart),
        .TxD_start(uart_TxD_start),
        .TxD_data(uart_TxD_data),
        .TxDready(uart_TxDready),
        .TxD(TxD)

    );
    async_receiver #(.ClkFrequency(10000000),.Baud(9600))
        async_receiver0(
        .clk(clk_uart),
        .RxD(RxD),
        .RxD_data_ready(uart_RxD_data_ready),
        .RxD_data(uart_RxD_data),
        .rdn(uart_rdn)

    );

    
    /*
     ram ram0(
         .clk(clk),
         .ce(sram_ce),
         .we(sram_we),
         .addr(sram_addr),
         .sel(sram_sel),
         .data_i(sram_data_o),
         .data_o(sram_data_i)
        
     );
    */
    mem_wb mem_wb0(
        .clk(clk),
        .rst(rst),

        .mem_reg_waddr(mem_reg_waddr_o),
        .mem_reg_we(mem_reg_we_o),
        .mem_reg_wdata(mem_reg_wdata_o),
        .wb_reg_waddr(wb_reg_waddr_i),
        .wb_reg_we(wb_reg_we_i),
        .wb_reg_wdata(wb_reg_wdata_i),
        
        .mem_cp0_reg_waddr(mem_cp0_reg_waddr_o),
        .mem_cp0_reg_we(mem_cp0_reg_we_o),
        .mem_cp0_reg_wdata(mem_cp0_reg_wdata_o),
        .wb_cp0_reg_waddr(wb_cp0_reg_waddr_i),
        .wb_cp0_reg_we(wb_cp0_reg_we_i),
        .wb_cp0_reg_wdata(wb_cp0_reg_wdata_i),
        .stall(stall),

                       //for hilo
        /*    wire ex_exmem_whilo;
    wire[`RegBus] ex_exmem_hi;
    wire[`RegBus] ex_exmem_lo;

    wire exmem_mem_whilo;
    wire[`RegBus] exmem_mem_hi;
    wire[`RegBus] exmem_mem_lo;
    
    wire mem_ex_memwb_hilo_we;
    wire[`RegBus]   mem_ex_memwb_hi;
    wire[`RegBus]   mem_ex_memwb_lo;
    
    wire memwb_ex_hilo_we;
    wire[`RegBus]    memwb_ex_hilo_hi;
    wire[`RegBus]    memwb_ex_hilo_lo;

    wire[`RegBus]    hilo_ex_hi;
    wire[`RegBus]    hilo_ex_lo;*/
    	.mem_hi(mem_ex_memwb_hi),
	    .mem_lo(mem_ex_memwb_lo),
	    .mem_whilo(mem_ex_memwb_hilo_we),
    	.wb_hi(memwb_ex_hilo_hi),
	    .wb_lo(memwb_ex_hilo_lo),
	    .wb_whilo(memwb_ex_hilo_we),

        .flush(flush)

    );
    hilo_reg hilo_reg0(
        .clk(clk),
        .rst(rst),
        .we(memwb_ex_hilo_we),
        .hi_i(memwb_ex_hilo_hi),
        .lo_i(memwb_ex_hilo_lo),
        .hi_o(hilo_ex_hi),
        .lo_o(hilo_ex_lo)
    );
    cp0_reg cp0_reg0(
        .clk(clk),
        .rst(rst),
        .we_i(wb_cp0_reg_we_i),
        .waddr_i(wb_cp0_reg_waddr_i),
        .raddr_i(cp0_reg_raddr_i),
        .wdata_i(wb_cp0_reg_wdata_i),
        .int_i(int),

        .rdata_o(cp0_reg_rdata_o),
        .timer_int_o(timer_int),

        .status_o(cp0_status),
		.cause_o(cp0_cause),
		.epc_o(cp0_epc),
        .excepttype_i(mem_excepttype_o),
        .current_inst_addr_i(mem_current_inst_address_o),
		.is_in_delayslot_i(mem_is_in_delayslot_o)
    );
    assign int = {3'b0, uart_RxD_data_ready, 1'b0, timer_int};
    
    //vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga640x480at60 (
    vga #(12, 640, 656, 752, 800, 480, 490, 492, 525, 1, 1) vga640x480at60 (
        .clk(pclk), 
        .pos(vga_pos),
        .hsync(video_hsync),
        .vsync(video_vsync),
        .data_enable(video_de)
    );
    

       
    
    vga_mem vga_mem0(
        .clk(clk),
        .pclk(pclk),
        .ce(vga_ce),
        .we(vga_we),
        .addr(vga_waddr),
        .data_i(vga_wdata),
        .pos(vga_pos),
        .video_data(video_data),
        .video_pixel(video_pixel)
    );

endmodule
