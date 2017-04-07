module primary_stage_classifier
#(
parameter DATA_WIDTH = 8,
parameter NUM_STAGE_THRESHOLD = 1,
parameter NUM_PARAM_PER_CLASSIFIER = 18,
parameter NUM_CLASSIFIERS_FIRST_STAGE = 10,
parameter NUM_CLASSIFIERS_SECOND_STAGE = 10,
parameter NUM_CLASSIFIERS_THIRD_STAGE = 10,
)
(
	clk_fpga,
	reset_fpga,
	rom_first_stage_classifier,
	rom_second_stage_classifier,
	rom_third_stage_classifier,
	integral_image,
	o_iscandidate
);

/*--------------------IO port declaration---------------------------------*/
input clk_fpga;
input reset_fpga;
input [DATA_WIDTH-1:0] integral_image[IWIDTH*IHEIGHT-1:0];
input [DATA_WIDTH-1:0] rom_first_stage_classifier [NUM_CLASSIFIERS_FIRST_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
input [DATA_WIDTH-1:0] rom_second_stage_classifier [NUM_CLASSIFIERS_SECOND_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
input [DATA_WIDTH-1:0] rom_third_stage_classifier [NUM_CLASSIFIERS_THIRD_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
output o_iscandidate;
/*-----------------------------------------------------------------------*/


wire is_first_candidate;
wire is_second_candidate;
wire is_third_candidate;

assign o_iscandidate = is_first_candidate&& is_second_candidate && is_third_candidate;

stage_classifier
#(
.DATA_WIDTH(DATA_WIDTH),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_CLASSIFIERS(NUM_CLASSIFIERS_FIRST_STAGE)
)
first_stage_classifier
(
.clk_fpga(clk_fpga),
.rom_stage_classifier(rom_first_stage_classifier),
.integral_image(integral_image),
.o_iscandidate(is_first_candidate)
)

stage_classifier
#(
.DATA_WIDTH(DATA_WIDTH),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_CLASSIFIERS(NUM_CLASSIFIERS_SECOND_STAGE)
)
second_stage_classifier
(
.clk_fpga(clk_fpga),
.rom_stage_classifier(rom_second_stage_classifier),
.integral_image(integral_image),
.o_iscandidate(is_second_candidate)
)

stage_classifier
#(
.DATA_WIDTH(DATA_WIDTH),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_CLASSIFIERS(NUM_CLASSIFIERS_THIRD_STAGE)
)
third_stage_classifier
(
.clk_fpga(clk_fpga),
.rom_stage_classifier(rom_third_stage_classifier),
.integral_image(integral_image),
.o_iscandidate(is_third_candidate)
)
endmodule