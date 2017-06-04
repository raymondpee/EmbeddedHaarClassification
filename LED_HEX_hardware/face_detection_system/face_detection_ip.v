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



//=== System Call
localparam LINUX_IDLE 						= 0;
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
 *                             Port Declarations                             *
 *****************************************************************************/
 // s1
input						s_clk;
input	[(ADDR_WIDTH-1):0]	s_address;
input						s_read;
output	[DATA_WIDTH_12:0]	s_readdata;
input						s_write;
input	[DATA_WIDTH_12:0]	s_writedata;
input						s_reset;

//===== Interface to export
 // s1
output	[(SEG7_NUM*8-1):0]  SEG7;

/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/
wire							end_recieve_pixel;
wire 							end_frame;
wire 							end_result;
wire							recieve_pixel;
wire 							fpga_ready_recieve_pixel;
wire							fpga_ready_send_result;
wire 							reset;

reg 							fpga_recieve_pixel;
reg								stop_send_result;
reg								result_sent;
reg 							notify_send_result;
reg 							trig_reset;
reg 							trig_send_result; 
reg								linux_start_send_pixel;
reg 							linux_end_send_pixel;

reg		[11:0]					state;
reg		[DATA_WIDTH_16-1:0]		pixel;				
reg     [DATA_WIDTH_12-1:0]		read_data;
reg		[DATA_WIDTH_12-1:0]		write_data;
reg		[DATA_WIDTH_12-1:0]		result_data;				


 /*****************************************************************************
 *                            Combinational logic                             *
 *****************************************************************************/
assign s_readdata = read_data;
assign recieve_pixel = fpga_ready_recieve_pixel && linux_end_send_pixel;
assign reset = s_reset || trig_reset;

/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 
//== Finite State Machine
always@(posedge s_clk)
begin
	trig_send_result				<= 0;
	trig_reset 						<= 0;
	case(state)
		LINUX_IDLE:
		begin
			if(write_data == LINUX_CALL_FPGA_RESET)
			begin
				trig_reset		<=1;
				state 			<= LINUX_STOP_SEND_PIXEL;
			end			
		end
		LINUX_STOP_SEND_PIXEL:
		begin
			if(write_data == LINUX_START_SEND_PIXEL)
			begin
				linux_end_send_pixel 	<= 0;
				linux_start_send_pixel 	<= 1;
				fpga_recieve_pixel		<= 1;	
				state 					<= LINUX_START_SEND_PIXEL;
			end
			else if(write_data == LINUX_START_RECIEVE_RESULT)
			begin
				trig_send_result 		<= 1;
				notify_send_result 		<= 1;
				state					<= LINUX_START_RECIEVE_RESULT;
			end
		end	
		LINUX_START_SEND_PIXEL:
		begin
			if(fpga_recieve_pixel)
			begin
				pixel 					<= write_data;
				fpga_recieve_pixel		<= 0;
				linux_end_send_pixel 	<= 1;
				linux_start_send_pixel 	<= 0;
				state 					<= LINUX_STOP_SEND_PIXEL;
			end
		end
		LINUX_START_RECIEVE_RESULT:
		begin
			if(write_data == LINUX_STOP_RECIEVE_RESULT)
			begin
				stop_send_result		<= 1;
				state					<= LINUX_STOP_RECIEVE_RESULT;
			end
		end
		LINUX_STOP_RECIEVE_RESULT:
		begin
			if(write_data == LINUX_START_RECIEVE_RESULT)
			begin
				trig_send_result 		<= 1;
				notify_send_result 		<= 1;
				state					<= LINUX_START_RECIEVE_RESULT;
			end
		end
	endcase
end
 
 
 
//===== Get data from LINUX to FPGA
always@(posedge s_clk)
begin
	if (s_write)
	begin
		write_data = s_writedata;
	end
end


//===== State declaration from FPGA to LINUX
always@(posedge s_clk)
begin
	if(s_read)
	begin
		if(fpga_ready_recieve_pixel)
		begin
			read_data 				<= FPGA_START_RECIEVE_PIXEL;
		end
		else if(end_recieve_pixel)
		begin
			read_data 				<= FPGA_STOP_RECIEVE_PIXEL;
		end
		else if(end_result)
		begin
			read_data 				<= FPGA_FINISH_RESULT;
		end
		else if(fpga_ready_send_result)
		begin
			if(notify_send_result)
			begin
				read_data			<= FPGA_START_SEND_RESULT;
				notify_send_result	<= 0;
			end
			else if(result_sent && stop_send_result)
			begin
				read_data 			<= FPGA_STOP_SEND_RESULT;
				result_sent 		<= 0;
				stop_send_result	<= 0;
			end
			else
			begin
				read_data 			<= result_data;
				result_sent			<= 1;
			end
		end
	end
end


//===== Reset 
always@(posedge s_clk)
begin
	if(s_reset)
	begin
		state					<= 0;
		trig_reset 				<= 0;
	end
	if(trig_reset)
	begin
		notify_send_result		<= 0;
		result_sent				<= 0;
		linux_start_send_pixel	<= 0;
		linux_end_send_pixel	<= 0;
		pixel					<= 0;
		trig_send_result		<= 0;
		stop_send_result		<= 0;
		fpga_recieve_pixel		<= 0;
	end
end

 /*****************************************************************************
 *                                   Modules                                  *
 *****************************************************************************/ 
face_detection
face_detection
(
.clk(s_clk),
.reset(reset),

//Pixel//
.o_fpga_ready_recieve_pixel(fpga_ready_recieve_pixel),
.recieve_pixel(recieve_pixel),
.o_recieve_pixel_end(end_recieve_pixel),
.pixel(pixel),

//Result//
.trig_send_result(trig_send_result),
.result_sent(result_sent),
.o_result_data(result_data),
.o_result_end(end_result),
.o_fpga_ready_send_result(fpga_ready_send_result)
);
 
 
endmodule

