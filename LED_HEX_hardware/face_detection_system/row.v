module row
#(
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter INTEGRAL_WIDTH =3,
parameter FRAME_CAMERA_WIDTH =10
)
(
	clk,
	reset,
	wen,
	fifo_in,
	fifo_reduction_sum,
	o_fill,
	o_fifo_data_out,
	o_row_integral,
);

// Take note that this addr width is required for the frame camera width
localparam ADDR_WIDTH = 12;

/*--------------------IO port declaration---------------------------------*/
input clk;
input reset;
input wen;
input [DATA_WIDTH_16-1:0] fifo_in;
input [DATA_WIDTH_16-1:0] fifo_reduction_sum;
output o_fill;
output [DATA_WIDTH_16-1:0] o_fifo_data_out;
output [DATA_WIDTH_16-1:0] o_row_integral[INTEGRAL_WIDTH-1:0];
/*-----------------------------------------------------------------------*/

wire fifo_rdreq;
wire [DATA_WIDTH_16-1:0] fifo_usedw;                    
wire [DATA_WIDTH_16-1:0] fifo_data_out;        
reg[DATA_WIDTH_16-1:0]row_integral[INTEGRAL_WIDTH-1:0];

/*--------------------Assignment declaration---------------------------------*/
assign o_fifo_data_out = fifo_data_out;
assign fifo_rdreq = (fifo_usedw == FRAME_CAMERA_WIDTH) ? 1:0;
assign o_fill = fifo_rdreq;
generate
	genvar index_integral;
	for(index_integral = 0; index_integral<INTEGRAL_WIDTH; index_integral = index_integral +1)
	begin
		assign o_row_integral[index_integral] = row_integral[index_integral];
	end
endgenerate
/*-------------------------------------------------------------------------*/

/*---------------------------------FIFO module ----------------------------*/
fifo 
#(
.DATA_WIDTH(DATA_WIDTH_16),
.ADDR_WIDTH(ADDR_WIDTH)
)
row_fifo
(
	.clock(clk),
	.data(fifo_in),
	.rdreq(fifo_rdreq),
	.wrreq(wen),
	.q(fifo_data_out),
	.usedw(fifo_usedw)	
);
/*-------------------------------------------------------------------------*/

/*-------------------------Integral Image Single Row ----------------------*/
always @(posedge clk or posedge reset)
begin	
	if(reset)
		row_integral[0]<=0;
	else
	begin
		if(wen)
		begin
			row_integral[0] <= fifo_data_out + fifo_reduction_sum + (row_integral[0] - row_integral[INTEGRAL_WIDTH-1]);
		end
	end
end

generate
	genvar index;
	for(index = 1; index<INTEGRAL_WIDTH; index = index +1)
	begin
		always @(posedge clk)
		begin			
			if(reset)
				row_integral[index]<=0;
			else
			if(wen)
			begin
				row_integral[index] <= row_integral[index-1] - row_integral[INTEGRAL_WIDTH-1];
			end
		end
	end
endgenerate
/*-------------------------------------------------------------------------*/
	
endmodule