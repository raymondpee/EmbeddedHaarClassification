// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns  //Assume our clock frequency is 100MHz
module test_face_detection_ip;

reg clk = 0;
always # 1 clk <= ~clk;


/*------------------------------ADAPTER FOR THE HARDWARE--------------------*/


localparam DATA_WIDTH_12 = 12;
localparam MAX_VAL = 255;

localparam NUM_STATE = 4;
localparam RESET = 0;
localparam PIXEL_INPUT_START = 1;
localparam PIXEL_INPUT_END = 2;
localparam FRAME_END = 3;

wire end_frame;
wire ready_recieve_pixel_ip;
wire end_recieve_pixel;
wire is_init;
reg lwhpcfpga_pixel_input;
reg init = 0;
reg trig_reset = 0;
reg [NUM_STATE-1:0] state = 0;
reg [NUM_STATE-1:0] next_state;
reg [DATA_WIDTH_12-1:0] pixel; // Pixel of the image


wire o_ready_recieve_pixel; 

assign is_init = init == 1;
assign o_ready_recieve_pixel = ready_recieve_pixel_ip;
assign end_recieve_pixel = lwhpcfpga_pixel_input;

always@(posedge clk)
begin
	if(trig_reset)
	begin
		init <=1;
		state <=RESET;
		next_state<=0;
		pixel<=0;
		trig_reset <= 0;
		lwhpcfpga_pixel_input<=0;
	end
	else
	begin
		state<= next_state;	
	end
end


always@(*)
begin
	next_state = state;
	case (state)
	RESET:
	begin
		if(!is_init || end_frame)
			trig_reset=1;
		if(ready_recieve_pixel_ip)	
			next_state = PIXEL_INPUT_START;
	end
	PIXEL_INPUT_START:
	begin
		if(end_recieve_pixel)
			next_state = PIXEL_INPUT_END;
		if(end_frame)
			next_state = RESET;
	end
	PIXEL_INPUT_END:
	begin
		lwhpcfpga_pixel_input<=0;
		if(ready_recieve_pixel_ip)	
			next_state = PIXEL_INPUT_START;
		if(end_frame)
			next_state = RESET;
	end
	endcase
end


//Pixel Input [Assume this is from the c language]
always @(posedge clk)
begin
	if(o_ready_recieve_pixel)
	begin
	  if(pixel == MAX_VAL)
		pixel <= 0;
	  else
		pixel <= pixel + 1;
	lwhpcfpga_pixel_input<=1;
	end
end


facial_detection_ip
facial_detection_ip
(
.clk(clk),
.reset(trig_reset),
.pixel(pixel),
.end_recieve_pixel(end_recieve_pixel),
.o_ready_recieve_pixel(ready_recieve_pixel_ip),
.o_end_frame(end_frame)
);
/*-----------------------------------------------------------------------*/

endmodule
