module seg_7_out(in_4bit, out_seg);
   input [3:0] in_4bit;
   output reg [6:0] out_seg;

   always @ (in_4bit) begin
      case (in_4bit)
         0 : out_seg = 7'b1000000;
         1 : out_seg = 7'b1111001;
         2 : out_seg = 7'b0100100;
         3 : out_seg = 7'b0110000;
         4 : out_seg = 7'b0011001;
         5 : out_seg = 7'b0010010;
         6 : out_seg = 7'b0000010;
         7 : out_seg = 7'b1111000;
         8 : out_seg = 7'b0000000;
         9 : out_seg = 7'b0010000;
         10 : out_seg = 7'b0001000;
         11 : out_seg = 7'b0000011;
         12 : out_seg = 7'b1000110;
         13 : out_seg = 7'b0100001;
         14 : out_seg = 7'b0000110;
         15 : out_seg = 7'b0001110;
         default: out_seg = 7'bz;
      endcase
   end

endmodule 