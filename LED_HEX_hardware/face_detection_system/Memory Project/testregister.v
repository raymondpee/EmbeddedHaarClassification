module testregister;

	reg [7:0] data =10;
	reg clk;
	
	initial
	begin
		clk <=0;
	end
	
	always
	#10 clk <=~clk;
	
	register r(
	.clk(clk)
	);
	
endmodule