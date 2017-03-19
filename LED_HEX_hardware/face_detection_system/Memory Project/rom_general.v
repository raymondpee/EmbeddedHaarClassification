module rom_general
#(
parameter ADDR_WIDTH = 8, // 9 bit
parameter DATA_WIDTH = 15 //16 bit
)
(
	output [DATA_WIDTH:0] index_start_stage_ram_0,
	output [DATA_WIDTH:0] index_end_stage_ram_0,
	output [DATA_WIDTH:0] index_start_stage_ram_1,
	output [DATA_WIDTH:0] index_end_stage_ram_1,
	output [DATA_WIDTH:0] index_start_stage_ram_2,
	output [DATA_WIDTH:0] index_end_stage_ram_2,
	output [DATA_WIDTH:0] index_start_stage_ram_3,
	output [DATA_WIDTH:0] index_end_stage_ram_3,
	input rden,
	input clk
);

localparam DATA_WIDTH_IO = 2*(DATA_WIDTH+)-1;

reg rden_general =0;
reg [1:0] count =0;
reg [1:0] count_data =0;
reg [DATA_WIDTH_IO:0] data_io =0;

always @(posedge clk)
begin
	if(count == 2)
	begin
		count = 0;
		rden_general = 0;
	end
	else
		rden_general = 1;
		
	if(rden)
		count = count +1;
	else
		count = count;
end

// Do generate operation here
always@(q_general_0)
begin
	case(count_data)
		2'b00:
			begin
				data_io[DATA_WIDTH_IO:DATA_WIDTH] =  q_general_0;
			end
		2'b01:
			begin
				data_io[DATA_WIDTH:0] =  q_general_0;
			end
		default:
			begin
				data_io = 0;
			end
	endcase
	
	if(rden)
		count = count +1;
	else
		count = count;	
end


rom_single_port_general_0
rom_single_port_general_0
(
	.address(addr_general),
	.clock(clk),
	.rden(rden_general),
	.q(q_general_0)
);

rom_single_port_general_1
rom_single_port_general_1
(
	.address(addr_general),
	.clock(clk),
	.rden(rden_general),
	.q(q_general_1)
);

rom_single_port_general_2
rom_single_port_general_2
(
	.address(addr_general),
	.clock(clk),
	.rden(rden_general),
	.q(q_general_2)
);

rom_single_port_general_3
rom_single_port_general_3
(
	.address(addr_general),
	.clock(clk),
	.rden(rden_general),
	.q(q_general_3)
);



endmodule