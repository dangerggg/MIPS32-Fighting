module vga_mem(
    input wire   clk,
    input wire   pclk,
    input wire   ce,
    input wire   we,
    input wire[23:0]  addr,
    input wire[31:0]  data_i,
    input wire[18:0]  pos,
    output reg[31:0] video_data,
    output reg[7:0] video_pixel
);

    wire[31:0] pixel_data;
    wire wen;
    assign wen = ce & we;
    //assign video_data = pixel_data;
    
    blk_mem_gen_0 block_ram(
        // write
        .clka(pclk),
        .addra(addr[18:2]),
        .dina(data_i),
        .ena(ce),
        .wea(we),
        // read
        .clkb(pclk),
        .addrb(pos[18:2]),
        .doutb(pixel_data),
        .enb(1'b1)
    );

    always @ (*) begin
        video_data <= pixel_data;
        case(pos[1:0])
            2'b00: begin
                video_pixel <= pixel_data[7:0];
            end
            2'b01: begin
                video_pixel <= pixel_data[15:8];
            end
            2'b10: begin
                video_pixel <= pixel_data[23:16];
            end
            2'b11: begin
                video_pixel <= pixel_data[31:24];
            end
        endcase
    end

    // reg[31:0] video_mem[0:9599];

    // always @ (*) begin
    //     video_mem[addr[15:2]] <= data_i;
    // end
    
    // always @ (*) begin
    //     case(pos[1:0])
    //         2'b00: begin
    //             video_pixel <= video_mem[pos[15:2]][7:0];
    //         end
    //         2'b01: begin
    //             video_pixel <= video_mem[pos[15:2]][15:8];
    //         end
    //         2'b10: begin
    //             video_pixel <= video_mem[pos[15:2]][23:16];
    //         end
    //         2'b11: begin
    //             video_pixel <= video_mem[pos[15:2]][31:24];
    //         end
    //     endcase
    // end

    // reg video_mem[0:20'hfffff];

    // assign pixel_addr = {hdata[9:0], vdata[9:0]};
    // assign vga_addr = {addr[21:12], addr[9:0]};
    // assign video_data[0] = video_mem[0];
    // assign video_data[1] = video_mem[1];
    // assign video_data[2] = video_mem[2];
    // assign video_data[3] = video_mem[3];
    // assign video_data[4] = video_mem[4];
    // assign video_data[5] = video_mem[5];
    // assign video_data[6] = video_mem[6];
    // assign video_data[7] = video_mem[7];
    
    // always @ (*) begin
    //     // if (hdata[6:0] == 7'b1111111) begin
    //     //     video_pixel <= 8'hff;
    //     // end else begin
    //         video_pixel <= {8{video_mem[pixel_addr]}};
    //     //end
    // end

	// always @ (*) begin
	// 	if (ce == 1'b1) begin
    //         if (we == 1'b1) begin
    //             video_mem[vga_addr] <= data_i[0];
    //             data_o <= 8'b00000000;
    //         end else begin
    //             data_o <= video_mem[vga_addr];
    //         end
	// 	end
	// end	
endmodule