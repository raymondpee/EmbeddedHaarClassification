`timescale 1 ns / 1 ns
module test_v_second_phase_haar_cascade;

localparam ADDR_WIDTH = 12;
localparam DATA_WIDTH_8 = 8;   // Max value 255
localparam DATA_WIDTH_12 = 12; // Max value 4095
localparam DATA_WIDTH_16 = 16; // Max value 177777
localparam NUM_PARAM_PER_CLASSIFIER= 19;
localparam NUM_STAGE_THRESHOLD = 3;

localparam NUM_CLASSIFIERS_STAGE_1 = 9;
localparam NUM_CLASSIFIERS_STAGE_2 = 16;
localparam NUM_CLASSIFIERS_STAGE_3 = 27;

localparam NUM_CLASSIFIERS_STAGE4 = 32;
localparam NUM_CLASSIFIERS_STAGE5 = 52;
localparam NUM_CLASSIFIERS_STAGE6 = 53;
localparam NUM_CLASSIFIERS_STAGE7 = 62;
localparam NUM_CLASSIFIERS_STAGE8 = 72;
localparam NUM_CLASSIFIERS_STAGE9 = 83;
localparam NUM_CLASSIFIERS_STAGE10 = 91;
localparam NUM_CLASSIFIERS_STAGE11 = 99;

localparam FILE_STAGE_1 = "Ram0.mif";
localparam FILE_STAGE_2 = "Ram1.mif";
localparam FILE_STAGE_3 = "Ram2.mif";

localparam FILE_STAGE4 = "Ram3.mif";
localparam FILE_STAGE5 = "Ram4.mif";
localparam FILE_STAGE6 = "Ram5.mif";
localparam FILE_STAGE7 = "Ram6.mif";
localparam FILE_STAGE8 = "Ram7.mif";
localparam FILE_STAGE9 = "Ram8.mif";
localparam FILE_STAGE10 = "Ram9.mif";
localparam FILE_STAGE11 = "Ram10.mif";
localparam NUM_STAGES = 8;


reg clk;
reg reset;
reg rden;

/*--------------------------- INITIAL STATEMENT ---------------------------*/
initial
begin
  clk = 0;
  rden = 0;
  #1 reset =1;
  #1 reset = 0;
  #1 rden = 1;
end
/*-----------------------------------------------------------------------*/


/*--------------------------- SEQUENTIAL LOGIC ---------------------------*/
// Clock:
always # 1 clk <= ~clk;

wire ready;
wire [NUM_STAGES-1:0] end_count_database_index;
wire [NUM_STAGES-1:0] end_count_tree_index;
wire [NUM_STAGES-1:0] end_count_classifier_index;
wire [ADDR_WIDTH-1:0] tree_index[NUM_STAGES-1:0];
wire [ADDR_WIDTH-1:0] classifier_index[NUM_STAGES-1:0];
wire [ADDR_WIDTH-1:0] database_index[NUM_STAGES-1:0];
wire [DATA_WIDTH_12-1:0] data_database[NUM_STAGES-1:0]; 

v_second_phase_haar_cascade
#(
.NUM_STAGES(NUM_STAGES),
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.FILE_STAGE4(FILE_STAGE4), 
.FILE_STAGE5(FILE_STAGE5), 
.FILE_STAGE6(FILE_STAGE6), 
.FILE_STAGE7(FILE_STAGE7), 
.FILE_STAGE8(FILE_STAGE8), 
.FILE_STAGE9(FILE_STAGE9), 
.FILE_STAGE10(FILE_STAGE10), 
.FILE_STAGE11(FILE_STAGE11), 
.NUM_CLASSIFIERS_STAGE4(NUM_CLASSIFIERS_STAGE4), 
.NUM_CLASSIFIERS_STAGE5(NUM_CLASSIFIERS_STAGE5), 
.NUM_CLASSIFIERS_STAGE6(NUM_CLASSIFIERS_STAGE6), 
.NUM_CLASSIFIERS_STAGE7(NUM_CLASSIFIERS_STAGE7), 
.NUM_CLASSIFIERS_STAGE8(NUM_CLASSIFIERS_STAGE8), 
.NUM_CLASSIFIERS_STAGE9(NUM_CLASSIFIERS_STAGE9), 
.NUM_CLASSIFIERS_STAGE10(NUM_CLASSIFIERS_STAGE10), 
.NUM_CLASSIFIERS_STAGE11(NUM_CLASSIFIERS_STAGE11) 
)
v_second_phase_haar_cascade
(
.clk_fpga(clk),
.reset_fpga(reset),
.i_rden(rden),
.o_tree_index(tree_index),
.o_classifier_index(classifier_index),
.o_database_index(database_index),
.o_data_database(data_database),	
.o_end_count_classifier_index(end_count_classifier_index),
.o_end_count_tree_index(end_count_tree_index),
.o_end_count_database_index(end_count_database_index)
);

endmodule