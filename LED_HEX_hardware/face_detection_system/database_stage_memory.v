module database_stage_memory
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter FILE_STAGE_MEM = "ram1.mif",
parameter SIZE_STAGE = 10
)
(
	clk,
	reset,
	ren_database_index,
	ren_database,
	o_data
);


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
input clk;
input reset;
input ren_database_index;
input ren_database;
output [DATA_WIDTH_16-1:0] o_data;

/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/
wire [ADDR_WIDTH-1:0] w_address; 
wire [DATA_WIDTH_12-1:0] w_rom_data;

reg [ADDR_WIDTH-1:0] address; 
reg [DATA_WIDTH_12-1:0] data;

/*****************************************************************************
 *                            Combinational logic                             *
 *****************************************************************************/
assign o_data = data;
assign o_address = address;

/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 
always @(posedge reset)
begin
	data<=0;
	address<=0;
end

/*****************************************************************************
*                                   Modules                                  *
*****************************************************************************/ 
 
counter
#(
.DATA_WIDTH(DATA_WIDTH_16)
)
counter_database_index
(
.clk(clk),
.reset(reset),
.enable(ren_database_index),
.ctr_out(address),
.max_size(SIZE_STAGE-1),
.end_count(w_end_count)
);

rom 
#(
.ADDR_WIDTH(ADDR_WIDTH), 
.DATA_WIDTH(DATA_WIDTH_16),
.MEMORY_FILE(FILE_STAGE_MEM)
)
rom_database
(
.clock(clk),
.ren(ren_database),
.address(address),
.q(data)
);



endmodule