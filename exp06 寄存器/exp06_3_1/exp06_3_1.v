
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module exp06_3_1(

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [8:0]		SW,

	//////////// LED //////////
	output		     [7:0]		LEDR
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

myLFSR i1(KEY[3], KEY[2:0], SW[7:0], SW[8], LEDR[7:0]);

//=======================================================
//  Structural coding
//=======================================================



endmodule
