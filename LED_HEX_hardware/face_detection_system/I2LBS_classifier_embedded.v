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
parameter FIRST_STAGE_MEM_SIZE = 100
)
(
clk,
reset,
enable,
integral_image,
database
);

localparam NUM_STAGES = 3;
localparam NUM_CLASSIFIER = NUM_CLASSIFIERS_STAGE_1* NUM_CLASSIFIERS_STAGE_2* NUM_CLASSIFIERS_STAGE_3;

input [DATA_WIDTH_16-1:0] 	integral_image	[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0]; 
input [DATA_WIDTH_16-1:0] 	database		[FIRST_STAGE_MEM_SIZE-1:0];


wire [DATA_WIDTH_16-1:0] threshold 		[NUM_STAGES-1:0];
wire [DATA_WIDTH_16-1:0] left_value 	[NUM_STAGES-1:0];
wire [DATA_WIDTH_16-1:0] right_value 	[NUM_STAGES-1:0];


reg [DATA_WIDTH_16-1:0] leafs [NUM_CLASSIFIER -1:0];

assign threshold[index] = database[];
assign left_value[index] = database[];
assign right_value[index] = database[];

always@(posedge clk)
begin
	if(reset)
	

end

endmodule