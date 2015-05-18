module divsim();
	wire [9:0] d,qq,rr;
	wire [18:0] n;
	// restriction: n[19 -:10] < d
	assign n = 19'b000010111_1110010111;
	assign d = 10'b1000001011;
	divider10a va( n,d,qq,rr );

	initial begin
		$monitor($stime, " n=%b d=%b qq=%b rr=%b", n,d, qq,rr);
	end
endmodule