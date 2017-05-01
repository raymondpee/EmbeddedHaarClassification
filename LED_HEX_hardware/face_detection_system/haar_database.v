module haar_database
#(
parameter ADDR_WIDTH = 12,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter NUM_STAGE_THRESHOLD = 3,
parameter NUM_PARAM_PER_CLASSIFIER = 18,
parameter NUM_STAGES_ALL_PHASE = 24
)
(
	clk,
	reset,
	en,
	o_index_tree,
	o_index_classifier,
	o_index_database,
	o_end_single_classifier,
	o_end_all_classifier,
	o_end_tree,
	o_end_database,
	o_end,
	o_data
);

/*-----------------------------LocalParam-----------------------------------*/
localparam FILE_STAGE1 = "ram0.mif";
localparam FILE_STAGE2 = "ram1.mif";
localparam FILE_STAGE3 = "ram2.mif";
localparam FILE_STAGE4 = "ram3.mif";
localparam FILE_STAGE5 = "ram4.mif";
localparam FILE_STAGE6 = "ram5.mif";
localparam FILE_STAGE7 = "ram6.mif";
localparam FILE_STAGE8 = "ram7.mif";
localparam FILE_STAGE9 = "ram8.mif";
localparam FILE_STAGE10 = "ram9.mif";
localparam FILE_STAGE11 = "ram10.mif";
localparam FILE_STAGE12 = "ram11.mif";
localparam FILE_STAGE13 = "ram12.mif";
localparam FILE_STAGE14 = "ram13.mif";
localparam FILE_STAGE15 = "ram14.mif";
localparam FILE_STAGE16 = "ram15.mif";
localparam FILE_STAGE17 = "ram16.mif";
localparam FILE_STAGE18 = "ram17.mif";
localparam FILE_STAGE19 = "ram18.mif";
localparam FILE_STAGE20 = "ram19.mif";
localparam FILE_STAGE21 = "ram20.mif";
localparam FILE_STAGE22 = "ram21.mif";
localparam FILE_STAGE23 = "ram22.mif";
localparam FILE_STAGE24 = "ram23.mif";
localparam FILE_STAGE25 = "ram24.mif";

localparam NUM_CLASSIFIERS_STAGE1 = 9;
localparam NUM_CLASSIFIERS_STAGE2 = 16;
localparam NUM_CLASSIFIERS_STAGE3 = 27;
localparam NUM_CLASSIFIERS_STAGE4 = 32;
localparam NUM_CLASSIFIERS_STAGE5 = 52;
localparam NUM_CLASSIFIERS_STAGE6 = 53;
localparam NUM_CLASSIFIERS_STAGE7 = 62;
localparam NUM_CLASSIFIERS_STAGE8 = 72;
localparam NUM_CLASSIFIERS_STAGE9 = 83;
localparam NUM_CLASSIFIERS_STAGE10 = 91;
localparam NUM_CLASSIFIERS_STAGE11 = 99;
localparam NUM_CLASSIFIERS_STAGE12 = 115;
localparam NUM_CLASSIFIERS_STAGE13 = 127;
localparam NUM_CLASSIFIERS_STAGE14 = 135;
localparam NUM_CLASSIFIERS_STAGE15 = 136;
localparam NUM_CLASSIFIERS_STAGE16 = 137;
localparam NUM_CLASSIFIERS_STAGE17 = 159;
localparam NUM_CLASSIFIERS_STAGE18 = 155;
localparam NUM_CLASSIFIERS_STAGE19 = 169;
localparam NUM_CLASSIFIERS_STAGE20 = 196;
localparam NUM_CLASSIFIERS_STAGE21 = 197;
localparam NUM_CLASSIFIERS_STAGE22 = 181;
localparam NUM_CLASSIFIERS_STAGE23 = 199;
localparam NUM_CLASSIFIERS_STAGE24 = 211;
localparam NUM_CLASSIFIERS_STAGE25 = 200;
/*-------------------------------------------------------------------------*/

/*--------------------IO port declaration---------------------------------*/
input clk;
input reset;
input en;

output o_end;
output [NUM_STAGES_ALL_PHASE-1:0]o_end_database;
output [NUM_STAGES_ALL_PHASE-1:0]o_end_tree;
output [NUM_STAGES_ALL_PHASE-1:0]o_end_single_classifier;
output [NUM_STAGES_ALL_PHASE-1:0]o_end_all_classifier;
output [DATA_WIDTH_12-1:0] o_index_tree[NUM_STAGES_ALL_PHASE-1:0];
output [DATA_WIDTH_12-1:0] o_index_classifier[NUM_STAGES_ALL_PHASE-1:0];
output [DATA_WIDTH_12-1:0] o_index_database[NUM_STAGES_ALL_PHASE-1:0];
output [DATA_WIDTH_12-1:0] o_data[NUM_STAGES_ALL_PHASE-1:0];
/*-----------------------------------------------------------------------*/

  
assign o_end = o_end_database[0] && o_end_database[1] && o_end_database[2] && o_end_database[3] && o_end_database[4]
				&& o_end_database[5] && o_end_database[6] && o_end_database[7] && o_end_database[8] && o_end_database[9]
				&& o_end_database[10] && o_end_database[11] && o_end_database[12] && o_end_database[13] && o_end_database[14]
				&& o_end_database[15] && o_end_database[16] && o_end_database[17] && o_end_database[18] && o_end_database[19]
				&& o_end_database[20] && o_end_database[21] && o_end_database[22] && o_end_database[23] && o_end_database[24];
  
fifo_stage_database
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE1),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE1)
)
stage_1
(
.clk(clk),
.reset(reset),
.en(en),
.o_index_tree(o_index_tree[0]),
.o_index_classifier(o_index_classifier[0]),
.o_index_database(o_index_database[0]),
.o_end_single_classifier(o_end_single_classifier[0]),
.o_end_all_classifier(o_end_all_classifier[0]),
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
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE2),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE2)
)
stage_2
(
.clk(clk),
.reset(reset),
.en(en),
.o_index_tree(o_index_tree[1]),
.o_index_classifier(o_index_classifier[1]),
.o_index_database(o_index_database[1]),
.o_end_single_classifier(o_end_single_classifier[1]),
.o_end_tree(o_end_tree[1]),
.o_end_database(o_end_database[1]),
.o_data(o_data[1])
);

fifo_stage_database
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE3),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE3)
)
stage_3
(
.clk(clk),
.reset(reset),
.en(en),
.o_index_tree(o_index_tree[2]),
.o_index_classifier(o_index_classifier[2]),
.o_index_database(o_index_database[2]),
.o_end_single_classifier(o_end_single_classifier[2]),
.o_end_all_classifier(o_end_all_classifier[2]),
.o_end_tree(o_end_tree[2]),
.o_end_database(o_end_database[2]),
.o_data(o_data[2])
);

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
stage_4
(
.clk(clk),
.reset(reset),
.en(en),
.o_index_tree(o_index_tree[3]),
.o_index_classifier(o_index_classifier[3]),
.o_index_database(o_index_database[3]),
.o_end_single_classifier(o_end_single_classifier[3]),
.o_end_all_classifier(o_end_all_classifier[3]),
.o_end_tree(o_end_tree[3]),
.o_end_database(o_end_database[3]),
.o_data(o_data[3])
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
stage_5
(
.clk(clk),
.reset(reset),
.en(en),
.o_index_tree(o_index_tree[4]),
.o_index_classifier(o_index_classifier[4]),
.o_index_database(o_index_database[4]),
.o_end_single_classifier(o_end_single_classifier[4]),
.o_end_all_classifier(o_end_all_classifier[4]),
.o_end_tree(o_end_tree[4]),
.o_end_database(o_end_database[4]),
.o_data(o_data[4])
);

endmodule