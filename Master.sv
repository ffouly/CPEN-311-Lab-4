module Master(
					input logic 			clk,
					input logic 			done,
					input logic 			shuffle_finish,
					input logic 			comp_finish,
					output logic 			start_mem,
					output logic 			start_shuffle,
					output logic 			start_comp,
					output logic	[7:0] address,
					output logic 	[7:0]	data,
					
					input logic	 	[7:0] add_shuffle,
					input logic 	[7:0] add_mem,
					input logic 	[7:0] add_comp,
					
					input logic 	[7:0]	data_shuff,
					input logic 	[7:0]	data_mem,
					input logic 	[7:0]	data_comp,
					
					input logic				wren_shuff,
					input logic				wren_mem,
					input logic				wren_comp,
					output logic			wren			);
					
		parameter start 			= 3'b000;
		parameter wait_mem		= 3'b001;
		parameter wait_shuffle 	= 3'b010;
		parameter wait_comp		= 3'b011;
		parameter finish			= 3'b100;
		
		logic [2:0] state, next_state;
		logic [7:0]	addr_sel, data_sel;
		logic wren_sel;
		
		initial begin 
		
			start_shuffle = 1'b0; 
			start_mem 	  = 1'b0;
			start_comp	  = 1'b0;
		end 
		
		always @(posedge clk) begin 
			case(state)
				start: 				begin 
											start_mem <= 1'b1;
											next_state <= wait_mem;
										end
										
				wait_mem:			begin 
										addr_sel <= add_mem;
										data_sel <= data_mem;
										wren_sel <= wren_mem;
										if(done) begin 
											next_state <= wait_shuffle;
											start_shuffle <= 1'b1;
											start_mem <= 1'b0;
											end 
										else next_state <= wait_mem;
										end
				
				wait_shuffle:		begin 
											addr_sel <= add_shuffle;
											data_sel	  <=	data_shuff;
											wren_sel 	<= wren_shuff;
											if(shuffle_finish) begin
												next_state <= wait_comp;
												start_comp <= 1'b1;
												start_shuffle <= 1'b0;
												end
											else next_state <= finish;
										end 
										
				/*wait_comp:			begin 
										addr_sel <= add_comp;
										data_sel <= data_comp;
										wren_sel <= wren_comp;
											if(comp_finish) begin
												next_state <= finish;
												start_comp <= 1'b0;
											end
											else next_state <= wait_comp;			
										end	*/
				finish:				next_state <= finish;
				default:				next_state <= start;
				
			endcase
		end 
		assign state = next_state;
		assign address = addr_sel;
		assign data = data_sel;
		assign wren = wren_sel;
		
endmodule 