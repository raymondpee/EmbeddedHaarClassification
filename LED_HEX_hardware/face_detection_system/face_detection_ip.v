module face_detection_ip
(	
//===== avalon MM s1 slave (read/write)
// write
s_clk,
s_address,
s_read,
s_readdata,
s_write,
s_writedata,
s_reset,
//

//===== avalon MM s1 to export (read)
// read/write
SEG7
);
				
/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
//===== Bridge
parameter	SEG7_NUM		=   8;
parameter	ADDR_WIDTH		=	3;		
parameter	DEFAULT_ACTIVE  =   1;
parameter	LOW_ACTIVE  	=   1;

//===== Data Width
localparam DATA_WIDTH_8			= 8;
localparam DATA_WIDTH_12 		= 12;
localparam DATA_WIDTH_16 		= 16;

//===== State
localparam WAIT 				= 0;
localparam RECIEVE_PIXEL 		= 1;
localparam RECIEVE_RESULT 		= 2;
localparam NUM_STATE 			= 3;

//===== Linux State
localparam LINUX_CALL_RESET 		= 900;
localparam LINUX_START_SEND_PIXEL 	= 901;
localparam LINUX_END_SEND_PIXEL 	= 902;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
 // s1
input						s_clk;
input	[(ADDR_WIDTH-1):0]	s_address;
input						s_read;
output	[7:0]				s_readdata;
input						s_write;
input	[7:0]				s_writedata;
input						s_reset;

//===== Interface to export
 // s1
output	[(SEG7_NUM*8-1):0]  SEG7;

/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/
wire							recieve_pixel;
wire							recieve_pixel_end;
wire 							frame_end;
wire 							result_end;
wire 							fpga_ready_recieve_pixel;

reg 							trig_reset;
reg 							recieve_result; 
reg 	[NUM_STATE-1:0] 		state;


// Bridge
reg								linux_start_send_pixel;
reg 							linux_end_send_pixel;
reg		[7:0]					pixel;				//Write From Linux
reg     [7:0]					read_data;
reg		[7:0]					result;				//Read To Linux


/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 
 
//===== Bridge IO Logic
always @ (negedge s_clk)
begin
	trig_reset = 0;
	if (s_write)
	begin
		if(s_writedata == LINUX_CALL_RESET)
		begin
			trig_reset = 1;
		end
		if(s_writedata == LINUX_START_SEND_PIXEL)
		begin
			linux_end_send_pixel = 0;
			linux_start_send_pixel = 1;
		end
		if(linux_start_send_pixel)
		begin
			pixel = s_writedata;
		end
		if(s_writedata == LINUX_END_SEND_PIXEL)
		begin
			linux_end_send_pixel = 1;
			linux_start_send_pixel = 0;
		end
	end
	else if (s_read)
	begin
		if(linux_start_send_pixel)
		begin
			if(fpga_ready_recieve_pixel)
				read_data = LINUX_START_SEND_PIXEL;
			else
				read_data = 0;
		end
		else
		begin
			read_data = 0;
		end
	end	
end
 
//===== Reset 
always@(posedge s_clk)
begin
	if(s_reset || trig_reset)
	begin
		linux_start_send_pixel<=0;
		linux_end_send_pixel<=0;
		state <=WAIT;
		pixel<=0;
		write<=0;
		recieve_result<=0;
	end
end

//===== Finite State Machine 
always@(posedge s_clk)
begin
	case (state)
	WAIT:
	begin
		if(fpga_ready_recieve_pixel && linux_end_send_pixel)
		begin
			state <= RECIEVE_PIXEL;
		end
		if(frame_end)
		begin
			state <= RECIEVE_RESULT;
		end
	end
	RECIEVE_PIXEL:
	begin
		if(recieve_pixel_end)
		begin
			state <= WAIT;
		end
	end
	RECIEVE_RESULT:
	begin
		recieve_result<=0;
		if(write)
		begin
			recieve_result<=1;
		end
		if(result_end)
		begin
			state = WAIT;
		end
	end	
	endcase
end
 

 /*****************************************************************************
 *                                   Modules                                  *
 *****************************************************************************/ 
face_detection
face_detection
(
.clk(clk),
.reset(trig_reset)

//Pixel//
.o_fpga_ready_recieve_pixel(fpga_ready_recieve_pixel),
.recieve_pixel(recieve_pixel),
.o_recieve_pixel_end(recieve_pixel_end),
.pixel(pixel),

//Result//
.recieve_result(recieve_result),
.o_result_data(data),
.o_enable_read_result_end(enable_read_result_end),
.o_result_end(result_end),
.o_frame_end(frame_end)
);
 
 
 
 /*****************************************************************************
 *                            Combinational logic                             *
 *****************************************************************************/
assign s_readdata = read_data;
assign recieve_pixel = state == RECIEVE_PIXEL;
assign recieve_result = state == RECIEVE_RESULT;
endmodule

