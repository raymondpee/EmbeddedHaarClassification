module image_container
#(
DATA_WIDTH_8 = 8,
DATA_WIDTH_12 = 12,
DATA_WIDTH_16 = 16,
DATA_WIDTH_32 = 32
FILE_NAME = "test.mif"
)
(
clk,
enable,
coordinate_index,
ori_x,
ori_y,
frame_width,
o_pixel
);

input clk;
input enable;
input [DATA_WIDTH_16-1:0] coordinate_index;
output [DATA_WIDTH_8-1:0] o_pixel;

wire [DATA_WIDTH_8-1:0] pixel;
assign o_pixel = pixel;

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