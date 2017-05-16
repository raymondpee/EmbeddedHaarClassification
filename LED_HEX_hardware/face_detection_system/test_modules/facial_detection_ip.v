module facial_detection_ip
(
clk,
reset,
pixel,
o_pixel_request,
o_state_inspect,
o_state_end
);

/*--------------------------------------------------------------------*/
/*---------------------------USER DEFINE-----------------------------*/
/*--------------------------------------------------------------------*/
localparam NUM_STAGES = 25;
localparam INTEGRAL_LENGTH = 24;
localparam NUM_RESIZE = 5;
localparam FRAME_ORIGINAL_CAMERA_WIDTH = 800;
localparam FRAME_ORIGINAL_CAMERA_HEIGHT= 600;
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

localparam RECIEVE_PIXEL = 0;
localparam INSPECT = 1;
localparam END = 2;
localparam NUM_STATE = 3;

input clk;
input reset;
input [DATA_WIDTH_12 -1:0] pixel;
output o_pixel_request;
output o_state_inspect;
output o_state_end;

wire all_database_end;
wire reset_database;
wire global_pixel_request;
wire global_database_request;

reg state_recieve_pixel;
wire state_inspect;
wire state_end;

wire write_in_end;
wire read_out_end;

wire reset_i2lbs;
wire enable_pixel_recieve;
wire enable_pixel_request;
wire enable_candidate;
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
wire [DATA_WIDTH_12-1:0] data_out;

reg reset_new_frame;
reg write_in;
reg read_out;
reg start_recieve;
reg end_recieve;
reg end_coordinate;
reg [NUM_STATE-1:0] state;
reg [NUM_STATE-1:0] next_state;
reg [DATA_WIDTH_12 -1:0] ori_x;
reg [DATA_WIDTH_12 -1:0] ori_y;

assign state_inspect = state == INSPECT;
assign state_end = state == END;

assign global_database_request = database_request>0;

assign o_state_inspect = state == INSPECT;
assign o_state_end = state == END;
assign o_pixel_request = enable_pixel_request;

assign enable_pixel_request = pixel_request == 5'b11111;
assign enable_candidate = candidate>0; 

assign reset_i2lbs = reset_new_frame || reset;
assign reset_database = reset_new_frame|| enable_pixel_request || reset;



always@(posedge clk)
begin
	if(reset_new_frame)reset_new_frame<=0;
end

always@(posedge clk)
begin
	if(reset)
	begin
		write_in <=0;
		read_out<=0;
		state<=0;
		next_state<=0;
		ori_x <= 0;
		ori_y <= 0;	
		start_recieve<=0;
		end_recieve <=0;
		end_coordinate<=0;
		reset_new_frame<=1;
	end
	else
	begin
		state <=next_state;
	end
end

always@(*)
begin
	next_state = state;
	case(state)
		RECIEVE_PIXEL:
		begin
			start_recieve = 1;
			if(end_recieve)
			begin	
				start_recieve = 0;
				next_state = INSPECT;
			end
		end
		INSPECT:
		begin
			end_recieve = 0;
			if(enable_pixel_request)
			begin
				if(end_coordinate)
				begin
					start_recieve = 0;
					next_state = END;
				end
				else if(enable_candidate)
				begin
					write_in = 1;
					if(write_in_end)
					begin
						write_in = 0;
						start_recieve = 1;
						next_state = RECIEVE_PIXEL;
					end
				end
				else
				begin
					start_recieve =1;
					next_state = RECIEVE_PIXEL;
				end				
			end
		end
		END:
		begin
			read_out = 1;
			if(read_out_end)
			begin
				read_out = 0;
				reset_new_frame = 1;
				next_state = RECIEVE_PIXEL;
			end
		end
	endcase

end


/*------------------------ COORDINATE ITERATION -------------------------*/
always @(posedge clk)
begin
	if(start_recieve)
	begin			
		if(ori_x == FRAME_ORIGINAL_CAMERA_WIDTH -1)
		begin 
			ori_x <= 0;
			if(ori_y == FRAME_ORIGINAL_CAMERA_HEIGHT -1)
			begin			
				ori_y <= 0;   
				end_coordinate<=1;
			end
			else
			begin
				ori_y <= ori_y + 1;
			end
		end
		else
		begin
			ori_x <= ori_x + 1;
		end
		end_recieve<=1;
	end
	else
		end_recieve<=0;
end
/*-----------------------------------------------------------------------*/


result
#(
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.NUM_RESIZE(NUM_RESIZE)
)
result
(
.clk(clk),
.reset(reset_i2lbs),
.write_in(write_in),
.o_write_in_end(write_in_end),
.read_out(read_out),
.o_read_out_end(read_out_end),
.ori_x(ori_x),
.ori_y(ori_y),
.candidate(candidate),
.o_data_out(data_out)
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
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH_1),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT_1)
)
I2LBS_1
(
.clk(clk),
.reset(reset_i2lbs),
.pixel(pixel),
.pixel_recieve(end_recieve),
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
.clk(clk),
.reset(reset_i2lbs),
.pixel(pixel),
.pixel_recieve(end_recieve),
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
.clk(clk),
.reset(reset_i2lbs),
.pixel(pixel),
.pixel_recieve(end_recieve),
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
.clk(clk),
.reset(reset_i2lbs),
.pixel(pixel),
.pixel_recieve(end_recieve),
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
.clk(clk),
.reset(reset_i2lbs),
.pixel(pixel),
.pixel_recieve(end_recieve),
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
.clk(clk),
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