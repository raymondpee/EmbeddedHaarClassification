module stage_database
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter FILE_STAGE_MEM = "ram1.mif",
parameter NUM_CLASSIFIERS_STAGE = 10,
parameter NUM_PARAM_PER_CLASSIFIER = 18
)
(
	clk_fpga,
	reset_fpga,
	ren,
	o_end_count,
	o_data,
	o_address
);

localparam NUM_DATABASE_INDEX = NUM_CLASSIFIERS_STAGE*NUM_PARAM_PER_CLASSIFIER;
input clk_fpga;
input reset_fpga;
input ren;
output o_end_count;
output [DATA_WIDTH_16-1:0] o_data;
output [ADDR_WIDTH-1:0] o_address;
 
wire end_count;
wire [ADDR_WIDTH-1:0] w_address; 
wire [DATA_WIDTH_12-1:0] w_rom_data;

reg [ADDR_WIDTH-1:0] r_address; 
reg [DATA_WIDTH_12-1:0] r_rom_data;

assign o_data = r_rom_data;
assign o_address = r_address;
assign o_end_count = end_count;

initial 
begin
	r_address = 0;
	r_rom_data =0;
end

counter
#(
.DATA_WIDTH(DATA_WIDTH_16)
)
counter_stage
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(ren),
.ctr_out(r_address),
.max_size(NUM_DATABASE_INDEX),
.end_count(end_count)
);

rom 
#(
.ADDR_WIDTH(ADDR_WIDTH), 
.DATA_WIDTH(DATA_WIDTH_16),
.MEMORY_FILE(FILE_STAGE_MEM)
)
rom_stage
(
.clock(clk_fpga),
.address(r_address),
.q(r_rom_data)
);



endmodule