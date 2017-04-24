module I2LBS
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16,
parameter INTEGRAL_WIDTH = 3,
parameter INTEGRAL_HEIGHT = 3,
parameter NUM_STAGE_THRESHOLD = 1,
parameter NUM_STAGES_SECOND_PHASE = 8,
parameter NUM_PARAM_PER_CLASSIFIER = 18,
parameter NUM_CLASSIFIERS_STAGE_1 = 10,
parameter NUM_CLASSIFIERS_STAGE_2 = 10,
parameter NUM_CLASSIFIERS_STAGE_3 = 10
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
	rom_stage1,
	rom_stage2,
	rom_stage3,
	second_phase_index_tree,
	second_phase_index_classifier,
	second_phase_index_database,
	second_phase_data,
	second_phase_end,
	second_phase_end_single_classifier,
	second_phase_end_all_classifier,
	second_phase_end_tree,
	second_phase_end_database	
	o_scale_xcoord,
	o_scale_ycoord,
	o_first_phase_candidate,
	o_integral_image
);

wire wr_en;
wire reach;
wire integral_image_ready;
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
input [DATA_WIDTH_8-1:0] rom_first_stage_classifier [NUM_CLASSIFIERS_STAGE_1*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
input [DATA_WIDTH_8-1:0] rom_second_stage_classifier [NUM_CLASSIFIERS_STAGE_2*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
input [DATA_WIDTH_8-1:0] rom_third_stage_classifier [NUM_CLASSIFIERS_STAGE_3*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
input [NUM_STAGES_SECOND_PHASE-1:0] second_phase_end_database;
input [NUM_STAGES_SECOND_PHASE-1:0] second_phase_end_tree;
input [NUM_STAGES_SECOND_PHASE-1:0] second_phase_end_single_classifier;
input [NUM_STAGES_SECOND_PHASE-1:0] second_phase_end_all_classifier;
input [DATA_WIDTH_12-1:0] second_phase_index_tree[NUM_STAGES_SECOND_PHASE-1:0];
input [DATA_WIDTH_12-1:0] second_phase_index_classifier[NUM_STAGES_SECOND_PHASE-1:0];
input [DATA_WIDTH_12-1:0] second_phase_index_database[NUM_STAGES_SECOND_PHASE-1:0];
input [DATA_WIDTH_12-1:0] second_phase_data[NUM_STAGES_SECOND_PHASE-1:0]; 


output o_candidate;
output [DATA_WIDTH_12-1:0] o_scale_xcoord;
output [DATA_WIDTH_12-1:0] o_scale_ycoord;
output [DATA_WIDTH_8-1:0] o_integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
/*-----------------------------------------------------------------------*/

assign o_scale_xcoord = scale_xcoord;
assign o_scale_ycoord = scale_ycoord;
assign wr_en = reach;


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
.wen(wr_en),
.frame_width(frame_dst_width),
.frame_height(frame_dst_height),
.integral_image(o_integral_image),
.o_integral_image_ready(integral_image_ready)
);

I2LBS_first_phase_classifier
#(
.DATA_WIDTH(DATA_WIDTH_8),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_CLASSIFIERS_STAGE_1(NUM_CLASSIFIERS_STAGE_1),
.NUM_CLASSIFIERS_STAGE_2(NUM_CLASSIFIERS_STAGE_2),
.NUM_CLASSIFIERS_STAGE_3(NUM_CLASSIFIERS_STAGE_3)
)
I2LBS_first_phase_classifier
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.rom_stage1(rom_stage1),
.rom_stage2(rom_stage2),
.rom_stage3(rom_stage3),
.integral_image(o_integral_image),
.o_first_phase_candidate(o_candidate)
);

I2LBS_second_phase_classifier
#(
.DATA_WIDTH_8(DATA_WIDTH_8),
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16),
.NUM_STAGES(NUM_STAGES_SECOND_PHASE)
)
I2LBS_second_phase_classifier
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.end_database(second_phase_end_database),
.end_tree(second_phase_end_tree),
.end_single_classifier(second_phase_end_single_classifier),
.index_tree(second_phase_index_tree),
.index_classifier(second_phase_index_classifier),
.index_database(second_phase_index_database),
.data(second_phase_data)
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
.o_isreach(reach)
);

endmodule