
module vgasim;
reg clk,RSTn;
wire out;

vga vga(.clk(clk), .RSTn(RSTn), .out(out));


initial begin
	$dumpfile("vga.vcd");
	$dumpvars(0,vga);

/*	$monitor($stime," %b  %b %d ,,, %b,%b %b", vga.vsync ,vga.conv.doing, vga.conv.ct, 
		vga.conv.bin[359-:10],vga.conv.dec[431-:12],
		vga.conv.bcdconv.bin);
*/
/*	$monitor($stime," %b  %b %d ,,, %d %b", vga.vsync ,vga.conv.doing, vga.conv.ct, 
		vga.conv.bin[359-:10],vga.conv.dec[431 -12 -:12] );
*/	
	//$monitor($stime, "%b %b", vga.vsync,vga.dec);
	// $monitor($stime, " %b %d", vga.linesel.vcnt, vga.linesel.linenum );
	// $monitor($stime, " %b %d %d ", vga.hvalid, vga.hcnt,vga.rgbsel.chrdxh);

	RSTn=1;
	clk=0;
	#1 RSTn = 0;
	#34 RSTn = 1;
	#(1*130000000) $finish; // at 258,550 calc fin. 130M to vsync stand.
end

always #10 clk <= ~clk;

/*always @( vga.hcnt) begin
	$display(  "%t %d %d,, %d %d" ,$stime,vga.rgbsel.chrdxh,vga.rgbsel.font.num,
	 vga.hcnt ,vga.rgbsel.fontout[3:0] );
end
*/
endmodule
