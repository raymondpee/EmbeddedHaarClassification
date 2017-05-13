module I2LBS
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16,
parameter INTEGRAL_WIDTH = 3,
parameter INTEGRAL_HEIGHT = 3,
parameter NUM_STAGE_THRESHOLD = 1,
parameter NUM_STAGES = 24,
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
pixel_recieve,
index_tree,
index_classifier,
index_database,
data,
end_single_classifier,
end_all_classifier,
end_tree,
end_database,
o_pixel_request,
o_database_request,
o_resize_x,
o_resize_y,
o_inspect_done,
o_integral_image_ready,
o_candidate
);

/*--------------------IO port declaration---------------------------------*/
input clk_os;
input clk_fpga;
input reset_os;
input reset_fpga;
input pixel_recieve;
input [DATA_WIDTH_12-1:0] pixel;
input [DATA_WIDTH_12-1:0] ori_x;
input [DATA_WIDTH_12-1:0] ori_y;
input [NUM_STAGES-1:0] end_database;
input [NUM_STAGES-1:0] end_tree;
input [NUM_STAGES-1:0] end_single_classifier;
input [NUM_STAGES-1:0] end_all_classifier;
input [DATA_WIDTH_12-1:0] index_tree[NUM_STAGES-1:0];
input [DATA_WIDTH_12-1:0] index_classifier[NUM_STAGES-1:0];
input [DATA_WIDTH_12-1:0] index_database[NUM_STAGES-1:0];
input [DATA_WIDTH_12-1:0] data[NUM_STAGES-1:0]; 
output o_candidate;
output o_pixel_request;
output o_database_request;
output o_inspect_done;
output o_integral_image_ready;
output [DATA_WIDTH_12-1:0] o_resize_x;
output [DATA_WIDTH_12-1:0] o_resize_y;
/*-----------------------------------------------------------------------*/


wire reach;
wire integral_image_ready;
wire inspect_done;
wire [DATA_WIDTH_12-1:0] resize_x;
wire [DATA_WIDTH_12-1:0] resize_y;
wire [DATA_WIDTH_12-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0]; 


reg enable;
reg pixel_request;
reg database_request;
reg enable_memory;
reg[NUM_STAGES-1:0] state;
reg[NUM_STAGES-1:0] next_state;

localparam IDLE = 0;
localparam REQUEST_RECIEVE = 1;
localparam INSPECT = 2;

assign o_resize_x = resize_x;
assign o_resize_y = resize_y;
assign o_pixel_request = pixel_request;
assign o_database_request = database_request;
assign o_inspect_done = inspect_done;
assign o_integral_image_ready = integral_image_ready;

always@(posedge clk_fpga)
begin
	if(reset_fpga)
	begin
		enable <=0;
		enable_memory<=0;
		pixel_request<=0;
		database_request<=0;
		state<= IDLE;
		next_state<=IDLE;
	end
	else
		state<= next_state;
end

always@(*)
begin
	next_state = state;
	case(state)
		IDLE: 
		begin
			pixel_request = 1;
			database_request = 0;
			enable_memory = pixel_recieve && reach;
			if(reach && integral_image_ready)
			begin
				next_state = INSPECT;
			end
			else
			begin
				next_state = IDLE;
			end
		end
		INSPECT: 
		begin
			pixel_request = 0;
			enable_memory = 0;
			database_request = 1;
			if(inspect_done)
			begin
				next_state = REQUEST_RECIEVE;
				enable = 0;
			end
			else
			begin
				next_state = INSPECT;
				enable =1;
			end
		end
		REQUEST_RECIEVE: 
		begin
			pixel_request = 1;
			enable_memory = pixel_recieve && reach;
			database_request = 0;
			if(enable_memory)
			begin
				next_state = INSPECT;
			end
			else
			begin
				next_state = REQUEST_RECIEVE;
			end
		end
		default:
		begin
			next_state = IDLE;
		end
	endcase

end


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
.clk(clk_os),
.reset(reset_os),
.pixel(pixel),
.wen(enable_memory),
.o_integral_image(integral_image),
.o_integral_image_ready(integral_image_ready)
);


I2LBS_classifier
#(
.DATA_WIDTH_8(DATA_WIDTH_8),
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16),
.NUM_STAGE(NUM_STAGES),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
)
I2LBS_classifier
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(enable),
.integral_image(integral_image),
.end_database(end_database),
.end_tree(end_tree),
.end_single_classifier(end_single_classifier),
.end_all_classifier(end_all_classifier),
.index_tree(index_tree),
.index_classifier(index_classifier),
.index_database(index_database),
.data(data),
.o_inspect_done(inspect_done),
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