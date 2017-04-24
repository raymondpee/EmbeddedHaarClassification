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

localparam SECOND_PHASE_NUM_STAGES = 8;

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

wire w_end;
wire ready;
wire [SECOND_PHASE_NUM_STAGES-1:0] end_database;
wire [SECOND_PHASE_NUM_STAGES-1:0] end_tree;
wire [SECOND_PHASE_NUM_STAGES-1:0] end_single_classifier;
wire [SECOND_PHASE_NUM_STAGES-1:0] end_all_classifier;
wire [ADDR_WIDTH-1:0] index_tree[SECOND_PHASE_NUM_STAGES-1:0];
wire [ADDR_WIDTH-1:0] index_classifier[SECOND_PHASE_NUM_STAGES-1:0];
wire [ADDR_WIDTH-1:0] index_database[SECOND_PHASE_NUM_STAGES-1:0];
wire [DATA_WIDTH_12-1:0] data[SECOND_PHASE_NUM_STAGES-1:0]; 

wire [DATA_WIDTH_8-1:0] rom_stage1 [NUM_CLASSIFIERS_STAGE_1*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
wire [DATA_WIDTH_8-1:0] rom_stage2 [NUM_CLASSIFIERS_STAGE_2*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	
wire [DATA_WIDTH_8-1:0] rom_stage3 [NUM_CLASSIFIERS_STAGE_3*NUM_PARAM_PER_CLASSIFIER+NUM_STAGE_THRESHOLD-1:0];	


reg [DATA_WIDTH_12 -1:0] xcoord;
reg [DATA_WIDTH_12 -1:0] ycoord;
reg [DATA_WIDTH_12 -1:0]frame_src_width;
reg [DATA_WIDTH_12 -1:0]frame_src_height;
reg [DATA_WIDTH_12 -1:0]frame_dst_width;
reg [DATA_WIDTH_12 -1:0]frame_dst_height;



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
.SECOND_PHASE_NUM_STAGES(SECOND_PHASE_NUM_STAGES),
.NUM_PARAM_PER_CLASSIFIER(NUM_PARAM_PER_CLASSIFIER),
.NUM_CLASSIFIERS_STAGE_1(NUM_CLASSIFIERS_STAGE_1),
.NUM_CLASSIFIERS_STAGE_2(NUM_CLASSIFIERS_STAGE_2),
.NUM_CLASSIFIERS_STAGE_3(NUM_CLASSIFIERS_STAGE_3)
)
I2LBS
(
.clk_os(clk_os),
.clk_fpga(clk_fpga),
.reset_os(reset_os),
.reset_fpga(reset_fpga),
.pixel(pixel),
.xcoord(xcoord),
.ycoord(ycoord),
.frame_src_width(frame_src_width),
.frame_src_height(frame_src_height),
.frame_dst_width(frame_dst_width),
.frame_dst_height(frame_dst_height),
.rom_stage1(rom_stage1),
.rom_stage2(rom_stage2),
.rom_stage3(rom_stage3),
.o_first_phase_candidate(first_phase_candidate),
.o_integral_image(integral_image),
.o_scale_xcoord(o_scale_xcoord),
.o_scale_ycoord(o_scale_ycoord)
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
.NUM_STAGES(SECOND_PHASE_NUM_STAGES),
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
.o_index_tree(index_tree),
.o_index_classifier(index_classifier),
.o_index_database(index_database),
.o_data(data),	
.o_end(w_end),
.o_end_all_classifier(end_all_classifier),
.o_end_single_classifier(end_single_classifier),
.o_end_tree(end_tree),
.o_end_database(end_database)
);

endmodule