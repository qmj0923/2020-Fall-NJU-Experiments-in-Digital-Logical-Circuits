`include "macro.v"

module I_exec(clk, clrn, en, 
   op, rs_data, rt_data, imm16,
   dst_type, res, finished);
   
   input clk, clrn, en;
   input [5:0] op;
   input [31:0] rs_data, rt_data;
   input [15:0] imm16;
   
   output reg [31:0] res;
   output reg [`DST_TYPE_WIDTH-1:0] dst_type;
   output reg finished;
   
   wire [31:0] imm32;
   assign imm32 = {{16{imm16[15]}}, imm16};
   
   always @(posedge clk) begin
      if (clrn == 0 || en == 0) begin
         finished <= 0;
      end else begin
         case(op)
         `OP_ADDI, `OP_ADDIU: begin
            res <= rs_data + imm32;
            dst_type <= `DST_RT;
         end
         `OP_SLTI: begin
            res <= $signed(rs_data) < $signed(imm32);
            dst_type <= `DST_RT;
         end
         `OP_SLTIU: begin
            res <= rs_data < imm32;
            dst_type <= `DST_RT;
         end
         `OP_ANDI: begin
            res <= rs_data & imm32;
            dst_type <= `DST_RT;
         end
         `OP_ORI: begin
            res <= rs_data | imm32;
            dst_type <= `DST_RT;
         end
         `OP_XORI: begin
            res <= rs_data ^ imm32;
            dst_type <= `DST_RT;
         end
         `OP_BEQ: begin
            res <= rs_data == rt_data;
            dst_type <= `DST_PC;
         end
         `OP_BNE: begin
            res <= rs_data != rt_data;
            dst_type <= `DST_PC;
         end
         `OP_BLEZ: begin
            res <= $signed(rs_data) <= 0;
            dst_type <= `DST_PC;
         end
         `OP_BGTZ: begin
            res <= $signed(rs_data) > 0;
            dst_type <= `DST_PC;
         end
         `OP_LW: begin
            res <= rs_data + imm32;
            dst_type <= `DST_MEM_L;
         end
         `OP_SW: begin
            res <= rs_data + imm32;
            dst_type <= `DST_MEM_S;
         end
         endcase
         finished <= 1;
      end
   end
   
endmodule
