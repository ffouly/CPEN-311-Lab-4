module compute (
						input logic start,
						input logic [31:0] encrypted_input, 
						input logic [23:0] s, 
						input logic [31:0] secret_key,
						output logic [31:0] decrypted_output);
						
	logic [31:0] i, j, k;													// loop counters 
	logic [7:0]	f;
	logic  temp;																// temporary variable to assist swap operation
	logic [1:0] state, next_state;
	
	parameter start 		= 3'b000;
	parameter modulus 	= 3'b001;
	parameter compute		= 3'b010;
	parameter dec_out 	= 3'b011;
	parameter check_32	= 3'b100;
	parameter finish 		= 3'b101;
	
	initial begin 
		i = 0; 
		j = 0;
		k = 0;
		comp_start = 0;
	end
	

	always @ (posedge clk) begin 
		case(state) begin
		
			  start: begin 														// checks for strat signal from master 
							if(start) next_state <= modulus;					// if start, we compute modulus 
							else next_state <= start;							// else, remain in start
						end
						
			modulus:	begin
							i <= (i+1)%256; 										// computing modulus statements
							j <= (j+s[i])%256;
							k <= k+1'd1;											// incrementing k counter 
							temp <= s[i];
							next_state <= compute;
						end
						
			compute:	begin
							s[i] <= s[j];											// performing swap of s[i] and s[j]
							s[j] <= temp;											
							next_state <= dec_out;
						end 
						
			dec_out:	begin 
							f <= s[(s[i]+s[j])%256];
							decrypted_output[k] <= f ^ encrypted_input[k];
							next_state = check_32;
						end 
						
		  check_32: begin 
								if(k< 32'd32) next_state <= modulus;		// for k to message length-1{...}, we continue loop
								else next_state <= finish;						// else, exit loop, wait for start signal again
						end						
			
			finish: 	begin 														// when done the loop 32 times, go back to wait for start
							start = 1'b0; 
							next_state = start;
						end
						
			default:		next_state = start;				
		endcase 
		
	end 