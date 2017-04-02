module facial_detection_ip
(
clk_os,
clk_fpga,
reset_os,
reset_fpga,
pixel
);
localparam ADDR_WIDTH;
localparam DATA_WIDTH_8 = 8;   // Max value 255
localparam DATA_WIDTH_12 = 12; // Max value 4095
localparam DATA_WIDTH_16 = 16; // Max value 177777

localparam NUM_STAGE_THRESHOLD = 1;
localparam NUM_PARAM_PER_CLASSIFIER = 18;
localparam NUM_CLASSIFIERS_FIRST_STAGE = 10;
localparam NUM_CLASSIFIERS_SECOND_STAGE = 10;
localparam NUM_CLASSIFIERS_THIRD_STAGE = 10;

localparam INTEGRAL_LENGTH = 8;
localparam INTEGRAL_WIDTH = INTEGRAL_LENGTH;
localparam INTEGRAL_HEIGHT = INTEGRAL_LENGTH;

localparam FRAME_CAMERA_WIDTH = 10;
localparam FRAME_CAMERA_HEIGHT = 10;

input clk_os;
input clk_fpga;
input reset_os;
input reset_fpga;
input [DATA_WIDTH_8 -1:0] pixel;

wire is_candidate;
wire [DATA_WIDTH_12 -1:0] o_scale_xcoord;
wire [DATA_WIDTH_12 -1:0] o_scale_ycoord;
wire [DATA_WIDTH_8-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];

reg [DATA_WIDTH_12 -1:0] xcoord;
reg [DATA_WIDTH_12 -1:0] ycoord;
reg [DATA_WIDTH_12 -1:0]frame_src_width;
reg [DATA_WIDTH_12 -1:0]frame_src_height;
reg [DATA_WIDTH_12 -1:0]frame_dst_width;
reg [DATA_WIDTH_12 -1:0]frame_dst_height;
reg [DATA_WIDTH_8-1:0] rom_first_stage_classifier [NUM_CLASSIFIERS_FIRST_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
reg [DATA_WIDTH_8-1:0] rom_second_stage_classifier [NUM_CLASSIFIERS_SECOND_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
reg [DATA_WIDTH_8-1:0] rom_third_stage_classifier [NUM_CLASSIFIERS_THIRD_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	


always@(posedge reset_fpga)
begin
	frame_src_width <= FRAME_CAMERA_WIDTH;
	frame_src_height <= FRAME_CAMERA_HEIGHT;
	frame_dst_width<= FRAME_CAMERA_WIDTH; // Change this in future
	frame_dst_height <= FRAME_CAMERA_HEIGHT;
	xcoord <= 0;
	ycoord <= 0;	
end

/*------------------------ COORDINATE ITERATION -------------------------*/
always @(posedge clk_os)
begin
  if(xcoord == frame_src_width -1)
  begin 
      xcoord <= 0;
      if(ycoord == frame_src_height -1) ycoord <= 0;   
      else                          ycoord <= ycoord + 1;
  end
  else
    xcoord <= xcoord + 1;
end
/*-----------------------------------------------------------------------*/


I2LBS
#(
.DATA_WIDTH_8(DATA_WIDTH_8), 
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_CLASSIFIERS_FIRST_STAGE(NUM_CLASSIFIERS_FIRST_STAGE),
.NUM_CLASSIFIERS_SECOND_STAGE(NUM_CLASSIFIERS_SECOND_STAGE),
.NUM_CLASSIFIERS_THIRD_STAGE(NUM_CLASSIFIERS_THIRD_STAGE)
)
I2LBS
(
clk_os(clk_os),
clk_fpga(clk_fpga),
reset_os(reset_os),
reset_fpga(reset_fpga),
pixel(pixel),
xcoord(xcoord),
ycoord(ycoord),
frame_src_width(frame_src_width),
frame_src_height(frame_src_height),
frame_dst_width(frame_dst_width),
frame_dst_height(frame_dst_height),
rom_first_stage_classifier(rom_first_stage_classifier),
rom_second_stage_classifier(rom_second_stage_classifier),
rom_third_stage_classifier(rom_third_stage_classifier),
o_scale_xcoord(o_scale_xcoord),
o_scale_ycoord(o_scale_ycoord),
o_is_candidate(is_candidate),
o_integral_image(integral_image)
);


secondary_stage_classifier
#(
.DATA_WIDTH(DATA_WIDTH),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH) ,
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
)
secondary_stage_classifier
(
	.clk_fpga(clk_fpga),
	.reset_fpga(reset_fpga),
	.integral_image(integral_image),
	.i_enable_write(is_candidate),
	.o_is_face(o_is_face)
);

endmodule