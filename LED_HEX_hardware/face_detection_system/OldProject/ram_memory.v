module ram_memory
#(
parameter FIFO_ADDR_WIDTH = 10,
parameter FIFO_DATA_WIDTH = 8,
parameter FIFO_COMPONENT_COUNT = 6,
parameter INTEGRAL_ROW =3,
parameter INTEGRAL_COLUMN =3
)
(
input [FIFO_DATA_WIDTH-1:0] pixel,
input clk
);

localparam INTEGRAL_WIDTH =3;                   //[INTEGRAL] Width of the INTEGRAL array
localparam ROW1_LOCATION = (INTEGRAL_WIDTH)*1 -1;  //[INTEGRAL] Row 1 INTEGRAL location 
localparam ROW2_LOCATION = (INTEGRAL_WIDTH)*2 -1;  //[INTEGRAL] Row 2 INTEGRAL location
localparam ROW3_LOCATION = (INTEGRAL_WIDTH)*3 -1;  //[INTEGRAL] Row 3 INTEGRAL location

wire [FIFO_ADDR_WIDTH-1:0] fifo_usedw [INTEGRAL_ROW-1:0];           //[RESOURCE]The number of FIFO occupied in each FIFO      
wire [FIFO_DATA_WIDTH-1:0] fifo_data_out[INTEGRAL_ROW-1:0];         //[RESOURCE]The value output from FIFO when full
wire [INTEGRAL_ROW-1:0] fifo_rdreq;                              //[RESOURCE]Flag for read request to FIFO
wire	fifo_wrreq    = 1;                                              //[RESOURCE]Flag for write request to FIFO
reg [FIFO_DATA_WIDTH-1:0] ram_integral [(INTEGRAL_ROW*INTEGRAL_COLUMN)-1:0];    //[RESOURCE]Array declaration of the integral image size

/*------[RESOURCE]Check if the FIFO is full, if fifo is full, then the read request will be true ----*/
wire rdreq0;
wire rdreq1;
wire rdreq2;
assign fifo_rdreq[0] = (fifo_usedw[0] == FIFO_COMPONENT_COUNT -1) ? 1:0;
assign fifo_rdreq[1] = (fifo_usedw[1] == FIFO_COMPONENT_COUNT -1) ? 1:0;
assign fifo_rdreq[2] = (fifo_usedw[2] == FIFO_COMPONENT_COUNT -1) ? 1:0;

/*-------- [RESOURCE] FIFO module for each system row --------*/
fifo 
#(
.DATA_WIDTH(FIFO_DATA_WIDTH),
.ADDR_WIDTH(FIFO_ADDR_WIDTH)
)
ram_row_last_1
(
	.clock(clk),
	.data(pixel),
	.rdreq(fifo_rdreq[0]),
	.wrreq(fifo_wrreq),
	.q(fifo_data_out[0]),
	.usedw(fifo_usedw[0])	
);

fifo 
#(
.DATA_WIDTH(FIFO_DATA_WIDTH),
.ADDR_WIDTH(FIFO_ADDR_WIDTH)
)
ram_row_last_2
(
	.clock(clk),
	.data(fifo_data_out[0]),
	.rdreq(fifo_rdreq[1]),
	.wrreq(fifo_wrreq),
	.q(fifo_data_out[1]),
	.usedw(fifo_usedw[1])
);

fifo 
#(
.DATA_WIDTH(FIFO_DATA_WIDTH),
.ADDR_WIDTH(FIFO_ADDR_WIDTH)
)
ram_row_last_3
(
	.clock(clk),
	.data(fifo_data_out[1]),
	.rdreq(fifo_rdreq[2]),
	.wrreq(fifo_wrreq),
	.q(fifo_data_out[2]),
	.usedw(fifo_usedw[2])
);

reg[FIFO_DATA_WIDTH -1:0 ] index;
initial
begin
  for(index =0; index <INTEGRAL_ROW*INTEGRAL_COLUMN; index = index +1)
  begin
    ram_integral[index] =0;
  end
end

/*------[INTEGRAL]Pipeline the INTEGRAL RAM so each last column recieve data from FIFO-----*/
always @(posedge clk)
begin
	ram_integral[ROW1_LOCATION] <= fifo_data_out[2]                                       + (ram_integral[ROW1_LOCATION] - ram_integral[ROW1_LOCATION-2]); 
	ram_integral[ROW2_LOCATION] <= fifo_data_out[1] + fifo_data_out[2]                    + (ram_integral[ROW2_LOCATION] - ram_integral[ROW2_LOCATION-2]);
	ram_integral[ROW3_LOCATION] <= fifo_data_out[0] + fifo_data_out[1] + fifo_data_out[2] + (ram_integral[ROW3_LOCATION] - ram_integral[ROW3_LOCATION-2]);
	
	ram_integral[ROW1_LOCATION-1] <= ram_integral[ROW1_LOCATION] - ram_integral[ROW1_LOCATION-2]; 
	ram_integral[ROW2_LOCATION-1] <= ram_integral[ROW2_LOCATION] - ram_integral[ROW2_LOCATION-2];
	ram_integral[ROW3_LOCATION-1] <= ram_integral[ROW3_LOCATION] - ram_integral[ROW3_LOCATION-2];
	
	ram_integral[ROW1_LOCATION-2] <= ram_integral[ROW1_LOCATION-1] - ram_integral[ROW1_LOCATION-2]; 
	ram_integral[ROW2_LOCATION-2] <= ram_integral[ROW2_LOCATION-1] - ram_integral[ROW2_LOCATION-2];
	ram_integral[ROW3_LOCATION-2] <= ram_integral[ROW3_LOCATION-1] - ram_integral[ROW3_LOCATION-2];
	
end



	
endmodule