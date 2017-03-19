module rom_haar
(
	output [15:0]q_0,
	output [15:0]q_1,
	output [15:0]q_2,
	output [15:0]q_3,
	input clk,
	input b_rden,
	output isready
)
;

localparam ADDR_WIDTH_GENERAL = 8; //9 bit address width in General.mif
localparam ADDR_WIDTH_ROM = 13;    //14 bit address width in all Rom.mif
localparam ADDR_SIZE_GENERAL = 2**ADDR_WIDTH_GENERAL; //General address size 
localparam ADDR_SIZE_ROM = 2**ADDR_WIDTH_ROM;         //ROM address size

localparam DATA_WIDTH = 15;        //16 bit of data for all input (try to synchronize them all)

//flag 
reg b_rden_rom = 0;
reg b_rden_general = 1;

reg [ADDR_WIDTH_GENERAL:0] addr_general = 0;  // address for general.mif
wire [DATA_WIDTH:0] q_general;                // data output from general rom


//General address counter
always@(posedge clk)
begin
	if(addr_general == MAX_ADDR_GENERAL)
	begin
		b_rden_rom 		<= 1;
		b_rden_general <= 0;
	end
	else
	begin
		addr_general <= addr_general +1;
	end
end

always@(posedge clk)
begin
	
end


rom_single_port_0
rom_single_port_0
(
	.address(),
	.clock(clk),
	.rden(b_rden_rom),
	.q(q_0)
);
rom_single_port_1
rom_single_port_1
(
	.address(),
	.clock(clk),
	.rden(b_rden_rom),
	.q(q_1)
);

rom_single_port_2
rom_single_port_2
(
	.address(),
	.clock(clk),
	.rden(b_rden_rom),
	.q(q_2)
);

rom_single_port_3
rom_single_port_3
(
	.address(),
	.clock(clk),
	.rden(b_rden_rom),
	.q(q_3)
);

endmodule