`include "macro.v"

module mem_ram(clk, clrn, 
   re, read_addr, read_data, 
   we, write_addr, write_data,
   read_finished, write_finished,func_char,
   scan_addr,scan_data,blink_en,one_char_flag,
	prog_type,cmd_flag,led_state,argu,seg0, seg1,pc_end,cpu_en   
   );
   output [6:0] seg0, seg1;
   input clk, clrn, re, we,blink_en,one_char_flag;
   input [`MEM_RAM_WIDTH-1:0] read_addr, write_addr;
   input [31:0] write_data;
   //add
   input [1:0] func_char;
	input [`PROG_TYPE_WIDTH-1:0]prog_type;

   reg [7:0] mems[`MEM_RAM_SIZE-1:0];
   output reg [31:0] read_data;
   output reg read_finished, write_finished;
   //vga
   input [`MEM_RAM_WIDTH-1:0]scan_addr;
   output [7:0]scan_data;
	
	assign scan_data = mems[scan_addr];
		
	//new
	input cmd_flag,cpu_en;
	input [7:0]argu;
	output reg [`INST_RAM_WIDTH-1:0] pc_end;
	
	integer i;
   //command
	parameter cmd_size = 2;
	reg [7:0] out[cmd_size-1:0];
   reg [7:0] un[cmd_size-1:0];
   reg [7:0] he[cmd_size-1:0];
	reg [7:0] ok[cmd_size-1:0];
	wire [7:0] fib;
	assign fib=mems[`LOC_FIB_RES];
	
	count ct(fib,seg0,seg1);
	//led
	output [9:0]led_state;
	assign led_state = {mems[`LOC_LED_SIGN+1],mems[`LOC_LED_SIGN]};
	
   initial begin
      //cmd
		un[0]=8'h6E; un[1]=8'h6F;
		he[0]=8'h68; he[1]=8'h69;
		ok[0]=8'h6F; ok[1]=8'h6B;
		out[0]=8'h0; out[1]=8'h0;
		//led
		{mems[`LOC_LED_SIGN+1],mems[`LOC_LED_SIGN]}=10'b0;
      $readmemh("D:/exp12/mem_file.txt", mems, 0, `MEM_RAM_SIZE-1);
   end
   
	always  @(*)begin//cmd
		case(prog_type)
			 `PROG_UNKNOWN:{out[1],out[0]} = {un[1],un[0]};
			 `PROG_HELLO:{out[1],out[0]} = {he[1],he[0]};
			 default:{out[1],out[0]} = {ok[1],ok[0]};
		endcase
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
   
      if (clrn == 0) begin
         write_finished <= 0;
			for(i = 0; i < `MEM_RAM_SIZE; i=i+1) mems[i]=8'b0;
      end 
		else if( we == 0) write_finished <= 0;
      else begin
         if(func_char==2)
            mems[write_addr-1] <= 8'b0;
         if(func_char==3||cpu_en==1)
            {mems[write_addr+3], mems[write_addr+2], mems[write_addr+1], mems[write_addr]} <= write_data;
         write_finished <= 1;
      end
		
		if(cmd_flag==1)
				{mems[write_addr+1], mems[write_addr]} <= {out[1],out[0]};	
	
		if(prog_type==`PROG_LED_ON || prog_type==`PROG_LED_OFF )begin
			 mems[`LOC_LED_NUM]<=argu;
			 mems[`LOC_LED_SW]<= (prog_type==`PROG_LED_ON) ? 1'b1 : 1'b0;
			 pc_end<=`PC_END_LED;
		end
		else if(prog_type==`PROG_FIB)begin
			mems[`LOC_FIB]<=argu;
			pc_end<=`PC_END_FIB;
			end
   end
   
endmodule 