module counter_100(clk_sys, clr, pause, sign_pause, RCO, Y_tens, Y_ones);
	input clk_sys, clr, pause;
	output reg sign_pause, RCO;
	output reg [6:0] Y_tens, Y_ones;
	
	reg clk_1s;
	reg [24:0] count_clk; 
	integer count;
	
	initial begin
		sign_pause = 0;
		RCO = 0;
		Y_tens = 7'b1;
		Y_ones = 7'b1;
		
		clk_1s = 0;
		count_clk = 0;
		count = 0;
	end
	
	always @ (posedge clk_sys)
		if (count_clk == 25'd25000000) begin
			count_clk <= 0;
			clk_1s <= ~clk_1s;
		end else
			count_clk <= count_clk + 1;
	
	always @ (count or pause)
		if (count == 99 && ~pause) RCO = 1;
		else                       RCO = 0;
		
	always @ (pause)
		if (pause) sign_pause = 1;
		else       sign_pause = 0;
		
	always @ (posedge clk_1s) begin
		if (clr)                        count <= 0;
		else if (~pause && count == 99) count <= 0;
		else if (~pause)                count <= count + 1;
		else                            count <= count;
	
		case (count / 10)
			0 : Y_tens <= 7'b1000000;
			1 : Y_tens <= 7'b1111001;
			2 : Y_tens <= 7'b0100100;
			3 : Y_tens <= 7'b0110000;
			4 : Y_tens <= 7'b0011001;
			5 : Y_tens <= 7'b0010010;
			6 : Y_tens <= 7'b0000010;
			7 : Y_tens <= 7'b1111000;
			8 : Y_tens <= 7'b0000000;
			9 : Y_tens <= 7'b0010000;
			default: Y_tens <= 7'bx;
		endcase
		case (count % 10)
			0 : Y_ones <= 7'b1000000;
			1 : Y_ones <= 7'b1111001;
			2 : Y_ones <= 7'b0100100;
			3 : Y_ones <= 7'b0110000;
			4 : Y_ones <= 7'b0011001;
			5 : Y_ones <= 7'b0010010;
			6 : Y_ones <= 7'b0000010;
			7 : Y_ones <= 7'b1111000;
			8 : Y_ones <= 7'b0000000;
			9 : Y_ones <= 7'b0010000;
			default: Y_ones <= 7'bx;
		endcase
	end

endmodule 