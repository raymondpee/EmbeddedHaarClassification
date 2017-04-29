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
i_pixel_recieve,
index_tree,
index_classifier,
index_database,
data,
end_single_classifier,
end_all_classifier,
end_tree,
end_database,
o_pixel_request,
o_resize_x,
o_resize_y,
o_candidate
);

/*--------------------IO port declaration---------------------------------*/
input clk_os;
input clk_fpga;
input reset_os;
input reset_fpga;
input i_pixel_recieve;
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
output o_pixel_request;
output [DATA_WIDTH_12-1:0] o_resize_x;
output [DATA_WIDTH_12-1:0] o_resize_y;
/*-----------------------------------------------------------------------*/

wire wr_en;
wire reach;
wire integral_image_ready;
wire inspect_done;
wire [DATA_WIDTH_12-1:0] resize_x;
wire [DATA_WIDTH_12-1:0] resize_y;
wire [DATA_WIDTH_12-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0]; 

reg pixel_request;
reg pixel_recieve;
reg[NUM_STAGES_ALL_PHASE-1:0] state;
reg[NUM_STAGES_ALL_PHASE-1:0] next_state;

localparam IDLE = 0;
localparam REQUEST_RECIEVE = 1;
localparam INSPECT = 2;

assign o_resize_x = resize_x;
assign o_resize_y = resize_y;
assign o_pixel_request = pixel_request;
assign wr_en = reach;


always@(posedge clk_fpga)
begin
	if(reset_fpga)
	begin
		state<= IDLE;
		pixel_request<=0;
		pixel_recieve<=0;
	end
	else
		state<= next_state;
end

always@(reach,pixel_recieve,integral_image_ready,inspect_done,i_pixel_recieve)
begin
	case(state)
		IDLE: 
		begin
			if(reach)
			begin
				next_state = REQUEST_RECIEVE;
				pixel_request = 1;
			end
			else
			begin
				next_state = IDLE;
				pixel_request = 0;
			end
		end
		REQUEST_RECIEVE: 
		begin
			if(i_pixel_recieve)
				pixel_recieve = 1;
			if(pixel_recieve && integral_image_ready)
			begin
				next_state = INSPECT;
				pixel_request = 0;
				pixel_recieve = 0;
			end
			else
			begin
				next_state = REQUEST_RECIEVE;
				pixel_request = 1;
			end
		end
		INSPECT: 
		begin
			if(inspect_done)
			begin
				next_state = IDLE;
				pixel_request = 0;
			end
			else
			begin
				next_state = INSPECT;
				pixel_request = 0;
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