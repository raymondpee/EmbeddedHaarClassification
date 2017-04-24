module I2LBS_first_phase_classifier
#(
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter NUM_STAGE_THRESHOLD = 1,
parameter NUM_PARAM_PER_CLASSIFIER = 18,
parameter NUM_CLASSIFIERS_STAGE_1 = 10,
parameter NUM_CLASSIFIERS_STAGE_2 = 10,
parameter NUM_CLASSIFIERS_STAGE_3 = 10,
parameter INTEGRAL_WIDTH = 3,
parameter INTEGRAL_HEIGHT = 3
)
(
clk_fpga,
reset_fpga,
rom_stage1,
rom_stage2,
rom_stage3,
integral_image,
o_candidate
);

/*--------------------IO port declaration---------------------------------*/
input clk_fpga;
input reset_fpga;
input [DATA_WIDTH_12-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
input [DATA_WIDTH_12-1:0] rom_stage1 [NUM_CLASSIFIERS_STAGE_1*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
input [DATA_WIDTH_12-1:0] rom_stage2 [NUM_CLASSIFIERS_STAGE_2*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
input [DATA_WIDTH_12-1:0] rom_stage3 [NUM_CLASSIFIERS_STAGE_3*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
output o_candidate;
/*-----------------------------------------------------------------------*/


wire candidate_stage_1;
wire candidate_stage_2;
wire candidate_stage_3;

assign o_candidate = candidate_stage_1&& candidate_stage_2 && candidate_stage_3;

stage_classifier
#(
.DATA_WIDTH_8(DATA_WIDTH_8),
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_CLASSIFIERS(NUM_CLASSIFIERS_STAGE_1),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
)
stage1
(
.clk_fpga(clk_fpga),
.rom_stage(rom_stage1),
.integral_image(integral_image),
.o_candidate(candidate_stage_1)
);

stage_classifier
#(
.DATA_WIDTH_8(DATA_WIDTH_8),
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_CLASSIFIERS(NUM_CLASSIFIERS_STAGE_2),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
)
stage2
(
.clk_fpga(clk_fpga),
.rom_stage(rom_stage2),
.integral_image(integral_image),
.o_candidate(candidate_stage_2)
);

stage_classifier
#(
.DATA_WIDTH_8(DATA_WIDTH_8),
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_CLASSIFIERS(NUM_CLASSIFIERS_STAGE_3),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
)
stage3
(
.clk_fpga(clk_fpga),
.rom_stage(rom_stage3),
.integral_image(integral_image),
.o_candidate(candidate_stage_3)
);
endmodule