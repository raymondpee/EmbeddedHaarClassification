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
	enable_write_result,
	o_enable_write_result_end,
	enable_read_result,
	o_enable_read_result_end,
	//Data in//
	ori_x,
	ori_y,
	candidate,
	//Data Out//
	o_data_out,
	o_result_end
);

input clk;
input reset;
input enable_write_result;
input enable_read_result;

input [DATA_WIDTH_12-1:0] ori_x;
input [DATA_WIDTH_12-1:0] ori_y;
input [NUM_RESIZE-1:0] candidate;

output o_enable_write_result_end;
output o_enable_read_result_end;
output o_result_end;
output o_data_out;

localparam NUM_VARIABLE = 3;

wire result_size;
wire enable_write_result_end;
wire enable_read_result_end;

wire [DATA_WIDTH_12-1:0] index_read_out;
wire [DATA_WIDTH_12-1:0] index_enable_write_result;
wire [DATA_WIDTH_12-1:0] data_out;

reg result_end;
reg [DATA_WIDTH_12-1:0] data_in;


assign o_enable_write_result_end = enable_write_result_end;
assign o_enable_read_result_end = enable_read_result_end;
assign o_data_out = data_out;
assign o_result_end = result_end;

//Set trigger signal and reset 
always@(posedge clk)
begin
	if(reset)
	begin
		result_end<=0;
	end
end

always@(posedge clk)
begin
	if(enable_write_result)
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
		result_end =1;
	end
end

//Set write in count state
counter 
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_enable_write_result
(
  .clk(clk),
  .reset(reset),
  .enable(enable_write_result),
  .max_size(NUM_VARIABLE),
  .end_count(enable_write_result_end),
  .ctr_out(index_enable_write_result)
);

//Set read out count state
counter 
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_enable_read_result
(
  .clk(clk),
  .reset(reset),
  .enable(enable_read_result),
  .max_size(NUM_VARIABLE),
  .end_count(enable_read_result_end),
  .ctr_out(index_read_out)
);


fifo 
#(
.DATA_WIDTH(DATA_WIDTH_12),
.ADDR_WIDTH(DATA_WIDTH_12)
)
row_fifo
(
	.clock(clk),
	.data(data_in),
	.rdreq(enable_read_result),
	.wrreq(enable_write_result),
	.q(data_out),
	.usedw(result_size)	
);


endmodule