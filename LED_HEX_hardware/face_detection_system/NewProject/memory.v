module memory
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH = 8,
parameter FIFO_COMPONENT_COUNT = 6,
parameter IWIDTH = 3,
parameter IHEIGHT = 3
)
(
	clk_os,
	reset_os,
	pixel,
	wen,
	o_row_integral,
	o_is_candidate
);
wire [DATA_WIDTH-1:0] fifo_data_out [IHEIGHT-1:0];
wire [DATA_WIDTH-1:0] fifo_reduction_sum [IHEIGHT-1:0];
wire [DATA_WIDTH-1:0] row_integral[IWIDTH-1:0][IHEIGHT-1:0];


/*--------------------IO port declaration---------------------------------*/
input clk_os;
input reset_os;
input [DATA_WIDTH-1:0] pixel;
input wen;
output [DATA_WIDTH-1:0] o_row_integral[IWIDTH*IHEIGHT-1:0];
/*-----------------------------------------------------------------------*/

/*----------------Reduction Sum declaration---------------------------------*/
assign fifo_reduction_sum[IHEIGHT-1] = 0;
generate
	genvar index_reduction;	
	for(index_reduction = 0;index_reduction <IHEIGHT-1;index_reduction= index_reduction +1)
	begin				
		assign fifo_reduction_sum[index_reduction] = fifo_reduction_sum[index_reduction+1] +fifo_data_out[index_reduction+1];
	end
endgenerate
/*-----------------------------------------------------------------------*/

generate
	genvar index_integral_y;	
	for(index_integral_y = 0;index_integral_y <IHEIGHT;index_integral_y= index_integral_y +1)
	begin	
		genvar index_integral_x;	
		for(index_integral_x = 0;index_integral_x <IWIDTH;index_integral_x= index_integral_x +1)
		begin
			assign o_row_integral[index_integral_x+IWIDTH*index_integral_y] = row_integral[index_integral_y][index_integral_x];
		end
	end
endgenerate



/*------------------Row declaration-----------------------------------------*/
row
#(
	.ADDR_WIDTH(ADDR_WIDTH),
	.DATA_WIDTH(DATA_WIDTH),
	.FIFO_COMPONENT_COUNT(FIFO_COMPONENT_COUNT),
	.IWIDTH(IWIDTH)
)
haar_row_0
(
	.clk_os(clk_os),
	.reset_os(reset_os),
	.wen(wen),
	.fifo_in(pixel),
	.fifo_reduction_sum(fifo_reduction_sum[0]),
	.o_fifo_data_out(fifo_data_out[0]),
	.o_row_integral(row_integral[0])
);

generate
	genvar index;	
	for(index = 1;index <IHEIGHT;index= index +1)
	begin				
		row
		#(
			.ADDR_WIDTH(ADDR_WIDTH),
			.DATA_WIDTH(DATA_WIDTH),
			.FIFO_COMPONENT_COUNT(FIFO_COMPONENT_COUNT),
			.IWIDTH(IWIDTH)
		)
		haar_row_n
		(
			.clk_os(clk_os),
			.reset_os(reset_os),
			.wen(wen),
			.fifo_in(fifo_data_out[index-1]),
			.fifo_reduction_sum(fifo_reduction_sum[index]),
			.o_fifo_data_out(fifo_data_out[index]),
			.o_row_integral(row_integral[index])
		);	
	end
endgenerate
/*-----------------------------------------------------------------------*/


endmodule