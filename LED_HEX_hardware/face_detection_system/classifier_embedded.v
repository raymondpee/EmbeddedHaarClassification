module classifier_embedded
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16,
parameter INTEGRAL_WIDTH = 10,
parameter INTEGRAL_HEIGHT = 10
)
(
clk,
reset,
calculate,
integral_image,
rect_A_1_index,
rect_B_1_index,
rect_C_1_index,
rect_D_1_index,
weight_1,
rect_A_2_index,
rect_B_2_index,
rect_C_2_index,
rect_D_2_index,
weight_2,
rect_A_3_index,
rect_B_3_index,
rect_C_3_index,
rect_D_3_index,
weight_3,
threshold,
left_value,
right_value,
o_haar
);

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
input 	clk;
input 	reset;
input 	calculate;
input 	[DATA_WIDTH_16-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
input 	[DATA_WIDTH_16-1:0] rect_A_1_index;
input 	[DATA_WIDTH_16-1:0] rect_B_1_index;
input 	[DATA_WIDTH_16-1:0] rect_C_1_index;
input 	[DATA_WIDTH_16-1:0] rect_D_1_index;
input 	[DATA_WIDTH_16-1:0] rect_A_2_index;
input 	[DATA_WIDTH_16-1:0] rect_B_2_index;
input 	[DATA_WIDTH_16-1:0] rect_C_2_index;
input 	[DATA_WIDTH_16-1:0] rect_D_2_index;
input 	[DATA_WIDTH_16-1:0] rect_D_1_index;
input 	[DATA_WIDTH_16-1:0] rect_A_3_index;
input 	[DATA_WIDTH_16-1:0] rect_B_3_index;
input 	[DATA_WIDTH_16-1:0] rect_C_3_index;
input 	[DATA_WIDTH_16-1:0] rect_D_3_index;
input 	[DATA_WIDTH_16-1:0] weight_1;
input 	[DATA_WIDTH_16-1:0] weight_2;
input 	[DATA_WIDTH_16-1:0] weight_3;
input 	[DATA_WIDTH_16-1:0]	threshold;
input 	[DATA_WIDTH_16-1:0]	right_value;
input 	[DATA_WIDTH_16-1:0]	left_value;
output 	[DATA_WIDTH_16-1:0] o_haar;


/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/
reg [DATA_WIDTH_16-1:0] rect_A_1;
reg [DATA_WIDTH_16-1:0] rect_B_1;
reg [DATA_WIDTH_16-1:0] rect_C_1;
reg [DATA_WIDTH_16-1:0] rect_D_1;
reg [DATA_WIDTH_16-1:0] rect_A_2;
reg [DATA_WIDTH_16-1:0] rect_B_2;
reg [DATA_WIDTH_16-1:0] rect_C_2;
reg [DATA_WIDTH_16-1:0] rect_D_2;
reg [DATA_WIDTH_16-1:0] rect_A_3;
reg [DATA_WIDTH_16-1:0] rect_B_3;
reg [DATA_WIDTH_16-1:0] rect_C_3;
reg [DATA_WIDTH_16-1:0] rect_D_3;

/*--- Rect for block 1 -----*/
reg [DATA_WIDTH_16-1:0] rect_minus_A_1;
reg [DATA_WIDTH_16-1:0] rect_minus_B_1;
reg [DATA_WIDTH_16-1:0] rect_1;
/*--- Rect for block 2 -----*/
reg [DATA_WIDTH_16-1:0] rect_minus_A_2;
reg [DATA_WIDTH_16-1:0] rect_minus_B_2;
reg [DATA_WIDTH_16-1:0] rect_2;
/*--- Rect for block 3 -----*/
reg [DATA_WIDTH_16-1:0] rect_minus_A_3;
reg [DATA_WIDTH_16-1:0] rect_minus_B_3;
reg [DATA_WIDTH_16-1:0] rect_3;

reg [DATA_WIDTH_16-1:0] rect_1_3;
reg [DATA_WIDTH_16-1:0] value;

reg [DATA_WIDTH_16-1:0] haar;

/*****************************************************************************
*                            Combinational logic                             *
*****************************************************************************/
assign o_haar = haar;
always@(posedge calculate)
begin
	rect_A_1 = integral_image[rect_A_1_index];
	rect_B_1 = integral_image[rect_B_1_index];
	rect_C_1 = integral_image[rect_C_1_index];
	rect_D_1 = integral_image[rect_D_1_index];
	rect_A_2 = integral_image[rect_A_2_index];
	rect_B_2 = integral_image[rect_B_2_index];
	rect_C_2 = integral_image[rect_C_2_index];
	rect_D_2 = integral_image[rect_D_2_index];
	rect_A_3 = integral_image[rect_A_3_index];
	rect_B_3 = integral_image[rect_B_3_index];
	rect_C_3 = integral_image[rect_C_3_index];
	rect_D_3 = integral_image[rect_D_3_index];
	
	rect_minus_A_1 = rect_A_1 + rect_D_1;
	rect_minus_B_1 = rect_B_1 + rect_C_1;
	rect_1 = weight_1*(rect_minus_A_1 - rect_minus_B_1);
		
	//rect 2
	rect_minus_A_2 = rect_A_2 + rect_D_2;
	rect_minus_B_2 = rect_B_2 + rect_C_2;
	rect_2 = weight_2*(rect_minus_A_2 - rect_minus_B_2);
		
	//rect 3
	rect_minus_A_3 = rect_A_3 - rect_D_3;
	rect_minus_B_3 = rect_B_3 - rect_C_3;
	rect_3 = weight_3*(rect_minus_A_3 - rect_minus_B_3);

	//value
	value = rect_1 + rect_3 + rect_2;
	haar =(value > threshold)? right_value:left_value;	
end

endmodule