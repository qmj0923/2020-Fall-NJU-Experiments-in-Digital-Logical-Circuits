module vga_char(clk,clrn,blink_en, h_addr, v_addr,ram_ascii, cursor_x, cursor_y,
               vga_data,scan_x, scan_y);
   input clk, clrn, blink_en;
   input [9:0] h_addr, v_addr;
   input [7:0] ram_ascii;//read ram get ascii
   input [6:0] cursor_x, cursor_y;
   
   output reg [11:0] vga_data;
   // (x,y) to (630,480) 0<=x<=69  0<=y<=29
   output [9:0] scan_x, scan_y;
   wire [9:0] cursor_scan_x, cursor_scan_y;
   
   // 字符内行列信息
   wire [3:0]  pixel_x; //0~8
   wire [11:0] pixel_y; //0~15
   wire [11:0] pixel_bit;
   
   reg [11:0] vga_font[2047:0];

   initial begin

   $readmemh("D:/exp12/vga_font.txt", vga_font, 0,2047 );
   end
   
	assign scan_x = h_addr / 9;
   assign scan_y = v_addr / 16;
   
   assign pixel_x = h_addr % 9;
   assign pixel_y = {ram_ascii[7:0], v_addr[3:0]};
   assign pixel_bit = vga_font[pixel_y];
   
   // cursor_x*9	 cursor_y*16
   assign cursor_scan_x = {cursor_x[6:0], 3'b0} + cursor_x;
   assign cursor_scan_y = {cursor_y[5:0], 4'b0};


   always @ (posedge clk) begin	//show
      if (clrn == 0) begin
         vga_data <= 12'h0;
      end
      else begin
         if (h_addr >= 179 || v_addr>=239)
            vga_data <=  12'h0;
         else if (h_addr >= cursor_scan_x && h_addr < cursor_scan_x + 9 && v_addr >= cursor_scan_y+13 && v_addr < cursor_scan_y + 16 )
            vga_data <=  12'hFFF;
         else 
            vga_data <= pixel_bit[pixel_x[3:0]] ? 12'hFFF : 12'h0;
      end
   end
   
   
endmodule
