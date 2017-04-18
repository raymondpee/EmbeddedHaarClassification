module v_second_phase_haar_cascade
#(
parameter NUM_STAGES = 8,
parameter ADDR_WIDTH = 12,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter NUM_STAGE_THRESHOLD = 3,
parameter NUM_PARAM_PER_CLASSIFIER = 18,
parameter FILE_STAGE4 = "ram3.mif",
parameter FILE_STAGE5 = "ram4.mif",
parameter FILE_STAGE6 = "ram5.mif",
parameter FILE_STAGE7 = "ram6.mif",
parameter FILE_STAGE8 = "ram7.mif",
parameter FILE_STAGE9 = "ram8.mif",
parameter FILE_STAGE10 = "ram9.mif",
parameter FILE_STAGE11 = "ram10.mif",
parameter NUM_CLASSIFIERS_STAGE4 = 32,
parameter NUM_CLASSIFIERS_STAGE5 = 52,
parameter NUM_CLASSIFIERS_STAGE6 = 53,
parameter NUM_CLASSIFIERS_STAGE7 = 62,
parameter NUM_CLASSIFIERS_STAGE8 = 72,
parameter NUM_CLASSIFIERS_STAGE9 = 83,
parameter NUM_CLASSIFIERS_STAGE10 = 91,
parameter NUM_CLASSIFIERS_STAGE11 = 99
)
(
	clk_fpga,
	reset_fpga,
	i_rden,
	o_tree_index,
	o_classifier_index,
	o_database_index,
	o_data_database,	
	o_end_count_classifier_index,
	o_end_count_tree_index,
	o_end_count_database_index,
);

/*-----------------------------LocalParam-----------------------------------*/

/*-------------------------------------------------------------------------*/

/*--------------------IO port declaration---------------------------------*/
input clk_fpga;
input reset_fpga;
input i_rden;

output [NUM_STAGES-1:0]o_end_count_database_index;
output [NUM_STAGES-1:0]o_end_count_tree_index;
output [NUM_STAGES-1:0]o_end_count_classifier_index;
output [ADDR_WIDTH-1:0]o_tree_index[NUM_STAGES-1:0];
output [ADDR_WIDTH-1:0] o_classifier_index[NUM_STAGES-1:0];
output [ADDR_WIDTH-1:0] o_database_index[NUM_STAGES-1:0];
output [DATA_WIDTH_12-1:0]o_data_database[NUM_STAGES-1:0];
/*-----------------------------------------------------------------------*/
 

fifo_stage_database
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE4),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE4)
)
fifo_stage_database_4
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.rden(i_rden),
.o_tree_index(o_tree_index[0]),
.o_classifier_index(o_classifier_index[0]),
.o_database_index(o_database_index[0]),
.o_end_count_classifier_index(o_end_count_classifier_index[0]),
.o_end_count_tree_index(o_end_count_tree_index[0]),
.o_end_count_database_index(o_end_count_database_index[0]),
.o_data_database(o_data_database[0])
);

endmodule