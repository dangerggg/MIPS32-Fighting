module sram_and_uart( 
			base_ram_data, base_ram_addr, base_ram_ce_n, base_ram_oe_n, base_ram_we_n,
			uart_rdn, uart_wrn, uart_dataready, uart_tbre, uart_tsre
			txd, rxd, leds, );
inout reg[31:0] base_ram_data;
output reg[19:0] base_ram_addr;
output reg[15:0] leds;
output reg base_ram_we_n, base_ram_oe_n, base_ram_ce_n;
output reg uart_wrn, uart_rdn;
output reg txd; 
input uart_dataready, uart_tbre, uart_tsre;
input rxd;
input clk11M, rst, clk;

//---------------------------------------------------------------
parameter[9:0] initial_read_state = 4'b0000,
			   read_s1 = 4'b0001,
			   read_s2 = 4'b0010,
			   sram_write = 4'b0100, 
			   write_holdon = 4'b0101,
			   sram_read = 4'b0110,
			   initial_write_state = 4'b1000,
			   write_s1 = 4'b1001,
			   write_s2 = 4'b1010,
			   write_s3 = 4'b1011,
			   jobs_done = 4'b1101;

reg[3:0] state_machine = 4'b0000;
reg[31:0] holdon_data = 32'b0;
reg[31:0] read_data = 32'b0;
reg[19:0] holdon_addr = 19'b0;
reg lock = 1'b0;

always @(posedge clk or posedge rst) begin
	if(clk) begin
		lock = ~lock;
	end
	else begin
		lock = 1'b0;
	end
end

always @(posedge clk11M or posedge rst) begin
	if (rst) begin
		state_machine <= 4'b0000;
		holdon_addr <= 19'b0;
		holdon_data <= 32'b0;
		base_ram_data <= 32'b0;
		base_ram_addr <= 19'b0;
		base_ram_we_n <= 1'b1;
		base_ram_oe_n <= 1'b1;
		base_ram_ce_n <= 1'b1;
		leds <= 16'h0000;
		uart_rdn <= 1'b1;
		uart_wdn <= 1'b1;
	end
	else if(clk) begin
		case (state_machine)
			initial_read_state: begin
				uart_rdn <= 1'b1;
				base_ram_data[7:0] <= 8'bz;
				state_machine <= read_s1;
			end
			read_s1: begin
				if(uart_dataready == 1'b0) begin
					state_machine <= initial_read_state;
				end
				else if(uart_dataready == 1'b1) begin
					uart_rdn <= 1'b0;
					state_machine <= read_s2;
				end
			end
			read_s2: begin
				holdon_data <= {24'h0000, base_ram_data[7:0]};
				state_machine <= sram_write;
			end
			sram_write: begin
				uart_rdn = 1'b1;
				base_ram_addr = 32'h0000;
				base_ram_ce_n = 1'b0;
				base_ram_we_n = 1'b0;
				base_ram_data = holdon_data;
				state_machine = write_holdon;
			end
			write_holdon: begin
				base_ram_we_n <= 1'b1;
				base_ram_ce_n <= 1'b1;
				state_machine <= sram_read;
			end
			sram_read: begin
				base_ram_addr = 32'h0000;
				base_ram_ce_n = 1'b0;
				base_ram_oe_n = 1'b0;
				read_data = base_ram_data;
				state_machine = initial_write_state;
			end
			initial_write_state: begin
				base_ram_ce_n <= 1'b1;
				base_ram_oe_n <= 1'b1;
				base_ram_data <= read_data;
				uart_wrn <= 1'b0;
				state_machine <= write_s1;
			end
			write_s1: begin
				uart_wrn <= 1'b1;
				state_machine <= write_s2;
			end
			write_s2: begin
				if(uart_tbre == 1'b1) begin
					state_machine <= write_s3;
				end
			end
			write_s3: begin
				if(uart_tsre == 1'b1) begin
					state_machine <= jobs_done;
				end
			end
			jobs_done: begin
				leds <= 16'hffff;
			end
	end
end
endmodule






