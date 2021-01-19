`include "macro.v"

module inst_ram(clk, clrn, 
   re, read_addr, read_data, 
   we, write_addr, write_data,
   read_finished, write_finished,prog_type);
   
   input clk, clrn, re, we;
   input [`INST_RAM_WIDTH-1:0] read_addr, write_addr;
   input [31:0] write_data;
	input [`PROG_TYPE_WIDTH-1:0]prog_type;
   
	output reg [31:0] read_data;
   output reg read_finished, write_finished;
   

   //read from three insts
   reg [7:0] fib_insts[`FIB_RAM_SIZE-1:0];
   reg [7:0] led_insts[`LED_RAM_SIZE-1:0];

	
   initial begin

		$readmemh("D:/exp12/led.txt", led_insts);
		$readmemh("D:/exp12/fib.txt", fib_insts);
   end
    
   always @ (negedge clk) begin // read
      if (clrn == 0 || re == 0) begin
         read_finished <= 0;
      end else begin
			case(prog_type)
				`PROG_LED_ON:read_data <= {led_insts[read_addr+3], led_insts[read_addr+2], led_insts[read_addr+1], led_insts[read_addr]};
				`PROG_LED_OFF:read_data <= {led_insts[read_addr+3], led_insts[read_addr+2], led_insts[read_addr+1], led_insts[read_addr]};
				`PROG_FIB:read_data <= {fib_insts[read_addr+3], fib_insts[read_addr+2], fib_insts[read_addr+1], fib_insts[read_addr]};
				default:read_data<=0;
			endcase
         read_finished <= 1;
      end
   end
   

   
endmodule
