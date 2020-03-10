//Know i is 0 to 255
module memory(output [7:0] data_out, output [7:0] address_out, output logic write_enable, output logic done, input clk, input reset, input en);

//Internal counter
logic [7:0] i; 

always @(posedge clk, posedge reset) begin

	if (reset == 1'b1)begin
		i = 8'b0; //Assign counter to zero
		write_enable = 1'b0;
		done = 1'b1;
	end
	else if (en == 1'b1) begin
		if (i==8'd255) done= 1'b1;
		else begin 
		i = i +8'b1;
		write_enable = 1'b1;
		done = 1'b0;
		end
	end
	else if (en == 1'b0) begin
		i = i; 
		write_enable = 1'b0;
		done = 1'b0;
	end
	else if (done== 1'b0)begin
		if (i== 8'd255)begin
		i= 8'b0;
		write_enable= 1'b0;
		done = 1'b1;
		end 
		
		else begin
		i = i+8'b1;
		write_enable = 1'b1;
		done = 1'b0;
		end 
	end 
end

assign address_out = i;
assign data_out = i; 

endmodule 