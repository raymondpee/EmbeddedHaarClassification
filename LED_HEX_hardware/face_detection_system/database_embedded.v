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
parameter NUM_CLASSIFIERS_STAGE_3 = 10,
parameter SIZE_DATABASE_EMBEDDED = 100
)
(
clk,
reset,
o_load_done,
o_database_stage_1,
o_database_stage_2,
o_database_stage_3
)

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
input clk;
input reset;
output o_load_done;
output [DATA_WIDTH_16-1:0] o_database_stage_1 [NUM_CLASSIFIERS_STAGE_1-1:0];
output [DATA_WIDTH_16-1:0] o_database_stage_2 [NUM_CLASSIFIERS_STAGE_2-1:0];
output [DATA_WIDTH_16-1:0] o_database_stage_3 [NUM_CLASSIFIERS_STAGE_3-1:0];


 /*****************************************************************************
 *                            Combinational logic                             *
 *****************************************************************************/
assign o_load_done 	= load_done;
assign o_database_stage_1 	= database_stage_1;
assign o_database_stage_2 	= database_stage_2;
assign o_database_stage_3 	= database_stage_3;

assign load_done    = !(load_data_stage_1 || load_data_stage_2 || load_data_stage_3);

/*****************************************************************************
 *                             Internal Wire/Register                        *
 *****************************************************************************/
wire  						load_done;
wire [DATA_WIDTH_16-1:0]	data_stage_1;
wire [DATA_WIDTH_16-1:0]	data_stage_2;
wire [DATA_WIDTH_16-1:0]	data_stage_3;
						
reg 						load_data;
reg [DATA_WIDTH_12-1:0]		load_count;
reg [DATA_WIDTH_12-1:0] 	index_memory_stage_1;
reg [DATA_WIDTH_12-1:0] 	index_memory_stage_2;
reg [DATA_WIDTH_12-1:0] 	index_memory_stage_3;
reg [DATA_WIDTH_16-1:0] 	database_stage_1 [NUM_CLASSIFIERS_STAGE_1-1:0];
reg [DATA_WIDTH_16-1:0] 	database_stage_2 [NUM_CLASSIFIERS_STAGE_2-1:0];
reg [DATA_WIDTH_16-1:0] 	database_stage_3 [NUM_CLASSIFIERS_STAGE_3-1:0];

/*****************************************************************************
 *                            Sequence logic                                 *
 *****************************************************************************/ 

always@(posedge clk)
begin
	if(reset)
	begin		
		load_done 				= 0;
		load_count_stage_1 		= 0;
		load_count_stage_2		= 0;
		load_count_stage_3		= 0;
		load_data_stage_1 		= 1;
		load_data_stage_2 		= 1;
		load_data_stage_3 		= 1;
		
		index_memory_stage_1 	= 0;
		for(index_memory_stage_1 = 0; index_memory_stage_1<NUM_CLASSIFIERS_STAGE_1; index_memory_stage_1 = index_memory_stage_1 +1)
		begin
			database_stage_1[index_memory_stage_1] =0;
		end
		
		index_memory_stage_2 	= 0;
		for(index_memory_stage_2 = 0; index_memory_stage_2<NUM_CLASSIFIERS_STAGE_2; index_memory_stage_2 = index_memory_stage_2 +1)
		begin
			database_stage_2[index_memory_stage_2] =0;
		end
		
		index_memory_stage_3 	= 0;
		for(index_memory_stage_3 = 0; index_memory_stage_3<NUM_CLASSIFIERS_STAGE_3; index_memory_stage_3 = index_memory_stage_3 +1)
		begin
			database_stage_3[index_memory_stage_3] =0;
		end
	end
end

always@(data_stage_1)
begin
	database_stage_1[load_count_stage_1] = data;	
	load_count_stage_1 = load_count_stage_1 +1;	
	if(load_count_stage_1 == NUM_CLASSIFIERS_STAGE_1)
	begin
		load_data_stage_1 = 0;
	end
end


always@(data_stage_2)
begin
	database_stage_2[load_count_stage_2] = data;	
	load_count_stage_2 = load_count_stage_2 +1;	
	if(load_count_stage_2 == NUM_CLASSIFIERS_STAGE_2)
	begin
		load_data_stage_2 = 0;
	end
end


always@(data_stage_3)
begin
	database_stage_3[load_count_stage_3] = data;	
	load_count_stage_3 = load_count_stage_3 +1;	
	if(load_count_stage_3 == NUM_CLASSIFIERS_STAGE_3)
	begin
		load_data_stage_3 = 0;
	end
end


/*****************************************************************************
*                                   Modules                                  *
*****************************************************************************/ 

database_stage_memory
#(
.ADDR_WIDTH(ADDR_WIDTH),
.FILE_STAGE_MEM(FILE_STAGE_FILE_1),
.SIZE_STAGE(NUM_CLASSIFIERS_STAGE_1)
)
database_stage_memory_stage_1
(
.clk(clk),
.reset(reset),
.ren_database_index(load_data),
.ren_database(load_data),
.o_data(data_stage_1)
);

database_stage_memory
#(
.ADDR_WIDTH(ADDR_WIDTH),
.FILE_STAGE_MEM(FILE_STAGE_FILE_2),
.SIZE_STAGE(NUM_CLASSIFIERS_STAGE_2)
)
database_stage_memory_stage_2
(
.clk(clk),
.reset(reset),
.ren_database_index(load_data),
.ren_database(load_data),
.o_data(data_stage_2)
);

database_stage_memory
#(
.ADDR_WIDTH(ADDR_WIDTH),
.FILE_STAGE_MEM(FILE_STAGE_FILE_3),
.SIZE_STAGE(NUM_CLASSIFIERS_STAGE_3)
)
database_stage_memory_stage_3
(
.clk(clk),
.reset(reset),
.ren_database_index(load_data),
.ren_database(load_data),
.o_data(data_stage_3)
);

endmodule