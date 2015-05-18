module addsim( q);

	output [16:0] q;
	wire [7:0] a,b;
	wire [16:0] q;
	assign a = 8'b 00101100;
	assign b = 8'b 00001011;
	reg rst;
	reg clk;
	parameter CLOCK = 100;
	initial begin
		$monitor($stime, " rst=%b clk=%b a=%b b=%b q=%b", rst,clk, a,b,q);
		clk <= 0;rst<=0;
		#150 rst <= 1;
		
		#2000 $finish;
	 end
	always #CLOCK begin	
		clk <= ~clk;
	end
		
	mul8bit multi( clk,rst, a,b,q );
	
	
endmodule
