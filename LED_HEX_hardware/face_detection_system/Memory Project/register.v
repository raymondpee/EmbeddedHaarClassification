module register
#(
parameter DATA_WIDTH =15, // max address value 255
parameter ADDR_WIDTH =13 // max address value 255
)
(
	input clk
);
	wire[DATA_WIDTH:0] q_data;
	reg [ADDR_WIDTH:0] address =0;
	reg [DATA_WIDTH:0] count =0;
	
	always @(posedge clk)
	begin
		address = address+1;
	end	

	always@(q_data)
	begin
		count = count +1;
	end
	
	rom_single_port_0
	rom_single_port_0 
	(
	.address(address),
	.clock(clk),
	.rden(1),
	.q(q_data)
	);
	
endmodule