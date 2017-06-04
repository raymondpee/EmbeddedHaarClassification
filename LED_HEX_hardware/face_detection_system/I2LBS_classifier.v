module I2LBS_classifier
#(
parameter DATA_WIDTH_8 = 8,
parameter DATA_WIDTH_12 = 12,
parameter DATA_WIDTH_16 = 16,
parameter NUM_STAGE = 10,
parameter INTEGRAL_WIDTH = 10,
parameter INTEGRAL_HEIGHT = 10
)
(
clk,
reset,
enable,
integral_image,
end_database,
end_tree,
end_single_classifier,
end_all_classifier,
index_tree,
index_classifier,
index_database,
data,
o_candidate,
o_inspect_done
);

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
input  clk;
input  reset;
input  enable;
input  [DATA_WIDTH_16-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];
input  [NUM_STAGE-1:0]end_database;
input  [NUM_STAGE-1:0]end_tree;
input  [NUM_STAGE-1:0]end_single_classifier;
input  [NUM_STAGE-1:0]end_all_classifier;
input  [DATA_WIDTH_12-1:0] index_tree[NUM_STAGE-1:0];
input  [DATA_WIDTH_12-1:0] index_classifier [NUM_STAGE-1:0];
input  [DATA_WIDTH_12-1:0] index_database [NUM_STAGE-1:0];
input  [DATA_WIDTH_16-1:0] data [NUM_STAGE-1:0];
output o_inspect_done;
output o_candidate;


/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/

wire pass;
wire [NUM_STAGE-1:0] candidate;
reg  reset_classifier;
reg  inspect_done;
reg  [DATA_WIDTH_12-1:0] count_stage;


/*****************************************************************************
*                            Combinational logic                             *
*****************************************************************************/

assign o_inspect_done = inspect_done;
assign o_candidate = pass;
assign pass = candidate == 25'b1111111111111111111111111;


/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 
always@(posedge clk)
begin
	if(reset)
	begin
		count_stage<=0;
		inspect_done<=0;
		reset_classifier<=1;
	end
	if(reset_classifier)
	begin
		count_stage<=0;
		inspect_done<=0;
		reset_classifier<=0;
	end
	if(inspect_done)
		inspect_done<=0;
end




always@(posedge clk)
begin
	if(end_database[count_stage])
	begin
		if(!candidate[count_stage]||pass)
		begin
			inspect_done <=1;
			reset_classifier<=1;
		end
		else 
		begin
			count_stage <= count_stage+1;
		end
	end
end


 /*****************************************************************************
 *                                   Modules                                  *
 *****************************************************************************/ 

generate
genvar index;
for(index = 0; index<NUM_STAGE; index = index +1)
begin
	classifier
	#(
	.INTEGRAL_WIDTH(INTEGRAL_WIDTH),
	.INTEGRAL_HEIGHT(INTEGRAL_HEIGHT)
	)
	classifier
	(
	.clk(clk),
	.reset(reset_classifier),
	.enable(enable),
	.integral_image(integral_image),
	.end_database(end_database[index]),
	.end_tree(end_tree[index]),
	.end_single_classifier(end_single_classifier[index]),
	.end_all_classifier(end_all_classifier[index]),
	.index_tree(index_tree[index]),
	.index_classifier(index_classifier[index]),
	.index_database(index_database[index]),
	.data(data[index]),
	.o_candidate(candidate[index])
	);
end
endgenerate

endmodule