module ksa(CLOCK_50, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, ssOut, nIn);

		input logic CLOCK_50;
		input logic [3:0] KEY;
		input logic SW [9:0];
		output logic [9:0] LEDR;	
		output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

		output logic [6:0]	ssOut;
		input logic [3:0]		nIn; 

		wire clk, reset_n, wren; 
										
		wire [7:0] s, address_ram , data;  
		
	initial begin

    clk <= CLOCK_50;
    reset_n <= KEY[3];
	 
	 end 
	 
	 memory mem(s);
	 s_memory mem1(.address(address_ram), .clock(CLOCK_50), .data(data), .wren(1'b1), .q(s));
	 
	shuffle_array	ahuff(.encrypted_input(encrypted_input),
								.s(s), 
							   .SW(SW), 
								.address(address_ram), 
							   .decrypted_output.(decrypted_output));

endmodule 
