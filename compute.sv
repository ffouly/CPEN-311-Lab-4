module compute (
						input logic 				clk,
						input logic 				start_comp, 
						input logic 	[31:0] 	encrypted_input, 
						input logic 	[23:0] 	s, 
						output logic	[7:0]		address,
						output logic 				wren,
						output logic 	[7:0]		write_val,
						output logic 	[31:0] 	decrypted_output,
						output logic				comp_finish);
						
	logic [7:0] i, j, k;													   			// loop counters 
	logic [7:0]	f;																			// temporary variable to assist swap operation
	logic [1:0] state, next_state;
	logic [23:0] read_i, read_j;
	
	parameter start 		= 4'b0000;
	parameter mem_read 	= 4'b0001;
	parameter readi		= 4'b0010;
	parameter sum_j		= 4'b0011;
	parameter wait_j  	= 4'b0100;
	parameter readj		= 4'b0101;
	parameter writei 	   = 4'b0110;
	parameter writej		= 4'b0111;
	parameter dec_out 	= 4'b1000;
	parameter check_32 	= 4'b1001;
	parameter finish		= 4'b1011;
	
	initial begin 
		i = 0; 
		j = 0;
		k = 0;
		comp_finish = 0;
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
								next_state = dec_out;
							end 
							
			dec_out:		begin 
								f <= s[(s[i]+s[j])];
								decrypted_output[k] <= f ^ encrypted_input[k];
								next_state <= check_32;									// checking for 32 counts
							end 
							
							
			check_32:	begin 
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
