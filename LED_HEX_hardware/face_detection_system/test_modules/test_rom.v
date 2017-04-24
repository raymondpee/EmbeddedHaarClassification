`timescale 1 ns / 1 ns
module test_rom;

localparam ADDR_WIDTH = 12;
localparam DATA_WIDTH = 16;
localparam MEMORY_FILE = "Ram0.mif";

wire [DATA_WIDTH-1:0]data;
reg clk;
reg reset;
reg [ADDR_WIDTH-1:0]address;

/*--------------------------- INITIAL STATEMENT ---------------------------*/
initial
begin
  clk = 1;
  address = 0;
  reset =1;
  #1 reset = 0;
end
/*-----------------------------------------------------------------------*/


/*--------------------------- SEQUENTIAL LOGIC ---------------------------*/
// Clock:
always # 1 clk <= ~clk;

always @(posedge clk)
begin
	address <= address+1;
end


/*
stage_classifier_db
#(
.ADDR_WIDTH(ADDR_WIDTH), 
.DATA_WIDTH(DATA_WIDTH),
.MEMORY_FILE(MEMORY_FILE)
)
stage_classifier_db
(
	.clk(clk),
	reset(reset),
	o_is_end_reached(o_is_end_reached),
	address(address),
	classifier_size(classifier_size),
	q(out)
);
*/

rom 
#(
.ADDR_WIDTH(ADDR_WIDTH), 
.DATA_WIDTH(DATA_WIDTH),
.MEMORY_FILE(MEMORY_FILE)
)
rom
(
.address(address),
.clock(clk),
.q(data)
);



endmodule