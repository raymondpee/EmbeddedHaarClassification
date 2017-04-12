module fifo_stage_classifier
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter NUM_PARAM_PER_CLASSIFIER = 18,
parameter MEMORY_FILE =  "memory.mif"
)
(
	clk_fpga,
	reset_fpga,
	trigger_compare_stage,
	classifier_size,
	integral_image,
	o_is_end_of_stage
);

/*--------------------IO port declaration---------------------------------*/
input clk_fpga;
input reset_fpga;
input trigger_compare_stage;
input classifier_size;
input [DATA_WIDTH_12-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
output o_is_candidate;
/*-----------------------------------------------------------------------*/

wire is_end_of_classifier;
wire is_end_of_stage;
wire [DATA_WIDTH_12-1:0] address_stage;
wire [DATA_WIDTH_12-1:0] address_classifier;
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
wire [DATA_WIDTH_8-1:0]q;

reg [DATA_WIDTH_12-1:0] haar_value[classifier_size-1:0];
reg	[DATA_WIDTH_8-1:0] stage_index;
reg [DATA_WIDTH_8-1:0] classifier_property[NUM_PARAM_PER_CLASSIFIER-1:0];

assign rect_A_1_index = classifier_property[0];
assign rect_B_1_index = classifier_property[1];
assign rect_C_1_index = classifier_property[2];
assign rect_D_1_index = classifier_property[3];
assign weight_1 = classifier_property[4];
assign rect_A_2_index = classifier_property[5];
assign rect_B_2_index = classifier_property[6];
assign rect_C_2_index = classifier_property[7];
assign rect_D_2_index = classifier_property[8];
assign weight_2 = classifier_property[9];
assign rect_A_3_index = classifier_property[10];
assign rect_B_3_index = classifier_property[11];
assign rect_C_3_index = classifier_property[12];
assign rect_D_3_index = classifier_property[13];
assign weight_3 = classifier_property[14];
assign threshold = classifier_property[15];
assign left_word = classifier_property[16];
assign right_word = classifier_property[17];
assign o_is_end_of_stage = is_end_of_stage;

always@(posedge clk_fpga)
begin
	classifier_property[address_classifier] <= q;
end

always@(posedge clk_fpga)
begin
	if(is_end_of_stage)
		stage_index<=0;		
	else
		if(is_end_of_classifier)
			stage_index<= stage_index +1;
		else
			stage_index<= stage_index;
end

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
.ADDR_WIDTH(ADDR_WIDTH)
)
counter_overall_in_stage
(
.clk(clk_fpga),
.reset(reset_fpga),
.trigger_compare(trigger_compare_stage),
.o_address(address_stage),
.max_size(classifier_size),
.o_is_end_reached(is_end_of_stage)
);

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
.ADDR_WIDTH(ADDR_WIDTH)
)
counter_each_classifier
(
.clk(clk_fpga),
.reset(reset_fpga),
.trigger_compare(trigger_compare),
.o_address(address_classifier),
.max_size(NUM_PARAM_PER_CLASSIFIER),
.o_is_end_reached(is_end_of_classifier)
);


rom 
#(
.ADDR_WIDTH(ADDR_WIDTH), 
.DATA_WIDTH(DATA_WIDTH_8),
.MEMORY_FILE(MEMORY_FILE)
)
rom_stage
(
.clock(clk_fpga),
.address(address_stage),
.q(q)
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
.o_haarvalue(haar_value)
);



endmodule