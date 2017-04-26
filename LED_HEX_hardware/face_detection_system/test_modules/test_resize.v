`timescale 1 ns / 1 ns
module test_resize;

localparam DATA_WIDTH_8 = 8;
localparam DATA_WIDTH_12 = 12;
localparam DATA_WIDTH_16 = 16;
localparam FRAME_ORIGINAL_CAMERA_WIDTH = 800;
localparam FRAME_ORIGINAL_CAMERA_HEIGHT = 600;
localparam FRAME_RESIZE_CAMERA_WIDTH = FRAME_ORIGINAL_CAMERA_WIDTH/2;
localparam FRAME_RESIZE_CAMERA_HEIGHT = FRAME_ORIGINAL_CAMERA_HEIGHT/2;

reg clk;
reg reset;
reg enable;

/*--------------------------- INITIAL STATEMENT ---------------------------*/
initial
begin
  clk = 0;
  #1 reset =1;
  #1 reset = 0;
end
/*-----------------------------------------------------------------------*/


initial
begin
	#1 enable = 1;
	#20 enable = 1;
end

/*--------------------------- SEQUENTIAL LOGIC ---------------------------*/
// Clock:
always # 1 clk <= ~clk;

reg [DATA_WIDTH_12 -1:0]ori_x;
reg [DATA_WIDTH_12 -1:0]ori_y;
always@(posedge reset)
begin
	ori_x <= 0;
	ori_y <= 0;	
end

/*------------------------ COORDINATE ITERATION -------------------------*/
always @(posedge clk)
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

wire o_reach;
wire [DATA_WIDTH_16-1:0] o_resize_x;
wire [DATA_WIDTH_16-1:0] o_resize_y;



resize
#(
.DATA_WIDTH_8(DATA_WIDTH_8),  
.DATA_WIDTH_12(DATA_WIDTH_12),
.DATA_WIDTH_16(DATA_WIDTH_16),
.FRAME_ORIGINAL_CAMERA_WIDTH(FRAME_ORIGINAL_CAMERA_WIDTH), 
.FRAME_ORIGINAL_CAMERA_HEIGHT(FRAME_ORIGINAL_CAMERA_HEIGHT),
.FRAME_RESIZE_CAMERA_WIDTH(FRAME_RESIZE_CAMERA_WIDTH),
.FRAME_RESIZE_CAMERA_HEIGHT(FRAME_RESIZE_CAMERA_HEIGHT)
)
resize
(
.clk_os(clk),    
.ori_x(ori_x),  
.ori_y(ori_y),  
.o_resize_x(o_resize_x),  
.o_resize_y(o_resize_y),  
.o_reach(o_reach)  
);

endmodule