module stage_classifier
#(
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter NUM_PARAM_PER_CLASSIFIER = 18,
parameter NUM_STAGE_THRESHOLD = 1,
parameter NUM_CLASSIFIERS = 10
)
(
	clk_fpga,
	integral_image,
	rom_stage_classifier,
	o_iscandidate
);

	/*--------------------IO port declaration---------------------------------*/
	input clk_fpga;
	input [DATA_WIDTH_8-1:0] rom_stage_classifier [NUM_CLASSIFIERS*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
	input [DATA_WIDTH_12-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
	output o_iscandidate;
	/*-----------------------------------------------------------------------*/
	
	wire [DATA_WIDTH_12-1:0]reduction_haar_value[NUM_CLASSIFIERS-1:0];
	wire [DATA_WIDTH_12-1:0]final_haar_value;
	wire [DATA_WIDTH_12-1:0]current_classifier_index;
	
	reg  [DATA_WIDTH_12-1:0] haar_value[NUM_CLASSIFIERS-1:0];
		
	assign final_haar_value = reduction_haar_value[NUM_CLASSIFIERS-1];
	assign stage_threshold = rom_stage_classifier[NUM_CLASSIFIERS*NUM_PARAM_PER_CLASSIFIER + NUM_STAGE_THRESHOLD];
	assign o_iscandidate = final_haar_value>stage_threshold;	
		
		
	/*--------------------REDUCTION CALCULATION---------------------------------*/
	assign reduction_haar_value[0] = haar_value[0];
	for(index_reduction = 1; index_reduction<NUM_CLASSIFIERS; index_reduction = index_reduction +1)
	begin
		assign reduction_haar_value[index_reduction] =  reduction_haar_value[index_reduction-1] + haar_value[index_reduction];
	end
	/*-------------------------------------------------------------------------*/
	

	/*-----------------------STAGE CLASSIFIER----------------------------------*/
	for(index_classifier = 0; index_classifier<NUM_CLASSIFIERS; index_classifier = index_classifier +1)
	begin
	
		wire [DATA_WIDTH_8-1:0]stage_thresholds;
		wire [DATA_WIDTH_8-1:0]rect_A_1_index;
		wire [DATA_WIDTH_8-1:0]rect_B_1_index;
		wire [DATA_WIDTH_8-1:0]rect_C_1_index;
		wire [DATA_WIDTH_8-1:0]rect_D_1_index;
		wire [DATA_WIDTH_8-1:0]weight_1;
		wire [DATA_WIDTH_8-1:0]rect_A_2_index;
		wire [DATA_WIDTH_8-1:0]rect_B_2_index;
		wire [DATA_WIDTH_8-1:0]rect_C_2_index;
		wire [DATA_WIDTH_8-1:0]rect_D_2_index;
		wire [DATA_WIDTH_8-1:0]weight_2;
		wire [DATA_WIDTH_8-1:0]rect_A_3_index;
		wire [DATA_WIDTH_8-1:0]rect_B_3_index;
		wire [DATA_WIDTH_8-1:0]rect_C_3_index;
		wire [DATA_WIDTH_8-1:0]rect_D_3_index;
		wire [DATA_WIDTH_8-1:0]weight_3;
		wire [DATA_WIDTH_8-1:0]threshold_index;
		wire [DATA_WIDTH_8-1:0]left_word_index;
		wire [DATA_WIDTH_8-1:0]right_word_index;		
		
		
		
		/*---------------------------CLASSIFIER PARAM INPUTS ------------------------------*/
		assign current_classifier_index = index_classifier*NUM_PARAM_PER_CLASSIFIER;
		assign rect_A_1_index = rom_stage_classifier[current_classifier_index+0];
		assign rect_B_1_index = rom_stage_classifier[current_classifier_index+1];
		assign rect_C_1_index = rom_stage_classifier[current_classifier_index+2];
		assign rect_D_1_index = rom_stage_classifier[current_classifier_index+3];
		assign weight_1 = rom_stage_classifier[current_classifier_index+4];
		assign rect_A_2_index = rom_stage_classifier[current_classifier_index+5];
		assign rect_B_2_index = rom_stage_classifier[current_classifier_index+6];
		assign rect_C_2_index = rom_stage_classifier[current_classifier_index+7];
		assign rect_D_2_index = rom_stage_classifier[current_classifier_index+8];
		assign weight_2 = rom_stage_classifier[current_classifier_index+9];
		assign rect_A_3_index = rom_stage_classifier[current_classifier_index+10];
		assign rect_B_3_index = rom_stage_classifier[current_classifier_index+11];
		assign rect_C_3_index = rom_stage_classifier[current_classifier_index+12];
		assign rect_D_3_index = rom_stage_classifier[current_classifier_index+13];
		assign weight_3 = rom_stage_classifier[current_classifier_index+14];
		assign threshold = rom_stage_classifier[current_classifier_index+15];
		assign left_word = rom_stage_classifier[current_classifier_index+16];
		assign right_word = rom_stage_classifier[current_classifier_index+17];	
		/*--------------------------------------------------------------------------------*/
			
		classifier
		#(
		.DATA_WIDTH_8(DATA_WIDTH_8),    // Max value 255
		.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
		.DATA_WIDTH_16(DATA_WIDTH_16) // Max value 177777
		)
		classifier
		(
			.clk(clk_fpga),	
			.rect_A_1(integral_image[rect_A_1_index]),
			.rect_B_1(integral_image[rect_B_1_index]),
			.rect_C_1(integral_image[rect_C_1_index]),
			.rect_D_1(integral_image[rect_D_1_index]),
			.weight_1(weight_1),
			.rect_A_2(integral_image[rect_A_2_index]),
			.rect_B_2(integral_image[rect_B_2_index]),
			.rect_C_2(integral_image[rect_C_2_index]),
			.rect_D_2(integral_image[rect_D_2_index]),
			.weight_2(weight_2),
			.rect_A_3(integral_image[rect_A_3_index]),
			.rect_B_3(integral_image[rect_B_3_index]),
			.rect_C_3(integral_image[rect_C_3_index]),
			.rect_D_3(memory_first_stage_classifier[current_classifier_index+13]),
			.weight_3(weight_3),
			.threshold(threshold),
			.left_word(left_word),
			.right_word(right_word),
			.o_haarvalue(haar_value[index_classifier])
		);
	end
	/*-------------------------------------------------------------------------*/
endmodule