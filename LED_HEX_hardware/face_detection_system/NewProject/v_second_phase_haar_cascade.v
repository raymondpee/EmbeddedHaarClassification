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
	o_index_tree,
	o_index_classifier,
	o_index_database,
	o_end_single_classifier,
	o_end_tree,
	o_end_database,
	o_end,
	o_data
);

/*-----------------------------LocalParam-----------------------------------*/

/*-------------------------------------------------------------------------*/

/*--------------------IO port declaration---------------------------------*/
input clk_fpga;
input reset_fpga;
input i_rden;

output o_end;
output [NUM_STAGES-1:0]o_end_database;
output [NUM_STAGES-1:0]o_end_tree;
output [NUM_STAGES-1:0]o_end_single_classifier;
output [ADDR_WIDTH-1:0]o_index_tree[NUM_STAGES-1:0];
output [ADDR_WIDTH-1:0] o_index_classifier[NUM_STAGES-1:0];
output [ADDR_WIDTH-1:0] o_index_database[NUM_STAGES-1:0];
output [DATA_WIDTH_12-1:0]o_data[NUM_STAGES-1:0];
/*-----------------------------------------------------------------------*/

reg r_rden;
always@(posedge i_rden) r_rden<=1;	
always@(posedge clk_fpga)
begin
	if(r_rden) r_rden<=0;
end
  
 assign o_end = o_end_database[0] && o_end_database[1];
  
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
.rden(r_rden),
.o_index_tree(o_index_tree[0]),
.o_index_classifier(o_index_classifier[0]),
.o_index_database(o_index_database[0]),
.o_end_single_classifier(o_end_single_classifier[0]),
.o_end_tree(o_end_tree[0]),
.o_end_database(o_end_database[0]),
.o_data(o_data[0])
);

fifo_stage_database
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE5),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE5)
)
fifo_stage_database_5
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.rden(r_rden),
.o_index_tree(o_index_tree[1]),
.o_index_classifier(o_index_classifier[1]),
.o_index_database(o_index_database[1]),
.o_end_single_classifier(o_end_single_classifier[1]),
.o_end_tree(o_end_tree[1]),
.o_end_database(o_end_database[1]),
.o_data(o_data[1])
);


endmodule