module p_encoder8to3(X, Y, Z);
	input [7:0] X;
	output reg [3:0] Y;
	output reg [6:0] Z;
	integer i;
	always @(X) begin
		begin : CODE
		Y[3:0] = 4'b0000;
		for (i = 7; i >= 0; i = i - 1)
			if (X[i] == 1) begin
				Y[3:1] = i;
				Y[0] = 1;
				disable CODE;
			end
		end
		case (Y)
			4'd1 : Z = 7'b1000000;
			4'd3 : Z = 7'b1111001;
			4'd5 : Z = 7'b0100100;
			4'd7 : Z = 7'b0110000;
			4'd9 : Z = 7'b0011001;
			4'd11 : Z = 7'b0010010;
			4'd13 : Z = 7'b0000010;
			4'd15 : Z = 7'b1111000;
			default : Z = 7'b0000000;
		endcase
	end
endmodule
	