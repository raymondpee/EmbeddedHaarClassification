module image_container
#(
DATA_WIDTH_8 = 8,
DATA_WIDTH_12 = 12,
DATA_WIDTH_16 = 16,
DATA_WIDTH_32 = 32,
FILE_NAME = "test.mif"
)
(
clk,
reset,
enable,
coordinate_index,
o_pixel,
o_lwphcfpga_input
);

input clk;
input reset;
input enable;
input [DATA_WIDTH_16-1:0] coordinate_index;
output [DATA_WIDTH_8-1:0] o_pixel;
output o_lwphcfpga_input;

reg enable_delay;
reg lwphcfpga_input;

wire [DATA_WIDTH_8-1:0] pixel;
assign o_pixel = pixel;
assign o_lwphcfpga_input = lwphcfpga_input;

always@(posedge clk)
begin
	if(reset)
	begin
		enable_delay<=0;
		lwphcfpga_input<=0;
	end
	if(enable)
	begin
		enable_delay <=1;
	end
	if(lwphcfpga_input)
	begin
		lwphcfpga_input<=0;
	end
	if(enable_delay)
	begin
		enable_delay<=0;
		lwphcfpga_input<=1;
	end

end


rom 
#(
.DATA_WIDTH(DATA_WIDTH_8),
.ADDR_WIDTH(DATA_WIDTH_32), 
.MEMORY_FILE(FILE_NAME)
)
rom_image
(
.clock(clk),
.ren(enable),
.address(coordinate_index),
.q(pixel)
);



endmodule