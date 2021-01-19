module I2C_Audio_Config ( clk_i2c,
                          reset_n,
								  I2C_SCLK,
								  I2C_SDAT,
								  testbit,
                          vol_up,
                          vol_down,
                          l_vol,
                          r_vol
                          //curr_vol
                          );
   parameter  total_cmd = 9;
   parameter [8:0] init_vol = 9'h48;

	input clk_i2c;  //10k I2C clock
   input reset_n;
   input vol_up, vol_down;
   
   output I2C_SCLK;
	output [3:0] testbit;
   output [8:0] l_vol, r_vol;
   inout  I2C_SDAT;

	reg [23:0] mi2c_data;
	reg  mi2c_go;
	wire mi2c_end;
	reg  [1:0] mi2c_state; //state 0: stop, state 1: sendnext;
	                       //state 2: wait for finish, state 3:move index
	wire [2:0] mi2c_ack;
	wire [7:0] audio_addr;
	
	reg [3:0] cmd_count;
	reg [6:0] audio_reg [15:0]; //register to write
	reg [8:0] audio_cmd [15:0]; //register content
   
   reg [8:0] curr_vol;
   reg [31:0] vol_cmd_off_cnt;
   reg vol_cmd_off;

initial
begin
   audio_reg[0]= 7'h0f; audio_cmd[0]=9'h0;  //reset
	audio_reg[1]= 7'h06; audio_cmd[1]=9'h0;  //Disable Power Down
	audio_reg[2]= 7'h08; audio_cmd[2]=9'h2;  //Sampling Control
	audio_reg[3]= 7'h02; audio_cmd[3]=init_vol; //Left Volume
	audio_reg[4]= 7'h03; audio_cmd[4]=init_vol; //Right Volume
	audio_reg[5]= 7'h07; audio_cmd[5]=9'h1;  //I2S format
	audio_reg[6]= 7'h09; audio_cmd[6]=9'h1;  //Active
	audio_reg[7]= 7'h04; audio_cmd[7]=9'h16; //Analog path
	audio_reg[8]= 7'h05; audio_cmd[8]=9'h06;  //Digital path
   curr_vol = init_vol;
   vol_cmd_off     = 0;
   vol_cmd_off_cnt = 32'b0;
end


assign audio_addr={7'b0011010,1'b0}; //WM8731 addr, always write
assign testbit = cmd_count[3:0];
	
assign l_vol = audio_cmd[3];
assign r_vol = audio_cmd[4];

I2C_Controller 	u0	(	.CLOCK(clk_i2c),		//	Controller Work Clock
						.I2C_SCLK(I2C_SCLK),		//	I2C CLOCK
 	 	 	 	 	 	.I2C_SDAT(I2C_SDAT),		//	I2C DATA
						.I2C_DATA(mi2c_data),		//	DATA:[SLAVE_ADDR,SUB_ADDR,DATA]
						.GO(mi2c_go),      			//	GO transfor
						.END(mi2c_end),				//	END transfor 
						.ACK(mi2c_ack),				//	ACK
						.RESET_N(reset_n)	);	
						
always @ (posedge clk_i2c or negedge reset_n)
begin
     if(!reset_n)
	  begin
        audio_reg[0]<= 7'h0f; audio_cmd[0]<=9'h0;  //reset
        audio_reg[1]<= 7'h06; audio_cmd[1]<=9'h0;  //Disable Power Down
        audio_reg[2]<= 7'h08; audio_cmd[2]<=9'h2;  //Sampling Control
        audio_reg[3]<= 7'h02; audio_cmd[3]<=init_vol; //Left Volume
        audio_reg[4]<= 7'h03; audio_cmd[4]<=init_vol; //Right Volume
        audio_reg[5]<= 7'h07; audio_cmd[5]<=9'h1;  //I2S format
        audio_reg[6]<= 7'h09; audio_cmd[6]<=9'h1;  //Active
        audio_reg[7]<= 7'h04; audio_cmd[7]<=9'h16; //Analog path
        audio_reg[8]<= 7'h05; audio_cmd[8]<=9'h06;  //Digital path
        curr_vol        <= init_vol;
        vol_cmd_off     <= 0;
        vol_cmd_off_cnt <= 32'b0;
	     cmd_count       <= 4'b0;
		  mi2c_state      <= 2'b0;
	     mi2c_go         <= 1'b0;
	  end
	  else
	  begin
        if (vol_cmd_off) begin
           if (vol_cmd_off_cnt == 32'd1000) begin
              vol_cmd_off <= 0;
              vol_cmd_off_cnt <= 32'b0;
           end else begin
              vol_cmd_off_cnt <= vol_cmd_off_cnt + 1;
           end
        end
        
        if ((vol_up || vol_down)
           && vol_cmd_off == 0
           && curr_vol + vol_up - vol_down >= 9'h0
           && curr_vol + vol_up - vol_down <= 9'h7f) 
        begin
           audio_reg[0]<= 7'h0f; audio_cmd[0]<=9'h0;  //reset
           audio_reg[1]<= 7'h06; audio_cmd[1]<=9'h0;  //Disable Power Down
           audio_reg[2]<= 7'h08; audio_cmd[2]<=9'h2;  //Sampling Control
           audio_reg[3]<= 7'h02; audio_cmd[3]<=curr_vol + vol_up - vol_down; //Left Volume
           audio_reg[4]<= 7'h03; audio_cmd[4]<=curr_vol + vol_up - vol_down; //Right Volume
           audio_reg[5]<= 7'h07; audio_cmd[5]<=9'h1;  //I2S format
           audio_reg[6]<= 7'h09; audio_cmd[6]<=9'h1;  //Active
           audio_reg[7]<= 7'h04; audio_cmd[7]<=9'h16; //Analog path
           audio_reg[8]<= 7'h05; audio_cmd[8]<=9'h06;  //Digital path
           curr_vol        <= curr_vol + vol_up - vol_down;
           vol_cmd_off     <= 1;
           vol_cmd_off_cnt <= 32'b0;
           cmd_count       <= 4'b0;
           mi2c_state      <= 2'd0;
        end
        
	     case(mi2c_state)
		  2'd0: begin  //stop
		            if(cmd_count ==4'b0)
						   mi2c_state <= 2'd1;
		        end
		  2'd1: begin
		            mi2c_data <= {audio_addr, audio_reg[cmd_count], audio_cmd[cmd_count]};
						mi2c_go   <= 1'b1;
						mi2c_state<= 2'd2;
		        end
		  2'd2: begin
		             if(mi2c_end)
						 begin
						        mi2c_state <= 2'd3;
								  mi2c_go    <= 1'b0;
						 end
		        end
		  2'd3: begin
		            cmd_count <= cmd_count + 4'd1;
						if(cmd_count + 4'd1 < total_cmd)
						   mi2c_state <= 2'd1;  //start next
					   else
						   mi2c_state <= 2'd0;  //last cmd
		        end
		  endcase
	  end
	  
end
								  
								  
endmodule