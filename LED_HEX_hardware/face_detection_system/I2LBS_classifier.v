module I2LBS_classifier
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16,
parameter NUM_STAGE = 10,
parameter INTEGRAL_WIDTH = 10,
parameter INTEGRAL_HEIGHT = 10,
parameter NUM_CLASSIFIERS_STAGE_1 = 9,
parameter NUM_CLASSIFIERS_STAGE_2 = 16,
parameter NUM_CLASSIFIERS_STAGE_3 = 27,
parameter SIZE_DATABASE_EMBEDDED = 100,
parameter NUM_PARAM_PER_CLASSIFIER = 18
)
(
clk,
reset,
enable,
integral_image,
database_stage_1,
database_stage_2,
database_stage_3,
end_database,
end_trees,
end_leafs,
index_tree,
index_leaf,
data,
o_candidate,
o_inspect_done
);

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
input  clk;
input  reset;
input  enable;
input  [DATA_WIDTH_16-1:0] 	integral_image	[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];


input [DATA_WIDTH_16-1:0] 	database_stage_1 [NUM_CLASSIFIERS_STAGE_1-1:0];
input [DATA_WIDTH_16-1:0] 	database_stage_2 [NUM_CLASSIFIERS_STAGE_2-1:0];
input [DATA_WIDTH_16-1:0] 	database_stage_3 [NUM_CLASSIFIERS_STAGE_3-1:0];

//== End Flag
input  [NUM_STAGE-1:0]		end_database;
input  [NUM_STAGE-1:0]		end_trees;
input  [NUM_STAGE-1:0]		end_leafs;

//== Index Flag
input  [DATA_WIDTH_12-1:0] 	index_tree		[NUM_STAGE-1:0];
input  [DATA_WIDTH_12-1:0] 	index_leaf 		[NUM_STAGE-1:0];
input  [DATA_WIDTH_16-1:0] 	data 			[NUM_STAGE-1:0];

//== Output
output 						o_inspect_done;
output 						o_candidate;


/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/

wire 							enable_stage_1;
wire 							enable_stage_2;
wire 							pass;
wire 	[NUM_STAGE-1:0] 		candidate;
reg  							reset_classifier;
reg  							inspect_done;
reg  	[DATA_WIDTH_12-1:0] 	count_stage;


/*****************************************************************************
*                            Combinational logic                             *
*****************************************************************************/

assign enable_stage_1 = enable;
assign enable_stage_2 = pass_stage_1;

assign o_inspect_done = inspect_done;
assign o_candidate = pass;
assign pass = candidate == 25'b1111111111111111111111111;


/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 
always@(posedge clk)
begin
	if(reset)
	begin
		count_stage<=0;
		inspect_done<=0;
		reset_classifier<=1;
	end
	if(reset_classifier)
	begin
		count_stage<=0;
		inspect_done<=0;
		reset_classifier<=0;
	end
	if(inspect_done)
		inspect_done<=0;
end




always@(posedge clk)
begin
	if(end_database[count_stage])
	begin
		if(!candidate[count_stage]||pass)
		begin
			inspect_done <=1;
			reset_classifier<=1;
		end
		else 
		begin
			count_stage <= count_stage+1;
		end
	end
end


 /*****************************************************************************
 *                                   Modules                                  *
 *****************************************************************************/ 

I2LBS_classifier_embedded
#(
.NUM_STAGE(NUM_STAGE),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT) ,
.NUM_CLASSIFIERS_STAGE_1(NUM_CLASSIFIERS_STAGE_1),
.NUM_CLASSIFIERS_STAGE_2(NUM_CLASSIFIERS_STAGE_2),
.NUM_CLASSIFIERS_STAGE_3(NUM_CLASSIFIERS_STAGE_3),
.SIZE_DATABASE_EMBEDDED(SIZE_DATABASE_EMBEDDED),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER)
)
I2LBS_classifier_embedded
(
.clk(clk),
.reset(reset),
.enable(enable_stage_1)
.integral_image(integral_image),
.database_stage_1(database_stage_1),
.database_stage_2(database_stage_2),
.database_stage_3(database_stage_3),
.o_pass(pass_stage_1)
);
 
 
generate
genvar index;
for(index = 0; index<NUM_STAGE; index = index +1)
begin :gen_classifier
	classifier
	#(
	.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
	.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
	)
	classifier
	(
	.clk(clk),
	.reset(reset_classifier),
	.enable(enable_stage_2),
	.integral_image(integral_image),
	.end_database(end_database[index]),
	.end_trees(end_trees[index]),
	.end_leafs(end_leafs[index]),
	.index_tree(index_tree[index]),
	.index_leaf(index_leaf[index]),
	.data(data[index]),
	.o_candidate(candidate[index])
	);
end
endgenerate

endmodule