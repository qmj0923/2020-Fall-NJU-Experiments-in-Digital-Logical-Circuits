module out_kbd(clk, clrn, ps2_clk, ps2_data, 
               nonchar_en, nonchar_key,
               stat, ascii_vec,
               ascii_h, ascii_l
               //scancode_h, scancode_l 
               );
   input clk, clrn, ps2_clk, ps2_data;
   output reg nonchar_en;
   
   // 1:left, 2:down, 3:up, 4:right, 5:enter, 6:backspace
   output reg [2:0] nonchar_key; 
   
   // {alt, ctrl, shift, caps}
   output [3:0] stat;
   
   output [7:0] ascii_vec;
   output [6:0] ascii_h, ascii_l;
   //output [6:0] scancode_h, scancode_l;
   
   wire ready, overflow;
   wire [7:0] data;
   
   reg nextdata_n, pressed, key_off, E0_skip;
   reg [3:0] kbd_type; //  {alt, ctrl, shift, caps}
   reg [7:0] eff_data;
   
   integer cnt_off;
   
   assign stat = kbd_type;

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
      
   roms_ascii rom1(
      .kbd_type(kbd_type[1:0]), 
      .addr(eff_data), 
      .dout_vec(ascii_vec)
   );

   //seg_7_out seg1(.in_4bit(eff_data[7:4]), .out_seg(scancode_h));
   //seg_7_out seg0(.in_4bit(eff_data[3:0]), .out_seg(scancode_l));
   seg_7_out seg3(.in_4bit(ascii_vec[7:4]), .out_seg(ascii_h));
   seg_7_out seg2(.in_4bit(ascii_vec[3:0]), .out_seg(ascii_l));
   
   initial begin
      nonchar_en = 0;
      nonchar_key = 0;
      nextdata_n = 1;
      pressed = 1;
      key_off = 0;
      E0_skip = 0;
      kbd_type = 4'b0;
      eff_data = 8'b0;
      cnt_off = 0;
   end
   
   always @ (posedge clk) begin
      if (clrn == 0) begin
         nonchar_en <= 0;
         nonchar_key <= 0;
         nextdata_n <= 1;
         pressed <= 1;
         key_off <= 0;
         E0_skip <= 0;
         kbd_type <= 4'b0;
         eff_data <= 8'b0;
         cnt_off <= 0;
      end else begin
         if (ready) begin 
            if (data == 8'hF0) begin // don't read "F0"
               pressed <= 0; // skip code "F0"
               nonchar_en <= 0;  // disable nonchar keys
               nonchar_key <= 0;
               eff_data <= 8'b0;
            end else begin
               if (pressed == 0) begin 
                  // the first time read the code that next "F0"
                  pressed <= 1;
                  key_off <= 1; // wait a while before reading the next code
                  if (data == 8'h58) kbd_type[0] <= ~kbd_type[0]; // Caps
                  else if (data == 8'h12 || data == 8'h59) kbd_type[1] <= 0; // shift off
                  else if (data == 8'h14) kbd_type[2] <= 0; // ctrl off
                  else if (data == 8'h11) kbd_type[3] <= 0; // alt off
               end else if (key_off == 0) begin
                  if (data == 8'hE0) begin
                     E0_skip <= 1; // skip code "E0"
                     eff_data <= 8'b0;
                  end else begin
                     if (E0_skip) begin
                        // the first time read the code that next "E0"
                        E0_skip <= 0;
                        if (data == 8'hF0) begin
                           pressed <= 0;
                           nonchar_en <= 0;
                           nonchar_key <= 0;
                        end else begin
                           if (data == 8'h6B) begin // left
                              nonchar_key <= 1;
                              nonchar_en <= 1;
                           end else if (data == 8'h72) begin // down
                              nonchar_key <= 2;
                              nonchar_en <= 1;
                           end else if (data == 8'h75) begin // up
                              nonchar_key <= 3;
                              nonchar_en <= 1;
                           end else if (data == 8'h74) begin // right 
                              nonchar_key <= 4;
                              nonchar_en <= 1;
                           end else if (data == 8'h14) kbd_type[2] <= 1; // ctrl
                           else if (data == 8'h11) kbd_type[3] <= 1; // alt
                        end
                     end else begin
                        // normal data
                        if (data == 8'h12 || data == 8'h59
                           || data == 8'h14 || data == 8'h11
                           || data == 8'h58 || data == 8'h5A
                           || data == 8'h66 || data == 8'h76
                           || data == 8'h05 || data == 8'h06
                           || data == 8'h04 || data == 8'h0C
                           || data == 8'h03 || data == 8'h0B
                           || data == 8'h83 || data == 8'h0A
                           || data == 8'h01 || data == 8'h09
                           || data == 8'h78 || data == 8'h07)
                        begin
                           eff_data <= 8'b0;
                           if (data == 8'h12 || data == 8'h59) kbd_type[1] <= 1; // shift
                           else if (data == 8'h14) kbd_type[2] <= 1; // ctrl
                           else if (data == 8'h11) kbd_type[3] <= 1; // alt
                           else if (data == 8'h5A) begin // enter
                              nonchar_key <= 5;
                              nonchar_en <= 1;
                           end else if (data == 8'h66) begin// backspace
                              nonchar_key <= 6;
                              nonchar_en <= 1;
                           end
                        end else eff_data <= data;
                     end
                  end
               end
            end
            nextdata_n <= 0; 
         end else nextdata_n <= 1;
      
         // delay for next shift
         if (key_off) begin
            if (cnt_off == 2500000) begin
               cnt_off <= 0;
               key_off <= 0;
            end else begin
               cnt_off <= cnt_off + 1;
               key_off <= 1;
            end
         end 
         
      end
   end

endmodule 