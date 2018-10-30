module sram_and_uart( 
			ext_ram_data, ext_ram_addr, ext_ram_ce_n, ext_ram_oe_n, ext_ram_we_n,
			uart_rdn, uart_wrn, uart_dataready, uart_tbre, uart_tsre
			txd, rxd);
inout reg[31:0] ext_ram_data;
output reg[19:0] ext_ram_addr;
output reg ext_ram_we_n, ext_ram_oe_n, ext_ram_ce_n;
input uart_dataready, uart_tbre, uart_tsre;
input rxd;
output reg txd; 
input clk, rst;
//---------------------------------------------------------------
parameter[9:0] base_ram_addr_in = 4'b0000,
			   base_ram_data_in = 4'b0001,
			   base_ram_loop_write = 4'b0010,
			   base_ram_read_sdby = 4'b0011,
			   base_ram_loop_read = 4'b0100,
			   ext_ram_addr_in = 4'b0101,
			   ext_ram_loop_write = 4'b0111,
			   ext_ram_read_sdby = 4'b1000,
			   ext_ram_loop_read = 4'b1001;

reg[3:0] state_machine = 4'b0000;
reg[31:0] holdon_data = 32'b0;
reg[19:0] holdon_addr = 19'b0;
integer cnt = 0;


always @(posedge clk or posedge rst) begin
	if (rst) begin
		state_machine <= 4'b0000;
		holdon_addr <= 19'b0;
		holdon_data <= 32'b0;
		cnt <= 0;
		base_ram_data <= 32'b0;
		base_ram_addr <= 19'b0;
		base_ram_we_n <= 1'b1;
		base_ram_oe_n <= 1'b1;
		base_ram_ce_n <= 1'b0;
		ext_ram_data <= 32'b0;
		ext_ram_addr <= 19'b0;
		ext_ram_we_n <= 1'b1;
		ext_ram_oe_n <= 1'b1;
		ext_ram_ce_n <= 1'b0;
		leds <= 16'hffff;
	end
	else begin
		case (state_machine)
			base_ram_addr_in: begin
				holdon_addr = switch[19:0];
				leds[15:8] = holdon_addr[7:0];
				state_machine = base_ram_data_in;
			end
			base_ram_data_in: begin
				holdon_data = switch[31:0];
				leds[7:0] = holdon_data[7:0];
				cnt = cnt + 1;
				base_ram_addr = holdon_addr;
				base_ram_we_n = 1'b0;
				base_ram_data = holdon_data;
				base_ram_we_n = 1'b1;
				state_machine = base_ram_loop_write;
			end
			base_ram_loop_write: begin
				holdon_data = holdon_data + 1;
				holdon_addr = holdon_addr + 1;
				holdon_data = switch[31:0];
				leds[7:0] = holdon_data[7:0];
				cnt = cnt + 1;
				base_ram_addr = holdon_addr;
				base_ram_we_n = 1'b0;
				base_ram_data = holdon_data;
				base_ram_we_n = 1'b1;
				if(cnt == 10) begin
					state_machine = base_ram_read_sdby;
					cnt = 0;
				end
			end
			base_ram_read_sdby: begin
				holdon_addr = holdon_addr - 9;
				base_ram_oe_n = 1'b0;
			end
			base_ram_loop_read: begin
				base_ram_addr = holdon_addr;
				holdon_data = base_ram_data;
				leds = holdon_data[15:0];
				holdon_addr = holdon_addr + 1;
				cnt = cnt + 1;
				if(cnt == 10) begin
					state_machine = ext_ram_addr_in;
					cnt = 0;
				end
			end
			ext_ram_addr_in: begin
				base_ram_we_n = 1'b1;
				base_ram_oe_n = 1'b1;
				holdon_addr = holdon_addr - 9;
				holdon_data = holdon_data - 9;
				ext_ram_addr = holdon_addr;
				ext_ram_we_n = 1'b0;
				ext_ram_data = holdon_data;
				ext_ram_we_n = 1'b1;
				state_machine = ext_ram_loop_write;
			end
	end
end

endmodule






