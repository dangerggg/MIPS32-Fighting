`timescale 1ns / 1ps
`include "defines.h"

module mips32_min_sopc(
    input wire          clk_in,
    input wire[5:0]     touch_btn,


    // base sram
    inout wire[31:0]     base_ram_data,
    output wire[19:0]    base_ram_addr,
    output wire          base_ram_ce_n,
    output wire          base_ram_oe_n,
    output wire          base_ram_we_n,
    output wire[3:0]     base_ram_be_n,
    // ext sram
    inout wire[31:0]     ext_ram_data,
    output wire[19:0]    ext_ram_addr,
    output wire          ext_ram_ce_n,
    output wire          ext_ram_oe_n,
    output wire          ext_ram_we_n,
    output wire[3:0]     ext_ram_be_n,
    //UART
    output wire txd,
    input wire  rxd,
    // vga
    output wire[7:0]        video_pixel,
    output wire             video_hsync,
    output wire             video_vsync,
    output wire             video_clk,
    output wire             video_de,
    
    output wire[15:0]    leds
);
    wire clk;
    wire clk_uart;
    wire rst;
    wire pclk;
    assign rst = touch_btn[5];
    clk_wiz_0 clk_wiz(
         .clk_out1(clk_uart),
         .clk_out2(pclk),
         .clk_in1(clk_in)
    );

    assign clk = touch_btn[4];
    wire[7:0]   int;
    wire        timer_int;

    mips32_top top0(
        .clk_uart(clk_uart),
        .clk(clk_uart),
        .pclk(pclk),
        .rst(rst),
        // .int_i(int),
        // .timer_int_o(timer_int),
        
        .base_ram_data(base_ram_data),
        .base_ram_addr(base_ram_addr),
        .base_ram_ce_n(base_ram_ce_n),
        .base_ram_oe_n(base_ram_oe_n),
        .base_ram_we_n(base_ram_we_n),
        .base_ram_be_n(base_ram_be_n),
        
        .ext_ram_data(ext_ram_data),
        .ext_ram_addr(ext_ram_addr),
        .ext_ram_ce_n(ext_ram_ce_n),
        .ext_ram_oe_n(ext_ram_oe_n),
        .ext_ram_we_n(ext_ram_we_n),
        .ext_ram_be_n(ext_ram_be_n),
                
        .TxD(txd),
        .RxD(rxd),
        
        .video_pixel(video_pixel),
        .video_hsync(video_hsync),
        .video_vsync(video_vsync),
        .video_clk(video_clk),
        .video_de(video_de),
        
        .touch_btn(touch_btn),

        .leds(leds)
    );
endmodule
