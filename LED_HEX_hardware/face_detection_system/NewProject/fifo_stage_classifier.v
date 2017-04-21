module fifo_stage_classifier
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16,
)
(
clk_fpga,
reset_fpga,
second_phase_end_database,
second_phase_end_tree,
second_phase_end_single_classifier,
second_phase_index_tree,
second_phase_index_classifier,
second_phase_index_database,
second_phase_data
);

wire [DATA_WIDTH_12-1:0]reduction_haar_value[NUM_CLASSIFIERS-1:0];

reg [DATA_WIDTH_8-1:0]rect_A_1_index;
reg [DATA_WIDTH_8-1:0]rect_B_1_index;
reg [DATA_WIDTH_8-1:0]rect_C_1_index;
reg [DATA_WIDTH_8-1:0]rect_D_1_index;
reg [DATA_WIDTH_8-1:0]weight_1;
reg [DATA_WIDTH_8-1:0]rect_A_2_index;
reg [DATA_WIDTH_8-1:0]rect_B_2_index;
reg [DATA_WIDTH_8-1:0]rect_C_2_index;
reg [DATA_WIDTH_8-1:0]rect_D_2_index;
reg [DATA_WIDTH_8-1:0]weight_2;
reg [DATA_WIDTH_8-1:0]rect_A_3_index;
reg [DATA_WIDTH_8-1:0]rect_B_3_index;
reg [DATA_WIDTH_8-1:0]rect_C_3_index;
reg [DATA_WIDTH_8-1:0]rect_D_3_index;
reg [DATA_WIDTH_8-1:0]weight_3;
reg [DATA_WIDTH_8-1:0]threshold_index;
reg [DATA_WIDTH_8-1:0]left_word_index;
reg [DATA_WIDTH_8-1:0]right_word_index;
reg [DATA_WIDTH_12-1:0] haar_value[NUM_CLASSIFIERS-1:0];

always@(clk_fpga)
begin
	case(second_phase_index_classifier)
	0:	rect_A_1_index <= second_phase_data;
	1:	rect_B_1_index <= second_phase_data;
	2:	rect_C_1_index <= second_phase_data;
	3:	rect_D_1_index <= second_phase_data;
	4:	weight_1 <= second_phase_data;
	5:	rect_A_2_index <= second_phase_data;
	6:	rect_B_2_index <= second_phase_data;
	7:	rect_C_2_index <= second_phase_data;
	8:	rect_D_2_index <= second_phase_data;
	9:	weight_2 <= second_phase_data;
	10:	rect_A_3_index <= second_phase_data;
	11:	rect_B_3_index <= second_phase_data;
	12:	rect_C_3_index <= second_phase_data;
	13:	rect_D_3_index <= second_phase_data;
	14:	weight_3 <= second_phase_data;
	15:	threshold_index <= second_phase_data;
	16:	left_word_index <= second_phase_data;
	17:	right_word_index <= second_phase_data;
	endcase
end

/*--------------------REDUCTION CALCULATION---------------------------------*/
assign reduction_haar_value[0] = haar_value[0];
for(index_reduction = 1; index_reduction<NUM_CLASSIFIERS; index_reduction = index_reduction +1)
begin
	assign reduction_haar_value[index_reduction] =  reduction_haar_value[index_reduction-1] + haar_value[index_reduction];
end
/*-------------------------------------------------------------------------*/
assign final_haar_value = reduction_haar_value[NUM_CLASSIFIERS-1];
assign stage_threshold = rom_stage[NUM_CLASSIFIERS*NUM_PARAM_PER_CLASSIFIER + NUM_STAGE_THRESHOLD];
assign candidate = final_haar_value>stage_threshold;


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
.rect_D_3(integral_image[rect_D_3_index]),
.weight_3(weight_3),
.threshold(threshold),
.left_word(left_word),
.right_word(right_word),
.o_haarvalue(haar_value[index_classifier])
);


endmodule