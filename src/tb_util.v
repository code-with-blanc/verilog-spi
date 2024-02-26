
task tick;
begin
	clk = ~clk; #5;
	clk = ~clk; #5;
end
endtask

task log_tb_state(
    input [8*TB_STATE_NUMCHARS:0] new_state
); begin
    tb_state = new_state;
    $display("[%4d][Info  ] TB state: %-s", $time, new_state);
end
endtask

task assert_out(
    input [OUTPUT_BITS-1:0] expected
); begin: assert_out_block
	if (out !== expected) begin
		$display("[%4d][Assert][Error] wrong value for 'out' | expected: %b  actual: %b", $time, expected, out);
		$finish;
    end else begin
        $display("[%4d][Assert][Ok] 'out' has expected value of %b", $time, expected);
    end
end
endtask

