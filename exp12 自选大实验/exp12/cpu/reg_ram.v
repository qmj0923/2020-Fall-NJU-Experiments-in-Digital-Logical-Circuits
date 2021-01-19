module reg_ram(clk, clrn, 
   re1, read_addr1, read_data1, 
   re2, read_addr2, read_data2, 
   we, write_addr, write_data,
   read_finished, write_finished);
   
   input clk, clrn, re1, re2, we;
   input [4:0] read_addr1, read_addr2, write_addr;
   input [31:0] write_data;
   
   
   output reg [31:0] read_data1, read_data2;
   output reg read_finished, write_finished;
   
   reg [31:0] regs[31:0];
   
   initial begin
      $readmemh("D:/exp12/reg_file.txt", regs, 0, 31);
   end
    
   always @ (negedge clk) begin // read
      if (clrn == 0 || (re1 == 0 && re2 == 0)) begin
         read_finished <= 0;
      end else begin
         if (re1) read_data1 <= regs[read_addr1];
         if (re2) read_data2 <= regs[read_addr2];
         read_finished <= 1;
      end
   end
   
   always @(posedge clk) begin // write
      if (clrn == 0 || we == 0) begin
         write_finished <= 0;
      end else begin
         regs[write_addr] <= write_data;
         write_finished <= 1;
      end
   end
   
endmodule
