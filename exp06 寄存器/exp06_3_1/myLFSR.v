module myLFSR(clk, ctr, load_val, in_data, out_Q);
	input clk, in_data;
	input [2:0] ctr;
	input [7:0] load_val;
	output reg [7:0] out_Q = 8'b0;
	
	always @ (negedge clk)
		case (ctr)
			3'd0: out_Q <= 8'b0;
			3'd1: out_Q <= load_val;
			3'd2: out_Q <= {1'b0, out_Q[7:1]};
			3'd3: out_Q <= {out_Q[6:0], 1'b0};
			3'd4: out_Q <= {out_Q[7], out_Q[7:1]};
			3'd5: out_Q <= {in_data, out_Q[7:1]};
			3'd6: out_Q <= {out_Q[0], out_Q[7:1]};
			3'd7: out_Q <= {out_Q[6:0], out_Q[7]};
			default: out_Q <= 8'bx;
		endcase
endmodule
	