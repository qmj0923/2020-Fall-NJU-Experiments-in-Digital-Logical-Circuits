module my_clock(clk_sys, alarm_clk, set_acce, sign_alarm, 
	h_ten, h_one, min_ten, min_one, s_ten, s_one);
	input clk_sys;
	input [9:0] alarm_clk; // {on_off, h, min_per_5}
	input [3:0] set_acce; // {on-off, h, min, s}
	output reg sign_alarm;
	output reg [6:0] h_ten, h_one, min_ten, min_one, s_ten, s_one;
	
	reg clk_1s;
	reg [24:0] count_clk; 
	integer alarm_h, alarm_min, count_h, count_min, count_s;
	
	initial begin
		sign_alarm = 0;
		h_ten = 7'b1;
		h_one = 7'b1;
		min_ten = 7'b1;
		min_one = 7'b1;
		s_ten = 7'b1;
		s_one = 7'b1;
		
		clk_1s = 0;
		count_clk = 0;

		count_h = 0;
		count_min = 0;
		count_s = 0;
	end
	
	always @ (posedge clk_sys)
		if (count_clk == 25'd25000000) begin // # change to 25'd5 for test bench
			count_clk <= 0;
			clk_1s <= ~clk_1s;
		end else
			count_clk <= count_clk + 1;

	always @ (alarm_clk[9] or count_h or count_min or count_s)
		if (alarm_clk[9]) begin
			alarm_h = alarm_clk[8:4];
			alarm_min = alarm_clk[3:0];
			alarm_min = alarm_min * 5;
			if (alarm_h == count_h 
				&& count_min >= alarm_min 
				&& count_min < alarm_min + 5)
				sign_alarm = 1;
			else 
				sign_alarm = 0;
		end else
			sign_alarm = 0;
			
	always @ (posedge clk_1s) begin
		if (~set_acce[3]) begin
			if (~set_acce[2]) count_h <= (count_h + 1) % 24;
			if (~set_acce[1]) count_min <= (count_min + 1) % 60;
			if (~set_acce[0]) count_s <= (count_s + 3) % 60;
		end
		else if (count_s == 59) begin
			count_s <= 0;
			if (count_min == 59) begin
				count_min <= 0;
				if (count_h == 23) count_h <= 0;
				else count_h <= count_h + 1;
			end else 
				count_min <= count_min + 1;
		end else
			count_s <= count_s + 1;
			
		case (count_s / 10)
			0 : s_ten <= 7'b1000000;
			1 : s_ten <= 7'b1111001;
			2 : s_ten <= 7'b0100100;
			3 : s_ten <= 7'b0110000;
			4 : s_ten <= 7'b0011001;
			5 : s_ten <= 7'b0010010;
			6 : s_ten <= 7'b0000010;
			7 : s_ten <= 7'b1111000;
			8 : s_ten <= 7'b0000000;
			9 : s_ten <= 7'b0010000;
			default: s_ten <= 7'bx;
		endcase
		case (count_s % 10)
			0 : s_one <= 7'b1000000;
			1 : s_one <= 7'b1111001;
			2 : s_one <= 7'b0100100;
			3 : s_one <= 7'b0110000;
			4 : s_one <= 7'b0011001;
			5 : s_one <= 7'b0010010;
			6 : s_one <= 7'b0000010;
			7 : s_one <= 7'b1111000;
			8 : s_one <= 7'b0000000;
			9 : s_one <= 7'b0010000;
			default: s_one <= 7'bx;
		endcase
		
		case (count_min / 10)
			0 : min_ten <= 7'b1000000;
			1 : min_ten <= 7'b1111001;
			2 : min_ten <= 7'b0100100;
			3 : min_ten <= 7'b0110000;
			4 : min_ten <= 7'b0011001;
			5 : min_ten <= 7'b0010010;
			6 : min_ten <= 7'b0000010;
			7 : min_ten <= 7'b1111000;
			8 : min_ten <= 7'b0000000;
			9 : min_ten <= 7'b0010000;
			default: min_ten <= 7'bx;
		endcase
		case (count_min % 10)
			0 : min_one <= 7'b1000000;
			1 : min_one <= 7'b1111001;
			2 : min_one <= 7'b0100100;
			3 : min_one <= 7'b0110000;
			4 : min_one <= 7'b0011001;
			5 : min_one <= 7'b0010010;
			6 : min_one <= 7'b0000010;
			7 : min_one <= 7'b1111000;
			8 : min_one <= 7'b0000000;
			9 : min_one <= 7'b0010000;
			default: min_one <= 7'bx;
		endcase	

		case (count_h / 10)
			0 : h_ten <= 7'b1000000;
			1 : h_ten <= 7'b1111001;
			2 : h_ten <= 7'b0100100;
			3 : h_ten <= 7'b0110000;
			4 : h_ten <= 7'b0011001;
			5 : h_ten <= 7'b0010010;
			6 : h_ten <= 7'b0000010;
			7 : h_ten <= 7'b1111000;
			8 : h_ten <= 7'b0000000;
			9 : h_ten <= 7'b0010000;
			default: h_ten <= 7'bx;
		endcase
		case (count_h % 10)
			0 : h_one <= 7'b1000000;
			1 : h_one <= 7'b1111001;
			2 : h_one <= 7'b0100100;
			3 : h_one <= 7'b0110000;
			4 : h_one <= 7'b0011001;
			5 : h_one <= 7'b0010010;
			6 : h_one <= 7'b0000010;
			7 : h_one <= 7'b1111000;
			8 : h_one <= 7'b0000000;
			9 : h_one <= 7'b0010000;
			default: h_one <= 7'bx;
		endcase
	end
		

endmodule 