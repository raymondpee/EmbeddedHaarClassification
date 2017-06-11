module database_embedded
#(
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH_8 = 8,   
parameter DATA_WIDTH_12 = 12, 
parameter DATA_WIDTH_16 = 16, 
parameter NUM_PARAM_PER_CLASSIFIER= 19,
parameter NUM_STAGE_THRESHOLD = 3,
parameter FILE_STAGE_FILE_1 = "memory1.mif",
parameter FILE_STAGE_FILE_2 = "memory2.mif",
parameter FILE_STAGE_FILE_3 = "memory3.mif",
parameter NUM_CLASSIFIERS_STAGE_1 = 10,
parameter NUM_CLASSIFIERS_STAGE_2 = 10,
parameter NUM_CLASSIFIERS_STAGE_3 = 10
)
(
clk,
reset,
o_load_done,
o_memory
)

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
input clk;
input reset;
output o_load_done;
output [DATA_WIDTH_16-1:0] o_memory[TOTAL_SIZE-1:0];

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
localparam SIZE_STAGE_1 = NUM_CLASSIFIERS_STAGE_1*NUM_PARAM_PER_CLASSIFIER + NUM_STAGE_THRESHOLD;
localparam SIZE_STAGE_2 = NUM_CLASSIFIERS_STAGE_2*NUM_PARAM_PER_CLASSIFIER + NUM_STAGE_THRESHOLD;
localparam SIZE_STAGE_3 = NUM_CLASSIFIERS_STAGE_3*NUM_PARAM_PER_CLASSIFIER + NUM_STAGE_THRESHOLD;
localparam TOTAL_SIZE = SIZE_STAGE_1 + SIZE_STAGE_2 + SIZE_STAGE_3;



 /*****************************************************************************
 *                            Combinational logic                             *
 *****************************************************************************/
assign o_load_done 	= load_done;
assign o_memory 	= memory;

/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/

reg 						load_data;
reg 						load_done;
reg [DATA_WIDTH_12-1:0]		load_count;
reg [DATA_WIDTH_12-1:0] 	index_memory;
reg	[DATA_WIDTH_16-1:0] 	memory		[TOTAL_SIZE-1:0];

/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 

always@(posedge clk)
begin
	if(reset)
	begin
		index_memory 	= 0;
		load_done 		= 0;
		load_count 		= 0;
		load_data 		= 1;
		for(index_memory = 0; index_memory<TOTAL_SIZE; index_memory = index_memory +1)
		begin
			memory[index_memory] =0;
		end
	end
end

always@(data)
begin
	memory[load_count] = data;
	load_count = load_count +1;	
	if(load_count == TOTAL_SIZE)
	begin
		load_data = 0;
		load_done = 1;
	end
end



/*****************************************************************************
*                                   Modules                                  *
*****************************************************************************/ 

database_stage_memory
#(
.ADDR_WIDTH(ADDR_WIDTH),
.FILE_STAGE_MEM(FILE_STAGE_MEM),
.SIZE_STAGE(SIZE_STAGE)
)
database_stage_memory
(
.clk(clk),
.reset(reset),
.ren_database_index(load_data),
.ren_database(load_data),
.o_data(data)
);

endmodule