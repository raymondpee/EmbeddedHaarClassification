module stage_database
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter FILE_STAGE_MEM = "ram1.mif",
parameter NUM_DATABASE_INDEX = 10
)
(
	clk_fpga,
	reset_fpga,
	ren_database_index,
	ren_database,
	o_end_count,
	o_start_load,
	o_data,
	o_address
);
input clk_fpga;
input reset_fpga;
input ren_database_index;
input ren_database;
output o_end_count;
output o_start_load;
output [DATA_WIDTH_16-1:0] o_data;
output [ADDR_WIDTH-1:0] o_address;


wire w_end_count; 
wire [ADDR_WIDTH-1:0] w_address; 
wire [DATA_WIDTH_12-1:0] w_rom_data;


reg r_start_load;
reg [ADDR_WIDTH-1:0] r_address; 
reg [DATA_WIDTH_12-1:0] r_rom_data;


assign o_start_load = r_start_load;
assign o_data = r_rom_data;
assign o_address = r_address;
assign o_end_count = w_end_count;

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


counter
#(
.DATA_WIDTH(DATA_WIDTH_16)
)
counter_database_index
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(ren_database_index),
.ctr_out(r_address),
.max_size(NUM_DATABASE_INDEX-1),
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
.clock(clk_fpga),
.ren(ren_database),
.address(r_address),
.q(r_rom_data)
);



endmodule