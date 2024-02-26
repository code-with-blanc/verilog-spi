`timescale 1 ps / 1 ps

module spc_tb;

`include "./src/tb_util.v"

localparam N_BYTES = 2;
localparam OUTPUT_BITS = N_BYTES*8;
localparam CMD_WRITE = 8'b1001_0001;

localparam TB_STATE_NUMCHARS = 32;
reg [8*TB_STATE_NUMCHARS:0] tb_state;

reg clk;
reg mosi;
reg cs_n;
wire data_ready;
wire [1-OUTPUT_BITS:0] out;

spc spc_dut (
    .sclk(clk),
    .mosi(mosi),
    .cs_n(cs_n),
    .out(out)
);

task write_byte(
	input [7:0] data
); begin: write_byte_block
	integer i;
	for (i = 0; i < 8; i = i+1) begin
		mosi = data[i];
		@(negedge clk);
	end
    mosi = 0;
    i = 'bx;
end
endtask

initial begin
	clk = 0;
	while(1) begin
		#5;
		clk = ~clk;
	end
end

initial begin
	// setup dumping
	$dumpfile("./signals/signals.vcd"); $dumpvars;

	// initial state
	log_tb_state("Initializing");
	clk = 0;
	mosi = 0;
	cs_n = 1;
	
	@(negedge clk);
	test_write_FF;

	@(negedge clk);
	@(negedge clk);
	
	test_write_00;

	@(negedge clk);

	test_write_55;

    #10;
	log_tb_state("Passed");
	$finish;
end

//////////// TEST TASKS //////////
task test_write_FF; begin
	log_tb_state("Writing [W|FF|FF]");
	cs_n = 0;
	write_byte(CMD_WRITE);
	write_byte(8'hFF);
	write_byte(8'hFF);
	cs_n = 1;
	// wait for output update
	@(negedge clk);
	// assert
	assert_out(16'hFFFF);
end
endtask

task test_write_00; begin
	    log_tb_state("Writing [W|00|00]");
	cs_n = 0;
	write_byte(CMD_WRITE);
	write_byte(8'h00);
	write_byte(8'h00);
	cs_n = 1;
	// wait for output update
	@(negedge clk);
	// assert
    assert_out(16'h0000);
end
endtask

task test_write_55; begin
    log_tb_state("Writing checkerboard pattern [W|55|55]");
	cs_n = 0;
	write_byte(CMD_WRITE);
	write_byte(8'h55);
	write_byte(8'h55);
	cs_n = 1;
	// wait for output update
	@(negedge clk);
	// assert
    assert_out(16'h5555);
end
endtask

task test_wrong_command; begin
    log_tb_state("Testing ignores wrong command [XW|55|55]");
	cs_n = 0;
	write_byte(CMD_WRITE);
	write_byte(8'h55);
	write_byte(8'h55);
	cs_n = 1;
	// wait for output update
	@(negedge clk);
	// assert
    assert_out(16'h5555);
end
endtask

endmodule
