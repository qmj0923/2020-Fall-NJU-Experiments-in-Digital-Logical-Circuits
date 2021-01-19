`include "macro.v"

module check(clk,press,clrn,ascii,func_char,argu,prog_type,
               cursor_en,blink_en,one_char_flag,cursor_x, cursor_y,
               write_finished,we,cmd_flag,enter_flag);
   input clk,press,clrn;
   input [7:0]ascii;
   input [1:0] func_char;
   reg [9:0]end_pointer;//for test
   output reg [7:0]argu;
   output reg [`PROG_TYPE_WIDTH-1:0]prog_type;//return type
   //output [6:0] seg0, seg1;
   //vga
   input cursor_en;
   output reg blink_en;
   input one_char_flag;	
   reg [14:0] num_y;
   output reg[6:0] cursor_x, cursor_y;
   integer   blink_cnt;
   //cursor
   input write_finished;
   reg cursor_move_en,move_over;
	
   output reg we;
   parameter clk_count = 2500000 ; // 2.5M for FPGA, 15 for simulation
   parameter blink_count = 25000000/2/clk_count;
   //replace clk_flush
	reg key_off,key_off_en;
	integer cnt_off;
	//new
	output reg cmd_flag,enter_flag;
	reg prog_change;
	reg [2:0]enter_cnt;
	parameter set_time = 5;
	
   parameter shell_size=0;
   
   /*buf ram check command && fib led hello*/
   reg [7:0] bufram [16-1:0];
   reg [7:0] fibram [5:0];//"./fib "
   reg [7:0] ledram [5:0];//"./led n "
   reg [7:0] ledoram [2:0];//"on off"
   reg [7:0] helloram [6:0];//"./hello"

   //count ct(prog_type,seg0,seg1);

   initial begin
	bufram[0] =0;bufram[1] =0;
	bufram[2] =0;bufram[3] =0;
	bufram[4] =0;bufram[5] =0;
	bufram[6] =0;
	bufram[7] =0;bufram[8] =0;
	bufram[9] =0;bufram[10]=0;
	bufram[11]=0;bufram[12]=0;
	bufram[13]=0;bufram[14]=0;
	bufram[15]=0;
	
   fibram[0]=8'h2E;fibram[1]=8'h2F;
   fibram[2]=8'h66;fibram[3]=8'h69;
   fibram[4]=8'h62;fibram[5]=8'h20;
	
   ledram[0]=8'h2E;ledram[1]=8'h2F;
   ledram[2]=8'h6C;ledram[3]=8'h65;
   ledram[4]=8'h64;ledram[5]=8'h20;
   
   ledoram[0] = 8'h6F;ledoram[1] = 8'h6E;
   ledoram[2] = 8'h66;
   
	helloram[0] = 8'h2E;helloram[1] = 8'h2F;
	helloram[2] = 8'h68;helloram[3] = 8'h65;
   helloram[4] = 8'h6C;helloram[5] = 8'h6C;
   helloram[6] = 8'h6F;
	
   num_y = 15'b0;
   num_y[0] = 1;

   we = 0 ;
   cursor_x = shell_size;
   cursor_y = 0;
   prog_type=`PROG_UNKNOWN;
   blink_en = 0;
   blink_cnt = 0;
	cursor_move_en = 0;
	argu=0;
	key_off_en = 0;
	key_off = 0;
   cnt_off = 0;
	move_over=0;
	cmd_flag=0;
	prog_change=0;
	enter_flag=0;
	enter_cnt=0;
	end_pointer=0;
	end

   always @(negedge press)begin
      if(clrn==0)begin
			prog_type <= `PROG_UNKNOWN;
			end_pointer<=0;
			bufram[0] =0;bufram[1] =0;
			bufram[2] =0;bufram[3] =0;
			bufram[4] =0;bufram[5] =0;
			bufram[6] =0;
			bufram[7] =0;bufram[8] =0;
			bufram[9] =0;bufram[10]=0;
			bufram[11]=0;bufram[12]=0;
			bufram[13]=0;bufram[14]=0;
			bufram[15]=0;
			prog_change<=0;
			argu<=0;
      end
      else begin
      if(func_char==1)begin//ascii == 5A enter	
				prog_change<=1;
            if(bufram[0]==fibram[0]&&bufram[1]==fibram[1]&&bufram[2]==fibram[2]
            &&bufram[3]==fibram[3]&&bufram[4]==fibram[4]&&bufram[5]==fibram[5]) begin//compare "./fib "
               prog_type <= `PROG_FIB;
               argu <= bufram[6]-8'h30;
					//cmd_flag<=1;	
               end
               
            else if(bufram[0]==ledram[0]&&bufram[1]==ledram[1]&&bufram[2]==ledram[2]
            &&bufram[3]==ledram[3]&&bufram[4]==ledram[4]&&bufram[5]==ledram[5]&&bufram[7]==ledram[5]) begin//compare "./led "
               if(bufram[8]==ledoram[0]&&bufram[9]==ledoram[1])begin
                  prog_type <= `PROG_LED_ON;
                  argu <= bufram[6]-8'h30;
						//cmd_flag<=0;
                  end
               else if(bufram[8]==ledoram[0]&&bufram[9]==ledoram[2]&&bufram[10]==ledoram[2])begin
                  prog_type <= `PROG_LED_OFF;
                  argu <= bufram[6]-8'h30;
						//cmd_flag<=0;
                  end
					else begin
						prog_type <= `PROG_UNKNOWN;
					end
               end
            
            else if(bufram[0]==helloram[0]&&bufram[1]==helloram[1]&&bufram[2]==helloram[2]
            &&bufram[3]==helloram[3]&&bufram[4]==helloram[4]&&bufram[5]==helloram[5]
            &&bufram[6]==helloram[6]&&bufram[7]==0) begin//compare "./hello"
               prog_type <= `PROG_HELLO;
					//cmd_flag<=1;
            end
            
            else begin
               prog_type <= `PROG_UNKNOWN;
				 end
					//cmd_flag<=1;
				bufram[0] =0;bufram[1] =0;
				bufram[2] =0;bufram[3] =0;
				bufram[4] =0;bufram[5] =0;
				bufram[6] =0;
				bufram[7] =0;bufram[8] =0;
				bufram[9] =0;bufram[10]=0;
				bufram[11]=0;bufram[12]=0;
				bufram[13]=0;bufram[14]=0;
				bufram[15]=0;
           
            end_pointer<=0;
      end
      else if(func_char==2)begin
			bufram[end_pointer] <= 0;
         end_pointer<=end_pointer-1;
			prog_change<=0;
			//cmd_flag<=0;
      end
      else if(func_char==3)begin
         bufram[end_pointer] <= ascii;
         end_pointer <= end_pointer + 1;
			prog_change<=0;
			//cmd_flag<=0;
      end
      end
   end
   
   

  
   always @ (posedge clk) begin
        if(clrn==0)begin
          enter_flag<=0;
          enter_cnt<=0;
      end
      else begin

		if(enter_cnt==set_time)begin
			enter_flag<=0;
		end
		else if(prog_change==1)begin
			enter_flag<=1;
			enter_cnt<=enter_cnt+1;
		end
		if(prog_change==0)
			enter_cnt<=0;
      end
	end
  
  
  always @ (posedge clk) begin
      if(clrn==0)begin
          we<=0;
         cursor_move_en<=0;
      end
      else begin
        if ((one_char_flag==1||we==1) && move_over==0)begin			
            if (write_finished==1) begin
                cursor_move_en<=1;
                we<=0;
                end
                else
                    we<=1;
        end
        else begin
            we<=0;
            cursor_move_en<=0;
        end
      end
   end
   
always @ (posedge clk) begin
        if(clrn==0)begin
            num_y <= 15'b0;
            num_y[0] <= 1;
            cursor_x <= shell_size;
            cursor_y <= 0;
            cnt_off <= 0;
            key_off <= 0;
            key_off_en <= 0;
             cmd_flag<=0;
        end
        else begin
            if(one_char_flag==0)move_over<=0;
                    
            if(key_off == 0 && key_off_en == 0)begin
                if(cmd_flag==1&&prog_change==1)begin
                    cmd_flag<=0;
                    if (cursor_y == 14) 
                        begin
                            num_y <= 15'b0;
                            num_y[0] <= 1;
                            cursor_x <= shell_size;
                            cursor_y <= 0;
                        end 
                    else 
                        begin
                            num_y[cursor_y+1] <= 1;
                            cursor_y <= cursor_y + 1;
                            cursor_x <= 0;
                        end
                end
                    
                if(cursor_move_en==1)
                        begin 
                    //blink_en <= 1;
                    case (func_char) 
                        1: begin // enter
                                cmd_flag<=1;
                            if (cursor_y == 14) 
                            begin
                                num_y <= 15'b0;
                                num_y[0] <= 1;
                                cursor_x <= shell_size;
                                cursor_y <= 0;
                                        //cmd_flag<=0;
                            end 
                            else 
                            begin
                                num_y[cursor_y+1] <= 1;
                                        cursor_y <= cursor_y + 1;
                                        cursor_x <= 0;
                                        
                            end
                        end
                        2: begin // backspace
                            if ( (cursor_x != 0 || cursor_y != 0) && (cursor_x != shell_size || !num_y[cursor_y]))
                            begin
                            if (cursor_x == 0)
                                begin
                                    cursor_x <= 19;
                                    cursor_y <= cursor_y - 1;
                                end
                            else 
                                begin
                                    cursor_x <= cursor_x-1;
                                end
                            end
                        end
                        3:begin
                            if (cursor_x == 19) //line end
                                begin
                                    if (cursor_y == 14) begin	//clear
                                        num_y <= 10'b0;
                                        cursor_x <= 0;
                                        cursor_y <= 0;
                                        end 
                                    else 
                                        begin
                                        cursor_x <= 0;
                                        cursor_y <= cursor_y + 1;
                                        end
                                end 
                            else 
                                    cursor_x <= cursor_x + 1;
                            end
                    endcase
                
                    key_off_en <= 1;
                        move_over<=1;
                end
            
            
            end
            //key off
            if (key_off==1 || key_off_en ==1) begin
                if (cnt_off == clk_count) 
                begin
                    cnt_off <= 0;
                    key_off <= 0;
                    key_off_en <= 0;
                end 
                else 
                begin
                    cnt_off <= cnt_off + 1;
                    key_off <= 1;
                end
            end 
            //key off
        end
	
    end

 
endmodule 