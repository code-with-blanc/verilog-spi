module spc #(
    parameter OUTPUT_BITS = 16
) (
    input wire sclk,
    input wire mosi,
    input wire cs_n,
    output wire [OUTPUT_BITS-1:0] out
);

wire ctl_data;
wire ctl_shift;
wire ctl_copy;

reg [OUTPUT_BITS-1:0] working_mem;
reg [OUTPUT_BITS-1:0] output_mem;
assign out = output_mem;

spi_controller #(
    OUTPUT_BITS
) controller (
    .sclk (sclk),
    .mosi (mosi),
    .cs_n (cs_n),
    .ctl_data (ctl_data),
    .ctl_shift (ctl_shift),
    .ctl_copy (ctl_copy)
);

initial begin
    working_mem = 0;
    output_mem = 0;
end

always @(posedge ctl_copy) begin
    output_mem = working_mem;
end

always @(posedge ctl_shift) begin
    working_mem = {ctl_data, working_mem[15:1]};
end

endmodule