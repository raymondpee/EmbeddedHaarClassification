module v_first_phase_haar_cascade
#(
parameter ADDR_WIDTH = 12,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter NUM_CLASSIFIERS_STAGE_1 = 9,
parameter NUM_CLASSIFIERS_STAGE_2 = 16,
parameter NUM_CLASSIFIERS_STAGE_3 = 27,
parameter FILE_STAGE_1 = "rom0.mif",
parameter FILE_STAGE_2 = "rom1.mif",
parameter FILE_STAGE_3 = "rom2.mif",
parameter NUM_PARAM_PER_CLASSIFIER= 19,
parameter NUM_STAGE_THRESHOLD = 3
)
(
	clk_fpga,
	reset_fpga,
	o_ready,
	o_rom_stage1,
	o_rom_stage2,
	o_rom_stage3
);

localparam NUM_STAGES = 3;

input clk_fpga;
input reset_fpga;
output o_ready;	
output [DATA_WIDTH_16-1:0] o_rom_stage1[NUM_CLASSIFIERS_STAGE_1*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];
output [DATA_WIDTH_16-1:0] o_rom_stage2[NUM_CLASSIFIERS_STAGE_2*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];
output [DATA_WIDTH_16-1:0] o_rom_stage3[NUM_CLASSIFIERS_STAGE_3*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];

reg [NUM_STAGES-1:0] ready;

assign o_ready = ready[0] && ready[1] && ready[2];

embedded_stage_database
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8 (DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12 (DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16 (DATA_WIDTH_16), // Max value 177777
.NUM_CLASSIFIERS (NUM_CLASSIFIERS_STAGE_1),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD (NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM (FILE_STAGE_1)
)
stage_1
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.o_ready(ready[0]),
.o_rom(o_rom_stage1)
);

embedded_stage_database
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8 (DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12 (DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16 (DATA_WIDTH_16), // Max value 177777
.NUM_CLASSIFIERS (NUM_CLASSIFIERS_STAGE_2),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD (NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM (FILE_STAGE_2)
)
stage_2
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.o_ready(ready[1]),
.o_rom(o_rom_stage2)
);

embedded_stage_database
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8 (DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12 (DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16 (DATA_WIDTH_16), // Max value 177777
.NUM_CLASSIFIERS (NUM_CLASSIFIERS_STAGE_3),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD (NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM (FILE_STAGE_3)
)
stage_3
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.o_ready(ready[2]),
.o_rom(o_rom_stage3)
);


endmodule