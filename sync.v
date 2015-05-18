`define HDOT 1056
`define HDOT0 1055
`define HFP 40
`define HSYNC 128
`define HBP 88

`define VDOT 628
`define VDOT0 627
`define VFP 1
`define VSYNC 4
`define VBP 23
	
module sync(clk,RSTn,hsync,vsync,hvalid,vvalid,hcnt,vcnt);
input clk,RSTn;
output hsync, vsync, hvalid, vvalid;
output[10:0] hcnt, vcnt;
reg[10:0] hcnt, vcnt;
reg hvalid, vvalid,hsync, vsync;
always @(posedge clk)begin
	if(!RSTn)begin
		hcnt <= `HDOT0; hvalid<=0; hsync<=0;
		vcnt <= `VDOT0; vvalid<=0; vsync<=0;
	end else begin 
		if( hcnt == 0 )begin
			hvalid<=0; hcnt<=`HDOT0;
		end else begin
			if( hcnt == (`HDOT-`HFP) )begin
				hsync<=1;
				if( vcnt == 0 )begin
					vvalid<=0; vcnt<=`VDOT0;
				end else begin
					if( vcnt==(`VDOT-`VFP) )vsync<=1;
					else if( vcnt==(`VDOT-`VFP-`VSYNC) )vsync<=0;
					else if( vcnt==(`VDOT-`VFP-`VSYNC-`VBP) )vvalid<=1;
					vcnt<=vcnt-1;
				end
			end else if( hcnt==(`HDOT-`HFP-`HSYNC) )hsync<=0;
			else     if( hcnt==(`HDOT-`HFP-`HSYNC-`HBP))hvalid<=vvalid;
			hcnt<=hcnt-1;
		end
	end
end
endmodule
