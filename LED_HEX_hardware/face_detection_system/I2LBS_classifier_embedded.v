module I2LBS_classifier_embedded
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16,
parameter NUM_STAGE = 10,
parameter INTEGRAL_WIDTH = 10,
parameter INTEGRAL_HEIGHT = 10,
parameter NUM_CLASSIFIERS_STAGE_1 = 9,
parameter NUM_CLASSIFIERS_STAGE_2 = 16,
parameter NUM_CLASSIFIERS_STAGE_3 = 27,
parameter SIZE_DATABASE_EMBEDDED = 100,
parameter NUM_PARAM_PER_CLASSIFIER = 18
)
(
clk,
reset,
enable,
integral_image,
database_stage_1,
database_stage_2,
database_stage_3,
o_pass
);

localparam NUM_STAGES 					= 3;
/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

input 						clk;
input 						enable;
input 						reset;
input [DATA_WIDTH_16-1:0] 	integral_image	[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0]; 
input [DATA_WIDTH_16-1:0] 	database_stage_1 [NUM_CLASSIFIERS_STAGE_1-1:0];
input [DATA_WIDTH_16-1:0] 	database_stage_2 [NUM_CLASSIFIERS_STAGE_2-1:0];
input [DATA_WIDTH_16-1:0] 	database_stage_3 [NUM_CLASSIFIERS_STAGE_3-1:0];
output 						o_pass;

/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/

wire 	pass_stage_1;
wire 	pass_stage_2;
wire 	pass_stage_3;
 
wire 	[DATA_WIDTH_16-1:0] sum_haar_1;
wire 	[DATA_WIDTH_16-1:0] sum_haar_2;
wire 	[DATA_WIDTH_16-1:0] sum_haar_3;

wire	[DATA_WIDTH_16-1:0] stage_threshold_stage_1;
wire	[DATA_WIDTH_16-1:0] stage_threshold_stage_2;
wire	[DATA_WIDTH_16-1:0] stage_threshold_stage_3;

	
wire	[DATA_WIDTH_16-1:0] cumulative_haar_stage_1 [NUM_CLASSIFIERS_STAGE_1 -1:0];
wire	[DATA_WIDTH_16-1:0] cumulative_haar_stage_2 [NUM_CLASSIFIERS_STAGE_2 -1:0];
wire	[DATA_WIDTH_16-1:0] cumulative_haar_stage_3 [NUM_CLASSIFIERS_STAGE_3 -1:0];	



reg 	[DATA_WIDTH_16-1:0] haar_stage_1 [NUM_CLASSIFIERS_STAGE_1 -1:0];
reg 	[DATA_WIDTH_16-1:0] haar_stage_2 [NUM_CLASSIFIERS_STAGE_1 -1:0];
reg 	[DATA_WIDTH_16-1:0] haar_stage_3 [NUM_CLASSIFIERS_STAGE_1 -1:0];


/*****************************************************************************
*                            Combinational logic                             *
*****************************************************************************/

assign sum_haar_1 = cumulative_haar_stage_1[NUM_CLASSIFIERS_STAGE_1-1]; 
assign sum_haar_2 = cumulative_haar_stage_2[NUM_CLASSIFIERS_STAGE_2-1];
assign sum_haar_3 = cumulative_haar_stage_3[NUM_CLASSIFIERS_STAGE_3-1];

assign stage_threshold_stage_1 = database_stage_1[NUM_CLASSIFIERS_STAGE_1];
assign stage_threshold_stage_2 = database_stage_2[NUM_CLASSIFIERS_STAGE_2];
assign stage_threshold_stage_3 = database_stage_3[NUM_CLASSIFIERS_STAGE_3];

assign pass_stage_1 = sum_haar_1 > stage_threshold_stage_1;
assign pass_stage_2 = sum_haar_2 > stage_threshold_stage_2;
assign pass_stage_3 = sum_haar_3 > stage_threshold_stage_3;

assign pass 	= pass_stage_1 && pass_stage_2 && pass_stage_3;
assign o_pass 	= pass;


generate
	genvar index_haar_stage_1;
	assign cumulative_haar_stage_1[0] =  haar_stage_1[0];	
	for(index_haar_stage_1 = 1; index_haar_stage_1<NUM_CLASSIFIERS_STAGE_1; index_haar_stage_1 = index_haar_stage_1 +1)
	begin
		assign cumulative_haar_stage_1[index_haar_stage_1] = cumulative_haar_stage_1[index_haar_stage_1-1] + haar_stage_1[index_haar_stage_1];
	end

	genvar index_haar_stage_2;
	assign cumulative_haar_stage_2[0] =  haar_stage_2[0];	
	for(index_haar_stage_2 = 1; index_haar_stage_2<NUM_CLASSIFIERS_STAGE_2; index_haar_stage_2 = index_haar_stage_2 +1)
	begin
		assign cumulative_haar_stage_2[index_haar_stage_2] = cumulative_haar_stage_2[index_haar_stage_2-1] + haar_stage_2[index_haar_stage_2];
	end
	
	
	genvar index_haar_stage_3;
	assign cumulative_haar_stage_3[0] =  haar_stage_3[0];	
	for(index_haar_stage_3 = 1; index_haar_stage_3<NUM_CLASSIFIERS_STAGE_3; index_haar_stage_3 = index_haar_stage_3 +1)
	begin
		assign cumulative_haar_stage_3[index_haar_stage_3] = cumulative_haar_stage_3[index_haar_stage_3-1] + haar_stage_3[index_haar_stage_3];
	end
	
endgenerate


/*****************************************************************************
*                                   Modules                                  *
*****************************************************************************/ 
generate	
	genvar index_leaf_stage_1;
	for(index_leaf_stage_1 = 0; index_leaf_stage_1<NUM_CLASSIFIERS_STAGE_1; index_leaf_stage_1 = index_leaf_stage_1 +1)
	begin 
		classifier_embedded
		#(
		.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
		.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
		)
		classifier_embedded
		(
		.clk(clk),
		.reset(reset),
		.calculate(calculate),
		.integral_image(integral_image),
		.rect_A_1_index(database_stage_1[index_leaf_stage_1 + 0]),
		.rect_B_1_index(database_stage_1[index_leaf_stage_1 + 1]),
		.rect_C_1_index(database_stage_1[index_leaf_stage_1 + 2]),
		.rect_D_1_index(database_stage_1[index_leaf_stage_1 + 3]),
		.weight_1(database_stage_1[index_leaf_stage_1 + 4]),
		.rect_A_2_index(database_stage_1[index_leaf_stage_1 + 5]),
		.rect_B_2_index(database_stage_1[index_leaf_stage_1 + 6]),
		.rect_C_2_index(database_stage_1[index_leaf_stage_1 + 7]),
		.rect_D_2_index(database_stage_1[index_leaf_stage_1 + 8]),
		.weight_2(database_stage_1[index_leaf_stage_1 + 9]),
		.rect_A_3_index(database_stage_1[index_leaf_stage_1 + 10]),
		.rect_B_3_index(database_stage_1[index_leaf_stage_1 + 11]),
		.rect_C_3_index(database_stage_1[index_leaf_stage_1 + 12]),
		.rect_D_3_index(database_stage_1[index_leaf_stage_1 + 13]),
		.weight_3(database_stage_1[index_leaf_stage_1 + 14]),
		.threshold(database_stage_1[index_leaf_stage_1 + 16]),
		.left_value(database_stage_1[index_leaf_stage_1 + 17]),
		.right_value(database_stage_1[index_leaf_stage_1 + 18]),
		.o_haar(haar_stage_1[index_leaf_stage_1])
		);
	end


	genvar index_leaf_stage_2;
	for(index_leaf_stage_2 = 0; index_leaf_stage_2<NUM_CLASSIFIERS_STAGE_2; index_leaf_stage_2 = index_leaf_stage_2 +1)
	begin
		classifier_embedded
		#(
		.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
		.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
		)
		classifier_embedded
		(
		.clk(clk),
		.reset(reset),
		.calculate(calculate),
		.integral_image(integral_image),
		.rect_A_1_index(database_stage_2[index_leaf_stage_2 + 0]),
		.rect_B_1_index(database_stage_2[index_leaf_stage_2 + 1]),
		.rect_C_1_index(database_stage_2[index_leaf_stage_2 + 2]),
		.rect_D_1_index(database_stage_2[index_leaf_stage_2 + 3]),
		.weight_1(database_stage_2[index_leaf_stage_2 + 4]),
		.rect_A_2_index(database_stage_2[index_leaf_stage_2 + 5]),
		.rect_B_2_index(database_stage_2[index_leaf_stage_2 + 6]),
		.rect_C_2_index(database_stage_2[index_leaf_stage_2 + 7]),
		.rect_D_2_index(database_stage_2[index_leaf_stage_2 + 8]),
		.weight_2(database_stage_2[index_leaf_stage_2 + 9]),
		.rect_A_3_index(database_stage_2[index_leaf_stage_2 + 10]),
		.rect_B_3_index(database_stage_2[index_leaf_stage_2 + 11]),
		.rect_C_3_index(database_stage_2[index_leaf_stage_2 + 12]),
		.rect_D_3_index(database_stage_2[index_leaf_stage_2 + 13]),
		.weight_3(database_stage_2[index_leaf_stage_2 + 14]),
		.threshold(database_stage_2[index_leaf_stage_2 + 16]),
		.left_value(database_stage_2[index_leaf_stage_2 + 17]),
		.right_value(database_stage_2[index_leaf_stage_2 + 18]),
		.o_haar(haar_stage_2[index_leaf_stage_2])
		);
	end

	genvar index_leaf_stage_3;
	for(index_leaf_stage_3 = 0; index_leaf_stage_3<NUM_CLASSIFIERS_STAGE_3; index_leaf_stage_3 = index_leaf_stage_3 +1)
	begin
		classifier_embedded
		#(
		.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
		.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
		)
		classifier_embedded
		(
		.clk(clk),
		.reset(reset),
		.calculate(calculate),
		.integral_image(integral_image),
		.rect_A_1_index(database_stage_3[index_leaf_stage_3 + 0]),
		.rect_B_1_index(database_stage_3[index_leaf_stage_3 + 1]),
		.rect_C_1_index(database_stage_3[index_leaf_stage_3 + 2]),
		.rect_D_1_index(database_stage_3[index_leaf_stage_3 + 3]),
		.weight_1(database_stage_3[index_leaf_stage_3 + 4]),
		.rect_A_2_index(database_stage_3[index_leaf_stage_3 + 5]),
		.rect_B_2_index(database_stage_3[index_leaf_stage_3 + 6]),
		.rect_C_2_index(database_stage_3[index_leaf_stage_3 + 7]),
		.rect_D_2_index(database_stage_3[index_leaf_stage_3 + 8]),
		.weight_2(database_stage_3[index_leaf_stage_3 + 9]),
		.rect_A_3_index(database_stage_3[index_leaf_stage_3 + 10]),
		.rect_B_3_index(database_stage_3[index_leaf_stage_3 + 11]),
		.rect_C_3_index(database_stage_3[index_leaf_stage_3 + 12]),
		.rect_D_3_index(database_stage_3[index_leaf_stage_3 + 13]),
		.weight_3(database_stage_3[index_leaf_stage_3 + 14]),
		.threshold(database_stage_3[index_leaf_stage_3 + 16]),
		.left_value(database_stage_3[index_leaf_stage_3 + 17]),
		.right_value(database_stage_3[index_leaf_stage_3 + 18]),
		.o_haar(haar_stage_3[index_leaf_stage_3])
		);
	end
endgenerate

endmodule