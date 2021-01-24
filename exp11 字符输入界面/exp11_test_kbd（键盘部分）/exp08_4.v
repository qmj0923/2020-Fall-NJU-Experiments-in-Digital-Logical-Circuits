
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module exp08_4(

	//////////// CLOCK //////////
	// input 		          		CLOCK2_50,
	// input 		          		CLOCK3_50,
	// input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// KEY //////////
	input 		     [0:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// Seg7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	//output		     [6:0]		HEX4,
	//output		     [6:0]		HEX5,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	// inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	// inout 		          		PS2_DAT2
   
   // for debug
   // output [1:0] kbd_type,
   // output [7:0] eff_data, ascii_vec, keystrokes
   output [7:0] data
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

   

//=======================================================
//  Structural coding
//=======================================================

   out_kbd o1(
      .clk(CLOCK_50), 
      .clrn(KEY), 
      .ps2_clk(PS2_CLK),
      .ps2_data(PS2_DAT),
      .stat(LEDR[3:0]),
      .nonchar_en(LEDR[9]),
      .nonchar_key(LEDR[7:5]),
      .ascii_h(HEX3), .ascii_l(HEX2),
      .scancode_h(HEX1), .scancode_l(HEX0),
      // .kbd_type(kbd_type), .eff_data(eff_data), .ascii_vec(ascii_vec), .keystrokes(keystrokes)
      .data(data)
   );


endmodule
