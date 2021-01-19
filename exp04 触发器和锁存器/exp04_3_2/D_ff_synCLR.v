module D_ff_synCLR(CLK, CLR, D, Q);
	input CLK, CLR, D;
	output reg Q;
	
	always @ (posedge CLK)
		if (CLR) Q <= 0;
		else Q <= D;
endmodule 