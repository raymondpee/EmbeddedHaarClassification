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
	write_in,
	o_write_in_end,
	read_out,
	o_read_out_end,
	ori_x,
	ori_y,
	candidate,
	o_data_out
);

input clk;
input reset;
input write_in;
input read_out;

input [DATA_WIDTH_12-1:0] ori_x;
input [DATA_WIDTH_12-1:0] ori_y;
input [NUM_RESIZE-1:0] candidate;

output o_write_in_end;
output o_read_out_end;
output o_data_out;

localparam NUM_VARIABLE = 3;

wire result_size;
wire write_in_end;
wire read_out_end;
wire [DATA_WIDTH_12-1:0] index_read_out;
wire [DATA_WIDTH_12-1:0] index_write_in;
wire [DATA_WIDTH_12-1:0] data_out;

reg trig_write_in_end;
reg trig_read_out_end;
reg [DATA_WIDTH_12-1:0] data_in;


assign o_write_in_end = trig_write_in_end;
assign o_read_out_end = trig_read_out_end;
assign o_data_out = data_out;

//Set trigger signal and reset 
always@(posedge clk)
begin
	if(reset || trig_write_in_end)
		trig_write_in_end<=0;
	if(reset || trig_read_out_end)
		trig_read_out_end<=0;
end

always@(posedge clk)
begin
	if(write_in)
	begin
		case(index_write_in)
			0: data_in <= ori_x;
			1: data_in <= ori_y;
			2: 
			begin
				data_in <= candidate;
				trig_write_in_end<=1;
			end
			default: data_in <= ori_x;
		endcase
	end
end

always@(posedge clk)
begin
	if(read_out)
	begin
		if(result_size == 0)
			trig_read_out_end<=1;
	end
end


//Set write in count state
counter 
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_write_in
(
  .clk(clk),
  .reset(reset),
  .enable(write_in),
  .max_size(NUM_VARIABLE),
  .end_count(write_in_end),
  .ctr_out(index_write_in)
);

//Set read out count state
counter 
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_read_out
(
  .clk(clk),
  .reset(reset),
  .enable(read_out),
  .max_size(result_size),
  .end_count(read_out_end),
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
	.rdreq(read_out),
	.wrreq(write_in),
	.q(data_out),
	.usedw(result_size)	
);


endmodule