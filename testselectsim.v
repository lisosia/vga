module testselectsim;
	wire  [1:0]  out;
	wire [3:0] ct;
	reg clk,rst;
	testselect sel(clk,rst,out, ct);
	initial begin	
		#1 rst <= 0;
		#10 rst <= 1;
		clk <= 0;	
		$monitor($stime, " clk = %b out = %b ct = %d", clk, out, ct);
		#3000 $finish;
	end
	always #100 begin
		clk = ~clk;
	end

endmodule