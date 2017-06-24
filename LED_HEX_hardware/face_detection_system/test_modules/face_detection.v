module face_detection
(
clk,
reset,
o_frame_end,

//Pixel//
recieve_pixel,
o_fpga_ready_recieve_pixel,
o_recieve_pixel_end,
pixel,

//Result//
trig_send_result,
result_sent,
o_result_data,
o_result_end,
o_fpga_ready_send_result
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
localparam NUM_STAGES 						= 25;
localparam INTEGRAL_LENGTH 					= 24;
//localparam NUM_RESIZE 						= 5;  //[RESIZE]
localparam NUM_RESIZE 						= 1;
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
localparam NUM_STAGE_THRESHOLD		= 3;
localparam INTEGRAL_WIDTH 			= INTEGRAL_LENGTH;
localparam INTEGRAL_HEIGHT 			= INTEGRAL_LENGTH;



localparam NUM_CLASSIFIERS_STAGE_1 = 9;
localparam NUM_CLASSIFIERS_STAGE_2 = 16;
localparam NUM_CLASSIFIERS_STAGE_3 = 27;
localparam NUM_CLASSIFIERS_STAGE_4 = 32;
localparam NUM_CLASSIFIERS_STAGE_5 = 52;
localparam NUM_CLASSIFIERS_STAGE_6 = 53;
localparam NUM_CLASSIFIERS_STAGE_7 = 62;
localparam NUM_CLASSIFIERS_STAGE_8 = 72;
localparam NUM_CLASSIFIERS_STAGE_9 = 83;
localparam NUM_CLASSIFIERS_STAGE_10 = 91;
localparam NUM_CLASSIFIERS_STAGE_11 = 99;
localparam NUM_CLASSIFIERS_STAGE_12 = 115;
localparam NUM_CLASSIFIERS_STAGE_13 = 127;
localparam NUM_CLASSIFIERS_STAGE_14 = 135;
localparam NUM_CLASSIFIERS_STAGE_15 = 136;
localparam NUM_CLASSIFIERS_STAGE_16 = 137;
localparam NUM_CLASSIFIERS_STAGE_17 = 159;
localparam NUM_CLASSIFIERS_STAGE_18 = 155;
localparam NUM_CLASSIFIERS_STAGE_19 = 169;
localparam NUM_CLASSIFIERS_STAGE_20 = 196;
localparam NUM_CLASSIFIERS_STAGE_21 = 197;
localparam NUM_CLASSIFIERS_STAGE_22 = 181;
localparam NUM_CLASSIFIERS_STAGE_23 = 199;
localparam NUM_CLASSIFIERS_STAGE_24 = 211;
localparam NUM_CLASSIFIERS_STAGE_25 = 200;


parameter FILE_STAGE1 = "ram0.mif";
parameter FILE_STAGE2 = "ram1.mif";
parameter FILE_STAGE3 = "ram2.mif";
parameter FILE_STAGE4 = "ram3.mif";
parameter FILE_STAGE5 = "ram4.mif";
parameter FILE_STAGE6 = "ram5.mif";
parameter FILE_STAGE7 = "ram6.mif";
parameter FILE_STAGE8 = "ram7.mif";
parameter FILE_STAGE9 = "ram8.mif";
parameter FILE_STAGE10 = "ram9.mif";
parameter FILE_STAGE11 = "ram10.mif";
parameter FILE_STAGE12 = "ram11.mif";
parameter FILE_STAGE13 = "ram12.mif";
parameter FILE_STAGE14 = "ram13.mif";
parameter FILE_STAGE15 = "ram14.mif";
parameter FILE_STAGE16 = "ram15.mif";
parameter FILE_STAGE17 = "ram16.mif";
parameter FILE_STAGE18 = "ram17.mif";
parameter FILE_STAGE19 = "ram18.mif";
parameter FILE_STAGE20 = "ram19.mif";
parameter FILE_STAGE21 = "ram20.mif";
parameter FILE_STAGE22 = "ram21.mif";
parameter FILE_STAGE23 = "ram22.mif";
parameter FILE_STAGE24 = "ram23.mif";
parameter FILE_STAGE25 = "ram24.mif";

localparam SIZE_STAGE_1 = NUM_CLASSIFIERS_STAGE_1*NUM_PARAM_PER_CLASSIFIER + NUM_STAGE_THRESHOLD;
localparam SIZE_STAGE_2 = NUM_CLASSIFIERS_STAGE_2*NUM_PARAM_PER_CLASSIFIER + NUM_STAGE_THRESHOLD;
localparam SIZE_STAGE_3 = NUM_CLASSIFIERS_STAGE_3*NUM_PARAM_PER_CLASSIFIER + NUM_STAGE_THRESHOLD;
localparam SIZE_DATABASE_EMBEDDED = SIZE_STAGE_1 + SIZE_STAGE_2 + SIZE_STAGE_3;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

input 							clk;
input 							reset;


//===== Pixel IO
input 	[DATA_WIDTH_16 -1:0] 	pixel;
input 							recieve_pixel;
output 							o_recieve_pixel_end;
output 							o_fpga_ready_recieve_pixel;

//===== Result IO
input 							result_sent;
input 							trig_send_result;
output 	[DATA_WIDTH_12-1:0]  	o_result_data;
output 							o_result_end;
output 							o_fpga_ready_send_result;
output							o_frame_end;




/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/
//== Integral Image
wire 	[NUM_RESIZE-1:0] 		integral_image_ready;

//== Coordinate
reg 							recieve_coordinate;
reg 							end_coordinate;
reg 	[DATA_WIDTH_12 -1:0] 	ori_x;
reg 	[DATA_WIDTH_12 -1:0] 	ori_y;

//== Pixel
wire 							fpga_request_pixel;
wire 							enable_recieve_pixel;
wire 	[NUM_RESIZE-1:0] 		pixel_request;

reg 							fpga_ready_recieve_pixel;

//== Result
wire							fpga_ready_send_result;
wire 							result_empty;
wire 							write_result_end;
wire 	[DATA_WIDTH_12-1:0] 	data_out;

reg 							write_result;

//== Database
wire							pass_first_stage;
wire							database_load_done;
wire 							fpga_request_database;
wire 							reset_database;
wire 	[NUM_RESIZE-1:0] 		database_request;
wire 	[NUM_RESIZE-1:0]		pass_first_stages;
wire 	[NUM_STAGES-1:0] 		end_leafs;
wire 	[NUM_STAGES-1:0] 		end_trees;
wire 	[NUM_STAGES-1:0] 		end_database;
wire 	[DATA_WIDTH_16-1:0] 	data						[NUM_STAGES-1:0]; 
wire 	[DATA_WIDTH_12-1:0] 	index_tree					[NUM_STAGES-1:0];
wire 	[DATA_WIDTH_12-1:0] 	index_leaf					[NUM_STAGES-1:0];
wire 	[DATA_WIDTH_16-1:0] 	database_stage_1 			[NUM_CLASSIFIERS_STAGE_1-1:0];
wire 	[DATA_WIDTH_16-1:0] 	database_stage_2 			[NUM_CLASSIFIERS_STAGE_2-1:0];
wire 	[DATA_WIDTH_16-1:0] 	database_stage_3 			[NUM_CLASSIFIERS_STAGE_3-1:0];

//== Candidate
wire 							fpga_got_candidate;
wire 	[NUM_RESIZE-1:0] 		candidate;
wire 	[NUM_RESIZE-1:0] 		inspect_done;


 /*****************************************************************************
 *                            Combinational logic                             *
 *****************************************************************************/

assign o_recieve_pixel_end = enable_recieve_pixel;
assign o_fpga_ready_recieve_pixel = fpga_ready_recieve_pixel && database_load_done;
assign o_result_end = result_empty;
assign o_result_data = data_out;
assign o_fpga_ready_send_result = fpga_ready_send_result&& !result_empty;
assign o_frame_end = end_coordinate;

assign fpga_request_database = database_request>0;
//assign fpga_request_pixel = pixel_request == 5'b11111; [RESIZE]
assign fpga_request_pixel = pixel_request >0;
assign fpga_got_candidate = candidate>0; 
assign enable_recieve_pixel = recieve_coordinate;
assign reset_database = fpga_request_pixel || reset;
assign pass_first_stage = pass_first_stages>0;

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
	if(fpga_request_pixel)
	begin
		if(fpga_got_candidate)
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
	else if(recieve_pixel)
	begin
		fpga_ready_recieve_pixel <=0;
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
.trig_send_result(trig_send_result),
.o_result(data_out),
.o_ready_send_result(fpga_ready_send_result),
.result_sent(result_sent),
.o_empty(result_empty)
);


database
#(
.ADDR_WIDTH(DATA_WIDTH_12),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGES(NUM_STAGES),

.NUM_CLASSIFIERS_STAGE_1(NUM_CLASSIFIERS_STAGE_1),
.NUM_CLASSIFIERS_STAGE_2(NUM_CLASSIFIERS_STAGE_2),
.NUM_CLASSIFIERS_STAGE_3(NUM_CLASSIFIERS_STAGE_3),
.NUM_CLASSIFIERS_STAGE_4(NUM_CLASSIFIERS_STAGE_4),
.NUM_CLASSIFIERS_STAGE_5(NUM_CLASSIFIERS_STAGE_5),
.NUM_CLASSIFIERS_STAGE_6(NUM_CLASSIFIERS_STAGE_6),
.NUM_CLASSIFIERS_STAGE_7(NUM_CLASSIFIERS_STAGE_7),
.NUM_CLASSIFIERS_STAGE_8(NUM_CLASSIFIERS_STAGE_8),
.NUM_CLASSIFIERS_STAGE_9(NUM_CLASSIFIERS_STAGE_9),
.NUM_CLASSIFIERS_STAGE_10(NUM_CLASSIFIERS_STAGE_10),
.NUM_CLASSIFIERS_STAGE_11(NUM_CLASSIFIERS_STAGE_11),
.NUM_CLASSIFIERS_STAGE_12(NUM_CLASSIFIERS_STAGE_12),
.NUM_CLASSIFIERS_STAGE_13(NUM_CLASSIFIERS_STAGE_13),
.NUM_CLASSIFIERS_STAGE_14(NUM_CLASSIFIERS_STAGE_14),
.NUM_CLASSIFIERS_STAGE_15(NUM_CLASSIFIERS_STAGE_15),
.NUM_CLASSIFIERS_STAGE_16(NUM_CLASSIFIERS_STAGE_16),
.NUM_CLASSIFIERS_STAGE_17(NUM_CLASSIFIERS_STAGE_17),
.NUM_CLASSIFIERS_STAGE_18(NUM_CLASSIFIERS_STAGE_18),
.NUM_CLASSIFIERS_STAGE_19(NUM_CLASSIFIERS_STAGE_19),
.NUM_CLASSIFIERS_STAGE_20(NUM_CLASSIFIERS_STAGE_20),
.NUM_CLASSIFIERS_STAGE_21(NUM_CLASSIFIERS_STAGE_21),
.NUM_CLASSIFIERS_STAGE_22(NUM_CLASSIFIERS_STAGE_22),
.NUM_CLASSIFIERS_STAGE_23(NUM_CLASSIFIERS_STAGE_23),
.NUM_CLASSIFIERS_STAGE_24(NUM_CLASSIFIERS_STAGE_24),
.NUM_CLASSIFIERS_STAGE_25(NUM_CLASSIFIERS_STAGE_25),

.FILE_STAGE1(FILE_STAGE1),
.FILE_STAGE2(FILE_STAGE2),
.FILE_STAGE3(FILE_STAGE3),
.FILE_STAGE4(FILE_STAGE4),
.FILE_STAGE5(FILE_STAGE5),
.FILE_STAGE6(FILE_STAGE6),
.FILE_STAGE7(FILE_STAGE7),
.FILE_STAGE8(FILE_STAGE8),
.FILE_STAGE9(FILE_STAGE9),
.FILE_STAGE10(FILE_STAGE10),
.FILE_STAGE11(FILE_STAGE11),
.FILE_STAGE12(FILE_STAGE12),
.FILE_STAGE13(FILE_STAGE13),
.FILE_STAGE14(FILE_STAGE14),
.FILE_STAGE15(FILE_STAGE15),
.FILE_STAGE16(FILE_STAGE16),
.FILE_STAGE17(FILE_STAGE17),
.FILE_STAGE18(FILE_STAGE18),
.FILE_STAGE19(FILE_STAGE19),
.FILE_STAGE20(FILE_STAGE20),
.FILE_STAGE21(FILE_STAGE21),
.FILE_STAGE22(FILE_STAGE22),
.FILE_STAGE23(FILE_STAGE23),
.FILE_STAGE24(FILE_STAGE24),
.FILE_STAGE25(FILE_STAGE25)
)
database
(
.clk(clk),
.reset_system 	(reset),
.reset_database	(reset_database),
.enable(fpga_request_database),


//== First Stage Database
.pass_first_stage(pass_first_stage),
.o_load_done(database_load_done),
.o_database_stage_1(database_stage_1),
.o_database_stage_2(database_stage_2),
.o_database_stage_3(database_stage_3),

//== Index
.o_index_leaf(index_leaf),
.o_index_tree(index_tree),

//== Data
.o_data(data),	

//== End Flag
.o_end_leafs(end_leafs),
.o_end_trees(end_trees),
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
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH_5),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT_5),
.NUM_CLASSIFIERS_STAGE_1(NUM_CLASSIFIERS_STAGE_1),
.NUM_CLASSIFIERS_STAGE_2(NUM_CLASSIFIERS_STAGE_2),
.NUM_CLASSIFIERS_STAGE_3(NUM_CLASSIFIERS_STAGE_3),
.SIZE_DATABASE_EMBEDDED(SIZE_DATABASE_EMBEDDED)
)
I2LBS_5
(
.clk(clk),
.reset(reset),
.pixel(pixel),
.enable_recieve_pixel(enable_recieve_pixel),
.database_stage_1(database_stage_1),
.database_stage_2(database_stage_2),
.database_stage_3(database_stage_3),
.ori_x(ori_x),
.ori_y(ori_y),
.index_tree(index_tree),
.index_leaf(index_leaf),
.data(data),
.end_leafs(end_leafs),
.end_trees(end_trees),
.end_database(end_database),
.o_pass_first_stage(pass_first_stages[0]),
.o_candidate(candidate[0]),
.o_pixel_request(pixel_request[0]),
.o_database_request(database_request[0]),
.o_inspect_done(inspect_done[0]),
.o_integral_image_ready(integral_image_ready[0])
);


//[RESIZE]
/*
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
.index_leaf(index_leaf),
.data(data),
.end_leafs(end_leafs),
.end_trees(end_trees),
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
.index_leaf(index_leaf),
.data(data),
.end_leafs(end_leafs),
.end_trees(end_trees),
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
.index_leaf(index_leaf),
.data(data),
.end_leafs(end_leafs),
.end_trees(end_trees),
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
.index_leaf(index_leaf),
.data(data),
.end_leafs(end_leafs),
.end_trees(end_trees),
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
.index_leaf(index_leaf),
.data(data),
.end_leafs(end_leafs),
.end_trees(end_trees),
.end_database(end_database),
.o_candidate(candidate[4]),
.o_pixel_request(pixel_request[4]),
.o_database_request(database_request[4]),
.o_inspect_done(inspect_done[4]),
.o_integral_image_ready(integral_image_ready[4])
);
*/



endmodule