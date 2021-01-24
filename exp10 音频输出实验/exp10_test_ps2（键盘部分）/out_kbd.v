module out_kbd(
   input clk,
   input clrn,
   input ps2_clk,
   input ps2_data, 
   output [7:0] key_8
   );
   
   wire ready, overflow;
   wire [7:0] data;
   
   reg nextdata_n, pressed, key_off;
   reg [7:0] eff_data, off_data;
   
   integer cnt_key;

   ps2_keyboard inst(
      .clk(clk),
      .clrn(clrn),
      .ps2_clk(ps2_clk),
      .ps2_data(ps2_data),
      .data(data),
      .ready(ready),
      .nextdata_n(nextdata_n),
      .overflow(overflow)
   );
   
   music_notes music1(
      .clk(clk),
      .en_n(key_off),
      .eff_data(eff_data),
      .off_data(off_data),
      .pressed_key(key_8)
   );
   
   initial begin
      nextdata_n = 1;
      key_off = 0;
      pressed = 1;
      eff_data = 8'b0;
      off_data = 8'b0;
      cnt_key = 0;
   end
   
   always @ (posedge clk) begin
      if (clrn == 0) begin
         nextdata_n <= 1;
         key_off <= 0;
         pressed <= 1;
         eff_data <= 8'b0;
         off_data <= 8'b0;
         cnt_key <= 0;
      end else begin
         if (ready) begin 
            if (data == 8'hF0) begin // don't read F0
               pressed <= 0;
            end else begin
               if (pressed == 0) begin
                  pressed <= 1;
                  key_off <= 1; // don't read break code
                  off_data <= data;
                  eff_data <= 0;
               end else begin
                  if (key_off == 0) eff_data <= data;
               end
            end
            nextdata_n <= 0; 
         end else nextdata_n <= 1;
      
         // delay for next effective code
         if (key_off) begin
            if (cnt_key == 5000000) begin
               cnt_key <= 0;
               key_off <= 0;
            end else begin
               cnt_key <= cnt_key + 1;
               key_off <= 1;
            end
         end 
         
      end
   end

endmodule 