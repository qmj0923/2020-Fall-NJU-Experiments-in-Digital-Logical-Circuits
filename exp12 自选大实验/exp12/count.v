module count(mycount, seg4, seg5);
	input [7:0]mycount;
	output [6:0]seg4, seg5;
	
	myseg s4(1'b1, mycount%10, seg4);
	myseg s5(1'b1, mycount/10, seg5);
//	myseg s4(1'b1, mycount[3:0], seg4);
//	myseg s5(1'b1, mycount[7:4], seg5);	
endmodule 