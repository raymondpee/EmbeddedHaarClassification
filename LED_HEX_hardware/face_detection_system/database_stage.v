module database_stage
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter NUM_CLASSIFIERS_STAGE = 10,
parameter NUM_PARAM_PER_CLASSIFIER= 19,
parameter NUM_STAGE_THRESHOLD = 3,
parameter FILE_STAGE_MEM = "memory.mif"
)
(
clk,
reset,
enable,

//== Data
o_data,

//== Index
o_index_tree,
o_index_leaf,

//== End Flag
o_end_leafs,
o_end_trees,
o_end_database	
);

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
input 							clk;
input 							reset;
input 							enable;

output 							o_end_database;
output 							o_end_trees;
output 							o_end_leafs;
output 	[DATA_WIDTH_12-1:0]		o_index_tree;
output 	[DATA_WIDTH_12-1:0] 	o_index_leaf;
output 	[DATA_WIDTH_16-1:0]		o_data;




/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
localparam DEFAULT_VALUE = 1010;
localparam SIZE_STAGE = NUM_CLASSIFIERS_STAGE*NUM_PARAM_PER_CLASSIFIER + NUM_STAGE_THRESHOLD;



/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/
wire 							end_trees;
wire 							end_database;
wire 							end_leafs;
wire 	[DATA_WIDTH_12-1:0] 	index_database;
wire 	[DATA_WIDTH_12-1:0] 	index_leaf;
wire 	[DATA_WIDTH_12-1:0] 	index_tree;

reg								renable;
reg 							trig_count_tree;
reg 							count_leaf;
reg 	[DATA_WIDTH_16-1:0] 	data;


 /*****************************************************************************
 *                            Combinational logic                             *
 *****************************************************************************/
assign o_data 				= data;
assign o_index_tree 		= index_tree;
assign o_index_leaf 		= index_leaf;
assign o_end_trees 			= end_trees;
assign o_end_leafs 			= end_leafs;
assign o_end_database 		= end_database;

/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 

always@(posedge enable)
begin
	renable <=1;	
end
 
always@(posedge reset)
begin
	renable <= 0;
	count_leaf <= 0;
end

always@(posedge end_leafs)
begin
	if(!end_trees)
	begin
		trig_count_tree <= 1;
	end
end

always@(posedge clk)
begin
	trig_count_tree<=0;	
	if(end_database)
	begin
		renable<=0;
	end
end


always@(data)
begin
	if(data == DEFAULT_VALUE)
	begin
		count_leaf<=0;
	end
	else
	begin
		if(end_database)
		begin
			count_leaf<=0;
		end
		else
		begin
			count_leaf<=1;
		end
	end
end


 /*****************************************************************************
 *                                   Modules                                  *
 *****************************************************************************/ 
counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_tree
(
.clk(clk),
.reset(reset),
.enable(trig_count_tree),
.ctr_out(index_tree),
.max_size(NUM_CLASSIFIERS_STAGE-1),
.end_count(end_trees)
);

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_classifier
(
.clk(clk),
.reset(reset),
.enable(count_leaf),
.ctr_out(index_leaf),
.max_size(NUM_PARAM_PER_CLASSIFIER-1),
.end_count(end_leafs)
);

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_database
(
.clk(clk),
.reset(reset),
.enable(count_leaf),
.ctr_out(index_database),
.max_size(SIZE_STAGE-1),
.end_count(end_database)
);

database_stage_memory
#(
.ADDR_WIDTH(ADDR_WIDTH),
.FILE_STAGE_MEM(FILE_STAGE_MEM),
.SIZE_STAGE(SIZE_STAGE)
)
database_stage_memory
(
.clk(clk),
.reset(reset),
.ren_database_index(renable),
.ren_database(renable),
.o_data(data)
);

endmodule