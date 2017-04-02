// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns
module test_module;

/*------------------------------LOCALPARAM------------------------------*/
localparam BYTE_WIDTH     = 8;
localparam BYTE_DOUBLE_WIDTH = 16;
localparam ADDR_WIDTH = 4; // we put 4 bit of address width to test first
localparam DATA_WIDTH = BYTE_WIDTH;
localparam FIFO_COMPONENT_COUNT = 6;
localparam MAX_VAL = 255;
localparam FRAME_WIDTH  = 10;
localparam FRAME_HEIGHT = 10;
localparam FRAME_DST_WIDTH  = FRAME_WIDTH/2;
localparam FRAME_DST_HEIGHT = FRAME_HEIGHT/2;

// Classifier level declaration
localparam NUM_PARAM_PER_CLASSIFIER = 18;
localparam NUM_FIRST_STAGE_CLASSIFIERS = 150;
localparam NUM_FIRST_CLASSIFIER_STAGES = 3;
/*-----------------------------------------------------------------------*/

wire is_coord_reach;
wire is_candidate;
wire [BYTE_DOUBLE_WIDTH -1:0] scale_xcoord; // Coordinate X of the image
wire [BYTE_DOUBLE_WIDTH -1:0] scale_ycoord; // Coordinate Y of the image
wire [DATA_WIDTH-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];

reg clk_os;
reg reset_os;
reg clk_fpga;
reg reset_fpga;
reg wen;
reg [BYTE_WIDTH -1:0] pixel = 0; // Pixel of the image
reg [BYTE_DOUBLE_WIDTH -1:0] xcoord = 0; // Coordinate X of the image
reg [BYTE_DOUBLE_WIDTH -1:0] ycoord = 0; // Coordinate Y of the image
reg [BYTE_WIDTH -1:0] memory_first_stage_classifier [NUM_FIRST_STAGE_CLASSIFIERS*NUM_PARAM_PER_CLASSIFIER -1:0];


/*--------------------------- INITIAL STATEMENT ---------------------------*/
initial
begin
  wen = 1;
  clk_os = 0;
  clk_fpga = 0;
  #1 reset_os = 1;
  #1 reset_os = 0;
end
/*-----------------------------------------------------------------------*/


/*--------------------------- SEQUENTIAL LOGIC ---------------------------*/
// Clock:
always # 1 clk_os <= ~clk_os;
always # 1 clk_fpga <= ~clk_fpga; 

//Pixel Iteration:
always @(posedge clk_os)
begin
  if(pixel == MAX_VAL)
    pixel <= 0;
  else
    pixel <= pixel + 1;
end
/*-----------------------------------------------------------------------*/





/*------------------------VERILOG MODULES--------------------------------*/


/*-----------------------------------------------------------------------*/

endmodule
