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

localparam DATA_WIDTH_24 = 24;

/*--------------------IO port declaration---------------------------------*/
input clk_os;
input  [DATA_WIDTH_12-1:0] ori_x;
input  [DATA_WIDTH_12-1:0] ori_y;
output [DATA_WIDTH_12-1:0] o_resize_x;
output [DATA_WIDTH_12-1:0] o_resize_y;
output o_reach; 
/*-----------------------------------------------------------------------*/

/*----- local variables ------*/
wire xloc;
wire yloc;
wire [DATA_WIDTH_24-1:0] x_ratio;
wire [DATA_WIDTH_24-1:0] y_ratio;
reg [DATA_WIDTH_24-1:0] oxcoord = 0;
reg [DATA_WIDTH_24-1:0] oycoord = 0;
reg [DATA_WIDTH_24-1:0] tempxcoord = 0;
reg [DATA_WIDTH_24-1:0] tempycoord = 0;


/*------Calculate output --------*/
localparam x_ratio = (FRAME_ORIGINAL_CAMERA_WIDTH<<DATA_WIDTH_24)/FRAME_RESIZE_CAMERA_WIDTH   +1;
localparam y_ratio = (FRAME_ORIGINAL_CAMERA_HEIGHT<<DATA_WIDTH_24)/FRAME_RESIZE_CAMERA_HEIGHT +1;


 
 
/*--------------------Assignment declaration---------------------------------*/
/*-----Assign back to output-------*/
assign o_resize_x = oxcoord;
assign o_resize_y = oycoord;
/*---- Evaluate see is the location is reached ---*/
assign xloc = (oxcoord == ori_x);
assign yloc = (oycoord == ori_y);
assign o_reach = xloc && yloc;
/*-----------------------------------------------------------------------*/


/*------Manage the scaling calculation of coordinate values----*/
always @(posedge clk_os )
begin
  
  if( ori_x == FRAME_ORIGINAL_CAMERA_WIDTH -1)
  begin 
    tempxcoord <= 0;
    oxcoord <=0;
    
    if( ori_y == FRAME_ORIGINAL_CAMERA_HEIGHT -1) 
    begin
      tempycoord <= 0; 
      oycoord <= 0; 
    end
    else
    begin
      if(ori_y > oycoord)
      begin
        tempycoord <= tempycoord + 1;
        oycoord <= ((tempycoord + 1) * y_ratio)>>DATA_WIDTH_24;
      end  
      else
        tempycoord <= tempycoord;
    end
    
  end
  
  else                  
  begin
    if(ori_x > oxcoord)
    begin    
      tempxcoord <= tempxcoord +1;
      oxcoord <= ((tempxcoord + 1) * x_ratio)>>DATA_WIDTH_24;
    end
    else                      
      tempxcoord <= tempxcoord;
  end
  

end

endmodule
