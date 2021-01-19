module sleep_or_not(clk, ps_data, tosleep);
   input clk, ps_data;
   output reg tosleep;
   
   parameter [31:0] lim = 100000000; // default 10000000
   integer cnt;
   
   initial begin
      cnt = 0;
      tosleep = 0;
   end
   
   always @ (posedge clk) begin
      if (ps_data == 0) begin
         cnt <= 0;
         tosleep <= 0;
      end else begin
         if (tosleep == 1 || cnt == lim) begin
            cnt <= lim;
            tosleep <= 1;
         end else begin
            cnt <= cnt + 1;
            tosleep <= 0;
         end
      end
   end
   
endmodule 