module haar_classifier
#(
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH =8
)
(
	output [DATA_WIDTH-1:0] o_haarvalue,
	input clk,
	input [DATA_WIDTH-1:0] rect_A_1,
	input [DATA_WIDTH-1:0] rect_B_1,
	input [DATA_WIDTH-1:0] rect_C_1,
	input [DATA_WIDTH-1:0] rect_D_1,
	input [DATA_WIDTH-1:0] rect_A_1,
	input [DATA_WIDTH-1:0] rect_B_1,
	input [DATA_WIDTH-1:0] rect_C_1,
	input [DATA_WIDTH-1:0] rect_D_1,
	input [DATA_WIDTH-1:0] rect_A_1,
	input [DATA_WIDTH-1:0] rect_B_1,
	input [DATA_WIDTH-1:0] rect_C_1,
	input [DATA_WIDTH-1:0] rect_D_1,
	input [DATA_WIDTH-1:0] threshold,
	input [DATA_WIDTH-1:0] left_word,
	input [DATA_WIDTH-1:0] right_word
)

/*--- Rect for block 1 -----*/
reg [DATA_WIDTH-1:0] rect_minus_A_1;
reg [DATA_WIDTH-1:0] rect_minus_B_1;
reg [DATA_WIDTH-1:0] rect_1;
/*--- Rect for block 2 -----*/
reg [DATA_WIDTH-1:0] rect_minus_A_2;
reg [DATA_WIDTH-1:0] rect_minus_B_2;
reg [DATA_WIDTH-1:0] rect_2;
/*--- Rect for block 3 -----*/
reg [DATA_WIDTH-1:0] rect_minus_A_3;
reg [DATA_WIDTH-1:0] rect_minus_B_3;
reg [DATA_WIDTH-1:0] rect_3;

reg [DATA_WIDTH-1:0] rect_1_3;
reg [DATA_WIDTH-1:0] value;
reg [DATA_WIDTH-1:0] haarvalue;

assign o_haarvalue = haarvalue;

always @(posedge clk)
begin
	//rect 1
	rect_minus_A_1 <= rect_A_1 - rect_B_1;
	rect_minus_B_1 <= rect_C_1 - rect_D_1;
	rect_1 <= rect_minus_A_1 + rect_minus_B_1;
	
	//rect 2
	rect_minus_A_2 <= rect_A_2 - rect_B_2;
	rect_minus_B_2 <= rect_C_2 - rect_D_2;
	rect_2 <= rect_minus_A_2 + rect_minus_B_2;
	
	//rect 3
	rect_minus_A_3 <= rect_A_3 - rect_B_3;
	rect_minus_B_3 <= rect_C_3 - rect_D_3;
	rect_3 <= rect_minus_A_3 + rect_minus_B_3;
	
	value <= (rect_1 + rect_3) - rect_2;
	
	if(value > threshold)
	{
		haarvalue = right_word;
	}
	else
	{
		haarvalue = left_word;
	}
end 


endmodule