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
wire							end_recieve_pixel;
wire 							end_frame;
wire 							end_result;
wire							recieve_pixel;
wire 							fpga_ready_recieve_pixel;

reg 							trig_reset;
reg 							send_result; 
reg								linux_start_send_pixel;
reg 							linux_end_send_pixel;

reg		[DATA_WIDTH_8-1:0]		pixel;				
reg     [DATA_WIDTH_8-1:0]		read_data;
reg		[DATA_WIDTH_8-1:0]		write_data;
reg		[DATA_WIDTH_8-1:0]		result_data;				


 /*****************************************************************************
 *                            Combinational logic                             *
 *****************************************************************************/
assign s_readdata = read_data;
assign recieve_pixel = fpga_ready_recieve_pixel && linux_end_send_pixel;


/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 

//===== Get data from LINUX to FPGA
always@(negedge s_clk)
begin
	if (s_write)
	begin
		if(s_writedata == LINUX_CALL_FPGA_RESET)
		begin
			trig_reset <= 1;
		end
		else if(s_writedata == LINUX_START_SEND_PIXEL)
		begin
			linux_end_send_pixel <= 0;
			linux_start_send_pixel <= 1;
			pixel <= s_writedata;
		end
		else if(s_writedata == LINUX_STOP_SEND_PIXEL)
		begin
			linux_end_send_pixel <= 1;
			linux_start_send_pixel <= 0;
		end
		else if(s_writedata == LINUX_START_RECIEVE_RESULT)
		begin
			send_result <= 1;
		end
		else if(s_writedata == LINUX_STOP_RECIEVE_RESULT)
		begin
			send_result <= 0;
		end	
	end
	trig_reset = 0;
end


//===== State declaration from FPGA to LINUX
always@(negedge s_clk)
begin
	if(s_read)
	begin
		if(fpga_ready_recieve_pixel)
		begin
			read_data <= FPGA_START_RECIEVE_PIXEL;
		end
		else if(end_recieve_pixel)
		begin
			read_data <= FPGA_STOP_RECIEVE_PIXEL;
		end
		else if(end_result)
		begin
			read_data <= FPGA_FINISH_RESULT;
		end
		else if(send_result)
		begin
			read_data <= result_data;
		end
		else 
		begin
			read_data <= FPGA_IDLE;
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
		pixel<=0;
		send_result<=0;
	end
end

 /*****************************************************************************
 *                                   Modules                                  *
 *****************************************************************************/ 
face_detection
face_detection
(
.clk(clk),
.reset(trig_reset),

//Pixel//
.o_fpga_ready_recieve_pixel(fpga_ready_recieve_pixel),
.recieve_pixel(recieve_pixel),
.o_recieve_pixel_end(end_recieve_pixel),
.pixel(pixel),

//Result//
.send_result(send_result),
.o_result_data(result_data),
.o_result_end(end_result),
.o_frame_end(end_frame)
);
 
 
endmodule

