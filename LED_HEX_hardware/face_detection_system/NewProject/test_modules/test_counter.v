`timescale 1 ns / 1 ns
module test_counter;

localparam ADDR_WIDTH = 12;
localparam MAX_MEM_SIZE = 10;

reg clk;
reg reset;
reg enable;

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
	#1 enable = 1;
	#20 enable = 1;
end

/*--------------------------- SEQUENTIAL LOGIC ---------------------------*/
// Clock:
always # 1 clk <= ~clk;

wire [ADDR_WIDTH-1:0]address;
wire end_count;

always @(posedge clk)
begin
	if(end_count)
		enable<=0;
end

counter
#(
.DATA_WIDTH(ADDR_WIDTH)
)
counter
(
.clk(clk),
.reset(reset),
.enable(enable),
.max_size(MAX_MEM_SIZE),
.ctr_out(address),
.end_count(end_count)
);

endmodule