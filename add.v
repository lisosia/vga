module add(a,b,c);
	input a,b;
	output c;
	assign c = a|b;
endmodule

/*  invalid code
module adder(clk,rst, arg1,arg2,out,overflow); // how to read from memory[reg] for each bits, using selector?
	parameter L = 100;
	parameter N = 16;
	input clk, rst;
	input [N*L-1:0] arg1;
	input [N*L-1:0] arg2;
	output [N*L-1:0] out;

	output overflow; // overflow check
	reg overflow;
	reg [4:0] ct;
	wire [N-1:0] a,b,q;
	wire c;
	reg cout;
	adderNbit #(.N( N )) adder ( a,b,q,c );
	assign a = arg1[8*ct+7 -:7];
	assign b = arg2[8*ct+7 -:7];

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			ct <= 0;			
		end
		else if (ct != L) begin 
			out[8*ct+7 -:7] <= q;
			cout <= c;
			ct <= ct+1;
		end else begin
			overflow <= q;
		end
	end
endmodule
*/

// add a,b(10bit,decimal)
// restrict   a,b unsigned, b!=0, 0<a,b<1000
//calc a-b with carry, 0<q<1000
module add10bitD(a,b, q,cin, cout); //sub 10bit decimal (10bit conressponds to 1000)
	parameter N = 10;
	input [N-1:0] a,b;
	output [N-1:0] q;
	input cin; 
	output cout;
	wire [N:0] cmp;
	assign cmp = 11'd1000;
	assign q    = (a+b+cin < cmp) ? (a+b+cin) : (a+b+cin-cmp); // lower bits assigned?
	assign cout = (a+b+cin < cmp) ? 0         : 1; // lower bits assigned?	
endmodule

module adderNbit( a,b,q,out );
	parameter N = 8;
	input[N-1:0] a,b;
	output[N-1:0] q;
	output out;
	
	wire[N:0] cout;
	assign cout[0] = 1'b0;
	assign out = cout[N];
	
	generate
	genvar i;
	for(i=0;i<N;i=i+1)
	begin: addgen
		fulladd add0( a[i],b[i], cout[i], q[i], cout[i+1] );
	end	
	endgenerate
endmodule

module add16bit(a,b,q,cout);
	parameter N = 16;
	input [N-1:0] a,b;
	output[N-1:0] q;
	output cout;
	adderNbit #(.N( N )) adder8bit( a,b,q,cout );
endmodule
	
module fulladd(a,b,cin,q,cout);
	input a,b,cin;
	output q,cout;
	assign {cout,q} = a+b+cin;
endmodule
	
module mul8bit(clk,rst,a,b,q);
	input clk,rst;
	input [7:0] a,b;
	output [16:0] q;
	reg [15:0] amem,bmem;
	reg [16:0] q; //17bit
	reg [3:0] count;
	
	wire [15:0] adderout;
	wire addercout;
	adderNbit #(.N(16)) adder16bit( q[15:0] , amem,adderout,addercout );
	always@(posedge clk)begin
		if(!rst)begin
			q <= 16'h00;
			count <= 8;
			amem <= a; bmem <= b;
		end else if(count != 0)begin
			if(bmem[0] == 1'b1) begin
				q <= {addercout, adderout};
			end
			bmem <= bmem >> 1; amem <= amem << 1;
			count <= count -1;
		end
		
	end
endmodule
	
	