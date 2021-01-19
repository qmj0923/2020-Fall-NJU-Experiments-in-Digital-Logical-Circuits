module logo_rom(
      //input            clka, // input wire clka
      input    [11:0]  addra, // input wire [11 : 0] addra
      output   [11:0]  douta  // output wire [11 : 0] douta
      );
      
      parameter ram_size = 4096; 
      (* ram_init_file = "D:/source/quartus/exp09_3_2/red.mif" *) reg [11:0] ram[ram_size-1:0];
      
      assign douta = ram[addra];
      
endmodule
