// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns
module test_face_detection_ip;

localparam DATA_WIDTH_12 = 12;
localparam MAX_VAL = 255;

reg clk_os = 0;
reg reset_os = 0;
reg clk_fpga = 0;
reg reset_fpga = 0;
reg [DATA_WIDTH_12-1:0] pixel = 0; // Pixel of the image

/*--------------------------- INITIAL STATEMENT ---------------------------*/
initial
begin
  clk_os = 0;
  clk_fpga = 0;
  #1 
  reset_os <= 1;
  reset_fpga<=1;
  #1 
  reset_os <= 0;
  reset_fpga<=0;
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

facial_detection_ip
facial_detection_ip
(
.clk_os(clk_os),
.clk_fpga(clk_fpga),
.reset_os(reset_os),
.reset_fpga(reset_fpga),
.pixel(pixel)
);
/*-----------------------------------------------------------------------*/

endmodule
