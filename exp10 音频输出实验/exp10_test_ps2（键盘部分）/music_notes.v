module music_notes(
   input clk,
   input en_n,
   input [7:0] eff_data,
   input [7:0] off_data,
   output reg [7:0] pressed_key
   );
   
   parameter [7:0] DO_1 = 8'h16;
   parameter [7:0] RE = 8'h1E;
   parameter [7:0] MI = 8'h26;
   parameter [7:0] FA = 8'h25;
   parameter [7:0] SO = 8'h2E;
   parameter [7:0] LA = 8'h36;
   parameter [7:0] SI = 8'h3D;
   parameter [7:0] DO_2 = 8'h3E;
   
   initial begin
      pressed_key = 8'b0;
   end
   
   always @ (posedge clk) begin
      if (en_n) begin
         pressed_key[0] = (off_data == DO_1) ? 0 : pressed_key[0];
         pressed_key[1] = (off_data == RE) ? 0 : pressed_key[1];
         pressed_key[2] = (off_data == MI) ? 0 : pressed_key[2];
         pressed_key[3] = (off_data == FA) ? 0 : pressed_key[3];
         pressed_key[4] = (off_data == SO) ? 0 : pressed_key[4];
         pressed_key[5] = (off_data == LA) ? 0 : pressed_key[5];
         pressed_key[6] = (off_data == SI) ? 0 : pressed_key[6];
         pressed_key[7] = (off_data == DO_2) ? 0 : pressed_key[7];
      end else begin
         pressed_key[0] = (eff_data == DO_1) ? 1 : pressed_key[0];
         pressed_key[1] = (eff_data == RE) ? 1 : pressed_key[1];
         pressed_key[2] = (eff_data == MI) ? 1 : pressed_key[2];
         pressed_key[3] = (eff_data == FA) ? 1 : pressed_key[3];
         pressed_key[4] = (eff_data == SO) ? 1 : pressed_key[4];
         pressed_key[5] = (eff_data == LA) ? 1 : pressed_key[5];
         pressed_key[6] = (eff_data == SI) ? 1 : pressed_key[6];
         pressed_key[7] = (eff_data == DO_2) ? 1 : pressed_key[7];
      end
   end
   
endmodule
