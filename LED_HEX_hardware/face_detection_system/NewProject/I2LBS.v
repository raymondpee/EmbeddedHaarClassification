module I2LBS
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16,
parameter INTEGRAL_WIDTH = 3,
parameter INTEGRAL_HEIGHT = 3,
parameter NUM_STAGE_THRESHOLD = 1,
parameter NUM_PARAM_PER_CLASSIFIER = 18,
parameter NUM_CLASSIFIERS_FIRST_STAGE = 10,
parameter NUM_CLASSIFIERS_SECOND_STAGE = 10,
parameter NUM_CLASSIFIERS_THIRD_STAGE = 10
)
(
	clk_os,
	clk_fpga,
	reset_os,
	reset_fpga,
	pixel,
	xcoord,
	ycoord,
	frame_src_width,
	frame_src_height,
	frame_dst_width,
	frame_dst_height,
	rom_first_stage_classifier,
	rom_second_stage_classifier,
	rom_third_stage_classifier,
	o_scale_xcoord,
	o_scale_ycoord,
	o_is_candidate,
	o_integral_image
);


wire is_candidate;
wire is_write_enable;
wire is_coord_reach;
wire [DATA_WIDTH_12-1:0] scale_xcoord;
wire [DATA_WIDTH_12-1:0] scale_ycoord;


/*--------------------IO port declaration---------------------------------*/
input clk_os;
input clk_fpga;
input reset_os;
input reset_fpga;
input [DATA_WIDTH_8-1:0] pixel;
input [DATA_WIDTH_12-1:0] i_xcoord;
input [DATA_WIDTH_12-1:0] i_ycoord;
input [DATA_WIDTH_8-1:0] rom_first_stage_classifier [NUM_CLASSIFIERS_FIRST_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
input [DATA_WIDTH_8-1:0] rom_second_stage_classifier [NUM_CLASSIFIERS_SECOND_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
input [DATA_WIDTH_8-1:0] rom_third_stage_classifier [NUM_CLASSIFIERS_THIRD_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	

output o_is_candidate;
output [DATA_WIDTH_12-1:0] o_scale_xcoord;
output [DATA_WIDTH_12-1:0] o_scale_ycoord;
output [DATA_WIDTH_8-1:0] o_integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
/*-----------------------------------------------------------------------*/

assign o_scale_xcoord = scale_xcoord;
assign o_scale_ycoord = scale_ycoord;
assign is_write_enable = is_coord_reach;


memory 
#(
.DATA_WIDTH(DATA_WIDTH_8),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
)
memory 
(
.clk_os(clk_os),
.reset_os(reset_os),
.pixel(pixel),
.wen(is_write_enable),
.frame_width(frame_dst_width),
.frame_height(frame_dst_height),
.o_integral_image(o_integral_image)
);

primary_stage_classifier
#(
.DATA_WIDTH(DATA_WIDTH_8),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_CLASSIFIERS_FIRST_STAGE(NUM_CLASSIFIERS_FIRST_STAGE),
.NUM_CLASSIFIERS_SECOND_STAGE(NUM_CLASSIFIERS_SECOND_STAGE),
.NUM_CLASSIFIERS_THIRD_STAGE(NUM_CLASSIFIERS_THIRD_STAGE)
)
primary_stage_classifier
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.rom_first_stage_classifier(rom_first_stage_classifier),
.rom_second_stage_classifier(rom_second_stage_classifier),
.rom_third_stage_classifier(rom_third_stage_classifier),
.integral_image(o_integral_image),
.o_iscandidate(o_is_candidate)
);

resize
#(
.DATA_WIDTH(DATA_WIDTH_8),
.DOUBLE_DATA_WIDTH(DOUBLE_DATA_WIDTH)
)
resize
(
.clk_os(clk_os),
.i_xcoord(xcoord),
.i_ycoord(ycoord),
.src_width(frame_src_width),
.src_height(frame_src_height),
.dst_width(frame_dst_width),
.dst_height(frame_dst_height),
.o_xcoord(scale_xcoord),
.o_ycoord(scale_ycoord),
.o_isreach(is_coord_reach)
);

endmodule