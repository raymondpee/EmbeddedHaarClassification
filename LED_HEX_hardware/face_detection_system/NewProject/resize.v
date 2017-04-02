module resize
#(
parameter DATA_WIDTH_8  = 8,
parameter DATA_WIDTH_12  = 12,
parameter DATA_WIDTH_16 = 16
)
(
	clk_os,    //clock based on the trigger from linux
	src_width,
	src_height,
	dst_width,
	dst_height,
	i_xcoord,  //Origin X coordinate
	i_ycoord,  //Origin Y coordinate
	o_xcoord,  //Nex X coordinate
	o_ycoord,  //Nex Y coordinate
	o_isreach  //Is the current coordinate is reached
);

/*------Calculate output --------*/
assign x_ratio = (src_width<<16)/dst_width   +1;
assign y_ratio = (src_height<<16)/dst_height +1;

/*--------------------IO port declaration---------------------------------*/
input clk_os;
/*---[input] X and Y coordinate from origin ----*/
input  [DATA_WIDTH_12-1:0] i_xcoord;
input  [DATA_WIDTH_12-1:0] i_ycoord;

output [DATA_WIDTH_12-1:0] o_xcoord;
output [DATA_WIDTH_12-1:0] o_ycoord;
output o_isreach; 
/*-----------------------------------------------------------------------*/




/*----- local variables ------*/
wire xloc;
wire yloc;
reg [DATA_WIDTH_12-1:0] oxcoord = 0;
reg [DATA_WIDTH_12-1:0] oycoord = 0;
reg [DATA_WIDTH_12-1:0] tempxcoord = 0;
reg [DATA_WIDTH_12-1:0] tempycoord = 0;
 
 
/*--------------------Assignment declaration---------------------------------*/
/*-----Assign back to output-------*/
assign o_xcoord = oxcoord;
assign o_ycoord = oycoord;
/*---- Evaluate see is the location is reached ---*/
assign xloc = (oxcoord == i_xcoord);
assign yloc = (oycoord == i_ycoord);
assign o_isreach = xloc && yloc;
/*-----------------------------------------------------------------------*/


/*------Manage the scaling calculation of coordinate values----*/
always @(posedge clk_os )
begin
  
  if( i_xcoord == src_width -1)
  begin 
    tempxcoord <= 0;
    oxcoord <=0;
    
    if( i_ycoord == src_height -1) 
    begin
      tempycoord <= 0; 
      oycoord <= 0; 
    end
    else
    begin
      if(i_ycoord > oycoord)
      begin
        tempycoord <= tempycoord + 1;
        oycoord <= ((tempycoord + 1) * y_ratio)>>16;
      end  
      else
        tempycoord <= tempycoord;
    end
    
  end
  
  else                  
  begin
    if(i_xcoord > oxcoord)
    begin    
      tempxcoord <= tempxcoord +1;
      oxcoord <= ((tempxcoord + 1) * x_ratio)>>16;
    end
    else                      
      tempxcoord <= tempxcoord;
  end
  

end

endmodule
