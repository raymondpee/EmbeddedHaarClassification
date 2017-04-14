module first_phase_haar_cascade
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter FILE_STAGE_1_MEM = "memory1.mif",
parameter FILE_STAGE_2_MEM = "memory2.mif",
parameter FILE_STAGE_3_MEM = "memory3.mif",
parameter NUM_CLASSIFIERS_FIRST_STAGE = 10,
parameter NUM_CLASSIFIERS_SECOND_STAGE = 10,
parameter NUM_CLASSIFIERS_THIRD_STAGE = 10,
parameter NUM_PARAM_PER_CLASSIFIER= 19,
parameter NUM_STAGE_THRESHOLD = 3
)
(
	clk_fpga,
	reset_fpga,
	ready,
	rom_stage1,
	rom_stage2,
	rom_stage3	
);

output ready;
output [DATA_WIDTH_8-1:0] rom_stage1 [NUM_CLASSIFIERS_FIRST_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
output [DATA_WIDTH_8-1:0] rom_stage2 [NUM_CLASSIFIERS_SECOND_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
output [DATA_WIDTH_8-1:0] rom_stage3 [NUM_CLASSIFIERS_THIRD_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	


wire address_stage1;
wire address_stage2;
wire address_stage3;

wire end_count_stage1;
wire end_count_stage2;
wire end_count_stage3;

wire [DATA_WIDTH_8 -1:0] q_stage1;
wire [DATA_WIDTH_8 -1:0] q_stage2;
wire [DATA_WIDTH_8 -1:0] q_stage3;

reg [DATA_WIDTH_8-1:0] reg_rom_stage1 [NUM_CLASSIFIERS_FIRST_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
reg [DATA_WIDTH_8-1:0] reg_rom_stage2 [NUM_CLASSIFIERS_SECOND_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
reg [DATA_WIDTH_8-1:0] reg_rom_stage3 [NUM_CLASSIFIERS_THIRD_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	

reg enable_stage1;
reg enable_stage2;
reg enable_stage3;

reg stage1_ready;
reg stage2_ready;
reg stage3_ready;

assign rom_stage1 = reg_rom_stage1;
assign rom_stage2 = reg_rom_stage2;
assign rom_stage3 = reg_rom_stage3;
assign ready = stage1_ready&& stage2_ready && stage3_ready;

always @(posedge reset_fpga)
begin
	enable_stage1<=1;
	enable_stage2<=1;
	enable_stage3<=1;
end

always@(posedge clk_fpga)
begin
	if(enable_stage1)
		if(end_count_stage1)
		begin
			enable_stage1<=0;
			stage1_ready<=1;
		end
		else
		begin
			reg_rom_stage1[address_stage1] <= q_stage1;
			stage1_ready<=0;
		end
end

always@(posedge clk_fpga)
begin
	if(enable_stage2)
		if(end_count_stage2)
		begin
			enable_stage2<=0;
			stage2_ready<=1;
		end
		else
		begin
			reg_rom_stage2[address_stage2] <= q_stage2;
			stage2_ready<=0;
		end
end

always@(posedge clk_fpga)
begin
	if(enable_stage3)
		if(end_count_stage3)
		begin
			enable_stage3<=0;
			stage3_ready<=1;
		end
		else
		begin
			reg_rom_stage3[address_stage3] <= q_stage3;
			stage3_ready<=0;
		end
end

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
.ADDR_WIDTH(ADDR_WIDTH)
)
counter_stage1
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(enable_stage1),
.ctr_out(address_stage1),
.max_size(NUM_CLASSIFIERS_FIRST_STAGE),
.end_count(end_count_stage1)
);

rom 
#(
.ADDR_WIDTH(ADDR_WIDTH), 
.DATA_WIDTH(DATA_WIDTH_8),
.MEMORY_FILE(FILE_STAGE_1_MEM)
)
rom_stage1
(
.clock(clk_fpga),
.address(address_stage1),
.q(q_stage1)
);

counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
.ADDR_WIDTH(ADDR_WIDTH)
)
counter_stage2
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(enable_stage2),
.ctr_out(address_stage2),
.max_size(NUM_CLASSIFIERS_SECOND_STAGE),
.end_count(end_count_stage2)
);

rom 
#(
.ADDR_WIDTH(ADDR_WIDTH), 
.DATA_WIDTH(DATA_WIDTH_8),
.MEMORY_FILE(FILE_STAGE_2_MEM)
)
rom_stage2
(
.clock(clk_fpga),
.address(address_stage2),
.q(q_stage2)
);


counter
#(
.DATA_WIDTH(DATA_WIDTH_12)
.ADDR_WIDTH(ADDR_WIDTH)
)
counter_stage3
(
.clk(clk_fpga),
.reset(reset_fpga),
.enable(enable_stage3),
.ctr_out(address_stage3),
.max_size(NUM_CLASSIFIERS_THIRD_STAGE),
.end_count(end_count_stage3)
);

rom 
#(
.ADDR_WIDTH(ADDR_WIDTH), 
.DATA_WIDTH(DATA_WIDTH_8),
.MEMORY_FILE(FILE_STAGE_3_MEM)
)
rom_stage3
(
.clock(clk_fpga),
.address(address_stage3),
.q(q_stage3)
);





endmodule