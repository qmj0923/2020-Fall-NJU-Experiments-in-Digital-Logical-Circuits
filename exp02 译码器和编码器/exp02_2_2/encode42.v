module encode42(x, en, y);
	input [3:0] x;
	input en;
	output reg [1:0]y;
	integer i;
	always @ (x or en) begin
		if (en) begin
			y = 0;
			for (i = 0; i <= 3; i = i + 1)
				if (x[i] == 1) y = i;
		end
		else y = 0;
	end
endmodule 