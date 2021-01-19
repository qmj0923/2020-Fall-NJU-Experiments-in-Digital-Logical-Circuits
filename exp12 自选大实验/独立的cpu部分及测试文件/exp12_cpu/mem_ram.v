`include "macro.v"

module mem_ram(clk, clrn, 
   re, read_addr, read_data, 
   we, write_addr, write_data,
   read_finished, write_finished);
   
   input clk, clrn, re, we;
   input [`MEM_RAM_WIDTH-1:0] read_addr, write_addr;
   input [31:0] write_data;
   
   output reg [31:0] read_data;
   output reg read_finished, write_finished;
   
   reg [7:0] mems[`MEM_RAM_SIZE-1:0];
   
   initial begin
      $readmemh("D:/source/quartus/exp12_cpu/mem_file.txt", mems, 0, `MEM_RAM_SIZE-1);
   end
   
   always @ (negedge clk) begin // read
      if (clrn == 0 || re == 0) begin
         read_finished <= 0;
      end else begin
         read_data <= {mems[read_addr+3], mems[read_addr+2], mems[read_addr+1], mems[read_addr]};
         read_finished <= 1;
      end
   end
   
   always @(posedge clk) begin // write
      if (clrn == 0 || we == 0) begin
         write_finished <= 0;
      end else begin
         {mems[write_addr+3], mems[write_addr+2], mems[write_addr+1], mems[write_addr]} <= write_data;
         write_finished <= 1;
      end
   end
   
endmodule
