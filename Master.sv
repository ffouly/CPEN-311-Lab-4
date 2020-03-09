module Master(
					input logic 				clk,
					input logic shuffle_finish,
					input logic comp_finish,
					output logic start_shuffle,
					output logic start_comp);
					
		parameter start 			= 2'b00;
		parameter wait_shuffle 	= 2'b01;
		parameter wait_comp		= 2'b11;
		parameter finish			= 2'b10;
		
		logic [1:0] state, next_state;
		
		initial begin 
		
			start_shuffle = 1'b0; 
			start_comp	  = 1'b0;
		end 
		
		always @(posedge clk) begin 
			case(state)
				start: 				begin 
											next_state <= wait_shuffle;
											start_shuffle <= 1'b1;
										end
				
				wait_shuffle:		begin 
											if(shuffle_finish) begin
												next_state <= wait_comp;
												start_comp <= 1'b1;
												start_shuffle <= 1'b0;
												end
											else next_state <= wait_shuffle;
										end 
										
				wait_comp:			begin 
											if(comp_finish) begin
												next_state <= finish;
												start_comp <= 1'b0;
											end
											else next_state <= wait_comp;			
										end	
				finish:				next_state <= finish;
				default:				next_state <= start;
				
			endcase
		end 
		assign state = next_state;
		
endmodule 