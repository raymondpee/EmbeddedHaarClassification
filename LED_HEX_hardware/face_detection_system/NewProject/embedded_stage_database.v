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

localparam NUM_DATABASE_INDEX = NUM_CLASSIFIERS*NUM_PARAM_PER_CLASSIFIER;

/*-----------------IO Port declaration -----------------*/
input clk_fpga;
input reset_fpga;
output o_ready;
output [DATA_WIDTH_16-1:0] o_rom[NUM_CLASSIFIERS*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];
/*-------------------------------------------------------*/

wire end_count;
wire [ADDR_WIDTH-1:0] address;
wire [DATA_WIDTH_16-1:0] data;
wire start_load;
wire [ADDR_WIDTH-1:0] database_index;


reg ren;
reg ready;
reg [DATA_WIDTH_16-1:0] rom [NUM_CLASSIFIERS*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	

assign o_ready = ready;
assign o_rom = rom;


always@(posedge reset_fpga)
begin
	if(reset_fpga)
	begin
		ren<=1;
	end
end


always@(posedge clk_fpga)
begin	
	if(start_load)
	begin
		if(end_count)
		begin
			ren<=0;
			ready<=1;
		end
		else
		begin
			rom[database_index] <= data;
			ready<=0;
		end
	end
end

counter
#(
.DATA_WIDTH(DATA_WIDTH_8)
)
counter_stage
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(start_load),
.ctr_out(database_index),
.max_size(NUM_DATABASE_INDEX),
.end_count(end_count)
);


stage_database
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.FILE_STAGE_MEM(FILE_STAGE_MEM),
.NUM_CLASSIFIERS_STAGE(NUM_CLASSIFIERS),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER)
)
stage_database
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.ren(ren),
.o_end_count(end_count),
.o_start_load(start_load),
.o_data(data),
.o_address(address)
);

endmodule