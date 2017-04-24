module fifo_stage_classifier
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16
)
(
clk_fpga,
reset_fpga,
end_database,
end_tree,
end_single_classifier,
end_all_classifier,
index_tree,
index_classifier,
index_database,
data,
stage_threshold,
o_candidate
);

input clk_fpga;
input reset_fpga;
input end_database;
input end_tree;
input end_single_classifier;
input end_all_classifier,
input index_tree;
input index_classifier;
input index_database;
input data;
input stage_threshold;
output o_candidate;


w_index_stage_threshold;
reg r_index_tree;
reg candidate;
reg [DATA_WIDTH_12-1:0]sum_haar;
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
reg [DATA_WIDTH_12-1:0] haar[NUM_CLASSIFIERS-1:0];

integer k_haar;

// Delay based on clock cycle
always@(posedge clk_fpga)
begin
	r_index_tree = index_tree;
end

always@(posedge clk_fpga)
begin
	if(r_end_classifier)
	begin
		if(w_end_stage_threshold == 0)
		begin
			case(w_index_stage_threshold)
			0:r_stage_threshold<= r_data;
			1:r_parent<= r_data;
			2:r_next<= r_data;
			endcase
		end
	end
end


always@(clk_fpga)
begin
	if(reset_fpga)
	begin
		r_index_tree<=0;
		candidate<=0;
		sum_haar<=0;
		rect_A_1_index<=0;
		rect_B_1_index<=0;
		rect_C_1_index<=0;
		rect_D_1_index<=0;
		weight_1<=0;
		rect_A_2_index<=0;
		rect_B_2_index<=0;
		rect_C_2_index<=0;
		rect_D_2_index<=0;
		weight_2<=0;
		rect_A_3_index<=0;
		rect_B_3_index<=0;
		rect_C_3_index<=0;
		rect_D_3_index<=0;
		weight_3<=0;
		threshold_index<=0;
		left_word_index<=0;
		right_word_index<=0;
		for(k_haar = 0; k_haar<NUM_CLASSIFIERS; k_haar= k_haar+1)
		begin
			haar[k_haar]<= 0;
		end
	end
	else
	begin
		if(end_all_classifier == 0)
		begin
			case(index_classifier)
				0:	rect_A_1_index <= data;
				1:	rect_B_1_index <= data;
				2:	rect_C_1_index <= data;
				3:	rect_D_1_index <= data;
				4:	weight_1 <= data;
				5:	rect_A_2_index <= data;
				6:	rect_B_2_index <= data;
				7:	rect_C_2_index <= data;
				8:	rect_D_2_index <= data;
				9:	weight_2 <= data;
				10:	rect_A_3_index <= data;
				11:	rect_B_3_index <= data;
				12:	rect_C_3_index <= data;
				13:	rect_D_3_index <= data;
				14:	weight_3 <= data;
				15:	threshold_index <= data;
				16:	left_word_index <= data;
				17:	right_word_index <= data;
			endcase
		end
		else
		begin
			
		end
	end
end

integer k;
always@(posedge end_single_classifier)
begin
	for(k =0; k< NUM_CLASSIFIERS; k++)
	begin
		sum_haar = sum_haar + haar[index_tree];  
	end
end

assign o_candidate = candidate;
always@(posedge end_database)
begin
	candidate = final_haar>stage_threshold;
end

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_stage_threshold
(
.clk(clk_fpga),
.reset(reset_counter_stage_threshold),
.enable(r_count_stage_threshold),
.ctr_out(w_index_stage_threshold),
.max_size(NUM_STAGE_THRESHOLD-1),
.end_count(w_end_stage_threshold)
);

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
.o_haarvalue(haar[r_index_tree])
);


endmodule