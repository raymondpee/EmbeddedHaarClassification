module second_stage_classifier
#(
parameter NUM_RESIZE = 5,
parameter ADDR_WIDTH = 10,
parameter DATA_WIDTH_8 = 8,   // Max value 255
parameter DATA_WIDTH_12 = 12, // Max value 4095
parameter DATA_WIDTH_16 = 16, // Max value 177777
parameter INTEGRAL_WIDTH = 3,
parameter INTEGRAL_HEIGHT = 3
)
(
	clk_fpga,
	reset_fpga,
	integral_image,
	i_enable_write,
	o_is_face
);

/*--------------------IO port declaration---------------------------------*/
input clk_fpga;
input i_enable_write;
input [DATA_WIDTH_12-1:0] integral_image[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0][NUM_RESIZE];
output o_is_face;
/*-----------------------------------------------------------------------*/

wire w_rdreq;
wire [ADDR_WIDTH-1:0] usedw;  

reg wrreq;
reg rdreq;
reg [DATA_WIDTH_8-1:0] count_rdreq;
reg [DATA_WIDTH_8-1:0] count_wrreq;
reg [DATA_WIDTH_12-1:0] integral_image_compute[INTEGRAL_WIDTH*INTEGRAL_HEIGHT-1:0];


module stage_classifier_db
#(
.ADDR_WIDTH(ADDR_WIDTH), 
parameter DATA_WIDTH = 8,
parameter MEMORY_FILE =  "memory.mif"
)
(
	clk,
	reset,
	req_compare,
	classifier_size,
	o_is_end_reached,
	q
);

module stage_classifier_db
#(
parameter ADDR_WIDTH = 12, 
parameter DATA_WIDTH = 8,
parameter MEMORY_FILE =  "memory.mif"
)
(
	clk,
	reset,
	req_compare,
	classifier_size,
	o_is_end_reached,
	q
);

module stage_classifier_db
#(
parameter ADDR_WIDTH = 12, 
parameter DATA_WIDTH = 8,
parameter MEMORY_FILE =  "memory.mif"
)
(
	clk,
	reset,
	req_compare,
	classifier_size,
	o_is_end_reached,
	q
);

endmodule