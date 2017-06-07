module I2LBS
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16,
parameter INTEGRAL_WIDTH = 3,
parameter INTEGRAL_HEIGHT = 3,
parameter NUM_STAGE_THRESHOLD = 3,
parameter NUM_STAGES = 25,
parameter NUM_PARAM_PER_CLASSIFIER = 18,
parameter FRAME_ORIGINAL_CAMERA_WIDTH = 10,
parameter FRAME_ORIGINAL_CAMERA_HEIGHT = 10,
parameter FRAME_RESIZE_CAMERA_WIDTH = 10,
parameter FRAME_RESIZE_CAMERA_HEIGHT = 10
)
(
clk,
reset,
pixel,
ori_x,
ori_y,
enable_recieve_pixel,
index_tree,
index_leaf,
data,
end_leafs,
end_trees,
end_database,
o_pixel_request,
o_database_request,
o_inspect_done,
o_integral_image_ready,
o_candidate
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
localparam IDLE = 0;
localparam REQUEST_RECIEVE = 1;
localparam INSPECT = 2;



/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
input 						clk;
input 						reset;
input 						enable_recieve_pixel;
input [DATA_WIDTH_16-1:0] 	pixel;
input [DATA_WIDTH_12-1:0] 	ori_x;
input [DATA_WIDTH_12-1:0] 	ori_y;

//== End Flag
input [NUM_STAGES-1:0] 		end_database;
input [NUM_STAGES-1:0] 		end_trees;
input [NUM_STAGES-1:0] 		end_leafs;


//== Index Flag
input [DATA_WIDTH_12-1:0] 	index_tree	[NUM_STAGES-1:0];
input [DATA_WIDTH_12-1:0] 	index_leaf	[NUM_STAGES-1:0];
input [DATA_WIDTH_16-1:0] 	data		[NUM_STAGES-1:0]; 


output 						o_candidate;
output 						o_pixel_request;
output 						o_database_request;
output 						o_inspect_done;
output 						o_integral_image_ready;


/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/
wire reach;
wire w_candidate;
wire integral_image_ready;
wire inspect_done;
wire [DATA_WIDTH_12-1:0] resize_x;
wire [DATA_WIDTH_12-1:0] resize_y;
wire [DATA_WIDTH_16-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0]; 

reg enable;
reg candidate;
reg pixel_request;
reg database_request;
reg enable_memory;
reg[2:0] state;
reg[2:0] next_state;

 /*****************************************************************************
 *                            Combinational logic                             *
 *****************************************************************************/
assign o_candidate = candidate;
assign o_pixel_request = pixel_request;
assign o_database_request = database_request;
assign o_inspect_done = inspect_done;
assign o_integral_image_ready = integral_image_ready;


/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 
always@(posedge clk)
begin
	enable_memory<=0;
	if(reset)
	begin
		enable 				<= 0;
		candidate			<= 0;
		enable_memory		<= 0;
		pixel_request		<= 0;
		database_request	<= 0;
		state				<= IDLE;
		next_state 			<= IDLE;
	end
end


always@(posedge enable_recieve_pixel)
begin
	if(reach && state!=INSPECT)
	begin
		enable_memory<=1;
	end
	else
	begin
		enable_memory<=0;
	end
end

always@(posedge clk)
begin	
	case(state)
		IDLE: 
		begin
			pixel_request 		<= 1;
			database_request 	<= 0;		
			if(reach && integral_image_ready)
			begin
				state 			<= INSPECT;
			end
		end
		INSPECT: 
		begin
			pixel_request 		<= 0;
			database_request 	<= 1;
			if(inspect_done)
			begin
				state 			<= REQUEST_RECIEVE;
				candidate 		<= w_candidate;
				enable 			<= 0;
			end
			else
			begin
				state 			<= INSPECT;
				enable 			<= 1;
			end
		end
		REQUEST_RECIEVE: 
		begin
			pixel_request 		<= 1;
			database_request 	<= 0;
			if(enable_memory)
			begin
				candidate 		<= 0;
				state 			<= INSPECT;
			end
			else
			begin
				state 			<= REQUEST_RECIEVE;
			end
		end
	endcase

end


 /*****************************************************************************
 *                                   Modules                                  *
 *****************************************************************************/ 

I2LBS_memory 
#(
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT),
.FRAME_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH),
.FRAME_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT)
)
I2LBS_memory 
(
.clk(clk),
.reset(reset),
.pixel(pixel),
.wen(enable_memory),
.o_integral_image(integral_image),
.o_integral_image_ready(integral_image_ready)
);


I2LBS_classifier
#(
.NUM_STAGE(NUM_STAGES),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
)
I2LBS_classifier
(
.clk(clk),
.reset(reset),
.enable(enable),
.integral_image(integral_image),
.end_database(end_database),
.end_trees(end_trees),
.end_leafs(end_leafs),
.index_tree(index_tree),
.index_leaf(index_leaf),
.data(data),
.o_inspect_done(inspect_done),
.o_candidate(w_candidate)
);

resize
#(
.FRAME_ORIGINAL_CAMERA_WIDTH(FRAME_ORIGINAL_CAMERA_WIDTH),
.FRAME_ORIGINAL_CAMERA_HEIGHT(FRAME_ORIGINAL_CAMERA_HEIGHT),
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT)
)
resize
(
.clk(clk),
.reset(reset),
.ori_x(ori_x),
.ori_y(ori_y),
.o_resize_x(resize_x),
.o_resize_y(resize_y),
.o_reach(reach)
);

endmodule