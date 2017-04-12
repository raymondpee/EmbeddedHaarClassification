`timescale 1 ns / 1 ns
module test_counter;

localparam ADDR_WIDTH = 12;
localparam DATA_WIDTH = 8;
localparam MEMORY_FILE = "memory.mif";
localparam MAX_MEM_SIZE = 10;

reg clk;
reg reset;


/*--------------------------- INITIAL STATEMENT ---------------------------*/
initial
begin
  clk = 0;
  #1 reset =1;
  #1 reset = 0;
end
/*-----------------------------------------------------------------------*/


initial
begin
	#1 	trigger_compare = 1;
	#10 trigger_compare = 0;
	#12 trigger_compare = 1;
end

/*--------------------------- SEQUENTIAL LOGIC ---------------------------*/
// Clock:
always # 1 clk <= ~clk;
wire is_end_reached;
wire [ADDR_WIDTH-1:0]address;
reg trigger_compare;

always@(posedge clk)
begin
	if(reset)
		trigger_compare<=0;
end

counter
#(
.DATA_WIDTH(DATA_WIDTH),
.ADDR_WIDTH(ADDR_WIDTH)
)
counter
(
.clk(clk),
.reset(reset),
.trigger_compare(trigger_compare),
.max_size(MAX_MEM_SIZE),
.o_address(address),
.o_is_end_reached(is_end_reached)
);

endmodule