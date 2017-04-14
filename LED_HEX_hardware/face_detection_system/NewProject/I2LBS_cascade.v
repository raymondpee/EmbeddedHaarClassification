module I2LBS_cascade
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
	rom_stage1,
	rom_stage2,
	rom_stage3,
	integral_image,
	candidate
);

/*--------------------IO port declaration---------------------------------*/
input clk_fpga;
input reset_fpga;
input [DATA_WIDTH-1:0] integral_image[IWIDTH*IHEIGHT-1:0];
input [DATA_WIDTH-1:0] rom_stage1 [NUM_CLASSIFIERS_FIRST_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
input [DATA_WIDTH-1:0] rom_stage2 [NUM_CLASSIFIERS_SECOND_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
input [DATA_WIDTH-1:0] rom_stage3 [NUM_CLASSIFIERS_THIRD_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
output candidate;
/*-----------------------------------------------------------------------*/


wire is_first_candidate;
wire is_second_candidate;
wire is_third_candidate;

assign candidate = is_first_candidate&& is_second_candidate && is_third_candidate;

stage_classifier
#(
.DATA_WIDTH(DATA_WIDTH),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_CLASSIFIERS(NUM_CLASSIFIERS_FIRST_STAGE)
)
stage1
(
.clk_fpga(clk_fpga),
.rom_stage_classifier(rom_stage1),
.integral_image(integral_image),
.candidate(is_first_candidate)
);

stage_classifier
#(
.DATA_WIDTH(DATA_WIDTH),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_CLASSIFIERS(NUM_CLASSIFIERS_SECOND_STAGE)
)
stage2
(
.clk_fpga(clk_fpga),
.rom_stage_classifier(rom_stage2),
.integral_image(integral_image),
.candidate(is_second_candidate)
);

stage_classifier
#(
.DATA_WIDTH(DATA_WIDTH),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_CLASSIFIERS(NUM_CLASSIFIERS_THIRD_STAGE)
)
stage3
(
.clk_fpga(clk_fpga),
.rom_stage_classifier(rom_stage3),
.integral_image(integral_image),
.candidate(is_third_candidate)
);
endmodule