module I2LBS_classifier
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16,
parameter NUM_STAGE = 10,
parameter INTEGRAL_WIDTH = 10,
parameter INTEGRAL_HEIGHT = 10
)
(
clk_fpga,
reset_fpga,
integral_image,
end_database,
end_tree,
end_single_classifier,
index_tree,
index_classifier,
index_database,
data,
o_candidate,
o_inspect_done
);

input clk_fpga;
input reset_fpga;
input [DATA_WIDTH_12-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
input [NUM_STAGE-1:0]end_database;
input [NUM_STAGE-1:0]end_tree;
input [NUM_STAGE-1:0]end_single_classifier;
input [DATA_WIDTH_12-1:0] index_tree[NUM_STAGE-1:0];
input [DATA_WIDTH_12-1:0] index_classifier [NUM_STAGE-1:0];
input [DATA_WIDTH_12-1:0] index_database [NUM_STAGE-1:0];
input [DATA_WIDTH_12-1:0] data [NUM_STAGE-1:0];
output o_inspect_done;
output[NUM_STAGE-1:0] o_candidate;

generate
genvar index;
for(index = 0; index<NUM_STAGE; index = index +1)
begin
	fifo_stage_classifier
	#(
	.DATA_WIDTH_8(DATA_WIDTH_8),
	.DATA_WIDTH_12(DATA_WIDTH_12),
	.DATA_WIDTH_16(DATA_WIDTH_16),
	.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
	.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
	)
	fifo_stage_classifier
	(
	.clk_fpga(clk_fpga),
	.reset_fpga(reset_fpga),
	.integral_image(integral_image),
	.end_database(end_database[index]),
	.end_tree(end_tree[index]),
	.end_single_classifier(end_single_classifier[index]),
	.index_tree(index_tree[index]),
	.index_classifier(index_classifier[index]),
	.index_database(index_database[index]),
	.data(data[index]),
	.o_candidate(o_candidate[index])
	);
end
endgenerate

endmodule