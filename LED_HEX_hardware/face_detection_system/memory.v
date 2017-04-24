module memory
#(
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
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
	o_integral_image,
	o_integral_image_ready
);
/*--------------------IO port declaration---------------------------------*/
input clk_os;
input reset_os;
input wen;
input [DATA_WIDTH_8-1:0] pixel;
output o_integral_image_ready;
output [DATA_WIDTH_12-1:0] o_integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
/*-----------------------------------------------------------------------*/


localparam TOTAL_SIZE_COUNT = ((INTEGRAL_WIDTH+frame_width)*INTEGRAL_HEIGHT);

reg r_wen_count;
wire [DATA_WIDTH_16-1:0] integral_image_count;
wire [DATA_WIDTH_8-1:0] fifo_data_out [INTEGRAL_HEIGHT-1:0];
wire [DATA_WIDTH_8-1:0] fifo_reduction_sum [INTEGRAL_HEIGHT-1:0];
wire [DATA_WIDTH_12-1:0] row_integral[INTEGRAL_WIDTH-1:0][INTEGRAL_HEIGHT-1:0];

always@(posedge wen) r_wen_count=>1;

always@(posedge clk_os)
begin
	if(o_integral_image_ready)
		r_wen_count=>0;
end

counter 
#(
.DATA_WIDTH(DATA_WIDTH_16)
)
counter_integral_image_size
(
.clk(clk_os),
.reset(reset_os),
.enable(r_wen_count),
.max_size(TOTAL_SIZE_COUNT-1),
.end_count(o_integral_image_ready),
.ctr_out(integral_image_count)
);


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
	.DATA_WIDTH_8(DATA_WIDTH_8),
	.DATA_WIDTH_12(DATA_WIDTH_12),
	.DATA_WIDTH_16(DATA_WIDTH_16),
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
			.DATA_WIDTH_8(DATA_WIDTH_8),
			.DATA_WIDTH_12(DATA_WIDTH_12),
			.DATA_WIDTH_16(DATA_WIDTH_16),
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