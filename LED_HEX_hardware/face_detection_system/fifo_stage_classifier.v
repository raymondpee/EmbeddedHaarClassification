module fifo_stage_classifier
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16,
parameter NUM_CLASSIFIERS = 18,
parameter INTEGRAL_WIDTH = 10,
parameter INTEGRAL_HEIGHT = 10
)
(
clk_fpga,
reset_fpga,
en,
integral_image,
end_database,
end_tree,
end_single_classifier,
end_all_classifier,
index_tree,
index_classifier,
index_database,
data,
o_candidate
);

input clk_fpga;
input reset_fpga;
input en;
input end_database;
input end_tree;
input end_single_classifier;
input end_all_classifier;
input [DATA_WIDTH_12-1:0] index_tree;
input [DATA_WIDTH_12-1:0] index_classifier;
input [DATA_WIDTH_12-1:0] index_database;
input [DATA_WIDTH_12-1:0] data;
input [DATA_WIDTH_12-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
output o_candidate;

wire w_copy_data;
wire w_calculate;
wire w_index_stage_threshold;
wire [DATA_WIDTH_12-1:0] w_haar;

reg r_index_tree;
reg r_end_all_classifier;
reg candidate;
reg [DATA_WIDTH_12-1:0]sum_haar;
reg [DATA_WIDTH_12-1:0]rect_A_1_index;
reg [DATA_WIDTH_12-1:0]rect_B_1_index;
reg [DATA_WIDTH_12-1:0]rect_C_1_index;
reg [DATA_WIDTH_12-1:0]rect_D_1_index;
reg [DATA_WIDTH_12-1:0]weight_1;
reg [DATA_WIDTH_12-1:0]rect_A_2_index;
reg [DATA_WIDTH_12-1:0]rect_B_2_index;
reg [DATA_WIDTH_12-1:0]rect_C_2_index;
reg [DATA_WIDTH_12-1:0]rect_D_2_index;
reg [DATA_WIDTH_12-1:0]weight_2;
reg [DATA_WIDTH_12-1:0]rect_A_3_index;
reg [DATA_WIDTH_12-1:0]rect_B_3_index;
reg [DATA_WIDTH_12-1:0]rect_C_3_index;
reg [DATA_WIDTH_12-1:0]rect_D_3_index;
reg [DATA_WIDTH_12-1:0]weight_3;
reg [DATA_WIDTH_12-1:0]threshold;
reg [DATA_WIDTH_12-1:0]left_word;
reg [DATA_WIDTH_12-1:0]right_word;
reg [DATA_WIDTH_12-1:0]r_stage_threshold;
reg [DATA_WIDTH_12-1:0]r_parent;
reg [DATA_WIDTH_12-1:0]r_next;
reg [DATA_WIDTH_12-1:0] haar[NUM_CLASSIFIERS-1:0];

integer k_haar;

assign o_candidate = candidate;
assign w_copy_data = !(end_single_classifier || end_database)&& en;
assign w_calculate = !w_copy_data;

// Delay based on clock cycle
always@(posedge clk_fpga)
begin
	r_index_tree <= index_tree;
	r_end_all_classifier <= end_all_classifier;
end

always@(posedge clk_fpga)
begin
	if(r_end_all_classifier)
	begin
		case(w_index_stage_threshold)
		0:r_stage_threshold<= data;
		1:r_parent<= data;
		2:r_next<= data;
		endcase
	end
end

always@(posedge end_single_classifier)
begin
	haar[index_tree]= w_haar;
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
		threshold<=0;
		left_word<=0;
		right_word<=0;
		r_stage_threshold <=0;
		r_parent<=0;
		r_next<=0;
		for(k_haar = 0; k_haar<NUM_CLASSIFIERS; k_haar= k_haar+1)
		begin
			haar[k_haar]<= 0;
		end
	end
	else
	begin
		if(w_copy_data)
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
				15:	threshold <= data;
				16:	left_word <= data;
				17:	right_word <= data;
			endcase
		end
	end
end

integer k;
always@(posedge end_single_classifier)
begin
	if(en)
		begin
		for(k =0; k< NUM_CLASSIFIERS; k++)
		begin
			sum_haar = sum_haar + haar[index_tree];  
		end
	end
end

always@(posedge end_database)
begin
	candidate = sum_haar>r_stage_threshold;
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
.reset(reset_fpga),
.en(w_calculate),
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
.o_haarvalue(w_haar)
);


endmodule