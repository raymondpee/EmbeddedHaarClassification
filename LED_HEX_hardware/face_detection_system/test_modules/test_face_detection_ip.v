// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns  //Assume our clock frequency is 100MHz
module test_face_detection_ip;



localparam FRAME_ORIGINAL_CAMERA_WIDTH 		= 800;
localparam FRAME_ORIGINAL_CAMERA_HEIGHT		= 600;

/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/
reg clk = 0;
reg reset;
reg read;
reg write;
reg end_coordinate;
reg [7:0] pixel;
reg [7:0] readdata;
reg [7:0] writedata;
reg [11:0] ori_x;
reg [11:0] ori_y;


/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 
initial
begin
	#1 reset = 1;
	#1 reset = 0;
end
 
always # 1 clk <= ~clk;
 
always@(posedge clk)
begin
	if(reset)
	begin
		read		<=1;
		write		<=0;
		readdata	<=0;
		writedata	<=0;
		pixel		<=0;
		end_coordinate <=0;
	end
end
 

always @(posedge clk)
begin
	write<=0;
	//== Pixel Input
	if(pixel == 255)
	begin
		pixel <= 0;
	end
	else
	begin
		pixel <= pixel + 1;
		write<=1;
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
end



face_detection_ip
face_detection_ip
(	
.s_clk(clk),
.s_read(read),
.s_readdata(readdata),
.s_write(write),
.s_writedata(writedata),
.s_reset(reset)
);

endmodule
