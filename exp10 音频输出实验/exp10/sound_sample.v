
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module sound_sample(

	//////////// CLOCK //////////
	//input 		          		CLOCK2_50,
	//input 		          		CLOCK3_50,
	//input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	//input 		     [9:0]		SW,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// Seg7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	//output		     [6:0]		HEX2,
	//output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// Audio //////////
	input 		          		AUD_ADCDAT,
	inout 		          		AUD_ADCLRCK,
	inout 		          		AUD_BCLK,
	output		          		AUD_DACDAT,
	inout 		          		AUD_DACLRCK,
	output		          		AUD_XCK,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	//inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	//inout 		          		PS2_DAT2,

	//////////// I2C for Audio and Video-In //////////
	output		          		FPGA_I2C_SCLK,
	inout 		          		FPGA_I2C_SDAT
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

wire clk_i2c;
wire reset;
wire [15:0] freq, audiodata;
wire [8:0] l_vol, r_vol;



//=======================================================
//  Structural coding
//=======================================================

assign reset = ~KEY[0];

audio_clk u1(CLOCK_50, reset,AUD_XCK, LEDR[9]);


//I2C part
clkgen #(10000) my_i2c_clk(CLOCK_50,reset,1'b1,clk_i2c);  //10k I2C clock  


I2C_Audio_Config myconfig(clk_i2c, KEY[0],FPGA_I2C_SCLK,FPGA_I2C_SDAT,LEDR[3:0],
                           ~KEY[3], ~KEY[2], l_vol, r_vol);

I2S_Audio myaudio(AUD_XCK, KEY[0], AUD_BCLK, AUD_DACDAT, AUD_DACLRCK, audiodata);

sin_processing out_sin(
   .clk_sys(CLOCK_50), 
   .clk_aud(AUD_DACLRCK),
   .clrn(KEY[0]),
   .ps2_clk(PS2_CLK),
   .ps2_data(PS2_DAT),
   .final_data(audiodata)
);

seg_7_out seg0(
   .in_4bit(r_vol[3:0]), 
   .out_seg(HEX0)
);

seg_7_out seg1(
   .in_4bit(r_vol[7:4]), 
   .out_seg(HEX1)
);

seg_7_out seg4(
   .in_4bit(l_vol[3:0]), 
   .out_seg(HEX4)
);

seg_7_out seg5(
   .in_4bit(l_vol[7:4]), 
   .out_seg(HEX5)
);
endmodule
