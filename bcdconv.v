module bcdconv(
	input [9:0] bin,
	output [11:0] dec);

	wire [9:0] q1,q2,r1,r2;
	divider10 div10a(bin,10'd10, q1,r1); //divider10 is in calc/
	divider10 div10b(q1 ,10'd10, q2,r2);
	wire [3:0] n1,n2,n3;
	assign n1 = (bin==10'b0)           ? 4'b0000 : r1[3:0] ;
	assign n2 = (bin==10'b0||q1==10'b0)? 4'b0000 : r2[3:0];
	assign n3 = (bin==10'b0||q1==10'b0)? 4'b0000 : q2[3:0];
	assign dec = { n3, n2, n1 };

endmodule