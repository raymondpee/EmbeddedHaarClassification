module second_phase_haar_cascade
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
	enable,
	candidate,
);

/*--------------------IO port declaration---------------------------------*/
input clk_fpga;
input enable;
input [DATA_WIDTH_12-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0][NUM_RESIZE];
output o_is_candidate;
/*-----------------------------------------------------------------------*/
 
localparam NUM_STAGES = 7;
localparam FILE_STAGE4_MEM = "ram4.mif";

reg[NUM_STAGES-1:0] end_count; 
reg[NUM_STAGES-1:0] enable_stage; 

//Test here first, if all ok then duplicate all
fifo_stage_classifier
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.CLASSIFIER_SIZE(NUM_CLASSIFIERS_STAGE4),
.MEMORY_FILE(FILE_STAGE4_MEM)
)
stage4
(
.clk_fpga(clk),
.reset_fpga(reset),
.enable(enable_stage[0]),
.integral_image(integral_image),
.end_count(end_count[0])
);

endmodule