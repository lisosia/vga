module sub(dammy);
	input dammy;
endmodule

// restrict   a,b unsigned, b!=0, 0<a,b<1000
//calc a-b with carry
module sub10bitD(a,b, q,cin, cout); //sub 10bit decimal (10bit conressponds to 1000)
	parameter N = 10;
	input [N-1:0] a,b;
	input cin; 
	output [N-1:0] q;
	output cout;
	wire [N-1:0] bc;
	assign bc = b + cin; //never overflow since a < 1000 < 2^10=1024
	assign q    = (a<bc) ?  ((10'd1000-bc)+a) : a-bc ;
	assign cout = (a<bc) ? 1 : 0;
endmodule