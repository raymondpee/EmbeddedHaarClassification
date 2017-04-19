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
	clk_fpga,
	reset_fpga,
	rden,
	o_index_tree,
	o_index_classifier,
	o_index_database,
	o_end_database,
	o_end_single_classifier,
	o_end_tree,
	o_data	
);
localparam DEFAULT_VALUE = 1010;
localparam NUM_DATABASE_INDEX = NUM_CLASSIFIERS_STAGE*NUM_PARAM_PER_CLASSIFIER + NUM_STAGE_THRESHOLD;
/*-----------------IO Port declaration -----------------*/
input clk_fpga;
input reset_fpga;
input rden;

output o_end_database;
output o_end_tree;
output o_end_single_classifier;
output [ADDR_WIDTH-1:0]o_index_tree;
output [ADDR_WIDTH-1:0] o_index_classifier;
output [ADDR_WIDTH-1:0] o_index_database;
output [DATA_WIDTH_12-1:0]o_data;
/*-------------------------------------------------------*/

wire w_end_tree;
wire w_end_fifoin_database;
wire w_end_fifoout_database;
wire w_end_all_classifiers;
wire w_end_single_classifier;
wire w_end_stage_threshold;
wire [ADDR_WIDTH-1:0] w_index_fifoin_database;
wire [ADDR_WIDTH-1:0] w_index_fifoout_database;
wire [ADDR_WIDTH-1:0] w_index_classifier;
wire [ADDR_WIDTH-1:0] w_index_tree;
wire [ADDR_WIDTH-1:0] w_index_stage_threshold;


reg r_count_tree;
reg r_count_database;
reg r_rden_database;
reg r_count_classifier;
reg r_count_fifoout_database;
reg r_count_stage_threshold;
reg r_end_database;
reg r_end_classifier;
reg reset_logic;
reg reset_counter_tree;
reg reset_counter_fifoout_database;
reg reset_counter_classifier;
reg reset_stage_database;
reg reset_counter_stage_threshold;
reg [DATA_WIDTH_12-1:0] r_data;
reg [DATA_WIDTH_12-1:0] r_stage_threshold;
reg [DATA_WIDTH_12-1:0] r_parent;
reg [DATA_WIDTH_12-1:0] r_next;

assign o_data = r_data;
assign o_index_tree = w_index_tree;
assign o_index_classifier = w_index_classifier;
assign o_index_database = w_index_fifoout_database;
assign o_end_tree = w_end_tree;
assign o_end_single_classifier = w_end_single_classifier;
assign o_end_database = r_end_database;
assign w_end_all_classifiers = ((w_index_fifoout_database + NUM_STAGE_THRESHOLD) == NUM_DATABASE_INDEX);

always@(posedge w_end_fifoout_database) r_end_database<=1;
always@(posedge w_end_all_classifiers) r_end_classifier<=1;
always@(posedge r_end_classifier) r_count_stage_threshold<=1;
always@(posedge w_end_stage_threshold) r_count_stage_threshold<=0;


always@(posedge clk_fpga)
begin
	if(r_end_classifier)
	begin
		if(w_end_stage_threshold == 0)
		begin
			case(w_index_stage_threshold)
			0:r_stage_threshold<= r_data;
			1:r_parent<= r_data;
			2:r_next<= r_data;
			endcase
		end
	end
end

always@(posedge reset_fpga)
begin
	r_stage_threshold<=0;
	r_parent<=0;
	r_next<=0;
	r_end_database<=0;
	r_count_classifier<=0;
	r_count_fifoout_database<=0;
	r_count_stage_threshold<=0;
	reset_logic<=1;
	reset_counter_tree<=1;
	reset_counter_stage_threshold<=1;
	reset_counter_classifier<=1;
	reset_counter_fifoout_database<=1;
	reset_stage_database<=1;
	r_end_classifier<=0;
end

always@(posedge clk_fpga)
begin
	if(reset_logic) reset_logic<=0;
	if(reset_counter_tree)reset_counter_tree<=0;
	if(reset_counter_fifoout_database)reset_counter_fifoout_database<=0;
	if(reset_counter_classifier)reset_counter_classifier<=0;
	if(reset_stage_database)reset_stage_database<=0;
	if(reset_counter_stage_threshold)reset_counter_stage_threshold<=0;
	if(r_count_tree) r_count_tree<=0;	
end


always@(posedge clk_fpga)
begin
	if(reset_logic)
	begin	
		r_data<=DEFAULT_VALUE;
		r_count_tree<=0;
		r_count_database<=0;
		r_rden_database<=0;
	end
	if(w_end_fifoout_database)
	begin
		r_rden_database<=0;
		r_data<=DEFAULT_VALUE;
		reset_logic<=1;
		reset_counter_fifoout_database<=1;
		reset_counter_classifier<=1;
		reset_stage_database<=1;
	end
end

always@(posedge rden)
begin
	r_count_database <=1;
	r_rden_database<=1;
end


always@(r_data)
begin
	if(r_data == DEFAULT_VALUE)
	begin
		r_count_classifier<=0;
		r_count_fifoout_database<=0;
	end
	else
	begin
		if(r_end_database)
		begin
			r_count_classifier<=0;
			r_count_fifoout_database<=0;
		end
		else
		begin
			r_count_classifier<=1;
			r_count_fifoout_database<=1;
		end
	end
end

always@(w_end_tree,w_end_fifoin_database,w_end_single_classifier)
begin
	if(w_end_tree) r_count_tree<=0;
	if(w_end_single_classifier) r_count_tree <= 1;
	if(w_end_fifoin_database) r_count_database<=0;
end

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_stage_threshold
(
.clk(clk_fpga),
.reset(reset_counter_stage_threshold),
.enable(r_count_stage_threshold),
.ctr_out(w_index_stage_threshold),
.max_size(NUM_STAGE_THRESHOLD-1),
.end_count(w_end_stage_threshold)
);

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_tree
(
.clk(clk_fpga),
.reset(reset_counter_tree),
.enable(r_count_tree),
.ctr_out(w_index_tree),
.max_size(NUM_CLASSIFIERS_STAGE-1),
.end_count(w_end_tree)
);

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_classifier
(
.clk(clk_fpga),
.reset(reset_counter_classifier),
.enable(r_count_classifier),
.ctr_out(w_index_classifier),
.max_size(NUM_PARAM_PER_CLASSIFIER-1),
.end_count(w_end_single_classifier)
);


counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_fifoout_database
(
.clk(clk_fpga),
.reset(reset_counter_fifoout_database),
.enable(r_count_fifoout_database),
.ctr_out(w_index_fifoout_database),
.max_size(NUM_DATABASE_INDEX-1),
.end_count(w_end_fifoout_database)
);


stage_database
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.FILE_STAGE_MEM(FILE_STAGE_MEM),
.NUM_DATABASE_INDEX(NUM_DATABASE_INDEX)
)
stage_database
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_stage_database),
.ren_database_index(r_count_database),
.ren_database(r_rden_database),
.o_end_count(w_end_fifoin_database),
.o_data(r_data),
.o_address(w_index_fifoin_database)
);

endmodule