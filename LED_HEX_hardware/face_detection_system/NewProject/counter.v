module counter 
#(
parameter DATA_WIDTH = 8
)
(
  clk,
  reset,
  enable,
  max_size,
  end_count,
  ctr_out
);
// Port definitions
input clk, reset, enable;
input [DATA_WIDTH-1:0]max_size;
output end_count;
output [DATA_WIDTH-1:0] ctr_out;
// Register definitions
reg [DATA_WIDTH-1:0] reg_ctr;
// Assignments
assign ctr_out = reg_ctr;
assign end_count = reg_ctr == max_size;

always @ (posedge clk or posedge reset)
begin
  if (reset)                 reg_ctr <= 0;
  else if (enable)
  begin
    if (end_count) reg_ctr <= 0;
    else           reg_ctr <= reg_ctr + 1;
  end
end
endmodule