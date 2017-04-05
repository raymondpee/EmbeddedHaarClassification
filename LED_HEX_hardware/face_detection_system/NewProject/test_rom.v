`timescale 1 ns / 1 ns
module test_rom;

localparam ADDR_WIDTH = 12;
localparam DATA_WIDTH = 8;
localparam MEMORY_FILE = "memory.mif";

reg clk;
reg reset;
reg [DATA_WIDTH-1:0]data;
reg [ADDR_WIDTH-1:0]address;

/*--------------------------- INITIAL STATEMENT ---------------------------*/
initial
begin
  clk = 0;
  #1reset =1;
end
/*-----------------------------------------------------------------------*/


/*--------------------------- SEQUENTIAL LOGIC ---------------------------*/
// Clock:
always # 1 clk <= ~clk;

always @(posedge clk)
begin
	address = address+1;
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
.clock(clk),
.q(data)
);


endmodule