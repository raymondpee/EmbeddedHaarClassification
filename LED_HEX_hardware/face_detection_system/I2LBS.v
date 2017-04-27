module I2LBS
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16,
parameter INTEGRAL_WIDTH = 3,
parameter INTEGRAL_HEIGHT = 3,
parameter NUM_STAGE_THRESHOLD = 1,
parameter NUM_STAGES_ALL_PHASE = 24,
parameter NUM_PARAM_PER_CLASSIFIER = 18,
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
index_tree,
index_classifier,
index_database,
data,
end_single_classifier,
end_all_classifier,
end_tree,
end_database,	
o_resize_x,
o_resize_y,
o_candidate,
o_integral_image
);

wire wr_en;
wire reach;
wire integral_image_ready;
wire [DATA_WIDTH_12-1:0] resize_x;
wire [DATA_WIDTH_12-1:0] resize_y;


/*--------------------IO port declaration---------------------------------*/
input clk_os;
input clk_fpga;
input reset_os;
input reset_fpga;
input [DATA_WIDTH_12-1:0] pixel;
input [DATA_WIDTH_12-1:0] ori_x;
input [DATA_WIDTH_12-1:0] ori_y;
input [NUM_STAGES_ALL_PHASE-1:0] end_database;
input [NUM_STAGES_ALL_PHASE-1:0] end_tree;
input [NUM_STAGES_ALL_PHASE-1:0] end_single_classifier;
input [NUM_STAGES_ALL_PHASE-1:0] end_all_classifier;
input [DATA_WIDTH_12-1:0] index_tree[NUM_STAGES_ALL_PHASE-1:0];
input [DATA_WIDTH_12-1:0] index_classifier[NUM_STAGES_ALL_PHASE-1:0];
input [DATA_WIDTH_12-1:0] index_database[NUM_STAGES_ALL_PHASE-1:0];
input [DATA_WIDTH_12-1:0] data[NUM_STAGES_ALL_PHASE-1:0]; 
output o_candidate;
output [DATA_WIDTH_12-1:0] o_resize_x;
output [DATA_WIDTH_12-1:0] o_resize_y;
output [DATA_WIDTH_12-1:0] o_integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
/*-----------------------------------------------------------------------*/

wire [DATA_WIDTH_12-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0]; 
assign o_resize_x = resize_x;
assign o_resize_y = resize_y;
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
.o_integral_image(integral_image),
.o_integral_image_ready(integral_image_ready)
);


I2LBS_classifier
#(
.DATA_WIDTH_8(DATA_WIDTH_8),
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16),
.NUM_STAGE(NUM_STAGES_ALL_PHASE),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
)
I2LBS_classifier
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.integral_image(integral_image),
.end_database(end_database),
.end_tree(end_tree),
.end_single_classifier(end_single_classifier),
.index_tree(index_tree),
.index_classifier(index_classifier),
.index_database(index_database),
.data(data),
.o_candidate(o_candidate)
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
.o_resize_x(resize_x),
.o_resize_y(resize_y),
.o_reach(reach)
);

endmodule