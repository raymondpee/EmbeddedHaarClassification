`timescale 1 ns / 1 ns
module test_v_first_phase_haar_cascade;

localparam ADDR_WIDTH = 12;
localparam DATA_WIDTH_8 = 8;   // Max value 255
localparam DATA_WIDTH_12 = 12; // Max value 4095
localparam DATA_WIDTH_16 = 16; // Max value 177777
localparam NUM_PARAM_PER_CLASSIFIER= 19;
localparam NUM_STAGE_THRESHOLD = 3;

localparam NUM_CLASSIFIERS_STAGE_1 = 9;
localparam NUM_CLASSIFIERS_STAGE_2 = 16;
localparam NUM_CLASSIFIERS_STAGE_3 = 27;
localparam FILE_STAGE_1 = "Ram0.mif";
localparam FILE_STAGE_2 = "Ram1.mif";
localparam FILE_STAGE_3 = "Ram2.mif";


reg clk;
reg reset;


/*--------------------------- INITIAL STATEMENT ---------------------------*/
initial
begin
  clk = 0;
  #1 reset =1;
  #1 reset = 0;
end
/*-----------------------------------------------------------------------*/


/*--------------------------- SEQUENTIAL LOGIC ---------------------------*/
// Clock:
always # 1 clk <= ~clk;

wire ready;
wire [DATA_WIDTH_16-1:0] rom_stage1[NUM_CLASSIFIERS_STAGE_1*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];

v_first_phase_haar_cascade
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.NUM_CLASSIFIERS_STAGE_1(NUM_CLASSIFIERS_STAGE_1),
.NUM_CLASSIFIERS_STAGE_2(NUM_CLASSIFIERS_STAGE_2),
.NUM_CLASSIFIERS_STAGE_3(NUM_CLASSIFIERS_STAGE_3),
.FILE_STAGE_1(FILE_STAGE_1),
.FILE_STAGE_2(FILE_STAGE_2),
.FILE_STAGE_3(FILE_STAGE_3),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD)
)
v_first_phase_haar_cascade
(
.clk_fpga(clk),
.reset_fpga(reset),
.o_ready(ready),
.o_rom_stage1(rom_stage1)
);

endmodule