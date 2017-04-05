module stage_classifier_db
#(
parameter ADDR_WIDTH = 12, 
parameter DATA_WIDTH = 8,
parameter MEMORY_FILE =  "memory.mif"
)
(
	clk,
	reset,
	o_is_end_reached,
	address,
	classifier_size,
	q
);

input clk;
input reset;
input [ADDR_WIDTH-1:0]address;
input [DATA_WIDTH-1:0]classifier_size;
output o_is_end_reached;
output [DATA_WIDTH-1:0]q;

reg is_end_reached;
reg [ADDR_WIDTH-1:0] count;

assign o_is_end_reached = is_end_reached;

/*------ This will need use State Machine to solve ------*/
//http://www.asic-world.com/tidbits/verilog_fsm.html
always@(posedge clk)
begin
	if(reset)
	begin
		count <= 0;
		is_end_reached<=0;
	end
	else if(count == classifier_size)
	begin
		count <= 0;
		is_end_reached<=1;
	end
	else
	begin
		count<= count +1;
		is_end_reached<=0;
	end
end

rom 
#(
.ADDR_WIDTH(ADDR_WIDTH), 
.DATA_WIDTH(DATA_WIDTH),
.MEMORY_FILE(MEMORY_FILE)
)
rom
(
	.address(address),
	.clock(clock),
	.q(q)
);

endmodule