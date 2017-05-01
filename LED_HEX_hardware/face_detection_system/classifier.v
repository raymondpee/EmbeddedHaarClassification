module classifier
#(
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16 // Max value 177777
)
(
input clk,	
input reset,
input en,
input [DATA_WIDTH_12-1:0] rect_A_1,
input [DATA_WIDTH_12-1:0] rect_B_1,
input [DATA_WIDTH_12-1:0] rect_C_1,
input [DATA_WIDTH_12-1:0] rect_D_1,
input [DATA_WIDTH_12-1:0] weight_1,
input [DATA_WIDTH_12-1:0] rect_A_2,
input [DATA_WIDTH_12-1:0] rect_B_2,
input [DATA_WIDTH_12-1:0] rect_C_2,
input [DATA_WIDTH_12-1:0] rect_D_2,
input [DATA_WIDTH_12-1:0] weight_2,
input [DATA_WIDTH_12-1:0] rect_A_3,
input [DATA_WIDTH_12-1:0] rect_B_3,
input [DATA_WIDTH_12-1:0] rect_C_3,
input [DATA_WIDTH_12-1:0] rect_D_3,
input [DATA_WIDTH_12-1:0] weight_3,
input [DATA_WIDTH_12-1:0] threshold,
input [DATA_WIDTH_12-1:0] left_word,
input [DATA_WIDTH_12-1:0] right_word,
output [DATA_WIDTH_12-1:0] o_haarvalue
);

/*--- Rect for block 1 -----*/
reg [DATA_WIDTH_12-1:0] rect_minus_A_1;
reg [DATA_WIDTH_12-1:0] rect_minus_B_1;
reg [DATA_WIDTH_12-1:0] rect_1;
/*--- Rect for block 2 -----*/
reg [DATA_WIDTH_12-1:0] rect_minus_A_2;
reg [DATA_WIDTH_12-1:0] rect_minus_B_2;
reg [DATA_WIDTH_12-1:0] rect_2;
/*--- Rect for block 3 -----*/
reg [DATA_WIDTH_12-1:0] rect_minus_A_3;
reg [DATA_WIDTH_12-1:0] rect_minus_B_3;
reg [DATA_WIDTH_12-1:0] rect_3;

reg [DATA_WIDTH_12-1:0] rect_1_3;
reg [DATA_WIDTH_12-1:0] value;
reg [DATA_WIDTH_12-1:0] haarvalue;


always@(posedge clk)
begin
	if(reset)
	begin
		rect_minus_A_1<=0;
		rect_minus_B_1<=0;
		rect_1<=0;
		rect_minus_A_2<=0;
		rect_minus_B_2<=0;
		rect_2<=0;
		rect_minus_A_3<=0;
		rect_minus_B_3<=0;
		rect_3<=0;
		rect_1_3<=0;
		value<=0;
		haarvalue<=0;
	end
end

assign o_haarvalue = haarvalue;
always@(posedge en)
begin
	rect_minus_A_1 = rect_A_1 - rect_B_1;
	rect_minus_B_1 = rect_C_1 - rect_D_1;
	rect_1 = weight_1*(rect_minus_A_1 + rect_minus_B_1);
		
	//rect 2
	rect_minus_A_2 = rect_A_2 - rect_B_2;
	rect_minus_B_2 = rect_C_2 - rect_D_2;
	rect_2 = weight_2*(rect_minus_A_2 + rect_minus_B_2);
		
	//rect 3
	rect_minus_A_3 = rect_A_3 - rect_B_3;
	rect_minus_B_3 = rect_C_3 - rect_D_3;
	rect_3 = weight_3*(rect_minus_A_3 + rect_minus_B_3);

	//value
	value = (rect_1 + rect_3) - rect_2;
	haarvalue =(value > threshold)? right_word:left_word;	
end




endmodule