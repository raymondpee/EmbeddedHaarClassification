module memory
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH = 8,
parameter INTEGRAL_WIDTH = 3,
parameter INTEGRAL_HEIGHT = 3
)
(
	clk_os,
	reset_os,
	pixel,
	wen,
	frame_width,
	frame_height,
	o_integral_image
);
wire [DATA_WIDTH-1:0] fifo_data_out [INTEGRAL_HEIGHT-1:0];
wire [DATA_WIDTH-1:0] fifo_reduction_sum [INTEGRAL_HEIGHT-1:0];
wire [DATA_WIDTH-1:0] row_integral[INTEGRAL_WIDTH-1:0][INTEGRAL_HEIGHT-1:0];


/*--------------------IO port declaration---------------------------------*/
input clk_os;
input reset_os;
input wen;
input [DATA_WIDTH-1:0] pixel;
output [DATA_WIDTH-1:0] o_integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
/*-----------------------------------------------------------------------*/

/*----------------Reduction Sum declaration---------------------------------*/
assign fifo_reduction_sum[INTEGRAL_HEIGHT-1] = 0;
generate
	genvar index_reduction;	
	for(index_reduction = 0;index_reduction <INTEGRAL_HEIGHT-1;index_reduction= index_reduction +1)
	begin				
		assign fifo_reduction_sum[index_reduction] = fifo_reduction_sum[index_reduction+1] +fifo_data_out[index_reduction+1];
	end
endgenerate
/*-----------------------------------------------------------------------*/

/*---------------Integral Image Wire Declaration--------------------------*/
generate
	genvar index_integral_y;	
	for(index_integral_y = 0;index_integral_y <INTEGRAL_HEIGHT;index_integral_y= index_integral_y +1)
	begin	
		genvar index_integral_x;	
		for(index_integral_x = 0;index_integral_x <INTEGRAL_WIDTH;index_integral_x= index_integral_x +1)
		begin
			assign o_integral_image[index_integral_x+INTEGRAL_WIDTH*index_integral_y] = row_integral[index_integral_y][index_integral_x];
		end
	end
endgenerate
/*-----------------------------------------------------------------------*/




/*------------------Row declaration-----------------------------------------*/
row
#(
	.ADDR_WIDTH(ADDR_WIDTH),
	.DATA_WIDTH(DATA_WIDTH),
	.INTEGRAL_WIDTH(INTEGRAL_WIDTH)
)
haar_row_0
(
	.clk_os(clk_os),
	.reset_os(reset_os),
	.wen(wen),
	.fifo_in(pixel),
	.fifo_reduction_sum(fifo_reduction_sum[0]),
	.fifo_width(frame_width),
	.o_fifo_data_out(fifo_data_out[0]),
	.o_integral_image(row_integral[0])
);

generate
	genvar index;	
	for(index = 1;index <INTEGRAL_HEIGHT;index= index +1)
	begin				
		row
		#(
			.ADDR_WIDTH(ADDR_WIDTH),
			.DATA_WIDTH(DATA_WIDTH),
			.INTEGRAL_WIDTH(INTEGRAL_WIDTH)
		)
		haar_row_n
		(
			.clk_os(clk_os),
			.reset_os(reset_os),
			.wen(wen),
			.fifo_in(fifo_data_out[index-1]),
			.fifo_reduction_sum(fifo_reduction_sum[index]),
			.fifo_width(frame_width),
			.o_fifo_data_out(fifo_data_out[index]),
			.o_integral_image(row_integral[index])
		);	
	end
endgenerate
/*-----------------------------------------------------------------------*/


endmodule