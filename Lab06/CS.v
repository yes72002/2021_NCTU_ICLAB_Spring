
//synopsys translate_off
`include "CS_IP.v"
//synopsys translate_on

module CS
#(parameter WIDTH_DATA_1 = 384, parameter WIDTH_RESULT_1 = 8,
parameter WIDTH_DATA_2 = 128, parameter WIDTH_RESULT_2 = 8)
(
    data,
    in_valid,
    clk,
    rst_n,
    result,
    out_valid
);

input [(WIDTH_DATA_1 + WIDTH_DATA_2 - 1):0] data;
input in_valid, clk, rst_n;

output reg [(WIDTH_RESULT_1 + WIDTH_RESULT_2 -1):0] result;
output reg out_valid;

wire [129:0]   sum_384;
wire [127:0]  data_384;
wire [7:0] result_IP1;
wire [7:0] result_IP4;
wire out_valid_IP1;
wire out_valid_IP4;

assign sum_384 = data[511:384] + data[383:256] + data[255:128];
assign data_384 = sum_384[129:128] + sum_384[127:0];
// IP
CS_IP #(.WIDTH_DATA(WIDTH_DATA_1/3), .WIDTH_RESULT(WIDTH_RESULT_1)) I_CS_IP1(
    .data(data_384),
    .in_valid(in_valid),
    .clk(clk),
    .rst_n(rst_n),
    .result(result_IP1),
    .out_valid(out_valid_IP1)
);
CS_IP #(.WIDTH_DATA(WIDTH_DATA_2), .WIDTH_RESULT(WIDTH_RESULT_2)) I_CS_IP4(
    .data(data[(WIDTH_DATA_1 + WIDTH_DATA_2 - 385):(WIDTH_DATA_1 + WIDTH_DATA_2 - 512)]),
    .in_valid(in_valid),
    .clk(clk),
    .rst_n(rst_n),
    .result(result_IP4),
    .out_valid(out_valid_IP4)
);
// out_valid
always @(*) begin
	out_valid = out_valid_IP1;
end
// result
always @(*) begin
	result = {result_IP1,result_IP4};
end

endmodule
