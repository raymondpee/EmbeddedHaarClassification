module face_detection
(
clk,
reset,

//Pixel//
recieve_pixel,
o_fpga_ready_recieve_pixel,
o_recieve_pixel_end,
pixel,

//Result//
send_result,
o_result_data,
o_result_end,

// End Of Frame Buffer
o_frame_end
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
localparam NUM_STAGES 						= 25;
localparam INTEGRAL_LENGTH 					= 24;
localparam NUM_RESIZE 						= 5;
localparam FRAME_ORIGINAL_CAMERA_WIDTH 		= 800;
localparam FRAME_ORIGINAL_CAMERA_HEIGHT		= 600;
localparam FRAME_RESIZE_CAMERA_WIDTH_1 		= 1*FRAME_ORIGINAL_CAMERA_WIDTH/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_HEIGHT_1 	= 1*FRAME_ORIGINAL_CAMERA_HEIGHT/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_WIDTH_2 		= 2*FRAME_ORIGINAL_CAMERA_WIDTH/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_HEIGHT_2 	= 2*FRAME_ORIGINAL_CAMERA_HEIGHT/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_WIDTH_3 		= 3*FRAME_ORIGINAL_CAMERA_WIDTH/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_HEIGHT_3 	= 3*FRAME_ORIGINAL_CAMERA_HEIGHT/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_WIDTH_4 		= 4*FRAME_ORIGINAL_CAMERA_WIDTH/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_HEIGHT_4 	= 4*FRAME_ORIGINAL_CAMERA_HEIGHT/NUM_RESIZE;
localparam FRAME_RESIZE_CAMERA_WIDTH_5 		= FRAME_ORIGINAL_CAMERA_WIDTH;
localparam FRAME_RESIZE_CAMERA_HEIGHT_5 	= FRAME_ORIGINAL_CAMERA_HEIGHT;

localparam DATA_WIDTH_8 			= 8;  
localparam DATA_WIDTH_12 			= 12; 
localparam DATA_WIDTH_16 			= 16; 
localparam NUM_PARAM_PER_CLASSIFIER = 19;
localparam INTEGRAL_WIDTH 			= INTEGRAL_LENGTH;
localparam INTEGRAL_HEIGHT 			= INTEGRAL_LENGTH;


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

input 							clk;
input 							reset;
output 							o_frame_end;

//===== Pixel IO
input 	[DATA_WIDTH_16 -1:0] 	pixel;
input 							recieve_pixel;
output 							o_recieve_pixel_end;
output 							o_fpga_ready_recieve_pixel;

//===== Result IO
input 							send_result;
output 	[DATA_WIDTH_12-1:0]  	o_result_data;
output 							o_result_end;





/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/
wire 							all_database_end;
wire 							reset_database;
wire 							global_pixel_request;
wire 							global_database_request;
wire 							write_result_end;
wire 							result_empty;
wire 							enable_recieve_pixel;
wire 							request_pixel;
wire 							got_candidate;
wire 	[NUM_RESIZE-1:0] 		candidate;
wire 	[NUM_RESIZE-1:0] 		inspect_done;
wire 	[NUM_RESIZE-1:0] 		integral_image_ready;
wire 	[NUM_RESIZE-1:0] 		pixel_request;
wire 	[NUM_RESIZE-1:0] 		database_request;
wire 	[NUM_STAGES-1:0] 		end_database;
wire 	[NUM_STAGES-1:0] 		end_tree;
wire 	[NUM_STAGES-1:0] 		end_single_classifier;
wire 	[NUM_STAGES-1:0] 		end_all_classifier;
wire 	[DATA_WIDTH_12-1:0] 	index_tree[NUM_STAGES-1:0];
wire 	[DATA_WIDTH_12-1:0] 	index_classifier[NUM_STAGES-1:0];
wire 	[DATA_WIDTH_12-1:0] 	index_database[NUM_STAGES-1:0];
wire 	[DATA_WIDTH_12-1:0] 	data[NUM_STAGES-1:0]; 
wire 	[DATA_WIDTH_12-1:0] 	data_out;


reg 							write_result;
reg 							fpga_ready_recieve_pixel;
reg 							recieve_coordinate;
reg 							end_coordinate;
reg 	[DATA_WIDTH_12 -1:0] 	ori_x;
reg 	[DATA_WIDTH_12 -1:0] 	ori_y;



 /*****************************************************************************
 *                            Combinational logic                             *
 *****************************************************************************/

assign o_recieve_pixel_end = enable_recieve_pixel;
assign o_fpga_ready_recieve_pixel = fpga_ready_recieve_pixel;
assign o_result_end = result_empty;
assign o_result_data = data_out;
assign o_frame_end = end_coordinate;

assign global_database_request = database_request>0;
assign request_pixel = pixel_request == 5'b11111;
assign got_candidate = candidate>0; 
assign enable_recieve_pixel = recieve_coordinate && recieve_pixel;
assign reset_database = request_pixel || reset;


/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 
//===== Reset 
always@(posedge clk)
begin
	if(reset)
	begin
		write_result <=0;
		ori_x <= 0;
		ori_y <= 0;	
		fpga_ready_recieve_pixel<=0;
		recieve_coordinate <=0;
		end_coordinate<=0;
	end
end


always@(posedge clk)
begin
	fpga_ready_recieve_pixel<=0;
	if(request_pixel)
	begin
		if(got_candidate)
		begin
			write_result <= 1;
			if(write_result_end)
			begin
				write_result <= 0;
				fpga_ready_recieve_pixel <= 1;
			end
		end
		else
		begin
			fpga_ready_recieve_pixel <= 1;
		end				
	end
end


//===== Coordinate Iterator
always @(posedge clk)
begin	
	recieve_coordinate <=0;	
	if(recieve_pixel)
	begin
		if(ori_x == FRAME_ORIGINAL_CAMERA_WIDTH -1)
		begin 
			ori_x <= 0;
			if(ori_y == FRAME_ORIGINAL_CAMERA_HEIGHT -1)
			begin			
				ori_y <= 0;   
				end_coordinate <= 1;
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
		recieve_coordinate <=1;
	end
end

 /*****************************************************************************
 *                                   Modules                                  *
 *****************************************************************************/ 

result
#(
.NUM_RESIZE(NUM_RESIZE)
)
result
(
.clk(clk),
.reset(reset),

//=== Write Result
.write_result(write_result),
.ori_x(ori_x),
.ori_y(ori_y),
.candidate(candidate),
.o_write_result_end(write_result_end),

//=== Read Result
.read_result(send_result),
.o_result(data_out),
.o_empty(result_empty)
);


database
#(
.ADDR_WIDTH(DATA_WIDTH_12),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGES(NUM_STAGES)
)
database
(
.clk(clk),
.reset(reset_database),
.enable(global_database_request),

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


I2LBS
#(
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT),
.NUM_STAGES(NUM_STAGES),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.FRAME_ORIGINAL_CAMERA_WIDTH(FRAME_ORIGINAL_CAMERA_WIDTH),
.FRAME_ORIGINAL_CAMERA_HEIGHT(FRAME_ORIGINAL_CAMERA_HEIGHT),
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH_1),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT_1)
)
I2LBS_1
(
.clk(clk),
.reset(reset),
.pixel(pixel),
.enable_recieve_pixel(enable_recieve_pixel),
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
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT),
.NUM_STAGES(NUM_STAGES),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.FRAME_ORIGINAL_CAMERA_WIDTH(FRAME_ORIGINAL_CAMERA_WIDTH),
.FRAME_ORIGINAL_CAMERA_HEIGHT(FRAME_ORIGINAL_CAMERA_HEIGHT),
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH_2),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT_2)
)
I2LBS_2
(
.clk(clk),
.reset(reset),
.pixel(pixel),
.enable_recieve_pixel(enable_recieve_pixel),
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
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT),
.NUM_STAGES(NUM_STAGES),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.FRAME_ORIGINAL_CAMERA_WIDTH(FRAME_ORIGINAL_CAMERA_WIDTH),
.FRAME_ORIGINAL_CAMERA_HEIGHT(FRAME_ORIGINAL_CAMERA_HEIGHT),
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH_3),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT_3)
)
I2LBS_3
(
.clk(clk),
.reset(reset),
.pixel(pixel),
.enable_recieve_pixel(enable_recieve_pixel),
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
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT),
.NUM_STAGES(NUM_STAGES),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.FRAME_ORIGINAL_CAMERA_WIDTH(FRAME_ORIGINAL_CAMERA_WIDTH),
.FRAME_ORIGINAL_CAMERA_HEIGHT(FRAME_ORIGINAL_CAMERA_HEIGHT),
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH_4),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT_4)
)
I2LBS_4
(
.clk(clk),
.reset(reset),
.pixel(pixel),
.enable_recieve_pixel(enable_recieve_pixel),
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
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT),
.NUM_STAGES(NUM_STAGES),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.FRAME_ORIGINAL_CAMERA_WIDTH(FRAME_ORIGINAL_CAMERA_WIDTH),
.FRAME_ORIGINAL_CAMERA_HEIGHT(FRAME_ORIGINAL_CAMERA_HEIGHT),
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH_5),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT_5)
)
I2LBS_5
(
.clk(clk),
.reset(reset),
.pixel(pixel),
.enable_recieve_pixel(enable_recieve_pixel),
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




endmodule