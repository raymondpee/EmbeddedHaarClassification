module resize
#(
parameter DATA_WIDTH_8  = 8,
parameter DATA_WIDTH_12  = 12,
parameter DATA_WIDTH_16 = 16,
parameter FRAME_ORIGINAL_CAMERA_WIDTH = 10,
parameter FRAME_ORIGINAL_CAMERA_HEIGHT = 10,
parameter FRAME_RESIZE_CAMERA_WIDTH = 10,
parameter FRAME_RESIZE_CAMERA_HEIGHT = 10
)
(
	clk_os,    //clock based on the trigger from linux
	ori_x,  //Origin X coordinate
	ori_y,  //Origin Y coordinate
	o_resize_x,  //Nex X coordinate
	o_resize_y,  //Nex Y coordinate
	o_reach  //Is the current coordinate is reached
);

/*------Calculate output --------*/
localparam DATA_WIDTH_24 = 24;
localparam x_ratio = (FRAME_ORIGINAL_CAMERA_WIDTH<<16)/FRAME_RESIZE_CAMERA_WIDTH   +1;
localparam y_ratio = (FRAME_ORIGINAL_CAMERA_HEIGHT<<16)/FRAME_RESIZE_CAMERA_HEIGHT +1;


/*--------------------IO port declaration---------------------------------*/
input clk_os;
input  [DATA_WIDTH_12-1:0] ori_x;
input  [DATA_WIDTH_12-1:0] ori_y;
output [DATA_WIDTH_12-1:0] o_resize_x;
output [DATA_WIDTH_12-1:0] o_resize_y;
output o_reach; 
/*-----------------------------------------------------------------------*/

/*----- local variables ------*/
reg xloc;
reg yloc;
reg reach;
reg [DATA_WIDTH_24-1:0] oxcoord = 0;
reg [DATA_WIDTH_24-1:0] oycoord = 0;
reg [DATA_WIDTH_24-1:0] resize_x = 0;
reg [DATA_WIDTH_24-1:0] resize_y = 0;
reg [DATA_WIDTH_24-1:0] tempxcoord = 0;
reg [DATA_WIDTH_24-1:0] tempycoord = 0;

assign o_reach = reach;
assign o_resize_x = resize_x;
assign o_resize_y = resize_y;

/*------Manage the scaling calculation of coordinate values----*/
always @(ori_x or ori_y )
begin
	if(ori_x > oxcoord)
	begin    
		tempxcoord  = tempxcoord + 1;
		oxcoord = ((tempxcoord) * x_ratio)>>16;
	end
	if(ori_y > oycoord)
	begin
		tempycoord = tempycoord + 1;
		oycoord = ((tempycoord) * y_ratio)>>16;
	end
	resize_x = oxcoord;
	resize_y = oycoord;
	xloc = (resize_x == ori_x);
	yloc = (resize_y == ori_y);
	reach = xloc && yloc;

	if( ori_x == FRAME_ORIGINAL_CAMERA_WIDTH -1)
	begin 
		tempxcoord = 0;
		oxcoord = 0;
	end
	if( ori_y == FRAME_ORIGINAL_CAMERA_HEIGHT -1) 
	begin
		tempycoord = 0; 
		oycoord =0;
	end
end

endmodule
