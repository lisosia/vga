module rgbselsim;
reg ck,rst;
wire hsync, vsync, hvalid, vvalid;
wire r, g, b;
reg [9:0] key;

vga vga(.ck(ck), .rst(rst), .hsync(hsync), .vsync(vsync), .hvalid(hvalid), .vvalid(vvalid), .r(r), .g(g), .b(b), .key(key) );

initial begin
	$dumpvars;
	$dumpfile("vga.vcd");
	rst=1;
	ck=0;
	#100 rst = 0;
	#100 rst = 1;
	#1000000
		key <= 'b 001000;
	#1000000
		key <= 'b 1000000000;
	#10000000 $finish;
end

always #10 ck <= ~ck;
endmodule
