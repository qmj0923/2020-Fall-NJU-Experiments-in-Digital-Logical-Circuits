module rom_down(press,code, ascii);
	input press;
	input [7:0] code;
	output reg [7:0] ascii;
	reg [7:0] rom [255:0];

	initial
	begin
		$readmemh("D:/exp12/down.txt", rom, 0, 255);
	end

	always @(*)
	begin
		if(press == 1 && code[7:0] != 8'hf0)
			ascii = rom[code];
	end
endmodule 