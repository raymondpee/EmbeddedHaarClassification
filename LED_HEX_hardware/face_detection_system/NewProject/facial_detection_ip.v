module facial_detection_ip
(
clk_os,
clk_fpga,
reset_os,
reset_fpga,
pixel
);

/*--------------------------------------------------------------------*/
/*---------------------------USER DEFINE-----------------------------*/
/*--------------------------------------------------------------------*/
localparam FRAME_CAMERA_WIDTH = 10;
localparam FRAME_CAMERA_HEIGHT = 10;
localparam INTEGRAL_LENGTH = 8;
localparam FILE_STAGE_1_MEM = ".//memory_mif//Ram0.mif";
localparam FILE_STAGE_2_MEM = ".//memory_mif//Ram1.mif";
localparam FILE_STAGE_3_MEM = ".//memory_mif//Ram2.mif";
localparam NUM_CLASSIFIERS_FIRST_STAGE = 10;
localparam NUM_CLASSIFIERS_SECOND_STAGE = 10;
localparam NUM_CLASSIFIERS_THIRD_STAGE = 10;
/*--------------------------------------------------------------------*/


/*---------------------------CONSTANTS--------------------------------*/
localparam ADDR_WIDTH;
localparam DATA_WIDTH_8 = 8;   // Max value 255
localparam DATA_WIDTH_12 = 12; // Max value 4095
localparam DATA_WIDTH_16 = 16; // Max value 177777
localparam NUM_STAGE_THRESHOLD = 3;
localparam NUM_PARAM_PER_CLASSIFIER = 18;
localparam INTEGRAL_WIDTH = INTEGRAL_LENGTH;
localparam INTEGRAL_HEIGHT = INTEGRAL_LENGTH;


input clk_os;
input clk_fpga;
input reset_os;
input reset_fpga;
input [DATA_WIDTH_8 -1:0] pixel;

wire ready;
wire first_phase_candidate;
wire second_phase_candidate;
wire third_phase_candidate;
wire [DATA_WIDTH_12 -1:0] o_scale_xcoord;
wire [DATA_WIDTH_12 -1:0] o_scale_ycoord;
wire [DATA_WIDTH_8-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];

reg [DATA_WIDTH_12 -1:0] xcoord;
reg [DATA_WIDTH_12 -1:0] ycoord;
reg [DATA_WIDTH_12 -1:0]frame_src_width;
reg [DATA_WIDTH_12 -1:0]frame_src_height;
reg [DATA_WIDTH_12 -1:0]frame_dst_width;
reg [DATA_WIDTH_12 -1:0]frame_dst_height;
wire [DATA_WIDTH_8-1:0] rom_stage1 [NUM_CLASSIFIERS_FIRST_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
wire [DATA_WIDTH_8-1:0] rom_stage2 [NUM_CLASSIFIERS_SECOND_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
wire [DATA_WIDTH_8-1:0] rom_stage3 [NUM_CLASSIFIERS_THIRD_STAGE*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	


always@(posedge reset_fpga)
begin
	frame_src_width <= FRAME_CAMERA_WIDTH;
	frame_src_height <= FRAME_CAMERA_HEIGHT;
	frame_dst_width<= FRAME_CAMERA_WIDTH; // Change this in future
	frame_dst_height <= FRAME_CAMERA_HEIGHT;
	xcoord <= 0;
	ycoord <= 0;	
end

/*------------------------ COORDINATE ITERATION -------------------------*/
always @(posedge clk_os)
begin
  if(xcoord == frame_src_width -1)
  begin 
      xcoord <= 0;
      if(ycoord == frame_src_height -1) ycoord <= 0;   
      else                          ycoord <= ycoord + 1;
  end
  else
    xcoord <= xcoord + 1;
end
/*-----------------------------------------------------------------------*/


I2LBS
#(
.DATA_WIDTH_8(DATA_WIDTH_8), 
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16),
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_CLASSIFIERS_FIRST_STAGE(NUM_CLASSIFIERS_FIRST_STAGE),
.NUM_CLASSIFIERS_SECOND_STAGE(NUM_CLASSIFIERS_SECOND_STAGE),
.NUM_CLASSIFIERS_THIRD_STAGE(NUM_CLASSIFIERS_THIRD_STAGE)
)
I2LBS
(
clk_os(clk_os),
clk_fpga(clk_fpga),
reset_os(reset_os),
reset_fpga(reset_fpga),
pixel(pixel),
xcoord(xcoord),
ycoord(ycoord),
frame_src_width(frame_src_width),
frame_src_height(frame_src_height),
frame_dst_width(frame_dst_width),
frame_dst_height(frame_dst_height),
rom_stage1(rom_stage1),
rom_stage2(rom_stage2),
rom_stage3(rom_stage3),
o_scale_xcoord(o_scale_xcoord),
o_scale_ycoord(o_scale_ycoord),
candidate(first_phase_candidate),
integral_image(integral_image)
);


first_phase_haar_cascade
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),  // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16),// Max value 177777
.FILE_STAGE_1_MEM(FILE_STAGE_1_MEM), 
.FILE_STAGE_2_MEM(FILE_STAGE_2_MEM), 
.FILE_STAGE_3_MEM(FILE_STAGE_3_MEM), 
.NUM_CLASSIFIERS_FIRST_STAGE(NUM_CLASSIFIERS_FIRST_STAGE),
.NUM_CLASSIFIERS_SECOND_STAGE(NUM_CLASSIFIERS_SECOND_STAGE), 
.NUM_CLASSIFIERS_THIRD_STAGE(NUM_CLASSIFIERS_THIRD_STAGE),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD)
)
first_phase_haar_cascade
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.ready(ready),
.rom_stage1(rom_stage1),
.rom_stage2(rom_stage2),
.rom_stage3(rom_stage3)	
);

second_phase_haar_cascade
#(
.NUM_RESIZE(NUM_RESIZE),
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
)
second_phase_haar_cascade
(
.clk_fpga(clk_fpga),
.reset_fpga(reset_fpga),
.integral_image(integral_image),
.enable(first_phase_candidate),
.candidate(second_phase_candidate)
);

endmodule