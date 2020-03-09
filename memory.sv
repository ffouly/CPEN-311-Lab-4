//Know i is 0 to 255
module memory(output [7:0] s);

logic [31:0] i; 

initial begin 
for (i = 8'b0; i < 8'd256; i = i+ 8'd1) 
	
	s[i]<= i;

end 

endmodule 