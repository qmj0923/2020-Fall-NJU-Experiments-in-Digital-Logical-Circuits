module out_kbd(clk, clrn, ps2_clk, ps2_data, stat,
               keystrokes_h, keystrokes_l,
               ascii_h, ascii_l,
               scancode_h, scancode_l 
               // kbd_type, eff_data, ascii_vec, keystrokes // for debug
               );
   input clk, clrn, ps2_clk, ps2_data;
   output [1:0] stat; // {shift, caps}
   output reg [6:0] keystrokes_h, keystrokes_l, ascii_h, ascii_l, scancode_h, scancode_l; 
   
   wire ready, tosleep, overflow;
   wire [7:0] data;
   wire [7:0] ascii_vec;
   wire [6:0] keystrokes_h_tmp, keystrokes_l_tmp, ascii_h_tmp, ascii_l_tmp, scancode_h_tmp, scancode_l_tmp;
   
   reg nextdata_n, shift_off;
   reg pressed, has_counted;
   reg [1:0] kbd_type; // {shift, caps}
   reg [7:0] eff_data, keystrokes;
   
   integer cnt_shift;
   
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
   
   sleep_or_not sp1(
      .clk(clk),
      .ps_data(ps2_data),
      .tosleep(tosleep)
   ); 
      
   roms_ascii rom1(
      .kbd_type(kbd_type), 
      .addr(eff_data), 
      .dout_vec(ascii_vec)
   );

   seg_7_out seg1(.in_4bit(eff_data[7:4]), .out_seg(scancode_h_tmp));
   seg_7_out seg0(.in_4bit(eff_data[3:0]), .out_seg(scancode_l_tmp));
   seg_7_out seg3(.in_4bit(ascii_vec[7:4]), .out_seg(ascii_h_tmp));
   seg_7_out seg2(.in_4bit(ascii_vec[3:0]), .out_seg(ascii_l_tmp));
   seg_7_out seg5(.in_4bit(keystrokes[7:4]), .out_seg(keystrokes_h_tmp));
   seg_7_out seg4(.in_4bit(keystrokes[3:0]), .out_seg(keystrokes_l_tmp));
   
   initial begin
      nextdata_n = 1;
      shift_off = 0;
      pressed = 1;
      has_counted = 0;
      kbd_type = 2'b0;
      eff_data = 8'b0;
      keystrokes = 0;
      cnt_shift = 0;
   end
   
   always @ (posedge clk) begin
      if (clrn == 0) begin
         nextdata_n <= 1;
         shift_off <= 0;
         pressed <= 1;
         has_counted <= 0;
         kbd_type <= 2'b0;
         eff_data <= 8'b0;
         keystrokes <= 0;
         cnt_shift <= 0;
      end else begin
         if (ready) begin 
            if (data == 8'hF0) begin // don't read F0
               pressed <= 0;
               if (has_counted == 0) begin
                  keystrokes <= keystrokes + 1;
                  has_counted <= 1;
               end 
            end else begin
               has_counted <= 0;
               if (pressed == 0) begin
                  pressed <= 1;
                  if (data == 8'h58) kbd_type[0] <= ~kbd_type[0]; // Caps
                  if (data == 8'h12 || data == 8'h59) begin // shift off
                     kbd_type[1] <= 0;
                     shift_off <= 1;
                  end
               end else begin
                  eff_data <= data;
                  if ((data == 8'h12 || data == 8'h59) && shift_off == 0) begin
                     kbd_type[1] <= 1; // shift on
                  end
               end
            end
            nextdata_n <= 0; 
         end else nextdata_n <= 1;
      
         // delay for next shift
         if (shift_off) begin
            if (cnt_shift == 10000000) begin
               cnt_shift <= 0;
               shift_off <= 0;
            end else begin
               cnt_shift <= cnt_shift + 1;
               shift_off <= 1;
            end
         end 
         
      end
   end
   
   always @ (posedge clk) begin
      if (clrn == 0) begin
         keystrokes_h <= 7'bz;
         keystrokes_l <= 7'bz;
         ascii_h <= 7'bz;
         ascii_l <= 7'bz;
         scancode_h <= 7'bz;
         scancode_l <= 7'bz;
      end else begin
         keystrokes_h <= keystrokes_h_tmp;
         keystrokes_l <= keystrokes_l_tmp;
         if (tosleep) begin 
            ascii_h <= 7'bz;
            ascii_l <= 7'bz;
            scancode_h <= 7'bz;
            scancode_l <= 7'bz;
         end else begin
            ascii_h <= ascii_h_tmp;
            ascii_l <= ascii_l_tmp;
            scancode_h <= scancode_h_tmp;
            scancode_l <= scancode_l_tmp;
         end
      end
   end

endmodule 