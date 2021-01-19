module sin_processing(
   input clk_sys,
   input clk_aud,
   input clrn,
   input ps2_clk,
   input ps2_data, 
   output reg [15:0] final_data
   );
   
   parameter [15:0] freq_do_1 = 16'd714;
   parameter [15:0] freq_re = 16'd802;
   parameter [15:0] freq_mi = 16'd900;
   parameter [15:0] freq_fa = 16'd954;
   parameter [15:0] freq_so = 16'd1070;
   parameter [15:0] freq_la = 16'd1201;
   parameter [15:0] freq_si = 16'd1349;
   parameter [15:0] freq_do_2 = 16'd1429;  
   
   wire [7:0] key_8;
   wire [15:0] freq0, freq1, freq2, freq3, freq4, freq5, freq6, freq7;
   wire [15:0] data0_tmp, data1_tmp, data2_tmp, data3_tmp, data4_tmp, data5_tmp, data6_tmp, data7_tmp;
   wire signed [15:0] data0, data1, data2, data3, data4, data5, data6, data7;
   wire signed [7:0] cnt;
   
   out_kbd kbd1(
      .clk(clk_sys),
      .clrn(clrn),
      .ps2_clk(ps2_clk),
      .ps2_data(ps2_data), 
      .key_8(key_8)
   );
   
   Sin_Generator sin_wave0(.clk(clk_aud), .reset_n(clrn), .freq(freq_do_1), .dataout(data0_tmp));
   Sin_Generator sin_wave1(.clk(clk_aud), .reset_n(clrn), .freq(freq_re), .dataout(data1_tmp));
   Sin_Generator sin_wave2(.clk(clk_aud), .reset_n(clrn), .freq(freq_mi), .dataout(data2_tmp));
   Sin_Generator sin_wave3(.clk(clk_aud), .reset_n(clrn), .freq(freq_fa), .dataout(data3_tmp));
   Sin_Generator sin_wave4(.clk(clk_aud), .reset_n(clrn), .freq(freq_so), .dataout(data4_tmp));
   Sin_Generator sin_wave5(.clk(clk_aud), .reset_n(clrn), .freq(freq_la), .dataout(data5_tmp));
   Sin_Generator sin_wave6(.clk(clk_aud), .reset_n(clrn), .freq(freq_si), .dataout(data6_tmp));
   Sin_Generator sin_wave7(.clk(clk_aud), .reset_n(clrn), .freq(freq_do_2), .dataout(data7_tmp));

   assign data0 = key_8[0] ? data0_tmp : 16'd0;
   assign data1 = key_8[1] ? data1_tmp : 16'd0;
   assign data2 = key_8[2] ? data2_tmp : 16'd0;
   assign data3 = key_8[3] ? data3_tmp : 16'd0;
   assign data4 = key_8[4] ? data4_tmp : 16'd0;
   assign data5 = key_8[5] ? data5_tmp : 16'd0;
   assign data6 = key_8[6] ? data6_tmp : 16'd0;
   assign data7 = key_8[7] ? data7_tmp : 16'd0;
   assign cnt = key_8[0]+key_8[1]+key_8[2]+key_8[3]+key_8[4]+key_8[5]+key_8[6]+key_8[7];
   
   initial begin
      final_data = 16'd0;
   end
   
   always @ (posedge clk_aud) begin
      if (clrn == 0 || cnt == 0) begin
         final_data <= 16'd0;
      end else begin
         final_data <= data0/cnt+data1/cnt+data2/cnt+data3/cnt+data4/cnt+data5/cnt+data6/cnt+data7/cnt;
         /*final_data <= $signed(data0)/cnt+$signed(data1)/cnt+$signed(data2)/cnt+$signed(data3)/cnt
                     +$signed(data4)/cnt+$signed(data5)/cnt+$signed(data6)/cnt+$signed(data7)/cnt;*/
      end
   end
      
endmodule
