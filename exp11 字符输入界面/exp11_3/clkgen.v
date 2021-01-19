module clkgen(
   input clkin,
   input rst,
   input clken,
   output reg clkout
   );
   
   parameter clk_freq=1000;
   parameter countlimit=50000000/2/clk_freq; // 自动计算计数次数
   
   reg[31:0] clkcount;
   always @ (posedge clkin)
      if(rst) begin
         clkcount=0;
         clkout=1'b0;
      end else begin
         if(clken) begin
            clkcount=clkcount+1;
            if(clkcount>=countlimit) begin
               clkcount=32'd0;
               clkout=~clkout;
            end else begin
               clkout=clkout;
            end
         end else begin
            clkcount=clkcount;
            clkout=clkout;
         end
      end
      
endmodule
