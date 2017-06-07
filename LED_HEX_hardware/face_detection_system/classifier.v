module classifier
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16,
parameter NUM_CLASSIFIERS = 18,
parameter INTEGRAL_WIDTH = 10,
parameter INTEGRAL_HEIGHT = 10
)
(
clk,
reset,
enable,
integral_image,

//== Database
index_tree,
index_leaf,
data,
end_database,
end_leafs,
end_trees,

o_candidate
);



/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
localparam DEFAULT_VALUE = 1010;
input clk;
input reset;
input enable;
input end_database;
input end_leafs;
input end_trees;
input [DATA_WIDTH_12-1:0] index_tree;
input [DATA_WIDTH_12-1:0] index_leaf;
input [DATA_WIDTH_16-1:0] data;
input [DATA_WIDTH_16-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
output o_candidate;


/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/
wire copy;
wire calculate;
wire [DATA_WIDTH_12-1:0] index_stage_threshold;

reg candidate;
reg [DATA_WIDTH_12-1:0]rect_A_1_index;
reg [DATA_WIDTH_12-1:0]rect_B_1_index;
reg [DATA_WIDTH_12-1:0]rect_C_1_index;
reg [DATA_WIDTH_12-1:0]rect_D_1_index;
reg [DATA_WIDTH_12-1:0]weight_1;
reg [DATA_WIDTH_12-1:0]rect_A_2_index;
reg [DATA_WIDTH_12-1:0]rect_B_2_index;
reg [DATA_WIDTH_12-1:0]rect_C_2_index;
reg [DATA_WIDTH_12-1:0]rect_D_2_index;
reg [DATA_WIDTH_12-1:0]weight_2;
reg [DATA_WIDTH_12-1:0]rect_A_3_index;
reg [DATA_WIDTH_12-1:0]rect_B_3_index;
reg [DATA_WIDTH_12-1:0]rect_C_3_index;
reg [DATA_WIDTH_12-1:0]rect_D_3_index;
reg [DATA_WIDTH_12-1:0]weight_3;
reg [DATA_WIDTH_12-1:0]threshold;
reg [DATA_WIDTH_12-1:0]left_word;
reg [DATA_WIDTH_12-1:0]right_word;
reg [DATA_WIDTH_16-1:0]r_stage_threshold;
reg [DATA_WIDTH_16-1:0]r_parent;
reg [DATA_WIDTH_16-1:0]r_next;
reg [DATA_WIDTH_16-1:0] haar;
reg [DATA_WIDTH_16-1:0]sum_haar;

reg [DATA_WIDTH_16-1:0] rect_A_1;
reg [DATA_WIDTH_16-1:0] rect_B_1;
reg [DATA_WIDTH_16-1:0] rect_C_1;
reg [DATA_WIDTH_16-1:0] rect_D_1;
reg [DATA_WIDTH_16-1:0] rect_A_2;
reg [DATA_WIDTH_16-1:0] rect_B_2;
reg [DATA_WIDTH_16-1:0] rect_C_2;
reg [DATA_WIDTH_16-1:0] rect_D_2;
reg [DATA_WIDTH_16-1:0] rect_A_3;
reg [DATA_WIDTH_16-1:0] rect_B_3;
reg [DATA_WIDTH_16-1:0] rect_C_3;
reg [DATA_WIDTH_16-1:0] rect_D_3;


/*--- Rect for block 1 -----*/
reg [DATA_WIDTH_16-1:0] rect_minus_A_1;
reg [DATA_WIDTH_16-1:0] rect_minus_B_1;
reg [DATA_WIDTH_16-1:0] rect_1;
/*--- Rect for block 2 -----*/
reg [DATA_WIDTH_16-1:0] rect_minus_A_2;
reg [DATA_WIDTH_16-1:0] rect_minus_B_2;
reg [DATA_WIDTH_16-1:0] rect_2;
/*--- Rect for block 3 -----*/
reg [DATA_WIDTH_16-1:0] rect_minus_A_3;
reg [DATA_WIDTH_16-1:0] rect_minus_B_3;
reg [DATA_WIDTH_16-1:0] rect_3;

reg [DATA_WIDTH_16-1:0] rect_1_3;
reg [DATA_WIDTH_16-1:0] value;

/*****************************************************************************
*                            Combinational logic                             *
*****************************************************************************/

assign copy = enable && !end_trees;
assign calculate = enable && end_leafs;
assign o_candidate = candidate;


/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 

always@(posedge clk)
begin
	if(end_trees)
	begin
		case(index_stage_threshold)
		0:r_stage_threshold<= data;
		1:r_parent<= data;
		2:r_next<= data;
		endcase
	end
end


always@(posedge clk)
begin
	if(reset ||!enable)
	begin
		candidate<=0;
		sum_haar<=0;
		rect_A_1_index<=0;
		rect_B_1_index<=0;
		rect_C_1_index<=0;
		rect_D_1_index<=0;
		weight_1<=0;
		rect_A_2_index<=0;
		rect_B_2_index<=0;
		rect_C_2_index<=0;
		rect_D_2_index<=0;
		weight_2<=0;
		rect_A_3_index<=0;
		rect_B_3_index<=0;
		rect_C_3_index<=0;
		rect_D_3_index<=0;
		weight_3<=0;
		threshold<=0;
		left_word<=0;
		right_word<=0;
		r_stage_threshold <=0;
		r_parent<=0;
		r_next<=0;		
		rect_A_1<=0;
		rect_B_1<=0;
		rect_C_1<=0;
		rect_D_1<=0;
		rect_A_2<=0;
		rect_B_2<=0;
		rect_C_2<=0;
		rect_D_2<=0;
		rect_A_3<=0;
		rect_B_3<=0;
		rect_C_3<=0;
		rect_D_3<=0;
		rect_minus_A_1<=0;
		rect_minus_B_1<=0;
		rect_1<=0;
		rect_minus_A_2<=0;
		rect_minus_B_2<=0;
		rect_2<=0;
		rect_minus_A_3<=0;
		rect_minus_B_3<=0;
		rect_3<=0;
		rect_1_3<=0;
		value<=0;
		haar<= 0;
	end
	else
	begin
		if(copy)
		begin
			case(index_leaf)
				0:	rect_A_1_index <= data;
				1:	rect_B_1_index <= data;
				2:	rect_C_1_index <= data;
				3:	rect_D_1_index <= data;
				4:	weight_1 <= data;
				5:	rect_A_2_index <= data;
				6:	rect_B_2_index <= data;
				7:	rect_C_2_index <= data;
				8:	rect_D_2_index <= data;
				9:	weight_2 <= data;
				10:	rect_A_3_index <= data;
				11:	rect_B_3_index <= data;
				12:	rect_C_3_index <= data;
				13:	rect_D_3_index <= data;
				14:	weight_3 <= data;
				16:	threshold <= data;
				17:	left_word <= data;
				18:	right_word <= data;
			endcase
		end
	end
end

always@(posedge calculate)
begin
	rect_A_1 = integral_image[rect_A_1_index];
	rect_B_1 = integral_image[rect_B_1_index];
	rect_C_1 = integral_image[rect_C_1_index];
	rect_D_1 = integral_image[rect_D_1_index];
	rect_A_2 = integral_image[rect_A_2_index];
	rect_B_2 = integral_image[rect_B_2_index];
	rect_C_2 = integral_image[rect_C_2_index];
	rect_D_2 = integral_image[rect_D_2_index];
	rect_A_3 = integral_image[rect_A_3_index];
	rect_B_3 = integral_image[rect_B_3_index];
	rect_C_3 = integral_image[rect_C_3_index];
	rect_D_3 = integral_image[rect_D_3_index];
	
	rect_minus_A_1 = rect_A_1 + rect_D_1;
	rect_minus_B_1 = rect_B_1 + rect_C_1;
	rect_1 = weight_1*(rect_minus_A_1 - rect_minus_B_1);
		
	//rect 2
	rect_minus_A_2 = rect_A_2 + rect_D_2;
	rect_minus_B_2 = rect_B_2 + rect_C_2;
	rect_2 = weight_2*(rect_minus_A_2 - rect_minus_B_2);
		
	//rect 3
	rect_minus_A_3 = rect_A_3 - rect_D_3;
	rect_minus_B_3 = rect_B_3 - rect_C_3;
	rect_3 = weight_3*(rect_minus_A_3 - rect_minus_B_3);

	//value
	value = rect_1 + rect_3 + rect_2;
	haar =(value > threshold)? right_word:left_word;	
	sum_haar = sum_haar + haar;
end


always@(posedge end_database)
begin
	candidate = sum_haar>r_stage_threshold;
end


/*****************************************************************************
*                                   Modules                                  *
*****************************************************************************/ 
localparam MAX_SIZE = 3;

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_stage_threshold
(
.clk(clk),
.reset(reset),
.enable(end_trees),
.ctr_out(index_stage_threshold),
.max_size(MAX_SIZE),
.end_count(end_count)
);




endmodule