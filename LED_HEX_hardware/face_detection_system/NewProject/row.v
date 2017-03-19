module row
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH = 8,
parameter FIFO_COMPONENT_COUNT = 6,
parameter IWIDTH =3
)
(
input clk_os,
input reset_os,
input wen,
input [DATA_WIDTH-1:0] fifo_in,
input [DATA_WIDTH-1:0] fifo_reduction_sum,

output [DATA_WIDTH-1:0] o_fifo_data_out
);

wire fifo_rdreq;
wire [DATA_WIDTH-1:0] fifo_usedw;                    
wire [DATA_WIDTH-1:0] fifo_data_out;        //[RESOURCE]The value output from FIFO when full

reg[DATA_WIDTH-1:0]row_integral[IWIDTH-1:0];

//--------------------------------FIFO Row Hardware Logic ---------------------------//
assign o_fifo_data_out = fifo_data_out;
assign fifo_rdreq = (fifo_usedw == FIFO_COMPONENT_COUNT -1) ? 1:0;
fifo 
#(
.DATA_WIDTH(DATA_WIDTH),
.ADDR_WIDTH(ADDR_WIDTH)
)
row_fifo
(
	.clock(clk_os),
	.data(fifo_in),
	.rdreq(fifo_rdreq),
	.wrreq(wen),
	.q(fifo_data_out),
	.usedw(fifo_usedw)	
);


//---------------------Integral Image Row Hardware Logic ---------------------------//
always @(posedge clk_os)
begin
	if(wen)
	begin
		if(reset_os)
			row_integral[0]<=0;
		else
			row_integral[0] <= fifo_data_out + fifo_reduction_sum + (row_integral[0] - row_integral[IWIDTH-1]);
	end
end

generate
	genvar index;
	for(index = 1; index<IWIDTH; index = index +1)
	begin
		always @(posedge clk_os)
		begin
			if(wen)
			begin
				if(reset_os)
					row_integral[index]<=0;
				else
					row_integral[index] = row_integral[index-1] - row_integral[IWIDTH-1];
			end
		end
	end
endgenerate

	
endmodule