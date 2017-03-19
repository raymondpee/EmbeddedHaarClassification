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
	index_a_1,
	index_b_2,
	index_c_3,
	index_d_4,
	index_a_1,
	index_b_2,
	index_c_3,
	index_d_4,
	index_a_1,
	index_b_2,
	index_c_3,
	index_d_4
);

wire [DATA_WIDTH-1:0] fifo_data_out [IHEIGHT-1:0];
wire [DATA_WIDTH-1:0] fifo_reduction_sum [IHEIGHT-1:0];


/*--------------------IO port declaration---------------------------------*/
input clk_os;
input reset_os;
input pixel;
input wen;

input [DATA_WIDTH-1:0] index_a_1;
input [DATA_WIDTH-1:0] index_b_2;
input [DATA_WIDTH-1:0] index_c_3;
input [DATA_WIDTH-1:0] index_d_4;
input [DATA_WIDTH-1:0] index_a_1;
input [DATA_WIDTH-1:0] index_b_2;
input [DATA_WIDTH-1:0] index_c_3;
input [DATA_WIDTH-1:0] index_d_4;
input [DATA_WIDTH-1:0] index_a_1;
input [DATA_WIDTH-1:0] index_b_2;
input [DATA_WIDTH-1:0] index_c_3;
input [DATA_WIDTH-1:0] index_d_4;
/*-----------------------------------------------------------------------*/

assign fifo_data_out[0] = pixel;
assign fifo_reduction_sum[0] = 0;
generate
	genvar index;	
	for(index = 0;index <IHEIGHT-1;index= index +1)
	begin		
		assign fifo_reduction_sum[index+1] = fifo_reduction_sum[index] + fifo_data_out[index];		
		row
		#(
			.ADDR_WIDTH(ADDR_WIDTH),
			.DATA_WIDTH(DATA_WIDTH),
			.FIFO_COMPONENT_COUNT(FIFO_COMPONENT_COUNT),
			.IWIDTH(IWIDTH)
		)
		haar_row
		(
			.clk_os(clk_os),
			.reset_os(reset_os),
			.wen(wen),
			.fifo_in(fifo_data_out[index]),
			.fifo_reduction_sum(fifo_reduction_sum[index]),
			.o_fifo_data_out(fifo_data_out[index+1])
		);	
	end
endgenerate



endmodule