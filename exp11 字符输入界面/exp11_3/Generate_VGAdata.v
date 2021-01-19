module Generate_VGAdata(clk, clrn, nonchar_en, nonchar_key, char_ascii,
                        h_addr, v_addr, vga_data,
                        test1_h, test1_l,
                        test2_h, test2_l
                        );
   input clk, clrn, nonchar_en;
   input [3:0] nonchar_key;
   input [7:0] char_ascii;
   input [9:0] h_addr, v_addr;
   
   output reg [11:0] vga_data;
   output [6:0] test1_h, test1_l;
   output [6:0] test2_h, test2_l;
   
   // the character's coordinate corresponding to the current scan address
   wire [9:0] scanchar_x, scanchar_y;
   // coordinate in the character matrix corresponding to the current scan address
   wire [3:0] matrix_x;
   wire [11:0] matrix_y;
   wire [11:0] matrix_line;
   
   wire [7:0] curr_char;
   wire [9:0] cursor_area_h, cursor_area_v;
   
   reg [7:0] screen_ram[0:29][0:69];
   reg [11:0] vga_font[4095:0];
   
   reg [29:0] line_with_prompt;
   
   reg flush_clk, cursor_blink;
   reg [6:0] cursor_x, cursor_y;
   reg [6:0] ram_pointer_x, ram_pointer_y;
   
   integer i, j, flush_cnt, blink_cnt, next_cursor_x;
   
   parameter flush_freq = 4500000;
   parameter blink_freq = 25000000/2/flush_freq;
   
   parameter cmd_prompt_size = 8;
   reg [8:0] cmd_prompt[cmd_prompt_size-1:0];
   
   assign scanchar_x = h_addr / 9;
   assign scanchar_y = v_addr / 16;
   assign curr_char = h_addr < 10'd630 ? screen_ram[scanchar_y][scanchar_x] : 8'b0;
   
   assign matrix_x = h_addr % 9;
   assign matrix_y = {curr_char[7:0], v_addr[3:0]};
   assign matrix_line = vga_font[matrix_y];
   
   // cursor_area_h = cursor_x*9
   // cursor_area_v = cursor_y*16
   assign cursor_area_h = {cursor_x[6:0], 3'b0} + cursor_x;
   assign cursor_area_v = {cursor_y[5:0], 4'b0};
   
   seg_7_out seg3(.in_4bit({1'b0, cursor_y[6:4]}), .out_seg(test1_h));
   seg_7_out seg2(.in_4bit(cursor_y[3:0]), .out_seg(test1_l));
   seg_7_out seg5(.in_4bit({1'b0, cursor_x[6:4]}), .out_seg(test2_h));
   seg_7_out seg4(.in_4bit(cursor_x[3:0]), .out_seg(test2_l));
   
   initial begin
   
   for (i = 0; i < 30; i = i+1)
      for (j = 0; j < 70; j = j+1)
         screen_ram[i][j] = 8'b0;
   $readmemh("D:/source/quartus/exp11_3/vga_font.txt", vga_font, 0, 4095);
   
   // "Hello, world!"
   screen_ram[0][0] = 8'h48;screen_ram[0][1] = 8'h65;
   screen_ram[0][2] = 8'h6C;screen_ram[0][3] = 8'h6C;
   screen_ram[0][4] = 8'h6F;screen_ram[0][5] = 8'h2C;
   screen_ram[0][7] = 8'h77;screen_ram[0][8] = 8'h6F;
   screen_ram[0][9] = 8'h72;screen_ram[0][10] = 8'h6C;
   screen_ram[0][11] = 8'h64;screen_ram[0][12] = 8'h21;
   // "myshell>"
   cmd_prompt[0] = 8'h6D;cmd_prompt[1] = 8'h79;
   cmd_prompt[2] = 8'h73;cmd_prompt[3] = 8'h68;
   cmd_prompt[4] = 8'h65;cmd_prompt[5] = 8'h6C;
   cmd_prompt[6] = 8'h6C;cmd_prompt[7] = 8'h3E;
   
   for (i = 0; i < cmd_prompt_size; i = i+1)
      screen_ram[2][i] = cmd_prompt[i];

   line_with_prompt = 30'b0;
   line_with_prompt[2] = 1;
   
   flush_clk = 0;
   flush_cnt = 0;
   
   cursor_x = cmd_prompt_size;
   cursor_y = 2;
   ram_pointer_x = cmd_prompt_size;
   ram_pointer_y = 2;
   
   cursor_blink = 0;
   blink_cnt = 0;
   
   end
   
   always @ (posedge clk) begin
      if (clrn == 0) begin
         vga_data <= 12'h0;
      end else begin
         if (h_addr >= cursor_area_h && h_addr < cursor_area_h + 9 
         && v_addr >= cursor_area_v && v_addr < cursor_area_v + 16
         && cursor_blink) begin
            vga_data <=  12'hFFF;
         end else begin
            vga_data <= matrix_line[matrix_x[3:0]] ? 12'hFFF : 12'h0;
         end
      end
   end
   
   // for continuous input
   always @ (posedge clk) begin
      if (clrn == 0) begin
         flush_clk <= 0;
         flush_cnt <= 0;
      end else if (flush_cnt == flush_freq) begin
         flush_cnt <= 0;
         flush_clk <= ~flush_clk;
      end else flush_cnt <= flush_cnt + 1;
   end
   
   always @ (posedge flush_clk) begin
      /*if (clrn == 0) begin
         // "Hello, world!"
         screen_ram[0][0] <= 8'h48;screen_ram[0][1] <= 8'h65;
         screen_ram[0][2] <= 8'h6C;screen_ram[0][3] <= 8'h6C;
         screen_ram[0][4] <= 8'h6F;screen_ram[0][5] <= 8'h2C;
         screen_ram[0][7] <= 8'h77;screen_ram[0][8] <= 8'h6F;
         screen_ram[0][9] <= 8'h72;screen_ram[0][10] <= 8'h6C;
         screen_ram[0][11] <= 8'h64;screen_ram[0][12] <= 8'h21;
         // "myshell>"
         cmd_prompt[0] <= 8'h6D;cmd_prompt[1] <= 8'h79;
         cmd_prompt[2] <= 8'h73;cmd_prompt[3] <= 8'h68;
         cmd_prompt[4] <= 8'h65;cmd_prompt[5] <= 8'h6C;
         cmd_prompt[6] <= 8'h6C;cmd_prompt[7] <= 8'h3E;
         for (i = 2; i < 30; i = i+1)
            for (j = 0; j < 70; j = j+1)
               screen_ram[i][j] <= 8'b0;
         for (i = 0; i < cmd_prompt_size; i = i+1)
            screen_ram[2][i] <= cmd_prompt[i];
         line_with_prompt <= 30'b0;
         line_with_prompt[2] <= 1;
         cursor_x <= cmd_prompt_size;
         cursor_y <= 2;
         ram_pointer_x <= cmd_prompt_size;
         ram_pointer_y <= 2;
         cursor_blink <= 0;
         blink_cnt <= 0;
      end else
      begin*/
      if (!nonchar_en && char_ascii == 8'b0) begin // no operations
         if (blink_cnt == blink_freq) begin // cursor blink rate
            blink_cnt <= 0;
            cursor_blink <= ~cursor_blink;
         end else blink_cnt <= blink_cnt + 1;
      end else if (nonchar_en) begin // special command
         cursor_blink <= 1;
         case (nonchar_key) 
            1: begin // left
               if (!(line_with_prompt[cursor_y] && cursor_x == cmd_prompt_size)) begin
                  if (cursor_x == 0) begin
                     if (cursor_y != 2) begin 
                        cursor_y <= cursor_y - 1;
                        cursor_x <= 69;
                     end
                  end else cursor_x <= cursor_x - 1;
               end
            end
            /*2: begin // down
               if (cursor_y < ram_pointer_y) begin
                  cursor_y <= cursor_y + 1;
                  if (line_with_prompt[cursor_y+1] && cursor_x < cmd_prompt_size)
                     cursor_x <= cmd_prompt_size;
                  else if (cursor_x > ram_pointer_x)
                     cursor_x <= ram_pointer_x;
                  else cursor_x <= cursor_x;
               end
            end
            3: begin // up
               if (cursor_y != 2) begin
                  cursor_y <= cursor_y - 1;
                  if (line_with_prompt[cursor_y-1] && cursor_x < cmd_prompt_size)
                     cursor_x <= cmd_prompt_size;
                  else cursor_x <= cursor_x;
               end
            end*/
            4: begin // right
               if (cursor_y < ram_pointer_y
               || cursor_y == ram_pointer_y && cursor_x < ram_pointer_x) begin
                  if (cursor_x == 69) begin
                     cursor_x <= 0;
                     cursor_y <= cursor_y + 1;
                  end else cursor_x <= cursor_x + 1;
               end
            end
            5: begin // enter
               if (ram_pointer_y == 29) begin
                  for (i = 2; i < 30; i = i+1)
                     for (j = 0; j < 70; j = j+1)
                        screen_ram[i][j] = 8'b0;
                  for (i = 0; i < cmd_prompt_size; i = i+1)
                     screen_ram[2][i] <= cmd_prompt[i];
                  line_with_prompt <= 30'b0;
                  line_with_prompt[2] <= 1;
                  cursor_x <= cmd_prompt_size;
                  cursor_y <= 2;
                  ram_pointer_x <= cmd_prompt_size;
                  ram_pointer_y <= 2;
               end else begin
                  for (i = 0; i < cmd_prompt_size; i = i+1)
                     screen_ram[ram_pointer_y+1][i] <= cmd_prompt[i];
                  line_with_prompt[ram_pointer_y+1] <= 1;
                  cursor_x <= cmd_prompt_size;
                  cursor_y <= ram_pointer_y + 1;
                  ram_pointer_x <= cmd_prompt_size;
                  ram_pointer_y <= ram_pointer_y + 1;
               end
            end
            6: begin // backspace
               if (cursor_x == ram_pointer_x && cursor_y == ram_pointer_y
               && (cursor_x != 0 || cursor_y != 2) 
               && (cursor_x != cmd_prompt_size || !line_with_prompt[cursor_y])
               ) begin
                  if (cursor_x == 0) begin
                     screen_ram[cursor_y-1][69] <= 8'b0;
                     cursor_x <= 69;
                     cursor_y <= cursor_y - 1;
                     ram_pointer_x <= 69;
                     ram_pointer_y <= cursor_y - 1;
                  end else begin
                     screen_ram[cursor_y][cursor_x-1] <= 8'b0;
                     cursor_x <= cursor_x-1;
                     ram_pointer_x <= cursor_x-1;
                  end
               end
            end
            default: begin
               cursor_x <= cursor_x;
               cursor_y <= cursor_y;
            end
         endcase
      end else begin // input char
         if (cursor_x == 69) begin
            if (cursor_y == 29) begin
               for (i = 2; i < 30; i = i+1)
                  for (j = 0; j < 70; j = j+1)
                     screen_ram[i][j] = 8'b0;
               screen_ram[2][0] <= char_ascii;
               line_with_prompt <= 30'b0;
               cursor_x <= 1;
               cursor_y <= 2;
               ram_pointer_x <= 1;
               ram_pointer_y <= 2;
            end else begin
               screen_ram[cursor_y][cursor_x] <= char_ascii;
               cursor_x <= 0;
               cursor_y <= cursor_y + 1;
               if (ram_pointer_y == cursor_y 
               && ram_pointer_x == cursor_x) begin
                  ram_pointer_x <= 0;
                  ram_pointer_y <= cursor_y + 1;
               end
            end
         end else begin
            screen_ram[cursor_y][cursor_x] <= char_ascii;
            cursor_x <= cursor_x + 1;
            if (ram_pointer_y == cursor_y 
            && ram_pointer_x == cursor_x) begin
               ram_pointer_x <= cursor_x + 1;
            end
         end
      end
      //end
      
   end

endmodule
