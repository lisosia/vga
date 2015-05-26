module slowclock(inclk,RSTn,outclk);
	input inclk, RSTn;
	output outclk;
	reg outclk;
	parameter DELAYCONST = 1;
	reg [DELAYCONST-1 :0] counter;
	always @(posedge inclk or negedge RSTn) begin
		if (!RSTn) begin
			counter <= 0;
			outclk <= 0;
		end
		else begin
			if(counter == 0) begin
				outclk <= ~outclk;
			end
			counter <= counter + 1;
		end
	end
endmodule