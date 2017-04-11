module second_stage_classifier
#(
parameter NUM_RESIZE = 5,
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter INTEGRAL_WIDTH = 3,
parameter INTEGRAL_HEIGHT = 3
)
(
	clk_fpga,
	reset_fpga,
	integral_image,
	req_compare,
	o_is_candidate
);

/*--------------------IO port declaration---------------------------------*/
input clk_fpga;
input req_compare;
input [DATA_WIDTH_12-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0][NUM_RESIZE];
output o_is_candidate;
/*-----------------------------------------------------------------------*/




fifo_stage_classifier
#(
ADDR_WIDTH(ADDR_WIDTH),
DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
MEMORY_FILE(MEMORY_FILE)
)
fifo_stage_classifier
(
.clk_fpga(clk),
.reset_fpga(reset),
.trigger_compare(req_compare),
.classifier_size(classifier_size),
.integral_image(integral_image),
.o_is_end_reached(o_is_end_reached)
);

endmodule