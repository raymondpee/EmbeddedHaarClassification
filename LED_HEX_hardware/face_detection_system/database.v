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
reset_system,
reset_database,
enable,

//== First Stage Database
pass_first_stage,
o_load_done,
o_memory_first_stage,

//== Data
o_data,

//== Index
o_index_tree,
o_index_leaf,

//== End Flag
o_end_leafs,
o_end_trees,
o_end_database	
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
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


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
input 						clk;
input 						reset_system;
input						reset_database;
input 						enable;
input  						pass_first_stage;

output						o_load_done;
output [NUM_STAGES-1:0]		o_end_database;
output [NUM_STAGES-1:0]		o_end_trees;
output [NUM_STAGES-1:0]		o_end_leafs;
output [DATA_WIDTH_12-1:0] 	o_index_tree				[NUM_STAGES-1:0];
output [DATA_WIDTH_12-1:0] 	o_index_leaf				[NUM_STAGES-1:0];
output [DATA_WIDTH_16-1:0] 	o_data						[NUM_STAGES-1:0];
output [DATA_WIDTH_16-1:0] 	o_memory_first_stage		[TOTAL_SIZE-1:0];

/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/
wire			load_second_stage;
reg				enable_second_stage;

/*****************************************************************************
 *                            Combinational logic                             *
 *****************************************************************************/
assign load_second_stage = enable_second_stage && enable;



always@(posedge clk)
begin
	if(reset)
	begin
		enable_second_stage <=0;
	end
	if(pass_first_stage)
	begin
		enable_second_stage<=1;
	end
end


 /*****************************************************************************
 *                                   Modules                                  *
 *****************************************************************************/ 
database_embedded
#(
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.FILE_STAGE_FILE_1(FILE_STAGE1),
.FILE_STAGE_FILE_2(FILE_STAGE2),
.FILE_STAGE_FILE_3(FILE_STAGE3),
.NUM_CLASSIFIERS_STAGE_1(NUM_CLASSIFIERS_STAGE1),
.NUM_CLASSIFIERS_STAGE_2(NUM_CLASSIFIERS_STAGE2),
.NUM_CLASSIFIERS_STAGE_3(NUM_CLASSIFIERS_STAGE3)
)
database_embedded
(
clk(clk),
reset(reset_system),
o_load_done(o_load_done),
o_memory(o_memory_first_stage)
)
 
 
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[3]),
.o_index_leaf(o_index_leaf[3]),
.o_end_leafs(o_end_leafs[3]),
.o_end_trees(o_end_trees[3]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[4]),
.o_index_leaf(o_index_leaf[4]),
.o_end_leafs(o_end_leafs[4]),
.o_end_trees(o_end_trees[4]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[5]),
.o_index_leaf(o_index_leaf[5]),
.o_end_leafs(o_end_leafs[5]),
.o_end_trees(o_end_trees[5]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[6]),
.o_index_leaf(o_index_leaf[6]),
.o_end_leafs(o_end_leafs[6]),
.o_end_trees(o_end_trees[6]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[7]),
.o_index_leaf(o_index_leaf[7]),
.o_end_leafs(o_end_leafs[7]),
.o_end_trees(o_end_trees[7]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[8]),
.o_index_leaf(o_index_leaf[8]),
.o_end_leafs(o_end_leafs[8]),
.o_end_trees(o_end_trees[8]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[9]),
.o_index_leaf(o_index_leaf[9]),
.o_end_leafs(o_end_leafs[9]),
.o_end_trees(o_end_trees[9]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[10]),
.o_index_leaf(o_index_leaf[10]),
.o_end_leafs(o_end_leafs[10]),
.o_end_trees(o_end_trees[10]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[11]),
.o_index_leaf(o_index_leaf[11]),
.o_end_leafs(o_end_leafs[11]),
.o_end_trees(o_end_trees[11]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[12]),
.o_index_leaf(o_index_leaf[12]),
.o_end_leafs(o_end_leafs[12]),
.o_end_trees(o_end_trees[12]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[13]),
.o_index_leaf(o_index_leaf[13]),
.o_end_leafs(o_end_leafs[13]),
.o_end_trees(o_end_trees[13]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[14]),
.o_index_leaf(o_index_leaf[14]),
.o_end_leafs(o_end_leafs[14]),
.o_end_trees(o_end_trees[14]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[15]),
.o_index_leaf(o_index_leaf[15]),
.o_end_leafs(o_end_leafs[15]),
.o_end_trees(o_end_trees[15]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[16]),
.o_index_leaf(o_index_leaf[16]),
.o_end_leafs(o_end_leafs[16]),
.o_end_trees(o_end_trees[16]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[17]),
.o_index_leaf(o_index_leaf[17]),
.o_end_leafs(o_end_leafs[17]),
.o_end_trees(o_end_trees[17]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[18]),
.o_index_leaf(o_index_leaf[18]),
.o_end_leafs(o_end_leafs[18]),
.o_end_trees(o_end_trees[18]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[19]),
.o_index_leaf(o_index_leaf[19]),
.o_end_leafs(o_end_leafs[19]),
.o_end_trees(o_end_trees[19]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[20]),
.o_index_leaf(o_index_leaf[20]),
.o_end_leafs(o_end_leafs[20]),
.o_end_trees(o_end_trees[20]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[21]),
.o_index_leaf(o_index_leaf[21]),
.o_end_leafs(o_end_leafs[21]),
.o_end_trees(o_end_trees[21]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[22]),
.o_index_leaf(o_index_leaf[22]),
.o_end_leafs(o_end_leafs[22]),
.o_end_trees(o_end_trees[22]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[23]),
.o_index_leaf(o_index_leaf[23]),
.o_end_leafs(o_end_leafs[23]),
.o_end_trees(o_end_trees[23]),
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
.reset(reset_database),
.enable(load_second_stage),
.o_index_tree(o_index_tree[24]),
.o_index_leaf(o_index_leaf[24]),
.o_end_leafs(o_end_leafs[24]),
.o_end_trees(o_end_trees[24]),
.o_end_database(o_end_database[24]),
.o_data(o_data[24])
);

endmodule