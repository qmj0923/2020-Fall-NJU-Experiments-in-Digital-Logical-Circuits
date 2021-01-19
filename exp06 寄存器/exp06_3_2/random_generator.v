module random_generator(clk, out_H, out_L);
	input clk;
	output reg [6:0] out_H, out_L;
	reg [7:0] out_binary = 8'b00000001;
	
	always @ (negedge clk)
		out_binary <= {(out_binary[4]^out_binary[3]^out_binary[2]^out_binary[0]),
			out_binary[7:1]};
			
	always @ (out_binary) begin
			case (out_binary[7:4])
			0 : out_H = 7'b1000000;
			1 : out_H = 7'b1111001;
			2 : out_H = 7'b0100100;
			3 : out_H = 7'b0110000;
			4 : out_H = 7'b0011001;
			5 : out_H = 7'b0010010;
			6 : out_H = 7'b0000010;
			7 : out_H = 7'b1111000;
			8 : out_H = 7'b0000000;
			9 : out_H = 7'b0010000;
			10 : out_H = 7'b0001000;
			11 : out_H = 7'b0000011;
			12 : out_H = 7'b1000110;
			13 : out_H = 7'b0100001;
			14 : out_H = 7'b0000110;
			15 : out_H = 7'b0001110;
			default: out_H = 7'bx;
		endcase
		case (out_binary[3:0])
			0 : out_L = 7'b1000000;
			1 : out_L = 7'b1111001;
			2 : out_L = 7'b0100100;
			3 : out_L = 7'b0110000;
			4 : out_L = 7'b0011001;
			5 : out_L = 7'b0010010;
			6 : out_L = 7'b0000010;
			7 : out_L = 7'b1111000;
			8 : out_L = 7'b0000000;
			9 : out_L = 7'b0010000;
			10 : out_L = 7'b0001000;
			11 : out_L = 7'b0000011;
			12 : out_L = 7'b1000110;
			13 : out_L = 7'b0100001;
			14 : out_L = 7'b0000110;
			15 : out_L = 7'b0001110;
			default: out_L = 7'bx;
		endcase
	end
	
endmodule
	