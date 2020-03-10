module compute (
						input logic 				clk,
						input logic 				start_comp, 
						input logic 	[7:0] 	encrypted_input, 
						input logic 	[7:0] 	s, 
						input logic 	[7:0] 	q_m, 
						output logic	[7:0]		address,
						output logic	[7:0]		address_m,
						output logic	[7:0]		address_d,
						output logic 				wren,
						output logic 				wren_d,
						output logic 	[7:0]		write_val,
						output logic 	[7:0] 	data_d,
						output logic				comp_finish);
						
	logic [7:0] i, j, k;													   			// loop counters 
	logic [7:0]	f;																			// temporary variable to assist swap operation
	logic [1:0] state, next_state;
	logic [23:0] read_i, read_j;
	logic [7:0] out_dec, read_en;
	
	parameter start 		= 5'b00000;
	parameter mem_read 	= 5'b00001;
	parameter readi		= 5'b00010;
	parameter sum_j		= 5'b00011;
	parameter wait_j  	= 5'b00100;
	parameter readj		= 5'b00101;
	parameter writei 	   = 5'b00110;
	parameter writej		= 5'b10000;
	parameter wait_enc	= 5'b00111;
	parameter read_enc	= 5'b01000;
	parameter dec_out 	= 5'b01001;
	parameter write_dec	= 5'b01011;
	parameter check_32 	= 5'b01100;
	parameter finish		= 5'b01101;
	
	initial begin 
		i = 0; 
		j = 0;
		k = 0;
		comp_finish = 0;
		wren = 1'b0; 
		wren_d = 1'b0;
	end
	
	logic [31:0] secret_key;															// variable to store SW into secret key

	always @ (posedge clk) begin 
		case(state) 
		
				start: 	begin 															// checks for strat signal from master 
								if(start_comp) next_state <= mem_read;						// if start, we compute modulus 
								else next_state <= start;								// else, remain in start
							end
								
			mem_read:	begin 
								address <= address +8'b1;								// incrementing address to read from, to get new s
								i <= i + 8'b1;												// incrementing i counter
								next_state <= readi; 								   // going to wait for data 
							end 
			
			readi:	   begin 
								read_i <= s; 												// reading ram value for s[i]
								next_state <= sum_j;										// waiting for data from RAM to be updated
							end
							
			sum_j:		begin 
								j <= j + readi;
								next_state <= wait_j;
							end
							
			wait_j:		begin 														
								address <= j; 												// setting address to j
								next_state <= readj;	
							end 
							
			readj:		begin 
								read_j <= s;												// reading address s[j]
								next_state <= writei;
							end
							
			writei:		begin
								wren <= 1'b1;												
								write_val <= readi;
								address <= j;
								i <= i + 32'd1;											// incrementing counter to access new s[i], 256 times
								next_state <= writej;									// going to perform swap on j
							end 
							
			writej:		begin
								wren <= 1'b1;
								write_val <= readj;
								address <= i;		
								next_state = wait_enc;
							end 
							
			wait_enc:	begin	
								wren <= 1'b0;
								address_m <= k;
								next_state <= read_enc;
							end
							
			read_enc:	begin 
								read_en <= q_m;
								next_state <= dec_out;
							end
							
			dec_out:		begin 
								f <= s[(s[i]+s[j])];
								out_dec <= f ^ read_en;
								next_state <= write_dec;									// checking for 32 counts
							end 
							
			write_dec:	begin 
								wren_d <= 1'b1;
								address_d <= k;
								data_d <= out_dec;
								next_state <= check_32;
							end
								
			check_32:	begin 
								wren_d <= 1'b0;
								if(i < 32'd32) next_state <= mem_read;				// for k = 0 to message_length-1 {...}
								else next_state <= finish;								// once 256 counts reached, we go to finish
								wren = 1'b0;
							end
								
			finish:		begin 	
								comp_finish <= 1'b1;
								next_state <= finish;									//  finish execution once 
							end
			

			default:    next_state <= start;
		
		endcase 
		
	end 
	
			assign state = next_state;
			
endmodule
