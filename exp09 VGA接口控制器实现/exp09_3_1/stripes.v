module stripes(
   input clk,
   input reset,
   output vga_clk,
   output vga_hs,
   output vga_vs,
   output valid,
   output [3:0] vga_r,
   output [3:0] vga_g,
   output [3:0] vga_b
   );
   
   reg [11:0] vga_data;
   wire [9:0] h_addr, v_addr;
   parameter h_width = 640;
   parameter v_width = 480;
   
   clkgen #(.clk_freq(25000000)) my_vgaclk(
      .clkin(clk),
      .rst(reset),
      .clken(1'b1),
      .clkout(vga_clk)
   );
   
   vga_ctrl v1(
      .pclk(vga_clk), //25MHz 时钟
      .reset(reset), // 置位
      .vga_data(vga_data), // 上层模块提供的VGA 颜色数据
      .h_addr(h_addr), // 提供给上层模块的当前扫描像素点坐标
      .v_addr(v_addr),
      .hsync(vga_hs), // 行同步和列同步信号
      .vsync(vga_vs),
      .valid(valid), // 消隐信号
      .vga_r(vga_r), // 红绿蓝颜色信号
      .vga_g(vga_g),
      .vga_b(vga_b)
   );
      
   initial begin
      vga_data = 0;
   end
   
   always @ (posedge clk) begin
      if (v_addr < 80 
         || (v_addr >= 240 && v_addr < 320)
         ) vga_data <= 12'hF00;
      else if ((v_addr >= 80 && v_addr < 160)
         || (v_addr >= 320 && v_addr < 400)
         ) vga_data <= 12'h0F0;
      else if ((v_addr >= 160 && v_addr < 240)
         || (v_addr >= 400 && v_addr < 480)
         ) vga_data <= 12'h00F;
      else vga_data <= 12'h0;
   end
   
endmodule
