`include "macro.v"

module R_exec(clk, clrn, en, shamt, funct, 
   rs_data, rt_data, dst_type, res, finished);
   input clk, clrn, en;
   input [4:0] shamt;
   input [5:0] funct;
   input [31:0] rs_data, rt_data;
   
   output [`DST_TYPE_WIDTH-1:0] dst_type;
   output reg [31:0] res;
   output reg finished;
   
   assign dst_type = `DST_RD;
   
   always @ (posedge clk) begin
      if (clrn == 0 || en == 0) begin
         finished <= 0;
      end else begin
         case(funct)
         `FUNCT_ADD, `FUNCT_ADDU: res <= rs_data + rt_data;
         `FUNCT_SUB, `FUNCT_SUBU: res <= rs_data + (~rt_data) + 1;
         `FUNCT_AND  : res <= rs_data & rt_data;
         `FUNCT_OR   : res <= rs_data | rt_data;
         `FUNCT_XOR  : res <= rs_data ^ rt_data;
         `FUNCT_NOR  : res <= !(rs_data | rt_data);
         `FUNCT_SLT  : res <= $signed(rs_data) < $signed(rt_data);
         `FUNCT_SLTU : res <= rs_data < rt_data;
         `FUNCT_SLL  : res <= rt_data << shamt;
         `FUNCT_SRL  : res <= rt_data >> shamt;
         `FUNCT_SRA  : res <= $signed(rt_data) >>> shamt;
         `FUNCT_SLLV : res <= rt_data << rs_data;
         `FUNCT_SRLV : res <= rt_data >> rs_data;
         `FUNCT_SRAV : res <= $signed(rt_data) >>> rs_data;
         endcase
         finished <= 1;
      end
   end
   
endmodule
