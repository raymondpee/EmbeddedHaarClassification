// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns  //Assume our clock frequency is 100MHz
module test_face_detection_ip;

reg clk = 0;
always # 1 clk <= ~clk;

localparam IMAGE_NAME = "Image.mif";

/*------------------------------ADAPTER FOR THE HARDWARE--------------------*/


localparam DATA_WIDTH_12 = 12;
localparam DATA_WIDTH_16 = 16;
localparam MAX_VAL = 255;

localparam NUM_STATE = 5;
localparam RESET = 0;
localparam START_RECIEVE_PIXEL = 1;
localparam END_RECIEVE_PIXEL = 2;
localparam START_RECIEVE_RESULT = 3;
localparam RECIEVE_RESULT = 4;

wire trig_lwhpcfpga_pixel_input;
wire end_frame;
wire result_end;
wire ready_recieve_pixel;

wire is_init;
wire [DATA_WIDTH_12 -1:0] frame_width;
wire [DATA_WIDTH_12 -1:0] ori_x;
wire [DATA_WIDTH_12 -1:0] ori_y;
wire [DATA_WIDTH_12-1:0] data;
wire start_recieve_pixel;
wire end_recieve_pixel;
wire enable_read_result_end;

reg write;

reg init = 0;
reg trig_reset = 0;
reg [NUM_STATE-1:0] state = 0;
reg [NUM_STATE-1:0] next_state;
reg [DATA_WIDTH_16-1:0] pixel; // Pixel of the image


reg enable_read_result;

assign is_init = init == 1;
assign start_recieve_pixel = state == START_RECIEVE_PIXEL;
assign end_recieve_pixel = state == END_RECIEVE_PIXEL;
assign enable_read_result = state == START_RECIEVE_RESULT;

always@(posedge clk)
begin
	if(trig_reset)
	begin
		init <=1;
		state <=RESET;
		next_state<=0;
		pixel<=0;
		write<=0;
		enable_read_result<=0;
		trig_reset <= 0;
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
			next_state = START_RECIEVE_PIXEL;
	end
	START_RECIEVE_PIXEL:
	begin
		if(write)
		begin
			next_state = END_RECIEVE_PIXEL;
		end
		if(end_frame)
		begin
			next_state = RECIEVE_RESULT;
		end
	end
	END_RECIEVE_PIXEL:
	begin
		if(ready_recieve_pixel)
		begin
			next_state = START_RECIEVE_PIXEL;
		end
		if(end_frame)
		begin
			next_state = RECIEVE_RESULT;
		end
	end
	RECIEVE_RESULT:
	begin
		enable_read_result<=0;
		if(write)
		begin
			enable_read_result<=1;
		end
		if(result_end)
		begin
			next_state = RESET;
		end
	end	
	endcase
end


/*---------------------------------------------------*/
//Pixel Input [Assume this is from the c language]
always @(posedge clk)
begin
	write<=0;
    if(state == START_RECIEVE_PIXEL)
    begin
      if(pixel == MAX_VAL)
        pixel <= 0;
      else
        pixel <= pixel + 1;
		write<=1;
    end
	if(state == RECIEVE_RESULT)
	begin
		write<=1;
	end
end

/*---------------------------------------------------*/


facial_detection_ip
facial_detection_ip
(
.clk(clk),
.reset(trig_reset),
.o_frame_width(frame_width),

//Pixel//
.o_ready_recieve_pixel(ready_recieve_pixel),
.start_recieve_pixel(start_recieve_pixel),
.pixel(pixel),
.end_recieve_pixel(end_recieve_pixel),

//Result//
.enable_read_result(enable_read_result),
.o_result_data(data),
.o_enable_read_result_end(enable_read_result_end),
.o_result_end(result_end),
.o_end_frame(end_frame)
);
/*-----------------------------------------------------------------------*/

endmodule
