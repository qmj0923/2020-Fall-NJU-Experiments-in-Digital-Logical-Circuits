`include "macro.v"

module keyboard(clk,clrn, ps2_clk, ps2_data,enter_en,argu,//,seg0, seg1, seg2, seg3, seg4, seg5
               blink_en,ascii,func_char,prog_type,cursor_x, cursor_y,
               we,one_char_flag,write_finished,cmd_flag,enter_flag);
               
	input clk,clrn, ps2_clk, ps2_data,enter_en;
	//output [6:0] seg0, seg1, seg2, seg3, seg4, seg5;
	reg  nextdata_n, press;
	wire  ready, overflow;
	wire [7:0] data;
	reg [7:0] my_data;
	output [7:0] ascii;
	//reuse exp8
   output [7:0]argu;
	output reg [1:0] func_char;
   //keyboard add
   reg key_off;
   integer cnt_off;
   //vga
   reg cursor_en;
   output blink_en;
   output reg one_char_flag;
	output enter_flag;	
   output [6:0] cursor_x, cursor_y;
   //ram
   output we;
   

	output [`PROG_TYPE_WIDTH-1:0]prog_type;
   //cursor
   input write_finished;
	//new 
	output cmd_flag;
	initial
	begin
		nextdata_n = 1;
		press = 1;
		my_data = 8'b00000000;						//handle data to my_data
		func_char = 0;
		key_off = 0;
		cnt_off = 0;
		cursor_en = 1;
		one_char_flag = 0;
		//enter_flag=0;
	end

	//myclock mycl(clk, clk_b);																					//clock
	ps2_keyboard key(clk, 1'b1, ps2_clk, ps2_data, data, ready, nextdata_n, overflow);		//ps2																
   /* give ascii*/
	rom_down r_down(press,my_data,ascii);
	//rom_up r_up(my_data,ascii_up);
	//ASCII asc(press,up, my_data, ascii_down, ascii, seg2, seg3);							
																	
	/*compare string command*/
	check ck(clk,press,clrn,ascii,func_char,argu,prog_type,
            cursor_en,blink_en,one_char_flag,cursor_x, cursor_y,
				write_finished,we,cmd_flag,enter_flag);
	//count t(ascii, seg2, seg3);			
	//count ct(argu, seg4, seg5);
		
   
   
	always @(posedge clk)begin
	if(clrn==0)begin
		nextdata_n <= 1;
		press <= 1;
		my_data <= 8'b00000000;						//handle data to my_data
	end
	else
	begin
      
		if (ready == 1)
		begin
         if(data[7:0] == 8'hf0)																//break code
			begin
				press <= 0;
				my_data <= 0;
				cursor_en <= 1;
            one_char_flag<=0;
			end
         else begin
            if(press == 0)
            begin    
               press <= 1;
               cursor_en <= 1;
					//enter_flag<=0;
               key_off <= 1; // wait a while before reading the next code
				end
            else if(key_off == 0)
            begin
                if((data[7:0] != 8'hf0) &&(data[7:0] != 8'he0) && (press == 1))			//press	
                  begin 
                     my_data <= data;
                     cursor_en <= 0;
                     one_char_flag<=1;
                     //we <= 1;
                     if(data == 8'h5A)begin //enter &&enter_en==1
                        func_char<=1;
								//enter_flag<=1;
								end
                     else if(data == 8'h66)
                        func_char<=2;//backspace
                     else //char
                        func_char<=3;
                     
                  end
            end
         end 
			nextdata_n <= 0;
		end
		
		else
			nextdata_n <= 1;
         
         // delay for next key
         if (key_off) begin
            if (cnt_off == 2500000) // 2.5M for FPGA, 15 for simulation
            begin
               cnt_off <= 0;
               key_off <= 0;
            end 
            else 
            begin
               cnt_off <= cnt_off + 1;
               key_off <= 1;
            end
         end else begin
				cnt_off<=0;
			end
		end
	end

   

endmodule
