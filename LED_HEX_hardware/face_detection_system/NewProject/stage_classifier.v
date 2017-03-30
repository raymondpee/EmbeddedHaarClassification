module stage_classifier
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH = 8,
parameter IWIDTH = 3,
parameter IHEIGHT = 3
)
(
	clk_fpga,
	reset_fpga,
	row_integral,
	i_enable_write,
	o_is_face
);

/*--------------------IO port declaration---------------------------------*/
input clk_fpga;
input i_enable_write;
input [DATA_WIDTH-1:0] row_integral[IWIDTH*IHEIGHT-1:0];
output o_is_face;
/*-----------------------------------------------------------------------*/

wire w_rdreq;
wire [ADDR_WIDTH-1:0] usedw;  

reg wrreq;
reg rdreq;
reg [DATA_WIDTH-1:0] count_rdreq;
reg [DATA_WIDTH-1:0] count_wrreq;
reg [DATA_WIDTH-1:0] row_integral_compute[IWIDTH*IHEIGHT-1:0];


always @(posedge i_enable_write)
begin
	wrreq <=1;
end

always @(posedge clk_fpga)
begin
	if(reset_fpga)
	begin
		wrreq <=0;
		count_wrreq <=0;
	end
	else
	begin
		if(wrreq)
		begin
			if(count_wrreq == IWIDTH*IHEIGHT)
			begin
				count_wrreq <= 0;
				wrreq <= 0;
			end
			else
			begin
				count_wrreq <= count_wrreq+1;
				wrreq <= 1;
			end
		end
	end
end



always @(posedge clk_fpga)
begin
	if(reset_fpga)
	begin
		rdreq <=0;
		count_rdreq <=0;
	end
	else
	begin
		if(rdreq)
		begin
			if(count_rdreq == IWIDTH*IHEIGHT||usedw<IWIDTH*IHEIGHT)
			begin
				count_rdreq <= 0;
				rdreq <= 0;
			end
			else
			begin
				count_rdreq <= count_rdreq+1;
				rdreq <= 1;
			end
		end
	end
end

// This fifo require to use different clock
/*---------------------------------FIFO module ----------------------------*/
fifo 
#(
.DATA_WIDTH(DATA_WIDTH),
.ADDR_WIDTH(ADDR_WIDTH)
)
fifo_integral_images
(
	.clock(clk_fpga),
	.data(row_integral[count_rdreq]),
	.rdreq(rdreq),
	.wrreq(wrreq),
	.q(row_integral_compute[count_wrreq]),
	.usedw(usedw)	
);
/*-------------------------------------------------------------------------*/



endmodule