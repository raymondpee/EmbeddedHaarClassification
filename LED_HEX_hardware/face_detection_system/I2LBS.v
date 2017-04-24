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
parameter NUM_CLASSIFIERS_STAGE_3 = 10,
parameter FRAME_ORIGINAL_CAMERA_WIDTH = 10,
parameter FRAME_ORIGINAL_CAMERA_HEIGHT = 10,
parameter FRAME_RESIZE_CAMERA_WIDTH = 10,
parameter FRAME_RESIZE_CAMERA_HEIGHT = 10
)
(
clk_os,
clk_fpga,
reset_os,
reset_fpga,
pixel,
ori_x,
ori_y,
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
second_phase_end_database,	
o_scale_xcoord,
o_scale_ycoord,
o_first_phase_candidate,
o_second_phase_candidate,
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
input [DATA_WIDTH_12-1:0] pixel;
input [DATA_WIDTH_12-1:0] ori_x;
input [DATA_WIDTH_12-1:0] ori_y;
input [DATA_WIDTH_12-1:0] rom_stage1 [NUM_CLASSIFIERS_STAGE_1*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
input [DATA_WIDTH_12-1:0] rom_stage2 [NUM_CLASSIFIERS_STAGE_2*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
input [DATA_WIDTH_12-1:0] rom_stage3 [NUM_CLASSIFIERS_STAGE_3*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
input second_phase_end;
input [NUM_STAGES_SECOND_PHASE-1:0] second_phase_end_database;
input [NUM_STAGES_SECOND_PHASE-1:0] second_phase_end_tree;
input [NUM_STAGES_SECOND_PHASE-1:0] second_phase_end_single_classifier;
input [NUM_STAGES_SECOND_PHASE-1:0] second_phase_end_all_classifier;
input [DATA_WIDTH_12-1:0] second_phase_index_tree[NUM_STAGES_SECOND_PHASE-1:0];
input [DATA_WIDTH_12-1:0] second_phase_index_classifier[NUM_STAGES_SECOND_PHASE-1:0];
input [DATA_WIDTH_12-1:0] second_phase_index_database[NUM_STAGES_SECOND_PHASE-1:0];
input [DATA_WIDTH_12-1:0] second_phase_data[NUM_STAGES_SECOND_PHASE-1:0]; 
output o_first_phase_candidate;
output o_second_phase_candidate;
output [DATA_WIDTH_12-1:0] o_scale_xcoord;
output [DATA_WIDTH_12-1:0] o_scale_ycoord;
output [DATA_WIDTH_12-1:0] o_integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
/*-----------------------------------------------------------------------*/

wire [DATA_WIDTH_12-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0]; 
assign o_scale_xcoord = scale_xcoord;
assign o_scale_ycoord = scale_ycoord;
assign wr_en = reach;
assign o_integral_image = integral_image;

I2LBS_memory 
#(
.DATA_WIDTH_8(DATA_WIDTH_8),
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT),
.FRAME_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH),
.FRAME_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT)
)
I2LBS_memory 
(
.clk_os(clk_os),
.reset_os(reset_os),
.pixel(pixel),
.wen(wr_en),
.o_integral_image(o_integral_image),
.o_integral_image_ready(integral_image_ready)
);

I2LBS_first_phase_classifier
#(
.DATA_WIDTH_8(DATA_WIDTH_8),
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_CLASSIFIERS_STAGE_1(NUM_CLASSIFIERS_STAGE_1),
.NUM_CLASSIFIERS_STAGE_2(NUM_CLASSIFIERS_STAGE_2),
.NUM_CLASSIFIERS_STAGE_3(NUM_CLASSIFIERS_STAGE_3),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
)
I2LBS_first_phase_classifier
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.rom_stage1(rom_stage1),
.rom_stage2(rom_stage2),
.rom_stage3(rom_stage3),
.integral_image(integral_image),
.o_candidate(o_first_phase_candidate)
);

I2LBS_second_phase_classifier
#(
.DATA_WIDTH_8(DATA_WIDTH_8),
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16),
.NUM_STAGE(NUM_STAGES_SECOND_PHASE),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
)
I2LBS_second_phase_classifier
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.integral_image(integral_image),
.end_database(second_phase_end_database),
.end_tree(second_phase_end_tree),
.end_single_classifier(second_phase_end_single_classifier),
.index_tree(second_phase_index_tree),
.index_classifier(second_phase_index_classifier),
.index_database(second_phase_index_database),
.data(second_phase_data),
.o_candidate(o_second_phase_candidate)
);

resize
#(
.DATA_WIDTH_8(DATA_WIDTH_8),
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16),
.FRAME_ORIGINAL_CAMERA_WIDTH(FRAME_ORIGINAL_CAMERA_WIDTH),
.FRAME_ORIGINAL_CAMERA_HEIGHT(FRAME_ORIGINAL_CAMERA_HEIGHT),
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT)
)
resize
(
.clk_os(clk_os),
.ori_x(ori_x),
.ori_y(ori_y),
.o_resize_x(scale_xcoord),
.o_resize_y(scale_ycoord),
.o_reach(reach)
);

endmodule