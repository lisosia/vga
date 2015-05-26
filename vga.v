`define FONTHLEN 16
`define FONTVLEN 32 
`define FONTHLENLOG2 4
`define FONTVLENLOG2 5

`define HCHAR 48 // under 800/FONTHLEN = 50 
`define VCHAR 18 // 600/ 
`define HCHARLOG2 6
`define VCHARLOG2 5
`define BITPERCH 4

`define L 47
`define N 10

`define ADR_BITS 6

module vga(clk,RSTn, hsync,vsync, r,g,b,  LEDa,LEDb,LEDc,LEDd,LEDe,LEDf,LEDg,LEDh);
	parameter N=10; parameter L=`L;
	input clk, RSTn;
	output hsync,vsync,  r,g,b;
	wire out,   hvalid,vvalid;
	assign r=out;assign g=out;assign b=out;
	wire [10:0] hcnt,vcnt;	
        output [7:0]     LEDa,LEDb,LEDc,LEDd,LEDe,LEDf,LEDg,LEDh;
   
   	sync sync(.clk(clk),.RSTn(RSTn),.hsync(hsync),.vsync(vsync),.hvalid(hvalid),.vvalid(vvalid),.hcnt(hcnt),.vcnt(vcnt) );

	parameter INSIZE = `L*N; // L*N
	parameter OUTSIZE = `L*12;
	wire [INSIZE-1 :0] bin;
	wire [OUTSIZE-1:0] dec;
        wire 		   slowclk;   
        slowclock slowclock_inst(clk,RSTn,slowclk);  
        wire [`ADR_BITS-1 :0]   ctrl_rdadd;
        wire [N-1:0] ctrl_out;   
	controll controll(slowclk,RSTn, clk,ctrl_rdadd,ctrl_out);
	//conv #(.L(`L)) conv(clk,RSTn, vsync ,bin, dec );
   
	parameter BUFSIZE = `HCHAR*`VCHAR * 4; // =3600
/*	wire [BUFSIZE-1 :0] display;
	displaysel #(.L(`L)) displaysel(clk,RSTn, 1'b0, {dec,{(BUFSIZE-OUTSIZE) {1'b1}} }  , display); //displaysel(clk, RSTn,next, in, out);
*/

	parameter LINEBITS = `BITPERCH*`HCHAR; // BITPERCH*HCHAR = 4*50=200
	wire [LINEBITS-1 :0] lineout;
        //linesel linesel(clk,RSTn,hcnt,vcnt, {dec,{(BUFSIZE-OUTSIZE) {1'b1}} }, lineout);
   charsel_N charsel_inst(slowclk,RSTn, hcnt,vcnt, 0,ctrl_rdadd, ctrl_out, lineout);
   print_led print_led(clk,0,RSTn, lineout[LINEBITS-1 -:12], lineout[LINEBITS-1-12 -:12], lineout[LINEBITS-1-12-12 -:12],  LEDa,LEDb,LEDc,LEDd,LEDe,LEDf,LEDg,LEDh);
   

	wire rgboutw;
	rgbsel rgbsel(clk,RSTn,lineout,   hsync,vsync,hvalid,vvalid,hcnt,vcnt,    rgboutw); //rgbsel(clk,RSTn,lineout, hsync,vsync,hvalid,vvalid,hcnt,vcnt,    out);
	assign out = rgboutw;

endmodule // VGA




module rgbsel(clk,RSTn,lineout, hsync,vsync,hvalid,vvalid,hcnt,vcnt,    out);
	input clk,RSTn ;
	input hsync,vsync,hvalid,vvalid;
	input [10:0] hcnt,vcnt;	
	parameter BITPERCH = 4;
	parameter LINEBITS = BITPERCH* `HCHAR;
	input [LINEBITS-1 :0] lineout;
	output out; reg out;

	wire [10:0] hcnt,vcnt;	

	//reg [6:0]   chrdxh;
	wire [`HCHARLOG2-1 : 0]   chrdxh;
	assign chrdxh = hcnt[`FONTHLENLOG2 +: `HCHARLOG2]; //long 2 FONTVLEN = 5


	wire [`FONTVLENLOG2-1 : 0]   findexv; //log2 FONTVLEN[]
	////////////////////////////!!!!!!!!!??????????????????????///////////////////
	wire [4:0] linenumlowbits;
	assign linenumlowbits = vcnt[0 +: `FONTVLENLOG2]; //long 2 FONTVLEN = 5
	assign findexv = linenumlowbits; //decr
	////////////////////////////!!!!!!!!!??????????????????????///////////////////


   	wire [`FONTHLENLOG2-1 : 0] findexh; //log2 FONTHLEN, incre
   	assign findexh = hcnt; //decr
   	wire [`FONTHLENLOG2+`FONTVLEN-1 : 0]  findex;
   	assign findex  = {findexv,findexh}; // 9bit

	wire [`FONTHLEN * `FONTVLEN -1 :0] fontout;
   	font font( lineout[BITPERCH*chrdxh +:BITPERCH], fontout );
   	wire outw;
   	assign outw = fontout[ findex ] ;

   	always@(posedge clk)begin
  	 	if(!RSTn || vsync) begin
			// findexv<=0; 
			//// findexh <= 0;
			//chrdxh <= `HCHAR;
		end else begin
			if(hvalid==1)begin
				out <= outw;				
				if(findexh == `FONTHLEN - 1)begin
					//chrdxh <= chrdxh - 1;
					////findexh <= 0;
				end else begin
					////findexh <= findexh+1;
				end
				
			end else begin //hvalid==0
				out <=0 ;
			end // else: !if(hvalid==1)

			if(hcnt==0)begin
				// findexv<= findexv+ 1;	  
				//chrdxh <=`HCHAR;
			end
			if(vcnt==0)begin
				//chrdxh <=`HCHAR;
				// findexv<= 0;
				////findexh<=0;
			end
			
				
		end // else: !if(!rst)
	end // always@ (posedge ck)

endmodule

module font(num, out);
	input [3:0] num;
	output[512-1 :0] out; //512 - 16*32
	assign out = fonts(num);

	function [512-1:0] fonts;
		input [3:0] num;
		case(num)
		4'd0: fonts = 512'h 00001ff81c381c381c381c381c381c381c381c381c381c381c381c381c381c381c381c381c381c381c381c381c381c381c381c381c381c381c381c381ff80000;
4'd1: fonts = 512'h 000007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e007e00000;
4'd2: fonts = 512'h 00001ff81ff80038003800380038003800380038003800380038003800381ff81ff81ff81c001c001c001c001c001c001c001c001c001c001c001ff81ff80000;
4'd3: fonts = 512'h 00001ff81ff80038003800380038003800380038003800380038003800381ff81ff81ff8003800380038003800380038003800380038003800381ff81ff80000;
4'd4: fonts = 512'h 000007e00de00de019e019e031e031e031e031e031e031e061e061e061e0c1e0c1e0ffffffffffff01e001e001e001e001e001e001e001e001e001e001e00000;
4'd5: fonts = 512'h 00001ff81ff81c001c001c001c001c001c001c001c001c001c001c001c001ff81ff81ff8003800380038003800380038003800380038003800381ff81ff80000;
4'd6: fonts = 512'h 00001ff81ff81c001c001c001c001c001c001c001c001c001c001c001c001ff81ff81ff81c381c381c381c381c381c381c381c381c381c381c381ff81ff80000;
4'd7: fonts = 512'h 00003ff83ff838383838383800380038003800380038003800380038003800380038003800380038003800380038003800380038003800380038003800380000;
4'd8: fonts = 512'h 00001ff81ff81c381c381c381c381c381c381c381c381c381c381c381c381ff81ff81ff81c381c381c381c381c381c381c381c381c381c381c381ff81ff80000;
4'd9: fonts = 512'h 00001ff81ff81c381c381c381c381c381c381c381c381c381c381c381c381ff81ff81ff8003800380038003800380038003800380038003800381ff81ff80000;
		4'd15:fonts = 512'h ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;	
			  
		default:fonts=512'h fffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000ffffffffffffffffffffffffffff;
		
		/*
		4'd0: fonts = 512'h FFFF0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
		4'd1: fonts = 512'h FFFF1111FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
		4'd2: fonts = 512'h FFFF2222FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
		4'd3: fonts = 512'h FFFF3333FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
		4'd4: fonts = 512'h FFFF4444FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
		4'd5: fonts = 512'h FFFF5555FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
		4'd6: fonts = 512'h FFFF6666FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
		4'd7: fonts = 512'h FFFF7777FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
		4'd8: fonts = 512'h FFFF8888FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
		4'd9: fonts = 512'h FFFF9999FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
		4'h F:fonts = 512'h ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;		  
		default:fonts=512'h xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
		*/
		endcase // case (num)
	endfunction
endmodule


module linesel(clk,RSTn,hcnt,vcnt, display, lineout);
	parameter BITPERCH = 4;
	parameter BUFSIZE = BITPERCH*50*18; // BITPERCH*HCHAR*VCHAR =3600
	parameter LINEBITS = BITPERCH*`HCHAR; // BITPERCH*HCHAR = 4*50=200
	input clk,RSTn;
	input [10:0] hcnt,vcnt;
	input [BUFSIZE-1 :0] display;
	output [LINEBITS-1 :0] lineout;

	wire [4:0] linenum;
	assign linenum = vcnt[`FONTVLENLOG2 +: 5]; //long 2 FONTVLEN = 5
	assign lineout = display[LINEBITS*linenum +: LINEBITS];
	/*reg [4:0] linenum;  // (log 2 VCHAR)-1:0
	always @(hcnt or vcnt or negedge RSTn) begin
		if (!RSTn || vcnt==0) begin
			linenum <= `VCHAR-1;			
		end 
		else if(hcnt==0) begin
			if( linenum == `VCHAR-1 ) begin
				linenum <= 0;
			end else begin
				linenum <= linenum +1;
			end
		end
	end
*/endmodule

module charsel_N(clk,RSTn,hcnt,vcnt, pagenum, rdadd,sum_q, lineout); //hvalid will assigned to RST
	parameter BITPERCH = 4;
        parameter ONE_DEC = BITPERCH * 3; //12   
	parameter LINEBITS = BITPERCH*`HCHAR; // BITPERCH*HCHAR = 4*48=192
        output [`ADR_BITS-1:0] rdadd;
        input [`N-1:0]  sum_q;
   
	input clk,RSTn;
	input [10:0] hcnt,vcnt;
	output [LINEBITS-1 :0] lineout;
        reg [LINEBITS-1 :0] lineout;

   input [2:0] 		    pagenum;   
   wire [4:0] 		    linenum; //TODO change to totalLineNum/`HCHAR
   reg [4:0] 		    linenum_rem;   
   reg [`N-1:0] 	    rdadd;
   
   assign linenum = vcnt[`FONTVLENLOG2 +: 5]; //long 2 FONTVLEN = 5
   
   reg 		   doing;
     reg [31 :0] h_dx; // < log2 (hchar + ~10 )
   parameter delay = 1;

   wire [BITPERCH*3 -1 :0] conv_dec;   
   bcdconv bcdconv1( sum_q , conv_dec);
   
			  
        always @(negedge clk or negedge RSTn) begin
	   if(!RSTn) begin
	      linenum_rem <= 4'b1111;
	   end else
	   if(linenum_rem != linenum) begin
	      doing <=1;
	      //TODO CAUTION!
	      rdadd <= (`L) -(pagenum+1)*(`VCHAR*`HCHAR/3) + (`HCHAR/3)*(linenum) + (`HCHAR/3 -1);
	      h_dx <= `HCHAR*BITPERCH  + ONE_DEC*delay;
	      linenum_rem <= linenum;
	   end else if (doing == 1'b1) begin 
	      if (h_dx != 0  ) begin
		 rdadd <=  rdadd - 1;
		 h_dx <= h_dx - ONE_DEC; 
		 lineout[(h_dx -1) -: (ONE_DEC) ] <= conv_dec;		 
	      end else begin
		 doing <= 0;		 
	      end
	       
	   end
	      
	end
endmodule

module displaysel(clk, RSTn,next, in, out);
	input clk, RSTn,next;
	//parameter L=36;
	parameter BUFSIZE = `HCHAR*`VCHAR * `BITPERCH; // =3600
	parameter INSIZED = (`L*3*`BITPERCH>BUFSIZE)? (`L*3*`BITPERCH) : BUFSIZE; //L*3*`BITPERCH =432
	parameter MAXINDEX = 0; // INSIZED / BUFSIZE 
	input [INSIZED-1 :0] in;
	output[BUFSIZE-1 :0] out;
	reg[ 7:0 ] index;
	assign out = in[ BUFSIZE*index +: BUFSIZE ] ;

	always @(posedge clk or negedge RSTn or posedge next) begin
		if (!RSTn) begin
			index <= 0;			
		end
		else if (next) begin
			if(index == MAXINDEX) begin
				index <= index; // not chage
			end else begin
				index <= index +1;				
			end
		end
	end
endmodule

module conv(clk,RSTn,start,bin,dec);
	input clk,RSTn,start;
	parameter INSIZE = `L * `N;//L*N
	input [INSIZE-1 :0] bin;
	parameter L=36; parameter BITPERUNIT=12;
	parameter OUTSIZE = `L*BITPERUNIT; // 36*12 = 432
	output[OUTSIZE-1:0] dec; //L*N*(3/10*BITPERCH) =L*12
	reg [OUTSIZE-1:0] dec;
	reg [10:0] ct;

	wire[11:0] decoutw;
        //TODO!!!
	bcdconv bcdconv( bin[10*ct-1 -:10], decoutw);


	reg doing;
	always @(posedge clk) begin
		if(!RSTn)begin
			doing <= 0;
			ct <= `L;
		end
		else  begin
			if(start) begin
				doing <= 1;
			end 
			if(doing) begin
				if( ct != 0 )begin
					dec[ BITPERUNIT*ct-1 -: BITPERUNIT] <= decoutw;
					ct <= ct-1;
				end else begin
					ct <= `L;
					doing <= 0;
				end			
			end
		end
	end
endmodule