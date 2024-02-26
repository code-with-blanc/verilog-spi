module spi_controller #(
	parameter OUTPUT_BITS = 16
) (
	input wire sclk,
	input wire mosi,
	input wire cs_n,
	output reg out_data_ready,
	output wire ctl_data,
	output wire ctl_shift,
	output reg ctl_copy
);

localparam CMD_WRITE = 8'b1001_0001;

localparam FSM_READING_CMD = 2'b00,
		   FSM_STREAMING   = 2'b01,
		   FSM_COPY    = 2'b10;
			  
reg [1:0] fsm_state;
reg [1:0] next_state;
// spi command parsing
reg [3:0] cmd_bit_cnt;
reg [7:0] cmd_reg;
// streaming
reg [$clog2(OUTPUT_BITS):0] stream_bit_cnt;
reg stream_enable;
// output copying
reg copy_done;

assign ctl_data = mosi & stream_enable;
assign ctl_shift = sclk & stream_enable;


initial begin
	set_initial_state;
end

// state transition
always @(negedge sclk) begin
	case (fsm_state)
		FSM_READING_CMD:
		begin
			if(cmd_bit_cnt == 7 && cmd_reg == CMD_WRITE) begin
				prepare_state_streaming;
				fsm_state = FSM_STREAMING;
			end					
		end

		FSM_STREAMING:
		begin
			if(stream_bit_cnt == OUTPUT_BITS-1) begin
				prepare_state_copy;
				fsm_state = FSM_COPY;
			end
		end
		
		FSM_COPY:
		begin
			set_initial_state;
			fsm_state = FSM_READING_CMD;
		end
		default:
			set_initial_state;
	endcase
end

// cmd buffer counter
always @(negedge sclk) begin
	if(fsm_state == FSM_READING_CMD && ~cs_n) begin
		if (cmd_bit_cnt == 7) begin
			cmd_bit_cnt <= 0;
			cmd_reg <= 0;
		end else begin
			cmd_bit_cnt <= cmd_bit_cnt + 1;
		end
	end
end

// stream counter
always @(negedge sclk) begin
	if(fsm_state == FSM_STREAMING) begin
		if (stream_bit_cnt == OUTPUT_BITS-1) begin
			stream_bit_cnt <= 0;
		end else begin
			stream_bit_cnt <= stream_bit_cnt + 1;
		end
	end
end

// handle inputs / outputs
always @(posedge sclk) begin
	case (fsm_state)
		FSM_READING_CMD:
		begin
			if(fsm_state == FSM_READING_CMD && ~cs_n) begin
				cmd_reg = {mosi, cmd_reg[7:1]};
			end
		end
		FSM_STREAMING:
		begin
			stream_enable = 1;
		end
		FSM_COPY:
		begin
			ctl_copy = 1;
		end
	endcase
end

task set_initial_state; begin
	// internal state
	fsm_state = FSM_READING_CMD;
	next_state = FSM_READING_CMD;
	cmd_reg = 0;
	cmd_bit_cnt = 0;
	stream_bit_cnt = 0;
	copy_done = 0;


	// outputs
	stream_enable = 0;
	ctl_copy = 0;
	out_data_ready = 0;
end
endtask

task prepare_state_streaming; begin
	stream_enable = 1;
	stream_bit_cnt = 0;
end
endtask

task prepare_state_copy; begin
	ctl_copy = 1;
end
endtask

endmodule
