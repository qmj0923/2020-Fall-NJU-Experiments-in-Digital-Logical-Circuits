module mypic(
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
   
   parameter h_width = 640;
   parameter v_width = 480;
   parameter ram_size = 327680;   
   reg [11:0] vga_data;
   wire [9:0] h_addr, v_addr;
   (* ram_init_file = "D:/source/quartus/exp09_3_1/my_picture.mif" *) reg [11:0] ram[ram_size-1:0];

   
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
      //$readmemh("D:/source/quartus/exp09_3_1/my_picture.txt", ram, 0, ram_size-1);
   end
   
   always @ (posedge clk) begin
      vga_data <= ram[{h_addr[9:0], v_addr[8:0]}];
   end
   
endmodule
