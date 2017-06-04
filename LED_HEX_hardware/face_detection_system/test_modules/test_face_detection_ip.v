// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns  //Assume our clock frequency is 100MHz
module test_face_detection_ip;




/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
//===== Data Width
localparam DATA_WIDTH_8			= 8;
localparam DATA_WIDTH_12 		= 12;
localparam DATA_WIDTH_16 		= 16;

localparam FRAME_ORIGINAL_CAMERA_WIDTH 		= 800;
localparam FRAME_ORIGINAL_CAMERA_HEIGHT		= 600;

//=== System Call
localparam LINUX_IDLE						= 0;
localparam LINUX_CALL_FPGA_RESET 			= 5;
localparam FPGA_IDLE					 	= 10;

//=== Pixel
localparam LINUX_START_SEND_PIXEL 			= 1;
localparam LINUX_STOP_SEND_PIXEL 			= 2;
localparam FPGA_START_RECIEVE_PIXEL 		= 11;
localparam FPGA_STOP_RECIEVE_PIXEL   		= 12;

//=== Result
localparam LINUX_START_RECIEVE_RESULT  		= 3;
localparam LINUX_STOP_RECIEVE_RESULT 		= 4;
localparam FPGA_START_SEND_RESULT			= 13;
localparam FPGA_STOP_SEND_RESULT			= 14;
localparam FPGA_FINISH_RESULT				= 15;

/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/
reg clk;
reg reset;
reg read;
reg write;
reg recieve_result;
reg [DATA_WIDTH_8-1:0] state;
reg end_coordinate;
reg prepare_pixel;
reg pixel_ready;
reg pixel_sent;
reg [7:0] pixel;
reg [DATA_WIDTH_12:0] writedata;
reg [DATA_WIDTH_12:0] ori_x;
reg [DATA_WIDTH_12:0] ori_y;
reg	[DATA_WIDTH_12:0] result_data;

wire [DATA_WIDTH_12:0] readdata;

//== Unused port
parameter	SEG7_NUM		=   8;
parameter	ADDR_WIDTH		=	3;	
wire	[(SEG7_NUM*8-1):0]  SEG7;
wire	[(ADDR_WIDTH-1):0]	s_address;

/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 
initial
begin
	clk = 0;
	#1 reset = 1;
	#1 reset = 0;
end
 
always # 1 clk <= ~clk;
 
always@(posedge clk)
begin
	if(reset)
	begin
		ori_x			<= 0;
		ori_y			<= 0;
		result_data		<= 0;
		state			<= 0;
		read			<= 1;
		write			<= 0;
		writedata		<= 0;
		pixel			<= 0;
		end_coordinate 	<= 0;
		recieve_result	<= 0;
		prepare_pixel	<= 0;
		pixel_ready		<= 0;
		pixel_sent		<= 0;
	end
end


always@(posedge clk)
begin
	write			<= 0;
	case(state)
	LINUX_IDLE:
	begin
		write		<= 1;
		writedata 	<= LINUX_CALL_FPGA_RESET;
		state		<= LINUX_STOP_SEND_PIXEL;
	end
	LINUX_STOP_SEND_PIXEL:
	begin
		if(end_coordinate)
		begin
			write		<= 1;
			writedata 	<= LINUX_START_RECIEVE_RESULT;
			state		<= LINUX_START_RECIEVE_RESULT;
		end
		else if(readdata == FPGA_START_RECIEVE_PIXEL)
		begin
			prepare_pixel 	<= 1;
			write			<= 1;
			writedata		<= LINUX_START_SEND_PIXEL;
			state 			<= LINUX_START_SEND_PIXEL;
		end
	end
	LINUX_START_SEND_PIXEL:
	begin
		if(pixel_sent && readdata == FPGA_START_RECIEVE_PIXEL)
		begin
			pixel_sent	<= 0;
			write		<= 1;
			writedata 	<= LINUX_STOP_SEND_PIXEL;
			state 		<= LINUX_STOP_SEND_PIXEL;			
		end
		else if(pixel_ready)
		begin
			pixel_sent		<= 1;
			pixel_ready		<= 0;
			prepare_pixel 	<= 0;
			write			<= 1;
			writedata		<= pixel;
		end
	end
	LINUX_START_RECIEVE_RESULT:
	begin
		if(recieve_result)
		begin
			write			<= 1;
			writedata 		<= LINUX_STOP_RECIEVE_RESULT;
			recieve_result	<= 0;
			result_data 	<= readdata;			
		end
		else if(readdata == FPGA_START_SEND_RESULT)
		begin
			recieve_result	<= 1;	
		end
	end
	LINUX_STOP_RECIEVE_RESULT:
	begin
		if(readdata == FPGA_FINISH_RESULT)
		begin
			state 			<= LINUX_IDLE;
		end
		else
		begin
			write 			<= 1;
			writedata		<= LINUX_START_RECIEVE_RESULT;
			state			<= LINUX_START_RECIEVE_RESULT;
		end
	end
	endcase
end 

always @(posedge clk)
begin
	if(prepare_pixel)
	begin
		//== Pixel Input
		if(pixel == 255)
		begin
			pixel <= 0;
		end
		else
		begin
			pixel <= pixel + 1;
		end
		
		//===== Coordinate Iterator
		if(ori_x == FRAME_ORIGINAL_CAMERA_WIDTH -1)
		begin 
			ori_x <= 0;
			if(ori_y == FRAME_ORIGINAL_CAMERA_HEIGHT -1)
			begin			
				ori_y <= 0;   
				end_coordinate <= 1;
			end
			else
			begin
				ori_y <= ori_y + 1;
			end
		end
		else
		begin
			ori_x <= ori_x + 1;
		end
		prepare_pixel<=0;
		pixel_ready  <=1;
	end
end



face_detection_ip
face_detection_ip
(	
.s_clk(clk),
.s_read(read),
.s_readdata(readdata),
.s_write(write),
.s_writedata(writedata),
.s_reset(reset),

//==Unused port
.s_address(s_address),
.SEG7(SEG7)
);

endmodule
