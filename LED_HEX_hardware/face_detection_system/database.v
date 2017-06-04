module database
#(
parameter ADDR_WIDTH = 12,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter NUM_STAGE_THRESHOLD = 3,
parameter NUM_PARAM_PER_CLASSIFIER = 18,
parameter NUM_STAGES = 25
)
(
	clk,
	reset,
	enable,
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
input enable;

output o_end;
output [NUM_STAGES-1:0]o_end_database;
output [NUM_STAGES-1:0]o_end_tree;
output [NUM_STAGES-1:0]o_end_single_classifier;
output [NUM_STAGES-1:0]o_end_all_classifier;
output [DATA_WIDTH_12-1:0] o_index_tree[NUM_STAGES-1:0];
output [DATA_WIDTH_12-1:0] o_index_classifier[NUM_STAGES-1:0];
output [DATA_WIDTH_12-1:0] o_index_database[NUM_STAGES-1:0];
output [DATA_WIDTH_16-1:0] o_data[NUM_STAGES-1:0];
/*-----------------------------------------------------------------------*/

  
assign o_end = o_end_database[0] && o_end_database[1] && o_end_database[2] && o_end_database[3] && o_end_database[4]
				&& o_end_database[5] && o_end_database[6] && o_end_database[7] && o_end_database[8] && o_end_database[9]
				&& o_end_database[10] && o_end_database[11] && o_end_database[12] && o_end_database[13] && o_end_database[14]
				&& o_end_database[15] && o_end_database[16] && o_end_database[17] && o_end_database[18] && o_end_database[19]
				&& o_end_database[20] && o_end_database[21] && o_end_database[22] && o_end_database[23] && o_end_database[24];
  
database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE1),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE1)
)
stage_1
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[0]),
.o_index_classifier(o_index_classifier[0]),
.o_index_database(o_index_database[0]),
.o_end_single_classifier(o_end_single_classifier[0]),
.o_end_all_classifier(o_end_all_classifier[0]),
.o_end_tree(o_end_tree[0]),
.o_end_database(o_end_database[0]),
.o_data(o_data[0])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE2),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE2)
)
stage_2
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[1]),
.o_index_classifier(o_index_classifier[1]),
.o_index_database(o_index_database[1]),
.o_end_single_classifier(o_end_single_classifier[1]),
.o_end_all_classifier(o_end_all_classifier[1]),
.o_end_tree(o_end_tree[1]),
.o_end_database(o_end_database[1]),
.o_data(o_data[1])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE3),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE3)
)
stage_3
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[2]),
.o_index_classifier(o_index_classifier[2]),
.o_index_database(o_index_database[2]),
.o_end_single_classifier(o_end_single_classifier[2]),
.o_end_all_classifier(o_end_all_classifier[2]),
.o_end_tree(o_end_tree[2]),
.o_end_database(o_end_database[2]),
.o_data(o_data[2])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE4),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE4)
)
stage_4
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[3]),
.o_index_classifier(o_index_classifier[3]),
.o_index_database(o_index_database[3]),
.o_end_single_classifier(o_end_single_classifier[3]),
.o_end_all_classifier(o_end_all_classifier[3]),
.o_end_tree(o_end_tree[3]),
.o_end_database(o_end_database[3]),
.o_data(o_data[3])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE5),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE5)
)
stage_5
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[4]),
.o_index_classifier(o_index_classifier[4]),
.o_index_database(o_index_database[4]),
.o_end_single_classifier(o_end_single_classifier[4]),
.o_end_all_classifier(o_end_all_classifier[4]),
.o_end_tree(o_end_tree[4]),
.o_end_database(o_end_database[4]),
.o_data(o_data[4])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE6),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE6)
)
stage_6
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[5]),
.o_index_classifier(o_index_classifier[5]),
.o_index_database(o_index_database[5]),
.o_end_single_classifier(o_end_single_classifier[5]),
.o_end_all_classifier(o_end_all_classifier[5]),
.o_end_tree(o_end_tree[5]),
.o_end_database(o_end_database[5]),
.o_data(o_data[5])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE7),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE7)
)
stage_7
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[6]),
.o_index_classifier(o_index_classifier[6]),
.o_index_database(o_index_database[6]),
.o_end_single_classifier(o_end_single_classifier[6]),
.o_end_all_classifier(o_end_all_classifier[6]),
.o_end_tree(o_end_tree[6]),
.o_end_database(o_end_database[6]),
.o_data(o_data[6])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE8),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE8)
)
stage_8
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[7]),
.o_index_classifier(o_index_classifier[7]),
.o_index_database(o_index_database[7]),
.o_end_single_classifier(o_end_single_classifier[7]),
.o_end_all_classifier(o_end_all_classifier[7]),
.o_end_tree(o_end_tree[7]),
.o_end_database(o_end_database[7]),
.o_data(o_data[7])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE9),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE9)
)
stage_9
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[8]),
.o_index_classifier(o_index_classifier[8]),
.o_index_database(o_index_database[8]),
.o_end_single_classifier(o_end_single_classifier[8]),
.o_end_all_classifier(o_end_all_classifier[8]),
.o_end_tree(o_end_tree[8]),
.o_end_database(o_end_database[8]),
.o_data(o_data[8])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE10),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE10)
)
stage_10
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[9]),
.o_index_classifier(o_index_classifier[9]),
.o_index_database(o_index_database[9]),
.o_end_single_classifier(o_end_single_classifier[9]),
.o_end_all_classifier(o_end_all_classifier[9]),
.o_end_tree(o_end_tree[9]),
.o_end_database(o_end_database[9]),
.o_data(o_data[9])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE11),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE11)
)
stage_11
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[10]),
.o_index_classifier(o_index_classifier[10]),
.o_index_database(o_index_database[10]),
.o_end_single_classifier(o_end_single_classifier[10]),
.o_end_all_classifier(o_end_all_classifier[10]),
.o_end_tree(o_end_tree[10]),
.o_end_database(o_end_database[10]),
.o_data(o_data[10])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE12),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE12)
)
stage_12
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[11]),
.o_index_classifier(o_index_classifier[11]),
.o_index_database(o_index_database[11]),
.o_end_single_classifier(o_end_single_classifier[11]),
.o_end_all_classifier(o_end_all_classifier[11]),
.o_end_tree(o_end_tree[11]),
.o_end_database(o_end_database[11]),
.o_data(o_data[11])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE13),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE13)
)
stage_13
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[12]),
.o_index_classifier(o_index_classifier[12]),
.o_index_database(o_index_database[12]),
.o_end_single_classifier(o_end_single_classifier[12]),
.o_end_all_classifier(o_end_all_classifier[12]),
.o_end_tree(o_end_tree[12]),
.o_end_database(o_end_database[12]),
.o_data(o_data[12])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE14),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE14)
)
stage_14
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[13]),
.o_index_classifier(o_index_classifier[13]),
.o_index_database(o_index_database[13]),
.o_end_single_classifier(o_end_single_classifier[13]),
.o_end_all_classifier(o_end_all_classifier[13]),
.o_end_tree(o_end_tree[13]),
.o_end_database(o_end_database[13]),
.o_data(o_data[13])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE15),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE15)
)
stage_15
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[14]),
.o_index_classifier(o_index_classifier[14]),
.o_index_database(o_index_database[14]),
.o_end_single_classifier(o_end_single_classifier[14]),
.o_end_all_classifier(o_end_all_classifier[14]),
.o_end_tree(o_end_tree[14]),
.o_end_database(o_end_database[14]),
.o_data(o_data[14])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE16),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE16)
)
stage_16
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[15]),
.o_index_classifier(o_index_classifier[15]),
.o_index_database(o_index_database[15]),
.o_end_single_classifier(o_end_single_classifier[15]),
.o_end_all_classifier(o_end_all_classifier[15]),
.o_end_tree(o_end_tree[15]),
.o_end_database(o_end_database[15]),
.o_data(o_data[15])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE17),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE17)
)
stage_17
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[16]),
.o_index_classifier(o_index_classifier[16]),
.o_index_database(o_index_database[16]),
.o_end_single_classifier(o_end_single_classifier[16]),
.o_end_all_classifier(o_end_all_classifier[16]),
.o_end_tree(o_end_tree[16]),
.o_end_database(o_end_database[16]),
.o_data(o_data[16])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE18),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE18)
)
stage_18
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[17]),
.o_index_classifier(o_index_classifier[17]),
.o_index_database(o_index_database[17]),
.o_end_single_classifier(o_end_single_classifier[17]),
.o_end_all_classifier(o_end_all_classifier[17]),
.o_end_tree(o_end_tree[17]),
.o_end_database(o_end_database[17]),
.o_data(o_data[17])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE19),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE19)
)
stage_19
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[18]),
.o_index_classifier(o_index_classifier[18]),
.o_index_database(o_index_database[18]),
.o_end_single_classifier(o_end_single_classifier[18]),
.o_end_all_classifier(o_end_all_classifier[18]),
.o_end_tree(o_end_tree[18]),
.o_end_database(o_end_database[18]),
.o_data(o_data[18])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE20),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE20)
)
stage_20
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[19]),
.o_index_classifier(o_index_classifier[19]),
.o_index_database(o_index_database[19]),
.o_end_single_classifier(o_end_single_classifier[19]),
.o_end_all_classifier(o_end_all_classifier[19]),
.o_end_tree(o_end_tree[19]),
.o_end_database(o_end_database[19]),
.o_data(o_data[19])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE21),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE21)
)
stage_21
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[20]),
.o_index_classifier(o_index_classifier[20]),
.o_index_database(o_index_database[20]),
.o_end_single_classifier(o_end_single_classifier[20]),
.o_end_all_classifier(o_end_all_classifier[20]),
.o_end_tree(o_end_tree[20]),
.o_end_database(o_end_database[20]),
.o_data(o_data[20])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE22),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE22)
)
stage_22
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[21]),
.o_index_classifier(o_index_classifier[21]),
.o_index_database(o_index_database[21]),
.o_end_single_classifier(o_end_single_classifier[21]),
.o_end_all_classifier(o_end_all_classifier[21]),
.o_end_tree(o_end_tree[21]),
.o_end_database(o_end_database[21]),
.o_data(o_data[21])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE23),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE23)
)
stage_23
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[22]),
.o_index_classifier(o_index_classifier[22]),
.o_index_database(o_index_database[22]),
.o_end_single_classifier(o_end_single_classifier[22]),
.o_end_all_classifier(o_end_all_classifier[22]),
.o_end_tree(o_end_tree[22]),
.o_end_database(o_end_database[22]),
.o_data(o_data[22])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE24),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE24)
)
stage_24
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[23]),
.o_index_classifier(o_index_classifier[23]),
.o_index_database(o_index_database[23]),
.o_end_single_classifier(o_end_single_classifier[23]),
.o_end_all_classifier(o_end_all_classifier[23]),
.o_end_tree(o_end_tree[23]),
.o_end_database(o_end_database[23]),
.o_data(o_data[23])
);

database_stage
#(
.ADDR_WIDTH(ADDR_WIDTH),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS_STAGE25),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_MEM(FILE_STAGE25)
)
stage_25
(
.clk(clk),
.reset(reset),
.enable(enable),
.o_index_tree(o_index_tree[24]),
.o_index_classifier(o_index_classifier[24]),
.o_index_database(o_index_database[24]),
.o_end_single_classifier(o_end_single_classifier[24]),
.o_end_all_classifier(o_end_all_classifier[24]),
.o_end_tree(o_end_tree[24]),
.o_end_database(o_end_database[24]),
.o_data(o_data[24])
);

endmodule