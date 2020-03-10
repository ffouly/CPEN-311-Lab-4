module ksa(CLOCK_50, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, ssOut, nIn);

		input logic CLOCK_50;
		input logic [3:0] KEY;
		input logic [9:0] SW;
		output logic [9:0] LEDR;	
		output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

		output logic [6:0]	ssOut;
		input logic [3:0]		nIn; 

		logic clk, reset_n, wren, wren_d, start_shuffle, start_comp, shuffle_finish, comp_finish, done, start_mem, enable;
		logic [7:0] address_m_shuffle, address_m_mem,address_m_comp, data_shuff, data_mem, data_comp;
		logic [7:0]	wren_mem, wren_comp, wren_shuff;
		
		logic [7:0] s, address, address_m, data, data_d, address_d; 
		logic [31:0] encrypted_input, decrypted_output;
		logic [7:0]	write_val_shuffle, write_val_comp;
		
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
		else if ((done == 1'b1)) begin
			//done = 1'b1;
			enable = 1'b1;
		end
		else begin
			enable = 1'b1;
		//	done = done;
		end
	end
	 
	 
				s_memory mem1(
									 .address(address), 
									 .clock(CLOCK_50), 
									 .data(data), 
									 .wren(wren), 
									 .q(s));
	 
	 			Master	 FSM( .clk(CLOCK_50),
									.done(done),
									.start_mem(start_mem),
									.shuffle_finish(shuffle_finish),
									.comp_finish(comp_finish),
									.start_shuffle(start_shuffle),
									.start_comp(start_comp),
									.address(address),
									.add_shuffle(address_m_shuffle),
									.add_mem(address_m_mem),
									.add_comp(address_m_comp),
									.data_shuff(data_shuff),
									.data_mem(data_mem),
									.data_comp(data),
									.data(data),
									.wren_mem(wren_mem),
									.wren_comp(wren_comp),
									.wren_shuff(wren_shuff),
									.wren(wren)); 					
		/*s_memory mem1(
									 .address(address_m_mem), 
									 .clock(CLOCK_50), 
									 .data(data), 
									 .wren(wren), 
									 .q(s)); */
	 
		  memory	 memorryy(  .data_out(data_mem), 
									.address_out(address_m_mem), 
									.write_enable(wren_mem), 
									.done(done),
									.clk(CLOCK_50),
									.reset(reset_n), 
									.en(enable));
	 
	/*shuffle_array	shuff( .clk(CLOCK_50),
									.start_shuffle(start_shuffle),
									.s(s), 
									.SW(SW), 
									.wren(wren_shuff),
									.write_val(data_shuff),
									.address(address_m_shuffle), 
									.shuffle_finish(shuffle_finish)); */
				
			 /*compute compute( .clk(CLOCK_50),
									.start_comp(start_comp), 
									.encrypted_input(q_m), 
									.s(s),
									.q_m(s),
									.address(address_m_comp),
									.address_m(address_m),
									.address_d(address_d),
									.wren(wren_comp),
									.wren_d(wren_d),
									.write_val(data_comp),
									.data_d(data_d),
									.comp_finish(comp_finish))
				; */
									

									

endmodule 
