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
	o_tree_index,
	o_classifier_index,
	o_database_index,
	o_end_count_classifier_index,
	o_end_count_tree_index,
	o_end_count_database_index,	
	o_data_database	
);
localparam NUM_DATABASE_INDEX = NUM_CLASSIFIERS_STAGE*NUM_PARAM_PER_CLASSIFIER + NUM_STAGE_THRESHOLD;
/*-----------------IO Port declaration -----------------*/
input clk_fpga;
input reset_fpga;
input rden;

output o_end_count_database_index;
output o_end_count_tree_index;
output o_end_count_classifier_index;
output [ADDR_WIDTH-1:0]o_tree_index;
output [ADDR_WIDTH-1:0] o_classifier_index;
output [ADDR_WIDTH-1:0] o_database_index;
output [DATA_WIDTH_12-1:0]o_data_database;
/*-------------------------------------------------------*/

wire end_count_tree_index;
wire end_count_classifier_index;
wire end_count_database_index;
wire [ADDR_WIDTH-1:0] database_index;
wire [ADDR_WIDTH-1:0] classifier_index;
wire [ADDR_WIDTH-1:0] tree_index;
wire [DATA_WIDTH_12-1:0] data_database;

reg r_rden;
reg ren_tree_index;
reg ren_classifier_index;
reg ren_database_index;
reg r_end_count_database_index;

assign o_data_database = data_database;
assign o_tree_index = tree_index;
assign o_classifier_index = classifier_index;
assign o_database_index = database_index;
assign o_end_count_tree_index = end_count_tree_index;
assign o_end_count_database_index = end_count_database_index;
assign o_end_count_classifier_index = end_count_classifier_index;


always@(posedge end_count_database_index)
begin
	r_end_count_database_index <=1;
end


always@(posedge clk_fpga)
begin
	if(rden)
		r_rden<=1;
	if(r_end_count_database_index)
		r_rden<=0;
end

always@(posedge r_rden)
begin
	ren_classifier_index<=1;
	ren_database_index <=1;
end


always@(posedge clk_fpga)
begin
	if(reset_fpga)
	begin
		ren_tree_index<=0;
		ren_classifier_index<=0;
		ren_database_index<=0;
		r_end_count_database_index<=0;
	end
	else
	begin
		if(r_rden)
		begin
			if(end_count_classifier_index)
			begin
				ren_tree_index <= 1;
				ren_classifier_index<=0;
				ren_database_index<=0;		
			end
			else if(end_count_tree_index)
			begin
				ren_tree_index<=0;
				ren_classifier_index<=0;
				if(end_count_database_index)
					ren_database_index<=0;
				else
					ren_database_index<=1;
			end
			else
			begin
				ren_tree_index <= 0;
				ren_classifier_index<=1;
				ren_database_index<=1;
			end
		end
	end
end




counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_tree_index
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(ren_tree_index),
.ctr_out(tree_index),
.max_size(NUM_CLASSIFIERS_STAGE),
.end_count(end_count_tree_index)
);

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_classifier
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(ren_classifier_index),
.ctr_out(classifier_index),
.max_size(NUM_PARAM_PER_CLASSIFIER-1),
.end_count(end_count_classifier_index)
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
.reset_fpga(reset_fpga),
.ren(ren_database_index),
.o_end_count(end_count_database_index),
.o_data(data_database),
.o_address(database_index)
);

endmodule