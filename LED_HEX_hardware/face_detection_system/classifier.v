module classifier
#(
	parameter DATA_WIDTH_8 = 8,   // Max value 255
	parameter DATA_WIDTH_12 = 12, // Max value 4095
	parameter DATA_WIDTH_16 = 16 // Max value 177777
)
(
	input clk,	
	input [DATA_WIDTH_8-1:0] rect_A_1,
	input [DATA_WIDTH_8-1:0] rect_B_1,
	input [DATA_WIDTH_8-1:0] rect_C_1,
	input [DATA_WIDTH_8-1:0] rect_D_1,
	input [DATA_WIDTH_8-1:0] weight_1,
	input [DATA_WIDTH_8-1:0] rect_A_2,
	input [DATA_WIDTH_8-1:0] rect_B_2,
	input [DATA_WIDTH_8-1:0] rect_C_2,
	input [DATA_WIDTH_8-1:0] rect_D_2,
	input [DATA_WIDTH_8-1:0] weight_2,
	input [DATA_WIDTH_8-1:0] rect_A_3,
	input [DATA_WIDTH_8-1:0] rect_B_3,
	input [DATA_WIDTH_8-1:0] rect_C_3,
	input [DATA_WIDTH_8-1:0] rect_D_3,
	input [DATA_WIDTH_8-1:0] weight_3,
	input [DATA_WIDTH_8-1:0] threshold,
	input [DATA_WIDTH_8-1:0] left_word,
	input [DATA_WIDTH_8-1:0] right_word,
	output [DATA_WIDTH_12-1:0] o_haarvalue
);

/*--- Rect for block 1 -----*/
wire [DATA_WIDTH_8-1:0] rect_minus_A_1;
wire [DATA_WIDTH_8-1:0] rect_minus_B_1;
wire [DATA_WIDTH_12-1:0] rect_1;
/*--- Rect for block 2 -----*/
wire [DATA_WIDTH_8-1:0] rect_minus_A_2;
wire [DATA_WIDTH_8-1:0] rect_minus_B_2;
wire [DATA_WIDTH_12-1:0] rect_2;
/*--- Rect for block 3 -----*/
wire [DATA_WIDTH_8-1:0] rect_minus_A_3;
wire [DATA_WIDTH_8-1:0] rect_minus_B_3;
wire [DATA_WIDTH_12-1:0] rect_3;

wire [DATA_WIDTH_12-1:0] rect_1_3;
wire [DATA_WIDTH_12-1:0] value;
wire [DATA_WIDTH_12-1:0] haarvalue;

//rect 1
assign rect_minus_A_1 = rect_A_1 - rect_B_1;
assign rect_minus_B_1 = rect_C_1 - rect_D_1;
assign rect_1 = weight1*(rect_minus_A_1 + rect_minus_B_1);
	
//rect 2
assign rect_minus_A_2 = rect_A_2 - rect_B_2;
assign rect_minus_B_2 = rect_C_2 - rect_D_2;
assign rect_2 = weight2*(rect_minus_A_2 + rect_minus_B_2);
	
//rect 3
assign rect_minus_A_3 = rect_A_3 - rect_B_3;
assign rect_minus_B_3 = rect_C_3 - rect_D_3;
assign rect_3 = weight3*(rect_minus_A_3 + rect_minus_B_3);

//value
assign value = (rect_1 + rect_3) - rect_2;
assign haarvalue =(value > threshold)? right_word:left_word;
assign o_haarvalue = haarvalue;


endmodule