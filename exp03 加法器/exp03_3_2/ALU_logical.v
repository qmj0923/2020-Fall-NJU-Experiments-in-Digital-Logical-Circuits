module ALU_logical(A, B, C, Y);
	input [3:0] A, B;
	input [2:0] C;
	output reg [6:0] Y;
	wire [3:0] t_no_Cin;
	wire [6:0] result0, result1, result2, result3,
			result4, result5, result6, result7;
	
	assign result0[4:0] = A + B;
	assign result0[5] = (A[3] == B[3]) 
	            && (A[3] != result0[3]); // overflow
	assign result0[6] = ~(| result0[3:0]); // zero 
	
	assign t_no_Cin = ~B;
	assign result1[4:0] = A + t_no_Cin + 1; // {carry, result}
	assign result1[5] = (A[3] == t_no_Cin[3]) 
	            && (A[3] != result1[3]); // overflow
	assign result1[6] = ~(| result1[3:0]); // zero 
	
	assign result2[6:4] = 3'b0;
	assign result3[6:4] = 3'b0;
	assign result4[6:4] = 3'b0;
	assign result5[6:4] = 3'b0;
	assign result6[6:1] = 6'b0;
	assign result7[6:1] = 6'b0;
	
	assign result2[3:0] = ~A;
	assign result3[3:0] = A & B;
	assign result4[3:0] = A | B;
	assign result5[3:0] = A ^ B;
	assign result6[0] = (A[3] == B[3] && A[2:0] > B[2:0]) 
		|| (A[3] == 0) && (B[3] == 1); // A > B
	assign result7[0] = (A == B);
	
	always @ (*)
		case (C)
			3'd0 : Y = result0;
			3'd1 : Y = result1;
			3'd2 : Y = result2;
			3'd3 : Y = result3;
			3'd4 : Y = result4;
			3'd5 : Y = result5;
			3'd6 : Y = result6;
			3'd7 : Y = result7;
		default: Y = 7'bx;
		endcase
		
endmodule 