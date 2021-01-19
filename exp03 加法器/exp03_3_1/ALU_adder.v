module ALU_adder(A, B, Cin, Y);
	input [3:0] A, B;
	input Cin;
	output [6:0] Y;
	wire [3:0] t_no_Cin;

	assign t_no_Cin = {4{Cin}} ^ B;
	assign Y[4:0] = A + t_no_Cin + Cin; // { carry, result}
	assign Y[5] = (A[3] == t_no_Cin[3]) 
	            && (A[3] != Y[3]); // overflow
	assign Y[6] = ~(| Y[3:0]); // zero 
	
endmodule 