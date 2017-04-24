module I2LBS_second_phase_classifier
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16,
parameter NUM_STAGES = 10
)
(
clk_fpga,
reset_fpga,
end_database,
end_tree,
end_single_classifier,
index_tree,
index_classifier,
index_database,
data
);

input clk_fpga;
input reset_fpga;
input end_database[NUM_STAGE-1:0];
input end_tree[NUM_STAGE-1:0];
input end_single_classifier[NUM_STAGE-1:0];
input index_tree[NUM_STAGE-1:0];
input[DATA_WIDTH_12-1:0] index_classifier [NUM_STAGE-1:0];
input[DATA_WIDTH_12-1:0] index_database [NUM_STAGE-1:0];
input[DATA_WIDTH_12-1:0] data [NUM_STAGE-1:0];

fifo_stage_classifier
#(
.DATA_WIDTH_8(DATA_WIDTH_8),
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16)
)
stage 4
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.end_database(end_database[0]),
.end_tree(end_tree[0]),
.end_single_classifier(end_single_classifier[0]),
.index_tree(index_tree[0]),
.index_classifier(index_classifier[0]),
.index_database(index_database[0]),
.data(data[0]),
.stage_threshold(stage_threshold[0]),
.o_candidate(o_candidate[0])
);

endmodule