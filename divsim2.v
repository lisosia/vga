module divsim();
	wire [9:0] n ,d,qq;
	wire [19:0] rrpast,   rr;
	// restriction: n[19 -:10] < d
   //1000000000_0111000110 <- 524,742
   assign rrpast= 19'b 1111111111011100000; //524,000
	assign n = 10'b 1011100110;//742
	assign d = 10'b 1000010011;
	divider10a va( rrpast,n,d, qq,rr );

	initial begin
		$monitor($stime, " n=%b d=%b qq=%b rr=%b", n,d, qq,rr);
	end
endmodule