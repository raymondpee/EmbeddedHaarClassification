module fifo_stage_database
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter NUM_CLASSIFIERS_STAGE = 10;
parameter NUM_PARAM_PER_CLASSIFIER= 19,
parameter NUM_STAGE_THRESHOLD = 3,
parameter FILE_STAGE_MEM = "memory.mif"
)
(
	clk_fpga,
	reset_fpga,
	enable,
	o_tree_index,
	o_data_database,	
	o_end_count_single_classifier_size,
	o_end_count_tree_index,
	o_end_count_database,
	o_address_classifier
);

/*-----------------IO Port declaration -----------------*/
input clk_fpga;
input reset_fpga;
input enable;

output o_end_count_database;
output o_end_count_tree_index;
output o_end_count_single_classifier_size;
output [ADDR_WIDTH-1:0]o_tree_index;
output [DATA_WIDTH_12-1:0]o_data_database;
output [ADDR_WIDTH-1:0] o_address_classifier;
/*-------------------------------------------------------*/

wire end_count_tree_index;
wire end_count_single_classifier_size;
wire end_count_database;
wire [ADDR_WIDTH-1:0] address_database;
wire [ADDR_WIDTH-1:0] address_classifier;
wire [ADDR_WIDTH-1:0] tree_index;
wire [DATA_WIDTH_12-1:0] data_database;

reg ren_tree_index;
reg ren_classifier;
reg ren_database;


assign o_data_database = data_database;
assign o_tree_index = tree_index;
assign o_address_classifier = address_classifier;
assign o_end_count_database = end_count_database;
assign o_end_count_single_classifier_size = end_count_single_classifier_size;

always@(posedge clk_fpga)
begin
	if(enable)
	begin
		ren_classifier<=1;
		ren_database <=1;
	end
	if(end_count_single_classifier_size)
	begin
		ren_tree_index <= 1;
		ren_classifier<=0;
	end
	else
	begin
		ren_tree_index <= 0;
	end
end


counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
.ADDR_WIDTH(ADDR_WIDTH)
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
.ADDR_WIDTH(ADDR_WIDTH)
)
counter_classifier
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(ren_classifier),
.ctr_out(address_classifier),
.max_size(NUM_PARAM_PER_CLASSIFIER),
.end_count(end_count_single_classifier_size)
);


stage_database
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.FILE_STAGE_MEM(FILE_STAGE_MEM),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER)
)
stage_database
(
clk_fpga(clk_fpga),
reset_fpga(reset_fpga),
ren(ren_database),
o_end_count(end_count_database),
o_data(data_database),
o_address(address_database)
);

endmodule