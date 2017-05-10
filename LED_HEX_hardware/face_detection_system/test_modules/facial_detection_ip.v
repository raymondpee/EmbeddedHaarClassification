module facial_detection_ip
(
clk_os,
clk_fpga,
reset_os,
reset_fpga,
pixel,
o_pixel_request
);

/*--------------------------------------------------------------------*/
/*---------------------------USER DEFINE-----------------------------*/
/*--------------------------------------------------------------------*/
localparam FRAME_ORIGINAL_CAMERA_WIDTH = 100;
localparam FRAME_ORIGINAL_CAMERA_HEIGHT= 24;
localparam FRAME_RESIZE_CAMERA_WIDTH = FRAME_ORIGINAL_CAMERA_WIDTH/2;
localparam FRAME_RESIZE_CAMERA_HEIGHT = FRAME_ORIGINAL_CAMERA_HEIGHT/2;
localparam NUM_STAGES = 5;
localparam INTEGRAL_LENGTH = 24;

/*--------------------------------------------------------------------*/


/*---------------------------CONSTANTS--------------------------------*/

localparam DATA_WIDTH_8 = 8;   // Max value 255
localparam DATA_WIDTH_12 = 12; // Max value 4095
localparam DATA_WIDTH_16 = 16; // Max value 177777
localparam ADDR_WIDTH = DATA_WIDTH_12;
localparam NUM_STAGE_THRESHOLD = 3;
localparam NUM_PARAM_PER_CLASSIFIER = 19;
localparam INTEGRAL_WIDTH = INTEGRAL_LENGTH;
localparam INTEGRAL_HEIGHT = INTEGRAL_LENGTH;


input clk_os;
input clk_fpga;
input reset_os;
input reset_fpga;
input [DATA_WIDTH_12 -1:0] pixel;
output o_pixel_request;

wire all_database_end;
wire candidate;

wire reset_database;
wire inspect_done;
wire pixel_request;
wire database_request;
wire [DATA_WIDTH_12 -1:0] resize_x;
wire [DATA_WIDTH_12 -1:0] resize_y;
wire [NUM_STAGES-1:0] end_database;
wire [NUM_STAGES-1:0] end_tree;
wire [NUM_STAGES-1:0] end_single_classifier;
wire [NUM_STAGES-1:0] end_all_classifier;
wire [DATA_WIDTH_12-1:0] index_tree[NUM_STAGES-1:0];
wire [DATA_WIDTH_12-1:0] index_classifier[NUM_STAGES-1:0];
wire [DATA_WIDTH_12-1:0] index_database[NUM_STAGES-1:0];
wire [DATA_WIDTH_12-1:0] data[NUM_STAGES-1:0]; 

reg r_pixel_recieve;
reg [DATA_WIDTH_12 -1:0]ori_x;
reg [DATA_WIDTH_12 -1:0]ori_y;

assign o_pixel_request = pixel_request;
assign reset_database = inspect_done || reset_fpga;

always@(posedge reset_fpga)
begin
	ori_x <= 0;
	ori_y <= 0;	
	r_pixel_recieve <=0;
end

/*------------------------ COORDINATE ITERATION -------------------------*/
always @(posedge clk_os)
begin
	if(pixel_request)
	begin
		if(ori_x == FRAME_ORIGINAL_CAMERA_WIDTH -1)
		begin 
			ori_x <= 0;
			if(ori_y == FRAME_ORIGINAL_CAMERA_HEIGHT -1) ori_y <= 0;   
			else                          ori_y <= ori_y + 1;
		end
		else
			ori_x <= ori_x + 1;
		r_pixel_recieve <=1;
	end
	if(r_pixel_recieve)
		r_pixel_recieve <=0;
end
/*-----------------------------------------------------------------------*/


I2LBS
#(
.DATA_WIDTH_8(DATA_WIDTH_8), 
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT),
.NUM_STAGES(NUM_STAGES),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.FRAME_ORIGINAL_CAMERA_WIDTH(FRAME_ORIGINAL_CAMERA_WIDTH),
.FRAME_ORIGINAL_CAMERA_HEIGHT(FRAME_ORIGINAL_CAMERA_HEIGHT),
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT)
)
I2LBS
(
.clk_os(clk_os),
.clk_fpga(clk_fpga),
.reset_os(reset_os),
.reset_fpga(reset_fpga),
.pixel(pixel),
.pixel_recieve(r_pixel_recieve),
.ori_x(ori_x),
.ori_y(ori_y),
.index_tree(index_tree),
.index_classifier(index_classifier),
.index_database(index_database),
.data(data),
.end_single_classifier(end_single_classifier),
.end_all_classifier(end_all_classifier),
.end_tree(end_tree),
.end_database(end_database),	
.o_resize_x(resize_x),
.o_resize_y(resize_y),
.o_candidate(candidate),
.o_pixel_request(pixel_request),
.o_database_request(database_request),
.o_inspect_done(inspect_done)
);


haar_database
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGES(NUM_STAGES)
)
haar_database
(
.clk(clk_fpga),
.reset(reset_database),
.en(database_request),
.o_index_tree(index_tree),
.o_index_classifier(index_classifier),
.o_index_database(index_database),
.o_data(data),	
.o_end(all_database_end),
.o_end_all_classifier(end_all_classifier),
.o_end_single_classifier(end_single_classifier),
.o_end_tree(end_tree),
.o_end_database(end_database)
);

endmodule