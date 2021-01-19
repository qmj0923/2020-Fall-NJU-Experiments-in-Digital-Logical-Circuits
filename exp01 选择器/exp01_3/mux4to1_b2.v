module mux4to1_b2(Y, X0, X1, X2, X3, F);
	input [1:0] Y, X0, X1, X2, X3;
	output reg [1:0] F;
	
	always @ (*)
		case(Y)
			0: F = X0;
			1: F = X1;
			2: F = X2;
			3: F = X3;
			default: F = 2'b00;
		endcase
	
endmodule 