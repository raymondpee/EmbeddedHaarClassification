module result
#(
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter NUM_RESIZE = 5
)
(
	clk,
	reset,
	// Enable/Disable read write //
	write_result,
	o_write_result_end,
	read_result,
	//Data in//
	ori_x,
	ori_y,
	candidate,
	//Data Out//
	o_result,
	o_empty
);

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
input 							clk;
input 							reset;

input 							write_result;
input 	[DATA_WIDTH_12-1:0] 	ori_x;
input 	[DATA_WIDTH_12-1:0] 	ori_y;
input 	[NUM_RESIZE-1:0] 		candidate;
output 							o_write_result_end;

input 							read_result;
output 							o_result;
output 							o_empty;



/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/
localparam 						NUM_VARIABLE = 3;
wire 							result_size;
wire 							write_result_end;
wire 	[DATA_WIDTH_12-1:0] 	index_read_out;
wire 	[DATA_WIDTH_12-1:0] 	index_enable_write_result;
wire 	[DATA_WIDTH_12-1:0] 	data_out;

reg 							result_empty;
reg 	[DATA_WIDTH_12-1:0] 	data_in;

 /*****************************************************************************
 *                            Combinational logic                             *
 *****************************************************************************/
assign o_write_result_end = write_result_end;
assign o_result = data_out;
assign o_empty = result_empty;


/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 
always@(posedge clk)
begin
	if(reset)
	begin
		result_empty<=0;
		data_in<=0;
	end
end

always@(posedge clk)
begin
	if(write_result)
	begin
		case(index_enable_write_result)
			0: data_in <= ori_x;
			1: data_in <= ori_y;
			2: data_in <= candidate;
			default: data_in <= ori_x;
		endcase
	end
end


always@(result_size)
begin
	if(result_size == 0)
	begin
		result_empty =1;
	end
end


 /*****************************************************************************
 *                                   Modules                                  *
 *****************************************************************************/ 
//=== Write In Count
counter 
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_enable_write_result
(
  .clk(clk),
  .reset(reset),
  .enable(write_result),
  .max_size(NUM_VARIABLE),
  .end_count(write_result_end),
  .ctr_out(index_enable_write_result)
);

//=== Database
fifo 
#(
.DATA_WIDTH(DATA_WIDTH_12),
.ADDR_WIDTH(DATA_WIDTH_12)
)
row_fifo
(
	.clock(clk),
	.data(data_in),
	.rdreq(read_result),
	.wrreq(write_result),
	.q(data_out),
	.usedw(result_size)	
);


endmodule