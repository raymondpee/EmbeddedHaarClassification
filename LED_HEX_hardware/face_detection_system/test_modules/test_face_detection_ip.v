// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns  //Assume our clock frequency is 100MHz
module test_face_detection_ip;

localparam DATA_WIDTH_12 = 12;
localparam MAX_VAL = 255;

wire pixel_request;
reg clk = 0;
reg reset = 0;
reg [DATA_WIDTH_12-1:0] pixel = 0; // Pixel of the image

/*--------------------------- INITIAL STATEMENT ---------------------------*/
initial
begin
  clk = 0;
  #1 reset <= 1;
  #1 reset <= 0;
end
/*-----------------------------------------------------------------------*/


/*--------------------------- SEQUENTIAL LOGIC ---------------------------*/
// Clock:
always # 1 clk <= ~clk;

//Pixel Iteration:
always @(posedge clk)
begin
	if(pixel_request)
	begin
	  if(pixel == MAX_VAL)
		pixel <= 0;
	  else
		pixel <= pixel + 1;
	end
end
/*-----------------------------------------------------------------------*/

/*------------------------VERILOG MODULES--------------------------------*/

facial_detection_ip
facial_detection_ip
(
.clk(clk),
.reset(reset),
.pixel(pixel),
.o_pixel_request(pixel_request)
);
/*-----------------------------------------------------------------------*/

endmodule
