module testselect(clk,rst,out, ct);
	input clk,rst;
	output [1:0] out;
	output [3:0] ct;
	reg [2*16:0] mem = 32'h 987610ff;
	reg [1:0] tmp;
	reg [3:0] count;
	assign ct = count;
	assign out = tmp;
	always @(posedge clk or negedge rst) begin
		if(!rst) begin
			count <= 0;
		end else begin
			count <= count +1;
			tmp <= mem[ count*2+1 -:2 ];
		end
	end
endmodule