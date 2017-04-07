module stage_classifier_db
#(
parameter ADDR_WIDTH = 12, 
parameter DATA_WIDTH = 8,
parameter MEMORY_FILE =  "memory.mif"
)
(
	clk,
	reset,
	req_compare,
	classifier_size,
	o_is_end_reached,
	q
);

input clk;
input reset;
input req_compare;
input [DATA_WIDTH-1:0]classifier_size;
output o_is_end_reached;
output [DATA_WIDTH-1:0]q;

localparam IDLE = 0;
localparam COMPARE = 1;
localparam STATE_SIZE = 2;


wire is_end_reached;
reg start_compare;
reg [ADDR_WIDTH-1:0] address;
reg[STATE_SIZE-1:0] state;
reg[STATE_SIZE-1:0] next_state;

assign is_end_reached = address == classifier_size;
assign o_is_end_reached = is_end_reached;



always@(posedge req_compare)
begin
	start_compare<=1;
end


/*---------------------STATE MACHINE-------------------*/
always@(posedge clk)
begin
	if(reset)
	begin
		start_compare<=0;
		address<=0;
		state <=0;
		next_state<=0;
	end
	else
	begin
		state <= next_state;
		case(state)
		IDLE:
			if(start_compare)	next_state <= COMPARE;
			else 			next_state <= IDLE;
		COMPARE:
			if(start_compare)
			begin
				if(is_end_reached)
				begin
					address <=0;
					start_compare<=0;
					next_state <= IDLE;
				end
				else
				begin
					address <= address +1;
					next_state <= COMPARE;
				end
			end
			else 
			begin
				next_state <= IDLE;
			end
		default: next_state <= IDLE;
	end
end
/*--------------------------------------------------------*/

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