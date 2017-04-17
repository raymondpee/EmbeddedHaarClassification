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
	o_start_load,
	o_data,
	o_address
);

localparam NUM_DATABASE_INDEX = NUM_CLASSIFIERS_STAGE*NUM_PARAM_PER_CLASSIFIER;
input clk_fpga;
input reset_fpga;
input ren;
output o_end_count;
output o_start_load;
output [DATA_WIDTH_16-1:0] o_data;
output [ADDR_WIDTH-1:0] o_address;
 
wire end_count;
wire [ADDR_WIDTH-1:0] w_address; 
wire [DATA_WIDTH_12-1:0] w_rom_data;

reg r_start_load;
reg r_ren;
reg [ADDR_WIDTH-1:0] r_address; 
reg [DATA_WIDTH_12-1:0] r_rom_data;


assign o_start_load = r_start_load;
assign o_data = r_rom_data;
assign o_address = r_address;
assign o_end_count = end_count;


always@(r_rom_data)
begin
	if(r_start_load ==0)
	begin
		if(r_rom_data>0)
			r_start_load = 1;
	end
end

always @(posedge reset_fpga)
begin
	r_rom_data<=0;
	r_address<=0;
	r_start_load<=0;
end

always@(ren)
begin
	r_ren<=ren;
end


counter
#(
.DATA_WIDTH(DATA_WIDTH_16)
)
counter_stage
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(r_ren),
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
.ren(r_ren),
.address(r_address),
.q(r_rom_data)
);



endmodule