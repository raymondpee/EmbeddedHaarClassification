module image_resize
#(
parameter BYTE_WIDTH = 8,
parameter BYTE_DOUBLE_WIDTH  = 16,
parameter SRC_WIDTH  = 800,
parameter SRC_HEIGHT = 600,
parameter DST_WIDTH  = 800,
parameter DST_HEIGHT = 600
)
(
input clk,
/*---[input] X and Y coordinate from origin ----*/
input  [BYTE_DOUBLE_WIDTH-1:0] i_xcoord,
input  [BYTE_DOUBLE_WIDTH-1:0] i_ycoord,

/*---[output] new X and Y coordinate----*/
output [BYTE_DOUBLE_WIDTH-1:0] o_xcoord,
output [BYTE_DOUBLE_WIDTH-1:0] o_ycoord,

/*---[output] Is the current coordinate is reached----*/
output o_isreach
);

/*------Calculate output --------*/
localparam xratio = (SRC_WIDTH<<16)/DST_WIDTH   +1;
localparam yratio = (SRC_HEIGHT<<16)/DST_HEIGHT +1;


/*----- local variables ------*/
wire xloc;
wire yloc;
reg [BYTE_DOUBLE_WIDTH-1:0] oxcoord = 0;
reg [BYTE_DOUBLE_WIDTH-1:0] oycoord = 0;
reg [BYTE_DOUBLE_WIDTH-1:0] tempxcoord = 0;
reg [BYTE_DOUBLE_WIDTH-1:0] tempycoord = 0;
 
/*-----Assign back to output-------*/
assign o_xcoord = oxcoord;
assign o_ycoord = oycoord;

/*---- Evaluate see is the location is reached ---*/
assign xloc = (oxcoord == i_xcoord);
assign yloc = (oycoord == i_ycoord);
assign o_isreach = xloc && yloc;


/*------Manage the scaling calculation of coordinate values----*/
always @(posedge clk )
begin
  
  if( i_xcoord == SRC_WIDTH -1)
  begin 
    tempxcoord <= 0;
    oxcoord <=0;
    
    if( i_ycoord == SRC_HEIGHT -1) 
    begin
      tempycoord <= 0; 
      oycoord <= 0; 
    end
    else
    begin
      if(i_ycoord > oycoord)
      begin
        tempycoord <= tempycoord + 1;
        oycoord <= ((tempycoord + 1) * yratio)>>16;
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
      oxcoord <= ((tempxcoord + 1) * xratio)>>16;
    end
    else                      
      tempxcoord <= tempxcoord;
  end
  

end

endmodule
