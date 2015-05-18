module divsim();
	wire [9:0] n,d,qq,rr;
	assign n = 10'b0110010111;
	assign d = 10'b0000001011;
	divider10 vvv( n,d,qq,rr );

	initial begin
		$monitor($stime, " n=%b d=%b qq=%b rr=%b", n,d, qq,rr);
	end
endmodule