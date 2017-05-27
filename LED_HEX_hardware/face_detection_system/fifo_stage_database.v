module fifo_stage_database
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
o_index_tree,
o_index_classifier,
o_index_database,
o_end_database,
o_end_single_classifier,
o_end_all_classifier,
o_end_tree,
o_data	
);
localparam DEFAULT_VALUE = 1010;
localparam SIZE_STAGE = NUM_CLASSIFIERS_STAGE*NUM_PARAM_PER_CLASSIFIER + NUM_STAGE_THRESHOLD;
/*-----------------IO Port declaration -----------------*/
input clk;
input reset;
input enable;

output o_end_database;
output o_end_tree;
output o_end_single_classifier;
output o_end_all_classifier;
output [DATA_WIDTH_12-1:0]o_index_tree;
output [DATA_WIDTH_12-1:0] o_index_classifier;
output [DATA_WIDTH_12-1:0] o_index_database;
output [DATA_WIDTH_12-1:0]o_data;
/*-------------------------------------------------------*/

wire end_trees;
wire end_database;
wire end_tree;
wire [DATA_WIDTH_12-1:0] index_database;
wire [DATA_WIDTH_12-1:0] index_tree;
wire [DATA_WIDTH_12-1:0] w_index_tree;
wire [DATA_WIDTH_12-1:0] w_index_stage_threshold;


reg trig_count_tree;
reg count_classifier;
reg count_database;
reg r_end_all_classifiers;
reg [DATA_WIDTH_12-1:0] data;

assign o_data = data;
assign o_index_tree = w_index_tree;
assign o_index_classifier = index_tree;
assign o_index_database = index_database;
assign o_end_tree = end_trees;
assign o_end_single_classifier = end_tree;
assign o_end_database = end_database;
assign o_end_all_classifier = end_trees;


always@(index_database)
begin
	if((index_database + NUM_STAGE_THRESHOLD) == SIZE_STAGE)
	begin
		r_end_all_classifiers =1;
	end
end

always@(posedge reset)
begin
	count_classifier<=0;
	count_database<=0;
	r_end_all_classifiers <=0;
end

always@(posedge clk)
begin
	if(trig_count_tree) trig_count_tree<=0;	
end


counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_tree
(
.clk(clk),
.reset(reset),
.enable(trig_count_tree),
.ctr_out(w_index_tree),
.max_size(NUM_CLASSIFIERS_STAGE-1),
.end_count(end_trees)
);

always@(posedge end_tree)
begin
	if(!end_trees)
		trig_count_tree <= 1;
end

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_classifier
(
.clk(clk),
.reset(reset),
.enable(count_classifier),
.ctr_out(index_tree),
.max_size(NUM_PARAM_PER_CLASSIFIER-1),
.end_count(end_tree)
);


counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_database
(
.clk(clk),
.reset(reset),
.enable(count_database),
.ctr_out(index_database),
.max_size(SIZE_STAGE-1),
.end_count(end_database)
);


always@(data)
begin
	if(data == DEFAULT_VALUE)
	begin
		count_classifier<=0;
		count_database<=0;
	end
	else
	begin
		if(end_database)
		begin
			count_classifier<=0;
			count_database<=0;
		end
		else
		begin
			count_classifier<=1;
			count_database<=1;
		end
	end
end

stage_database
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.FILE_STAGE_MEM(FILE_STAGE_MEM),
.SIZE_STAGE(SIZE_STAGE)
)
stage_database
(
.clk(clk),
.reset(reset),
.ren_database_index(enable),
.ren_database(enable),
.o_data(data)
);

endmodule