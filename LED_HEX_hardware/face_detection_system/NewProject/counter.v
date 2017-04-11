module counter
#(
parameter DATA_WIDTH = 8,
parameter ADDR_WIDTH = 12
)
(
	clk,
	reset,
	trigger_compare,
	max_size,
	o_address,
	o_is_end_reached
);

input clk;
input reset;
input trigger_compare;
input[DATA_WIDTH-1:0] max_size;
output o_address;
output o_is_end_reached;


localparam IDLE = 0;
localparam COMPARE = 1;
localparam STATE_SIZE = 2;

wire is_end_reached;
reg compare;
reg [ADDR_WIDTH-1:0] address;
reg[STATE_SIZE-1:0] state;
reg[STATE_SIZE-1:0] next_state;


assign is_end_reached = address == max_size;
assign o_is_end_reached = is_end_reached;
assign o_address = address;

always@(posedge trigger_compare)
begin
	compare<=1;
end

/*---------------------STATE MACHINE-------------------*/
always@(posedge clk)
begin
	if(reset)
	begin
		compare<=0;
		address<=0;
		state <=0;
		next_state<=0;
	end
	else
	begin
		state <= next_state;
		case(state)
		IDLE:
			if(compare)	next_state <= COMPARE;
			else 			next_state <= IDLE;
		COMPARE:
			if(compare)
			begin
				if(is_end_reached)
				begin
					address <=0;
					compare<=0;
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