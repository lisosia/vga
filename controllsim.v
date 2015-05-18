`define L 10
module controllsim;
	parameter L = `L; parameter N = 10; parameter T = L*N-1;
	reg clk, rst;
	wire [T:0] sum;
	controll c(clk,rst, sum);
	initial begin
	
		$monitor( $stime, " clk=%b,rst=%b, state=%h,count=%d,,,sum=%h, div1wradd/rdadd=%h/%h, quo=%d,  divN =%d,  divD=%d,    div1q=%d,   div1_wren=%b",
		                     clk,   rst,   c.state, c.count   , c.sum,c.div1_wradd,c.div1_rdadd,c.div1quo,c.div1Nbitn,c.div1Nbitd,c.div1_q, c.div1_wren);
	

	/*
		$monitor( $stime, " %b <%d> %d ,,,%d, %d, %d, %d ,,, %d %d",
		 clk,c.state, c.count, 
		 c.divider1.tmp, c.divider1.d, c.divider1.q, c.divider1.r,
		 c.div1[999:990], c.div1[989:980],
		 );
	*/

	/*
		$monitor( $stime, " %b <%d> %d %d ,,,%d, %d, %d, %d",
		 clk,c.state, c.count, c.div1[999:990],c.divider1.n, c.divider1.d, c.divider1.q, c.divider1.r );
	*/

	/*
		$monitor( $stime, " %b <%d> %d %d ,,,%d, %d, %d, %d",
		 clk,c.state, c.count, c.div1[999:990],c.subsracter.a, c.subsracter.b,
		  c.subsracter.q, c.subsracter.cin );
	*/
	/*
	$monitor( $stime, " %b <%d> %d k=%d ,,,%d, %d, %d, %d",
	clk,c.state, c.count, c.div3valk,
	c.div1[999:990], c.div1[989:980],c.div1[979:970], c.div1[969:960] );
	*/
	/*
	$monitor( $stime, " %b <%d> %d k=%d ,,,%d, %d, %d, %d",
	clk,c.state, c.count, c.div3valk,
	c.sub[999:990], c.sub[989:980],c.sub[979:970], c.sub[969:960] );
	*/

	/*
	$monitor( $stime, " %b <%d> %d k=%d ,,,div1=%d, div2=%d, sub=%d, sum=%d",
	clk,c.state, c.count, c.div3valk,
	c.div1[999:990], c.div2[999:990], c.sub[999:990], c.sum[999:990] );
	*/

	/*
	$monitor( c.state, " %b <%d> %d k=%d ,,,%d, %d, %d, %d",
	clk,c.state, c.count, c.div3valk,
	c.sum[999:990], c.sum[989:980],c.sum[979:970], c.sum[969:960] );
	*/
		$dumpfile("controllsim.vcd");
		$dumpvars(0, c);

		clk <= 0;
		#1 rst <= 0;
		#34 rst <= 1;
		// #(10*5*100*10) $finish;
	   	#(5*5*100*10) $finish;
	end
	always #10 begin
		clk <= ~clk;
	end

	always @( clk  ) begin
		// $display(c.state);

			/*	
		$display( c.div3valk,
			c.sum[T -:10], c.sum[T-10 -:10],c.sum[T-20 -:10], c.sum[T-30 -:10],c.sum[T-40 -:10],
			c.sum[40 +:10], c.sum[30 +:10],c.sum[20 +:10]  );
	*/
		/*
		$display(  clk,c.state, c.div3valk,
			c.sum[T -:10], c.sum[T-10 -:10],c.sum[T-20 -:10] );
		
		$display("");
		*/ 
       end

endmodule