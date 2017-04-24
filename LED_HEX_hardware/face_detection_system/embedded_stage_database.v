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
output [DATA_WIDTH_12-1:0] o_rom[NUM_DATABASE_INDEX-1:0];
/*-------------------------------------------------------*/

wire w_end_fifoin_database;
wire w_end_fifoout_database;
wire w_start_load;
wire [ADDR_WIDTH-1:0] w_index_fifoout_database;
wire [ADDR_WIDTH-1:0] w_index_fifoin_database;
wire [DATA_WIDTH_12-1:0] w_data;

integer k;
reg r_ren;
reg r_ready;
reg r_count_fifo_database;
reg [DATA_WIDTH_12-1:0] rom [NUM_DATABASE_INDEX-1:0];	

assign o_ready = r_ready;
assign o_rom = rom;

initial 
begin
	for(k = 0; k<NUM_DATABASE_INDEX; k = k+1)
	begin
		rom[k] =0;
	end
end

always@(posedge w_start_load) r_count_fifo_database<=1;

always@(posedge clk_fpga)
begin	
	if(reset_fpga)
	begin
		r_ren<=1;
		r_ready<=0;
		r_count_fifo_database<=0;
	end
	if(w_end_fifoin_database)
		r_ren<=0;
	if(r_count_fifo_database)
	begin
		if(w_end_fifoout_database)
		begin
			r_ready<=1;
			r_count_fifo_database<=0;
		end
		else
		begin			
			rom[w_index_fifoout_database] <= w_data;
			r_ready<=0;
			r_count_fifo_database<=1;
		end
	end
end


counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
)
counter_fifoout_database
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(r_count_fifo_database),
.ctr_out(w_index_fifoout_database),
.max_size(NUM_DATABASE_INDEX-1),
.end_count(w_end_fifoout_database)
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
.ren_database_index(r_ren),
.ren_database(r_ren),
.o_end_count(w_end_fifoin_database),
.o_start_load(w_start_load),
.o_data(w_data),
.o_address(w_index_fifoin_database)
);

endmodule