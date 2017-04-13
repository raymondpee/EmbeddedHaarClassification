module fifo_stage_classifier
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter NUM_PARAM_PER_CLASSIFIER = 18,
parameter CLASSIFIER_SIZE,
parameter MEMORY_FILE =  "memory.mif"
)
(
	clk_fpga,
	reset_fpga,
	enable,
	integral_image
);

/*--------------------IO port declaration---------------------------------*/
input clk_fpga;
input reset_fpga;
input [DATA_WIDTH_12-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
/*-----------------------------------------------------------------------*/

wire end_count_stage;
wire end_count_classifier;
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
wire [DATA_WIDTH_12-1:0] w_haar_value; 

reg enable_stage;
reg enable_classifier;
reg [DATA_WIDTH_12-1:0] haar_value[CLASSIFIER_SIZE-1:0];
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


always@(posedge clk_fpga)
begin
	if(enable)
	begin
		enable_stage<=1;
		enable_classifier<=1;
	end
end


always@(posedge clk_fpga)
begin
	if(end_count_classifier)
	begin
		enable_stage <= 1;
		enable_classifier<=0;
		haar_value[address_stage]<= w_haar_value;
	end
	else
	begin
		enable_stage <= 0;
		enable_classifier<=1;
		classifier_property[address_classifier] <= q;
	end
end

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
.ADDR_WIDTH(ADDR_WIDTH)
)
counter_stage
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(enable_stage),
.ctr_out(address_stage),
.max_size(CLASSIFIER_SIZE),
.end_count(end_count_stage)
);

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
.ADDR_WIDTH(ADDR_WIDTH)
)
counter_classifier
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(enable_classifier),
.ctr_out(address_classifier),
.max_size(NUM_PARAM_PER_CLASSIFIER),
.end_count(end_count_classifier)
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
.o_haarvalue(w_haar_value)
);



endmodule