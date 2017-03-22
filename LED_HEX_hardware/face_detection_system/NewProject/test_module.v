module test_module;


/*-----------------------------------------------------------------------*//*-----------------------------------------------------------------------*/
/*----GENERAL DEFINITION-----*/
localparam BYTE_WIDTH     = 8;
localparam BYTE_DOUBLE_WIDTH = 16;

/*---- FIFO definition -----*/
localparam ADDR_WIDTH = 4; // we put 4 bit of address width to test first
localparam DATA_WIDTH = BYTE_WIDTH;
localparam FIFO_COMPONENT_COUNT = 6;
localparam MAX_VAL = 255;

/*----- Width and Height of the frame ----*/
//Original size of the frame 
localparam FRAME_WIDTH  = 10;
localparam FRAME_HEIGHT = 10;
//Size of the frame after resize
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



/*----- Region of clock management -----*/
initial
begin
  clk = 0;
  wen = 1;
  #1 reset_os = 1;
  #1 reset_os = 0;
end

always
# 1 clk <= ~clk;


/*----Region to define each pixel iteration-----*/
always @(posedge clk)
begin
  if(pixel == MAX_VAL)
    pixel <= 0;
  else
    pixel <= pixel + 1;
end

/*----- Region for each coordinate iteration ----*/
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
.clk(clk),
.i_xcoord(xcoord),
.i_ycoord(ycoord),
.o_xcoord(scale_xcoord),
.o_ycoord(scale_ycoord),
.o_isreach(is_coord_reach)
);

memory 
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH(DATA_WIDTH),
.FIFO_COMPONENT_COUNT(FIFO_COMPONENT_COUNT)
)
memory 
(
.clk(clk),
.reset_os(reset_os),
.pixel(pixel),
.wen(wen)
);

endmodule
