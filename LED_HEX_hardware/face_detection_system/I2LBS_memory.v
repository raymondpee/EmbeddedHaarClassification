module I2LBS_memory
#(
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter INTEGRAL_WIDTH = 3,
parameter INTEGRAL_HEIGHT = 3,
parameter FRAME_CAMERA_WIDTH = 10,
parameter FRAME_CAMERA_HEIGHT = 10
)
(
clk,
reset,
pixel,
wen,
o_integral_image,
o_integral_image_ready
);
/*--------------------IO port declaration---------------------------------*/
input clk;
input reset;
input wen;
input [DATA_WIDTH_16-1:0] pixel;

output o_integral_image_ready;
output [DATA_WIDTH_16-1:0] o_integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
/*-----------------------------------------------------------------------*/

localparam TOTAL_SIZE_COUNT = (FRAME_CAMERA_WIDTH*INTEGRAL_HEIGHT) + 2*INTEGRAL_WIDTH;

localparam NUM_STATE = 3;
localparam IDLE = 0;
localparam FILL_FIFO_INTEGRAL = 1;
localparam FILL_INTEGRAL = 2;
 
wire ready;
wire end_count_integral;
wire[INTEGRAL_HEIGHT-1:0] fill;
wire [DATA_WIDTH_12-1:0] integral_image_count;
wire [DATA_WIDTH_16-1:0] fifo_data_out [INTEGRAL_HEIGHT-1:0];
wire [DATA_WIDTH_16-1:0] fifo_reduction_sum [INTEGRAL_HEIGHT-1:0];
wire [DATA_WIDTH_16-1:0] row_integral[INTEGRAL_WIDTH-1:0][INTEGRAL_HEIGHT-1:0];

reg count_integral;
reg [INTEGRAL_HEIGHT-1:0] r_fill;
reg integral_image_ready;
reg [NUM_STATE-1:0] state;
reg [NUM_STATE-1:0] next_state;

assign ready = fill[INTEGRAL_HEIGHT-1];
assign o_integral_image_ready = integral_image_ready;

always@(posedge clk)
begin
	if(reset)
	begin
		state <=IDLE;
		next_state<=IDLE;
		integral_image_ready <=0;
		count_integral<=0;
		r_fill<=0;
	end
	else
		state<=next_state;
end

always@(*)
begin
	next_state = state;
	case(state)
		IDLE:
		begin
			if(wen && !integral_image_ready)
			begin
				next_state = FILL_FIFO_INTEGRAL;
			end
		end
		FILL_FIFO_INTEGRAL:
		begin
			if(ready)
			begin
				next_state = FILL_INTEGRAL;
			end
		end
		FILL_INTEGRAL:
		begin
			count_integral = wen;
			if(end_count_integral)
			begin
				count_integral = 0;
				integral_image_ready = 1;
				next_state = IDLE;
			end
		end
	endcase
end


counter 
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_integral_image_size
(
.clk(clk),
.reset(reset),
.enable(count_integral),
.max_size(INTEGRAL_WIDTH),
.end_count(end_count_integral),
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

always@(posedge fill[0])
begin
	r_fill[0] = 1;
end

row
#(
	.DATA_WIDTH_8(DATA_WIDTH_8),
	.DATA_WIDTH_12(DATA_WIDTH_12),
	.DATA_WIDTH_16(DATA_WIDTH_16),
	.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
	.FRAME_CAMERA_WIDTH(FRAME_CAMERA_WIDTH)
)
haar_row_0
(
	.clk(clk),
	.reset(reset),
	.wen(wen),
	.fifo_in(pixel),
	.fifo_reduction_sum(fifo_reduction_sum[0]),
	.o_fill(fill[0]),
	.o_fifo_data_out(fifo_data_out[0]),
	.o_row_integral(row_integral[0])
);

generate
	genvar index;	
	for(index = 1;index <INTEGRAL_HEIGHT;index= index +1)
	begin	
		always@(posedge fill[index])
		begin
			r_fill[index] = 1;
		end

	
		row
		#(
			.DATA_WIDTH_8(DATA_WIDTH_8),
			.DATA_WIDTH_12(DATA_WIDTH_12),
			.DATA_WIDTH_16(DATA_WIDTH_16),
			.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
			.FRAME_CAMERA_WIDTH(FRAME_CAMERA_WIDTH)
		)
		haar_row_n
		(
			.clk(clk),
			.reset(reset),
			.wen(r_fill[index-1] && wen),
			.fifo_in(fifo_data_out[index-1]),
			.fifo_reduction_sum(fifo_reduction_sum[index]),
			.o_fill(fill[index]),
			.o_fifo_data_out(fifo_data_out[index]),
			.o_row_integral(row_integral[index])
		);	
	end
endgenerate
/*-----------------------------------------------------------------------*/


endmodule