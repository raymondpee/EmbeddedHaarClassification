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
/*-----------------------------------------------------------------------*/

wire is_coord_reach;
wire [BYTE_DOUBLE_WIDTH -1:0] scale_xcoord; // Coordinate X of the image
wire [BYTE_DOUBLE_WIDTH -1:0] scale_ycoord; // Coordinate Y of the image

reg clk;
reg reset_os;
reg wen;
reg [BYTE_WIDTH -1:0] pixel = 0; // Pixel of the image
reg [BYTE_DOUBLE_WIDTH -1:0] xcoord = 0; // Coordinate X of the image
reg [BYTE_DOUBLE_WIDTH -1:0] ycoord = 0; // Coordinate Y of the image



/*--------------------------- INITIAL STATEMENT ---------------------------*/
initial
begin
  wen = 1;
  clk = 0;
  #1 reset_os = 1;
  #1 reset_os = 0;
end
/*-----------------------------------------------------------------------*/


/*--------------------------- SEQUENTIAL LOGIC ---------------------------*/
// Clock:
always
# 1 clk <= ~clk;

//Pixel Iteration:
always @(posedge clk)
begin
  if(pixel == MAX_VAL)
    pixel <= 0;
  else
    pixel <= pixel + 1;
end
/*-----------------------------------------------------------------------*/


/*------------------------ COORDINATE ITERATION -------------------------*/
always @(posedge clk)
begin
  if(xcoord == FRAME_WIDTH -1)
  begin 
      xcoord <= 0;
      if(ycoord == FRAME_HEIGHT -1) ycoord <= 0;   
      else                          ycoord <= ycoord + 1;
  end
  else
    xcoord <= xcoord + 1;
end
/*-----------------------------------------------------------------------*/


/*------------------------VERILOG MODULES--------------------------------*/
/*  [We close this for now, we want to debug]
resize
#(
.BYTE_WIDTH(BYTE_WIDTH),
.BYTE_DOUBLE_WIDTH(BYTE_DOUBLE_WIDTH),
.SRC_WIDTH(FRAME_WIDTH),
.SRC_HEIGHT(FRAME_HEIGHT),
.DST_WIDTH(FRAME_DST_WIDTH),
.DST_HEIGHT(FRAME_DST_HEIGHT)
)
resize_half
(
.clk_os(clk),
.i_xcoord(xcoord),
.i_ycoord(ycoord),
.o_xcoord(scale_xcoord),
.o_ycoord(scale_ycoord),
.o_isreach(is_coord_reach)
);
*/

memory 
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH(DATA_WIDTH),
.FIFO_COMPONENT_COUNT(FIFO_COMPONENT_COUNT)
)
memory 
(
.clk_os(clk),
.reset_os(reset_os),
.pixel(pixel),
.wen(wen)
);
/*-----------------------------------------------------------------------*/

endmodule
