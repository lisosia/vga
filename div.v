module divider10(n,d,q,r);
	input [9:0] n;
	input [9:0] d;
	output [9:0] q;
	output [9:0] r;

	wire [9:0] q0;
	wire [18:0] r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;

	subdivider10 div0({9'b0,n}, {d,9'b0}, q0[9], r0);
	subdivider10 div1(r0      , {1'b0,d,8'b0}, q0[8], r1);
	subdivider10 div2(r1, {2'b0,d,7'b0}, q0[7], r2);
	subdivider10 div3(r2, {3'b0,d,6'b0}, q0[6], r3);
	subdivider10 div4(r3, {4'b0,d,5'b0}, q0[5], r4);
	subdivider10 div5(r4, {5'b0,d,4'b0}, q0[4], r5);
	subdivider10 div6(r5, {6'b0,d,3'b0}, q0[3], r6);
	subdivider10 div7(r6, {7'b0,d,2'b0}, q0[2], r7);
	subdivider10 div8(r7, {8'b0,d,1'b0}, q0[1], r8);
	subdivider10 div9(r8, {9'b0,d}, q0[0], r9);

	assign q = (d==10'b0) ? 10'bx: q0;
	assign r = (d==10'b0) ? 10'bx: r9[9:0];
endmodule

module subdivider10(n,d,q,r); //compare <<20>> bits
	input [18:0] n;
	input [18:0] d;
	output q;
	output [18:0] r;

	assign q = (n >= d);
	assign r = (q==1) ? n-d : n;
endmodule // subdivider10

module subdivider20(n,d,q,r); //compare <<20>> bits
	input [19:0] n;
	input [19:0] d;
	output q;
	output [19:0] r;

	assign q = (n >= d);
	assign r = (q==1) ? n-d : n;
endmodule

module divider10a( rrpast,n,d,q,rr); //specialize divider10 for multistage division
	input [9:0] n,d;
	input [10+9:0] rrpast;
	output [9:0] q;
	output [10+9:0] rr;

        wire [9 +1:0] 	q0;   
	wire [9:0]  r;
	wire [19:0] r0,r1,r2,r3,r4,r5,r6,r7,r8,r9, r10;
	wire [19:0] tmp;
	assign tmp = rrpast+n; // tmp[19 -=10] / d == 0 is guaranteed in sequantina division.
	subdivider20 div0(tmp[19:0],{d,10'b0},q0[10],r0); //q[10] is ALWAYS "0" q0[10] is DAMMY, and r0 is inmportant
	subdivider20 div1(r0, {1'b0,d,9'b0}, q0[9], r1);
	subdivider20 div2(r1, {2'b0,d,8'b0}, q0[8], r2);
	subdivider20 div3(r2, {3'b0,d,7'b0}, q0[7], r3);
	subdivider20 div4(r3, {4'b0,d,6'b0}, q0[6], r4);
	subdivider20 div5(r4, {5'b0,d,5'b0}, q0[5], r5);
	subdivider20 div6(r5, {6'b0,d,4'b0}, q0[4], r6);
	subdivider20 div7(r6, {7'b0,d,3'b0}, q0[3], r7);
	subdivider20 div8(r7, {8'b0,d,2'b0}, q0[2], r8);
	subdivider20 div9(r8, {9'b0,d,1'b0}, q0[1], r9);
       subdivider20 div10(r9, {10'b0,d}   , q0[0], r10);

	assign q = (d==10'b0) ? 10'bx: q0[9:0];
	assign r = (d==10'b0) ? 10'bx:r10[9:0];
	assign rr = r * 10'd1000;
        // assign rr = 0; //TODO!!!
   
endmodule
