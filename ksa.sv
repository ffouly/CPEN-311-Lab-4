module ksa(CLOCK_50, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, ssOut, nIn);

		input logic CLOCK_50;
		input logic [3:0] KEY;
		input logic SW [9:0];
		output logic [9:0] LEDR;	
		output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

		output logic [6:0]	ssOut;
		input logic [3:0]		nIn; 

		wire clk, reset_n, wren, write_enable_k, enable, end_triggor, done; 
										
		wire [7:0] s, address_ram , data_f;  
		
	initial begin

    clk <= CLOCK_50;
    reset_n <= KEY[3];
	 
	 end 

	
	//This ensures is only called once
	always_ff @(posedge CLOCK_50, posedge reset_n) begin
		if (reset_n == 1) begin
			//done = 1'b0;
			enable = 1'b0;
		end
		else if ((end_triggor == 1'b1) && (done == 1'b0)) begin
			//done = 1'b1;
			enable = 1'b1;
		end
		else begin
			enable = 1'b1;
		//	done = done;
		end
	end
	 	 
	 memory mem(.data_out(data_f), 
					.address_out(address_ram), 
					.write_enable(write_enable_k), 
					.done(end_triggor), 
					.clk(CLOCK_50), 
					.reset(reset_n), 
					.en(enable));
	 s_memory mem1(.address(address_ram), 
						.clock(CLOCK_50), 
						.data(data_f), 
						.wren(write_enable_k), 
						.q(s));
	 
	/*shuffle_array	ahuff(.encrypted_input(encrypted_input),
								.s(s), 
							   .SW(SW), 
								.address(address_ram), 
							   .decrypted_output(decrypted_output));*/

endmodule 