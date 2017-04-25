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
localparam FRAME_ORIGINAL_CAMERA_WIDTH = 10;
localparam FRAME_ORIGINAL_CAMERA_HEIGHT= 10;
localparam FRAME_RESIZE_CAMERA_WIDTH = FRAME_ORIGINAL_CAMERA_WIDTH/2;
localparam FRAME_RESIZE_CAMERA_HEIGHT = FRAME_ORIGINAL_CAMERA_HEIGHT/2;

localparam INTEGRAL_LENGTH = 24;
localparam NUM_CLASSIFIERS_STAGE_1 = 9;
localparam NUM_CLASSIFIERS_STAGE_2 = 16;
localparam NUM_CLASSIFIERS_STAGE_3 = 27;
localparam NUM_CLASSIFIERS_STAGE4 = 32;
localparam NUM_CLASSIFIERS_STAGE5 = 52;
localparam NUM_CLASSIFIERS_STAGE6 = 53;
localparam NUM_CLASSIFIERS_STAGE7 = 62;
localparam NUM_CLASSIFIERS_STAGE8 = 72;
localparam NUM_CLASSIFIERS_STAGE9 = 83;
localparam NUM_CLASSIFIERS_STAGE10 = 91;
localparam NUM_CLASSIFIERS_STAGE11 = 99;

localparam FILE_STAGE_1 = "Ram0.mif";
localparam FILE_STAGE_2 = "Ram1.mif";
localparam FILE_STAGE_3 = "Ram2.mif";
localparam FILE_STAGE4 = "Ram3.mif";
localparam FILE_STAGE5 = "Ram4.mif";
localparam FILE_STAGE6 = "Ram5.mif";
localparam FILE_STAGE7 = "Ram6.mif";
localparam FILE_STAGE8 = "Ram7.mif";
localparam FILE_STAGE9 = "Ram8.mif";
localparam FILE_STAGE10 = "Ram9.mif";
localparam FILE_STAGE11 = "Ram10.mif";

localparam NUM_STAGES_SECOND_PHASE = 8;

/*--------------------------------------------------------------------*/


/*---------------------------CONSTANTS--------------------------------*/

localparam DATA_WIDTH_8 = 8;   // Max value 255
localparam DATA_WIDTH_12 = 12; // Max value 4095
localparam DATA_WIDTH_16 = 16; // Max value 177777
localparam ADDR_WIDTH = DATA_WIDTH_12;
localparam NUM_STAGE_THRESHOLD = 3;
localparam NUM_PARAM_PER_CLASSIFIER = 18;
localparam INTEGRAL_WIDTH = INTEGRAL_LENGTH;
localparam INTEGRAL_HEIGHT = INTEGRAL_LENGTH;


input clk_os;
input clk_fpga;
input reset_os;
input reset_fpga;
input [DATA_WIDTH_12 -1:0] pixel;

wire ready;
wire first_phase_candidate;
wire second_phase_candidate;
wire third_phase_candidate;
wire [DATA_WIDTH_12 -1:0] o_scale_xcoord;
wire [DATA_WIDTH_12 -1:0] o_scale_ycoord;
wire [DATA_WIDTH_12 -1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];

wire second_phase_end;
wire [NUM_STAGES_SECOND_PHASE-1:0] second_phase_end_database;
wire [NUM_STAGES_SECOND_PHASE-1:0] second_phase_end_tree;
wire [NUM_STAGES_SECOND_PHASE-1:0] second_phase_end_single_classifier;
wire [NUM_STAGES_SECOND_PHASE-1:0] second_phase_end_all_classifier;
wire [DATA_WIDTH_12-1:0] second_phase_index_tree[NUM_STAGES_SECOND_PHASE-1:0];
wire [DATA_WIDTH_12-1:0] second_phase_index_classifier[NUM_STAGES_SECOND_PHASE-1:0];
wire [DATA_WIDTH_12-1:0] second_phase_index_database[NUM_STAGES_SECOND_PHASE-1:0];
wire [DATA_WIDTH_12-1:0] second_phase_data[NUM_STAGES_SECOND_PHASE-1:0]; 

wire [DATA_WIDTH_12-1:0] rom_stage1 [NUM_CLASSIFIERS_STAGE_1*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
wire [DATA_WIDTH_12-1:0] rom_stage2 [NUM_CLASSIFIERS_STAGE_2*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
wire [DATA_WIDTH_12-1:0] rom_stage3 [NUM_CLASSIFIERS_STAGE_3*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	


reg [DATA_WIDTH_12 -1:0]ori_x;
reg [DATA_WIDTH_12 -1:0]ori_y;


always@(posedge reset_fpga)
begin
	ori_x <= 0;
	ori_y <= 0;	
end

/*------------------------ COORDINATE ITERATION -------------------------*/
always @(posedge clk_os)
begin
  if(ori_x == FRAME_ORIGINAL_CAMERA_WIDTH -1)
  begin 
      ori_x <= 0;
      if(ori_y == FRAME_ORIGINAL_CAMERA_HEIGHT -1) ori_y <= 0;   
      else                          ori_y <= ori_y + 1;
  end
  else
    ori_x <= ori_x + 1;
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
.NUM_STAGES_SECOND_PHASE(NUM_STAGES_SECOND_PHASE),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_CLASSIFIERS_STAGE_1(NUM_CLASSIFIERS_STAGE_1),
.NUM_CLASSIFIERS_STAGE_2(NUM_CLASSIFIERS_STAGE_2),
.NUM_CLASSIFIERS_STAGE_3(NUM_CLASSIFIERS_STAGE_3),
.FRAME_ORIGINAL_CAMERA_WIDTH(FRAME_ORIGINAL_CAMERA_WIDTH),
.FRAME_ORIGINAL_CAMERA_HEIGHT(FRAME_ORIGINAL_CAMERA_HEIGHT),
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT)
)
I2LBS
(
.clk_os(clk_os),
.clk_fpga(clk_fpga),
.reset_os(reset_os),
.reset_fpga(reset_fpga),
.pixel(pixel),
.ori_x(ori_x),
.ori_y(ori_y),
.rom_stage1(rom_stage1),
.rom_stage2(rom_stage2),
.rom_stage3(rom_stage3),
.second_phase_index_tree(second_phase_index_tree),
.second_phase_index_classifier(second_phase_index_classifier),
.second_phase_index_database(second_phase_index_database),
.second_phase_data(second_phase_data),
.second_phase_end(second_phase_end),
.second_phase_end_single_classifier(second_phase_end_single_classifier),
.second_phase_end_all_classifier(second_phase_end_all_classifier),
.second_phase_end_tree(second_phase_end_tree),
.second_phase_end_database(second_phase_end_database),	
.o_scale_xcoord(o_scale_xcoord),
.o_scale_ycoord(o_scale_ycoord),
.o_first_phase_candidate(first_phase_candidate),
.o_integral_image(integral_image)
);


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

v_second_phase_haar_cascade
#(
.NUM_STAGES(NUM_STAGES_SECOND_PHASE),
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH_8(DATA_WIDTH_8),   // Max value 255
.DATA_WIDTH_12(DATA_WIDTH_12), // Max value 4095
.DATA_WIDTH_16(DATA_WIDTH_16), // Max value 177777
.NUM_STAGE_THRESHOLD(NUM_STAGE_THRESHOLD),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.FILE_STAGE4(FILE_STAGE4), 
.FILE_STAGE5(FILE_STAGE5), 
.FILE_STAGE6(FILE_STAGE6), 
.FILE_STAGE7(FILE_STAGE7), 
.FILE_STAGE8(FILE_STAGE8), 
.FILE_STAGE9(FILE_STAGE9), 
.FILE_STAGE10(FILE_STAGE10), 
.FILE_STAGE11(FILE_STAGE11), 
.NUM_CLASSIFIERS_STAGE4(NUM_CLASSIFIERS_STAGE4), 
.NUM_CLASSIFIERS_STAGE5(NUM_CLASSIFIERS_STAGE5), 
.NUM_CLASSIFIERS_STAGE6(NUM_CLASSIFIERS_STAGE6), 
.NUM_CLASSIFIERS_STAGE7(NUM_CLASSIFIERS_STAGE7), 
.NUM_CLASSIFIERS_STAGE8(NUM_CLASSIFIERS_STAGE8), 
.NUM_CLASSIFIERS_STAGE9(NUM_CLASSIFIERS_STAGE9), 
.NUM_CLASSIFIERS_STAGE10(NUM_CLASSIFIERS_STAGE10), 
.NUM_CLASSIFIERS_STAGE11(NUM_CLASSIFIERS_STAGE11) 
)
v_second_phase_haar_cascade
(
.clk_fpga(clk),
.reset_fpga(reset),
.i_rden(first_phase_candidate),
.o_index_tree(second_phase_index_tree),
.o_index_classifier(second_phase_index_classifier),
.o_index_database(second_phase_index_database),
.o_data(second_phase_data),	
.o_end(second_phase_end),
.o_end_all_classifier(second_phase_end_all_classifier),
.o_end_single_classifier(second_phase_end_single_classifier),
.o_end_tree(second_phase_end_tree),
.o_end_database(second_phase_end_database)
);

endmodule