module ksa(CLOCK_50, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, ssOut, nIn);

		input logic CLOCK_50;
		input logic [3:0] KEY;
		input logic SW [9:0];
		output logic [9:0] LEDR;	
		output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

		output logic [6:0]	ssOut;
		input logic [3:0]		nIn; 

		wire clk, reset_n, wren, start_shuffle, start_comp, shuffle_finish, comp_finish; 
										
		wire [7:0] s, address_shuffle, address_comp, data; 
		wire [31:0] encrypted_input, decrypted_output;
		wire [7:0]	write_val_shuffle, write_val_comp;
		
	initial begin

    clk <= CLOCK_50;
    reset_n <= KEY[3];
	 
	 end 
	 
	 memory mem(s);
	 s_memory mem1(.address(address_ram), .clock(CLOCK_50), .data(data), .wren(1'b1), .q(s));
	 
	shuffle_array	shuffle( .clk(CLOCK_50),
									.start_shuffle(start_shuffle),
									.encrypted_input(encrypted_input), 
									.s(s), 
									//.SW(SW), 
									.wren(wren),
									.write_val(write_val_comp),
									.address(address_shuffle), 
									.decrypted_output(decrypted_output),
									.shuffle_finish(shuffle_finish));
				
			 compute compute( .clk(CLOCK_50),
									.start_comp(start_comp), 
									.encrypted_input(encrypted_input), 
									.s(s),
									.address(address_comp),
									.wren(wren),
									.write_val(write_val_shuffle),
									.decrypted_output(decrypted_output),
									.comp_finish(comp_finish));
									
			Master		 FSM( .clk(CLOCK_50),
									.shuffle_finish(shuffle_finish),
									.comp_finish(comp_finish),
									.start_shuffle(start_shuffle),
									.start_comp(start_comp));
									

endmodule 
