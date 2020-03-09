`define start 3'b000
`define compute 3'b001

module shuffle_array(
							input logic 	[31:0] 	encrypted_input, 
							input logic 	[23:0]	s, 
							input logic 	[9:0] 	SW, 
							output logic 	[7:0] 	address, 
							output logic 	[31:0] 	decrypted_output);

	logic [31:0] i, j;															   	// loop counters
	logic [31:0] secret_key;
	logic  temp, comp_start;															// temporary variable & slave start signal
	logic [1:0] state, next_state;
	
	parameter start 		= 3'b000;
	parameter mem_read 	= 3'b001;
	parameter wait_req	= 3'b010;
	parameter shuffle 	= 3'b011;
	parameter swap 		= 3'b100;
	parameter check_256 	= 3'b101;
	parameter finish 		= 3'b110;

	
	compute comp(.start(comp_start),
					 .encrypted_input(encrypted_input), 
					 .s(s), 
					 .secret_key(secret_key),
					 .decrypted_output(decrypted_output));
	
	assign secret_key = {14'b0, SW};
	
	initial begin 
		address = 8'b0;																	// initializing address to read from RAM to be 0
		i = 0; 																			   // initializing loop counters to 0
		j = 0; 
		comp_start = 0;																	// initializing start signal to slave to 0
	end
	
	
	always @ (posedge clk) begin
		case(state) begin 
		
			start: 		begin 
								if(start_sig) next_state <= mem_read; 				// waiting for start signal from master 
								else next_state <= start;								// if not, keep waiting 
								comp_start <= 1'b0;										// setting signa to compute encrypted bytes off
							end
			
			mem_read:	begin 
								address <= address +8'b1;								// incrementing address to read from, to get new s
								next_state <= wait_req; 								// going to wait for data 
							end 
			
			wait_req:	next_state <= shuffle;										// waiting for data from RAM to be updated
	
			shuffle:		begin 
								j <= (j + s[i] + secret_key[(i%3)])%256;			// shuffling array based on secret key
								temp <= s[i];
								next_state <= swap;										// going to swap variables 
							end
							
			swap:			begin
								s[i] <= s[j];
								s[j] <= temp;	
								i <= i + 32'd1;											// incrementing counter to access new s[i], 256 times
								next_state <= check_256;								// going to check if 256 counts reached
							end 
							
			check_256:	begin 
								if(i< 32'd256) next_state <= mem_read;				// for i 0 to 255 {...}
								else next_state <= finish;								// once 256 counts reached, we go to finish
							end
								
			finish:		begin 	
								comp_start <= 1'b1;										// sending start signal to slave to compute bytes in 
								next_state <= start;										//  encrypted message, then going back to wait for start
							end
			

			default:    next_state <= start;
			endcase
		end 



endmodule 