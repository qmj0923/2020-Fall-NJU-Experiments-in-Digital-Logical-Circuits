`include "macro.v"

module cpu(clk, clrn, en, curr_PC, PC_end, 
   inst_re, mem_re, mem_we, 
   cpu_finished, inst_finished, 
   mem_r_finished, mem_w_finished,
   inst_data, rt_data, exec_res, 
   mem_addr, mem_data

   // for debug
   // reg_re1, reg_re2, reg_we, 
   // reg_r_finished, reg_w_finished, 
   // rs_addr, rt_addr, reg_w_addr, 
   // rs_data, 
   // state 
   );
   
   input clk, clrn, en;
   reg [2:0] state;
   output cpu_finished;
   
   output reg [`INST_RAM_WIDTH-1:0] curr_PC;
   reg [`INST_RAM_WIDTH-1:0] next_PC;
   input [`INST_RAM_WIDTH-1:0] PC_end;
   reg [`INST_TYPE_WIDTH-1:0] inst_type;

   // instruction fetch
   output reg inst_re;
   input [31:0] inst_data;
   input inst_finished;

   // decode
   reg reg_re1, reg_re2;
   wire [4:0] rs_addr, rt_addr;
   reg [4:0] reg_w_addr;
   wire [4:0] rd_addr, shamt;
   wire [5:0] op, funct;
   wire [15:0] imm16;
   wire [25:0] tar;
   wire [31:0] rs_data;
   output [31:0] rt_data;
   wire reg_r_finished;
   
   // execute
   reg R_en, I_en;
   reg [`DST_TYPE_WIDTH-1:0] dst_type;
   wire [`DST_TYPE_WIDTH-1:0] dst_type_R, dst_type_I;
   wire [31:0] res_R, res_I;
   output reg [31:0] exec_res;
   wire finished_R, finished_I;

   // memory
   output reg mem_re, mem_we;
   output reg [`MEM_RAM_WIDTH-1:0] mem_addr;
   input [31:0] mem_data;
   input mem_r_finished, mem_w_finished;

   // write back
   reg reg_we;
   wire reg_w_finished;

   
   assign op = inst_data[31:26];
   assign rs_addr = inst_data[25:21];
   assign rt_addr = inst_data[20:16];
   assign rd_addr = inst_data[15:11];
   assign shamt = inst_data[10:6];
   assign funct = inst_data[5:0];
   assign imm16 = inst_data[15:0];
   assign tar = inst_data[25:0];
   
   assign cpu_finished = (state == 0) ? 1 :
                     ((state == 1) ? cpu_finished : 0);

   reg_ram reg1(.clk(clk), .clrn(clrn), 
      .re1(reg_re1), .re2(reg_re2), .we(reg_we),
      .read_addr1(rs_addr), .read_data1(rs_data), 
      .read_addr2(rt_addr), .read_data2(rt_data), 
      .write_addr(reg_w_addr), .write_data(exec_res),
      .read_finished(reg_r_finished),
      .write_finished(reg_w_finished));
   
   R_exec r1(.clk(clk), .clrn(clrn), .en(R_en), 
      .shamt(shamt), .funct(funct), 
      .rs_data(rs_data), .rt_data(rt_data), 
      .dst_type(dst_type_R), .res(res_R), 
      .finished(finished_R));
   
   I_exec i1(.clk(clk), .clrn(clrn), .en(I_en), 
      .op(op), .rs_data(rs_data), .rt_data(rt_data), 
      .imm16(imm16), .dst_type(dst_type_I), .res(res_I), 
      .finished(finished_I));
   
   initial begin
      state = 0;
      curr_PC = 0;
   end
   
   always @ (posedge clk) begin
      if (clrn == 0 || en == 0) begin
         state <= 0;
         curr_PC <= 0;
      end else begin
         inst_re <= 0;
         reg_re1 <= 0;
         reg_re2 <= 0;
         reg_we <= 0;
         mem_re <= 0;
         mem_we <= 0;
         R_en <= 0;
         I_en <= 0;
         
         case(state)
         0: begin
            curr_PC <= 0;
            next_PC <= 0;            
            state <= 1;
         end
         1: begin // instruction fetch
            inst_re <= 1;
            next_PC <= curr_PC + 4;
            if (inst_finished) state <= 2;
         end
         2: begin // decode
            reg_re1 <= 1;
            reg_re2 <= 1;
            if (reg_r_finished) begin
               state <= 3;
               if (op == 6'h2) begin // J_TYPE
                  next_PC <= {4'b0, tar, 2'b0}; // [`INST_RAM_WIDTH-1:0]
                  state <= 6;
               end else if (op == 6'h0) begin  // R_TYPE
                  inst_type <= `R_TYPE;
                  reg_w_addr <= rd_addr;
               end else begin
                  inst_type <= `I_TYPE;
                  reg_w_addr <= rt_addr;
               end
            end
         end
         3: begin // execute
            if (inst_type == `R_TYPE) begin
               R_en <= 1;
               if (finished_R) begin
                  exec_res <= res_R;
                  dst_type <= dst_type_R;
                  state <= 5;
               end
            end else if (inst_type == `I_TYPE) begin
               I_en <= 1;
               if (finished_I) begin
                  dst_type <= dst_type_I;
                  if (dst_type_I == `DST_MEM_L
                  || dst_type_I == `DST_MEM_S) begin
                     mem_addr <= res_I[`MEM_RAM_WIDTH-1:0];
                     state <= 4;
                  end else if (dst_type_I == `DST_PC) begin
                     if (res_I) next_PC <= {14'b0, imm16, 2'b0} + curr_PC + 4;
                     state <= 6;
                  end else begin
                     exec_res <= res_I;
                     state <= 5;
                  end
               end
            end
         end
         4: begin // memory
            if (dst_type == `DST_MEM_L) begin
               mem_re <= 1;
               if (mem_r_finished) begin
                  exec_res <= mem_data;
                  state <= 5;
               end
            end else if (dst_type == `DST_MEM_S) begin
               mem_we <= 1;
               if (mem_w_finished) begin
                  state <= 6;
               end
            end
         end
         5: begin // write back
            reg_we <= 1;
            if (reg_w_finished) state <= 6;
         end
         6: begin // PC update
            if (next_PC == PC_end) begin
               state <= 0;
            end else begin
               curr_PC <= next_PC;
               state <= 1;
            end
         end
         endcase
         
      end

   end
   
endmodule
