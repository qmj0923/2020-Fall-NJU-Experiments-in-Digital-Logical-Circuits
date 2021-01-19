module top_flyinglogo(clk, rst, pclk, hsync, vsync, valid, vga_r, vga_g, vga_b);
   input           clk;
   input           rst;
   
   output          hsync;
   output          vsync;
   output [3:0]    vga_r;
   output [3:0]    vga_g;
   output [3:0]    vga_b;
   
   
   output          pclk;
   output          valid;
   wire [9:0]      h_cnt;     // 当前位置行坐标
   wire [9:0]      v_cnt;     // 当前位置列坐标
   reg [11:0]      vga_data;
   
   reg [11:0]      rom_addr;  // 当前对应的logo坐标
   wire [11:0]     douta;
   
   wire            logo_area; // 当前位置是否在logo中
   reg [9:0]       logo_x;
   reg [9:0]       logo_y;
   parameter [9:0] logo_length = 64;
   parameter [9:0] logo_hight  = 64;
   parameter [9:0] logo_init_x = 10'b0110101110;
   parameter [9:0] logo_init_y = 10'b0000110010;
   
   reg [7:0]       speed_cnt;
   wire            speed_ctrl;
   
   reg [3:0]       flag_edge;
   reg [1:0]       flag_add_sub;
   
   clkgen #(.clk_freq(25000000)) u00(
      .clkin(clk),
      .rst(rst),
      .clken(1'b1),
      .clkout(pclk)
   );
   
	logo_rom u1 (
      //.clka(pclk),         // input wire clka
      .addra(rom_addr),    // input wire [11 : 0] addra
      .douta(douta)        // output wire [11 : 0] douta
      );
 
	vga_timing u2 (
		.pclk(pclk), 
		.reset(rst), 
		.hsync(hsync), 
		.vsync(vsync), 
		.valid(valid), 
		.h_cnt(h_cnt), 
		.v_cnt(v_cnt)
		);

   debounce u3(
      .clk(pclk), 
      .sig_in(speed_cnt[5]),
      .sig_out(speed_ctrl)
      );
 
   assign logo_area = ((v_cnt >= logo_y) 
                     & (v_cnt <= logo_y + logo_hight - 1) 
                     & (h_cnt >= logo_x) 
                     & (h_cnt <= logo_x + logo_length - 1)) 
                  ? 1'b1 : 1'b0;
   assign vga_r = vga_data[11:8];
   assign vga_g = vga_data[7:4];
   assign vga_b = vga_data[3:0];
                  
   initial begin
      vga_data = 0;
      rom_addr = 0;
      logo_x = logo_init_x;
      logo_y = logo_init_y;
      speed_cnt = 8'h00;
      flag_add_sub = 2'b01;
      flag_edge = 4'h9;
   end
   
   always @(posedge pclk) begin: logo_display
      if (rst == 1'b1)
         vga_data <= 12'b000000000000;
      else begin
         if (valid == 1'b1) begin
            if (logo_area == 1'b1) begin
               rom_addr <= rom_addr + 12'b01;
               vga_data <= douta;
            end else begin
               rom_addr <= rom_addr;
               vga_data <= 12'b000000000000;
            end
         end else begin
            vga_data <= 12'b111111111111;
            if (v_cnt == 1)
               rom_addr <= 12'b0;
         end
      end
   end

   always @(posedge pclk) begin: speed_control
      if (rst == 1'b1)
         speed_cnt <= 8'h00;
      else begin
         if ((v_cnt[5] == 1'b1) & (h_cnt == 1))
            speed_cnt <= speed_cnt + 8'h01;
      end
   end
   

   
   always @(posedge pclk) begin: logo_move
      if (rst == 1'b1) begin
         flag_add_sub = 2'b01;
         
         logo_x <= logo_init_x;
         logo_y <= logo_init_y;
      end else begin
         if (speed_ctrl == 1'b1) begin
            if (logo_x == 1) begin
               if (logo_y == 1) begin
                  flag_edge <= 4'h1; // 左下角
                  flag_add_sub = 2'b00;
               end else if (logo_y == 480 - logo_hight) begin
                  flag_edge <= 4'h2; // 左上角
                  flag_add_sub = 2'b01;
               end else begin
                  flag_edge <= 4'h3; // 左侧边
                  flag_add_sub[1] = (~flag_add_sub[1]);
               end
            end else if (logo_x == 640 - logo_length) begin
               if (logo_y == 1) begin
                  flag_edge <= 4'h4; // 右下角
                  flag_add_sub = 2'b10;
               end else if (logo_y == 480 - logo_hight) begin
                  flag_edge <= 4'h5; // 右上角
                  flag_add_sub = 2'b11;
               end else begin
                  flag_edge <= 4'h6; // 右侧边
                  flag_add_sub[1] = (~flag_add_sub[1]);
               end
            end else if (logo_y == 1) begin
               flag_edge <= 4'h7; // 下侧边
               flag_add_sub[0] = (~flag_add_sub[0]);
            end else if (logo_y == 480 - logo_hight) begin
               flag_edge <= 4'h8; // 上侧边
               flag_add_sub[0] = (~flag_add_sub[0]);
            end else begin
               flag_edge <= 4'h9; // 保持运动方向不变
               flag_add_sub = flag_add_sub;
            end
            
            case (flag_add_sub)
               2'b00 : begin
                     logo_x <= logo_x + 10'b0000000001;
                     logo_y <= logo_y + 10'b0000000001;
                  end
               2'b01 : begin
                     logo_x <= logo_x + 10'b0000000001;
                     logo_y <= logo_y - 10'b0000000001;
                  end
               2'b10 : begin
                     logo_x <= logo_x - 10'b0000000001;
                     logo_y <= logo_y + 10'b0000000001;
                  end
               2'b11 : begin
                     logo_x <= logo_x - 10'b0000000001;
                     logo_y <= logo_y - 10'b0000000001;
                  end
               default : begin
                     logo_x <= logo_x + 10'b0000000001;
                     logo_y <= logo_y + 10'b0000000001;
                  end
            endcase
         end
         
      end
   end
	
endmodule
