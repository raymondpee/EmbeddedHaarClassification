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
localparam NUM_STAGES = 25;
localparam INTEGRAL_LENGTH = 24;
localparam NUM_RESIZE = 5;
localparam FRAME_ORIGINAL_CAMERA_WIDTH = 100;
localparam FRAME_ORIGINAL_CAMERA_HEIGHT= 24;
localparam FRAME_RESIZE_CAMERA_WIDTH_1 = 1*FRAME_ORIGINAL_CAMERA_WIDTH/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_HEIGHT_1 = 1*FRAME_ORIGINAL_CAMERA_HEIGHT/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_WIDTH_2 = 2*FRAME_ORIGINAL_CAMERA_WIDTH/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_HEIGHT_2 = 2*FRAME_ORIGINAL_CAMERA_HEIGHT/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_WIDTH_3 = 3*FRAME_ORIGINAL_CAMERA_WIDTH/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_HEIGHT_3 = 3*FRAME_ORIGINAL_CAMERA_HEIGHT/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_WIDTH_4 = 4*FRAME_ORIGINAL_CAMERA_WIDTH/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_HEIGHT_4 = 4*FRAME_ORIGINAL_CAMERA_HEIGHT/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_WIDTH_5 = FRAME_ORIGINAL_CAMERA_WIDTH;
localparam FRAME_RESIZE_CAMERA_HEIGHT_5 = FRAME_ORIGINAL_CAMERA_HEIGHT;


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
localparam MAX_RESIZE = 2**(NUM_RESIZE-1);


input clk_os;
input clk_fpga;
input reset_os;
input reset_fpga;
input [DATA_WIDTH_12 -1:0] pixel;
output o_pixel_request;

wire all_database_end;
wire reset_database;
wire global_pixel_request;
wire global_database_request;

wire [NUM_RESIZE-1:0] candidate;
wire [NUM_RESIZE-1:0] inspect_done;
wire [NUM_RESIZE-1:0] integral_image_ready;
wire [NUM_RESIZE-1:0] pixel_request;
wire [NUM_RESIZE-1:0] database_request;
wire [NUM_STAGES-1:0] end_database;
wire [NUM_STAGES-1:0] end_tree;
wire [NUM_STAGES-1:0] end_single_classifier;
wire [NUM_STAGES-1:0] end_all_classifier;
wire [DATA_WIDTH_12-1:0] index_tree[NUM_STAGES-1:0];
wire [DATA_WIDTH_12-1:0] index_classifier[NUM_STAGES-1:0];
wire [DATA_WIDTH_12-1:0] index_database[NUM_STAGES-1:0];
wire [DATA_WIDTH_12-1:0] data[NUM_STAGES-1:0]; 

reg global_candidate;
reg save_index;
reg save_ori_x;
reg save_ori_y;

reg enable_save_candidate;
reg pixel_recieve;
reg [DATA_WIDTH_12 -1:0] index;
reg [DATA_WIDTH_12 -1:0] ori_x;
reg [DATA_WIDTH_12 -1:0] ori_y;

assign global_database_request = database_request>0;
assign global_pixel_request = (global_candidate == 0) && (pixel_request == 5'b11111);   
assign reset_database = global_pixel_request || reset_fpga;
assign o_pixel_request = global_pixel_request;


always@(posedge reset_fpga)
begin
	ori_x <= 0;
	ori_y <= 0;	
	pixel_recieve <=0;
	enable_save_candidate<=0;
	global_candidate<=0;
	index<=0;
end


always@(posedge clk_fpga)
begin
	global_candidate <= candidate> 0 && (pixel_request == 1'b11111);
	if(global_candidate)
	begin
		for(index = 0; index<NUM_STAGES; index = index +1)
		begin
			enable_save_candidate <= 1;
			save_ori_x <= ori_x;
			save_ori_y <= ori_y;
			save_index <= index;
		end
		index<=0;
		global_candidate <=0;
	end
end

/*------------------------ COORDINATE ITERATION -------------------------*/
always @(posedge clk_os)
begin
	if(global_pixel_request)
	begin			
		if(ori_x == FRAME_ORIGINAL_CAMERA_WIDTH -1)
		begin 
			ori_x <= 0;
			if(ori_y == FRAME_ORIGINAL_CAMERA_HEIGHT -1) ori_y <= 0;   
			else                          ori_y <= ori_y + 1;
		end
		else
			ori_x <= ori_x + 1;
		pixel_recieve <=1;
	end
	else
		pixel_recieve <=0;
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
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH_1),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT_1)
)
I2LBS_1
(
.clk_os(clk_os),
.clk_fpga(clk_fpga),
.reset_os(reset_os),
.reset_fpga(reset_fpga),
.pixel(pixel),
.pixel_recieve(pixel_recieve),
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
.o_candidate(candidate[0]),
.o_pixel_request(pixel_request[0]),
.o_database_request(database_request[0]),
.o_inspect_done(inspect_done[0]),
.o_integral_image_ready(integral_image_ready[0])
);

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
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH_2),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT_2)
)
I2LBS_2
(
.clk_os(clk_os),
.clk_fpga(clk_fpga),
.reset_os(reset_os),
.reset_fpga(reset_fpga),
.pixel(pixel),
.pixel_recieve(pixel_recieve),
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
.o_candidate(candidate[1]),
.o_pixel_request(pixel_request[1]),
.o_database_request(database_request[1]),
.o_inspect_done(inspect_done[1]),
.o_integral_image_ready(integral_image_ready[1])
);

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
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH_3),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT_3)
)
I2LBS_3
(
.clk_os(clk_os),
.clk_fpga(clk_fpga),
.reset_os(reset_os),
.reset_fpga(reset_fpga),
.pixel(pixel),
.pixel_recieve(pixel_recieve),
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
.o_candidate(candidate[2]),
.o_pixel_request(pixel_request[2]),
.o_database_request(database_request[2]),
.o_inspect_done(inspect_done[2]),
.o_integral_image_ready(integral_image_ready[2])
);

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
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH_4),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT_4)
)
I2LBS_4
(
.clk_os(clk_os),
.clk_fpga(clk_fpga),
.reset_os(reset_os),
.reset_fpga(reset_fpga),
.pixel(pixel),
.pixel_recieve(pixel_recieve),
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
.o_candidate(candidate[3]),
.o_pixel_request(pixel_request[3]),
.o_database_request(database_request[3]),
.o_inspect_done(inspect_done[3]),
.o_integral_image_ready(integral_image_ready[3])
);

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
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH_5),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT_5)
)
I2LBS_5
(
.clk_os(clk_os),
.clk_fpga(clk_fpga),
.reset_os(reset_os),
.reset_fpga(reset_fpga),
.pixel(pixel),
.pixel_recieve(pixel_recieve),
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
.o_candidate(candidate[4]),
.o_pixel_request(pixel_request[4]),
.o_database_request(database_request[4]),
.o_inspect_done(inspect_done[4]),
.o_integral_image_ready(integral_image_ready[4])
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
.en(global_database_request),
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