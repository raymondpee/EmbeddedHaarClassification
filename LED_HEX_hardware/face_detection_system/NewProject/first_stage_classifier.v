module first_stage_classifier
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH = 8,
parameter NUM_PARAM_PER_CLASSIFIER = 18,
parameter NUM_CLASSIFIERS_PER_STAGE = 50,
parameter NUM_FIRST_CLASSIFIER_STAGES = 3
)
(
	clk_fpga,
	reset_fpga,
	memory_first_stage_classifier,
	num_classifiers_for_each_stage,
	stage_thresholds,
	o_iscandidate
);
/*--------------------IO port declaration---------------------------------*/
input clk_fpga;
input reset_fpga;
input [DATA_WIDTH-1:0] memory_first_stage_classifier [NUM_FIRST_CLASSIFIER_STAGES*NUM_CLASSIFIERS_PER_STAGE*NUM_PARAM_PER_CLASSIFIER -1:0];
input [DATA_WIDTH-1:0] num_classifiers_for_each_stage [NUM_FIRST_CLASSIFIER_STAGES -1:0];
input [DATA_WIDTH-1:0] stage_thresholds [NUM_FIRST_CLASSIFIER_STAGES -1:0];
output o_iscandidate;
/*-----------------------------------------------------------------------*/

generate
	genvar index_stage;
	for(index_stage = 0; index_stage<NUM_FIRST_CLASSIFIER_STAGES; index_stage = index_stage +1)
	begin
		genvar index_reduction;
		genvar index_classifier;
		wire [DATA_WIDTH-1:0] stage_num;
		wire [DATA_WIDTH-1:0] reduction_haar_value[NUM_CLASSIFIERS_PER_STAGE-1:0];
		wire [DATA_WIDTH-1:0] final_haar_value;
		reg  [DATA_WIDTH-1:0] haar_value[NUM_CLASSIFIERS_PER_STAGE-1:0];
		assign reduction_haar_value[0] = haar_value[0];
		for(index_reduction = 1; index_reduction<NUM_CLASSIFIERS_PER_STAGE; index_reduction = index_reduction +1)
		begin
			assign reduction_haar_value[index_reduction] =  reduction_haar_value[index_reduction-1] + haar_value[index_reduction];
		end
		
		assign stage_num = num_classifiers_for_each_stage[index_stage];
		assign final_haar_value = reduction_haar_value[stage_num];
		assign o_iscandidate = final_haar_value>stage_thresholds[index_stage];
		
		for(index_classifier = 0; index_classifier<NUM_CLASSIFIERS_PER_STAGE; index_classifier = index_classifier +1)
		begin
		classifier
		#(
		.DATA_WIDTH(DATA_WIDTH)
		)
		classifier
		(
			.clk(clk_fpga),	
			.rect_A_1(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE) +(index_classifier*NUM_PARAM_PER_CLASSIFIER+0)]),
			.rect_B_1(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+1)]),
			.rect_C_1(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+2)]),
			.rect_D_1(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+3)]),
			.weight_1(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+4)]),
			.rect_A_2(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+5)]),
			.rect_B_2(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+6)]),
			.rect_C_2(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+7)]),
			.rect_D_2(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+8)]),
			.weight_2(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+9)]),
			.rect_A_3(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+10)]),
			.rect_B_3(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+11)]),
			.rect_C_3(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+12)]),
			.rect_D_3(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+13)]),
			.weight_3(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+14)]),
			.threshold(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+15)]),
			.left_word(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+16)]),
			.right_word(memory_first_stage_classifier[(index_stage*NUM_CLASSIFIERS_PER_STAGE)+(index_classifier*NUM_PARAM_PER_CLASSIFIER+17)]),
			.o_haarvalue(haar_value[index_classifier])
		);
		end
	end
endgenerate


endmodule