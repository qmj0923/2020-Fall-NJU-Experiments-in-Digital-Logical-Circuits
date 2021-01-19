module Sin_Generator(clk,
                     reset_n,
							freq,
							dataout
                     );
input clk;
input reset_n;
input [15:0] freq;
output reg [15:0] dataout;
(* ram_init_file = "sintable.mif" *) reg [15:0] sintable [1023:0]/*systhesis */;

reg [15:0] freq_counter; //16bit counter

always @(posedge clk) //change data at posedge of lrclk
begin
       dataout <= sintable[freq_counter[15:6]]; // 10-bit address;
end


always @(posedge clk or negedge reset_n) //step counter
begin
    if(!reset_n)
	    freq_counter <= 16'b0;
	 else
	    freq_counter <= freq_counter + freq;
end
endmodule