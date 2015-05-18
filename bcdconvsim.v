module bcdconvsim;
	wire [9:0] bin;
	wire [11:0] dec;
	assign bin = 10'd209;
	bcdconv bcdconv(bin,dec);
	initial begin
		$monitor($stime, "%d %d %d %b %b" ,dec[11 -:4],dec[7 -:4],dec[3 -:4],
			bcdconv.q2,bcdconv.r1);
	end
endmodule