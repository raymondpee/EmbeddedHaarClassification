// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns
module test_I2LBS_memory;

localparam DATA_WIDTH_8 = 8;
localparam DATA_WIDTH_12 = 12;
localparam DATA_WIDTH_16 = 16;
localparam MAX_VAL = 255;

localparam FRAME_CAMERA_WIDTH = 20;
localparam FRAME_CAMERA_HEIGHT = 20;
localparam INTEGRAL_LENGTH = 8;
localparam INTEGRAL_WIDTH = INTEGRAL_LENGTH;
localparam INTEGRAL_HEIGHT = INTEGRAL_LENGTH;

reg clk_os;
reg reset_os;
reg clk_fpga;
reg reset_fpga;
reg [DATA_WIDTH_12-1:0] pixel = 0; // Pixel of the image
reg wen;

wire integral_image_ready;
wire [DATA_WIDTH_12-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
/*--------------------------- INITIAL STATEMENT ---------------------------*/
initial
begin
  clk_os = 0;
  clk_fpga = 0;
  #1 reset_os = 1;
  #1 reset_os = 0;
  #1 wen = 1;
end
/*-----------------------------------------------------------------------*/


/*--------------------------- SEQUENTIAL LOGIC ---------------------------*/
// Clock:
always # 1 clk_os <= ~clk_os;
always # 1 clk_fpga <= ~clk_fpga; 

//Pixel Iteration:
always @(posedge clk_os)
begin
	if(reset_os)
		wen<=0;
	else
	begin
		if(wen)
		begin
			if(pixel == MAX_VAL)
				pixel <= 0;
			else
				pixel <= pixel + 1;
		end
	end
end
/*-----------------------------------------------------------------------*/

I2LBS_memory
#(
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT),
.FRAME_CAMERA_WIDTH(FRAME_CAMERA_WIDTH),
.FRAME_CAMERA_HEIGHT(FRAME_CAMERA_HEIGHT)
)
I2LBS_memory
(
.clk_os(clk_os),
.reset_os(reset_os),
.pixel(pixel),
.wen(wen),
.o_integral_image(integral_image),
.o_integral_image_ready(integral_image_ready)
);


endmodule