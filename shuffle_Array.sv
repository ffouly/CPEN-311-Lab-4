module shuffle_array(
							input logic 				clk,
							input logic					start_shuffle,
							input logic 	[31:0] 	encrypted_input, 
							input logic 	[23:0]	s, 
							input logic 	[9:0] 	SW, 
							output logic 				wren,
							output logic 	[7:0]		write_val,
							output logic 	[7:0] 	address, 
							output logic 	[31:0] 	decrypted_output,
							output logic 				shuffle_finish);

	logic [7:0] i, j;															   		// loop counters
	logic [23:0] read_i, read_j;														// variables to store s[i] and s[j]
	logic [23:0] secret_key;															// variable to store SW into secret key
	logic [1:0] state, next_state;
	logic [7:0] key_byte;																// variable to store current byte beign processed
	
	parameter start 		= 4'b0000;
	parameter mem_read 	= 4'b0001;
	parameter readi		= 4'b0010;
	parameter key		 	= 4'b0011;
	parameter shuffle  	= 4'b0100;
	parameter wait_j 		= 4'b0101;
	parameter readj 		= 4'b0110;
	parameter writei 	   = 4'b0111;
	parameter writej 	   = 4'b1000;
	parameter check_256 	= 4'b1001;
	parameter finish 		= 4'b1011;

	
	assign secret_key = {14'b0, SW};
	
	initial begin 
		address = 8'b0;																	// initializing address to read from RAM to be 0
		i = 0; 																			   // initializing loop counters to 0
		j = 0; 																				// initializing start signal to slave to 0
		shuffle_finish = 1'b0;
	end
	
	
	always @ (posedge clk) begin
		case(state)  
		
			start: 		begin 
								if(start_shuffle) next_state <= mem_read; 					// waiting for start signal from master 
								else next_state <= start;								// if not, keep waiting 
							end
			
			mem_read:	begin 
								address <= address +8'b1;								// incrementing address to read from, to get new s
								next_state <= readi; 								   // going to wait for data 
							end 
			
			readi:	   begin 
								read_i = s; 												// reading ram value for s[i]
								next_state <= key;										// waiting for data from RAM to be updated
							end
			
			key:			begin 															// reading one byte at a time 
								if((i%3) == 8'b0)	key_byte = secret_key[23:16];		
								else if((i%3) == 8'b1)	key_byte = secret_key[15:8];
								else key_byte = secret_key[7:0];
								next_state <= shuffle;
							end 
			shuffle:		begin 
								j <= (j + s[i] + key_byte);			   // shuffling array based on secret key
								next_state <= wait_j;									// going to swap variables 
							end
							
			wait_j:		begin 														
								address = j; 												// setting address to j
								next_state = readj;	
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
								next_state <= check_256;								// going to check if 256 counts reached
							end 
							
							
			check_256:	begin 
								if(i < 32'd256) next_state <= mem_read;			// for i 0 to 255 {...}
								else next_state <= finish;								// once 256 counts reached, we go to finish
								wren = 1'b0;
							end
								
			finish:		begin 	
								shuffle_finish <= 1'b1;
								next_state <= finish;										//  finish execution once 
							end
			

			default:    next_state <= start;
			endcase
		end 

		assign state = next_state;

endmodule 