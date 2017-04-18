module embedded_stage_database
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter NUM_CLASSIFIERS = 10,
parameter NUM_PARAM_PER_CLASSIFIER= 19,
parameter NUM_STAGE_THRESHOLD = 3,
parameter FILE_STAGE_MEM = "memory.mif"
)
(
	clk_fpga,
	reset_fpga,
	o_ready,
	o_rom
);

localparam NUM_DATABASE_INDEX = NUM_CLASSIFIERS*NUM_PARAM_PER_CLASSIFIER + NUM_STAGE_THRESHOLD;

/*-----------------IO Port declaration -----------------*/
input clk_fpga;
input reset_fpga;
output o_ready;
output [DATA_WIDTH_16-1:0] o_rom[NUM_DATABASE_INDEX-1:0];
/*-------------------------------------------------------*/

wire end_count;
wire end_count_database_index;
wire [ADDR_WIDTH-1:0] address;
wire [DATA_WIDTH_16-1:0] data;
wire start_load;
wire [ADDR_WIDTH-1:0] database_index;

integer k;
reg r_ren;
reg ready;
reg ren_database_index;
reg [DATA_WIDTH_16-1:0] rom [NUM_DATABASE_INDEX-1:0];	

assign o_ready = ready;
assign o_rom = rom;

initial 
begin
	for(k = 0; k<NUM_DATABASE_INDEX; k = k+1)
	begin
		rom[k] =0;
	end
end


always@(posedge clk_fpga)
begin
	if(ren)
		r_ren<=1;
	if(end_count)
		r_ren<=0;
end

always@(posedge start_load)
begin
	ren_database_index<=1;
end

always@(posedge clk_fpga)
begin	
	if(ren_database_index)
	begin
		if(end_count_database_index)
		begin
			ready<=1;
			ren_database_index<=0;
		end
		else
		begin			
			rom[database_index] <= data;
			ready<=0;
			ren_database_index<=1;
		end
	end
end


counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_stage
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(ren_database_index),
.ctr_out(database_index),
.max_size(NUM_DATABASE_INDEX),
.end_count(end_count_database_index)
);


stage_database
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.FILE_STAGE_MEM(FILE_STAGE_MEM),
.NUM_DATABASE_INDEX(NUM_DATABASE_INDEX)
)
stage_database
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.ren(r_ren),
.o_end_count(end_count),
.o_start_load(start_load),
.o_data(data),
.o_address(address)
);

endmodule