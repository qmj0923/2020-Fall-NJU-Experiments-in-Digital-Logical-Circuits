module roms_ascii(kbd_type, addr, dout_vec);
   input [1:0] kbd_type; // normal, cap, shift, capshift 
   input [7:0] addr;
   output reg [7:0] dout_vec;
   
   reg [7:0] normcode[255:0];
   reg [7:0] capcode[255:0];
   reg [7:0] shiftcode[255:0];
   reg [7:0] capshiftcode[255:0];
   
   initial begin
      dout_vec = 8'bz;
      $readmemh("D:/source/quartus/exp11_test_kbd/scancode.txt", normcode, 0, 255);
      $readmemh("D:/source/quartus/exp11_test_kbd/capcode.txt", capcode, 0, 255);
      $readmemh("D:/source/quartus/exp11_test_kbd/shiftcode.txt", shiftcode, 0, 255);
      $readmemh("D:/source/quartus/exp11_test_kbd/capshiftcode.txt", capshiftcode, 0, 255);
   end
      
   always @ (*) begin
      case (kbd_type) 
         2'd0: dout_vec = normcode[addr];
         2'd1: dout_vec = capcode[addr];
         2'd2: dout_vec = shiftcode[addr];
         2'd3: dout_vec = capshiftcode[addr];
         default: dout_vec = 8'bz;
      endcase
   end
   
endmodule