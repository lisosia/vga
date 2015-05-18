module subsim(q);
	output [9:0] q;
	wire [9:0] a,b,q;
	wire cout;
	assign a = 9'b 010101100;
	assign b = 9'b 110001011;

	sub10bitD sub( a,b,q,1'b1,cout );
	initial begin
		$monitor($stime, " a=%b b=%b q=%b cout=%b", a,b,q, cout);
		#2000 $finish;
	end
	
endmodule
