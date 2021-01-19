module D_ff_asynCLR(CLK, CLR, D, Q);
	input CLK, CLR, D;
	output reg Q;
	
	always @ (posedge CLK or posedge CLR)
		if (CLR) Q <= 0;
		else Q <= D;
endmodule 