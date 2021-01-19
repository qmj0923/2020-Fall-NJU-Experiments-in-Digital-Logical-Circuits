module rams_16(clk, en, we, inaddr, outaddr, din, dout_h, dout_l);
	input clk;
	input en, we;
	input [3:0] inaddr;
	input [3:0] outaddr;
	input [1:0] din;
	output reg [6:0] dout_h, dout_l;
	
	reg [7:0] ram [15:0];
	wire [7:0] dout_vec;
	wire [6:0] dout_h_tmp, dout_l_tmp;
	
	initial begin
		$readmemh("D:/source/quartus/exp07_4/mem1.txt", ram, 0, 15);
	end
		
   assign dout_vec = ram[outaddr];
   seg_7_out s1(dout_vec[7:4], dout_h_tmp);
   seg_7_out s2(dout_vec[3:0], dout_l_tmp);
	
   always @ (posedge clk) begin
      if (en && we) ram[inaddr] <= {6'b0, din};
      else if (en && !we) begin
         dout_h <= dout_h_tmp;
         dout_l <= dout_l_tmp;	
      end else begin
         dout_h <= dout_h;
         dout_l <= dout_l;
      end
   end
	
	/* assign dout_h = dout_h_tmp;
	assign dout_l = dout_l_tmp;*/
	
endmodule