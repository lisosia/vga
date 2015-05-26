`define L 47
`define N 10
module print_led(clk,keys,RSTn, dec0,dec1,dec2, LEDa,LEDb,LEDc,LEDd,LEDe,LEDf,LEDg,LEDh);
   input clk,RSTn;
   input [9:0] keys;
   parameter INSIZE = `L*`N; // L*N
   parameter OUTSIZE = `L*12;
   //wire [INSIZE-1 :0] bin;
   //wire [OUTSIZE-1:0] dec;

   //slowclock slowclock_inst(clk,RSTn,slowclk);   
   //controll controll(slowclk,RSTn, bin);

   input [11:0] dec0,dec1,dec2;
   /*bcdconv bcdconv0( bin[10* (10-0) -1  -:10] , dec0 );
   bcdconv bcdconv1( bin[10* (10-1) -1  -:10] , dec1 );
   bcdconv bcdconv2( bin[10* (10-2) -1  -:10] , dec2 );
   */
   /*assign dec0 = dec[OUTSIZE-1     -:12];   
   assign dec1 = dec[OUTSIZE-1 -12 -:12];   
   assign dec2 = dec[OUTSIZE-1 -24 -:12];   
    */
   
   output [7:0]  LEDa,LEDb,LEDc,LEDd,LEDe,LEDf,LEDg,LEDh;

   assign LEDa = ledout( dec0[ 11 -:4 ] );   
   assign LEDb = ledout( dec0[ 7  -:4 ] );   
   assign LEDc = ledout( dec0[ 3  -:4 ] );    
   assign LEDd = ledout( dec1[ 11 -:4 ] );   
   assign LEDe = ledout( dec1[ 7  -:4 ] );   
   assign LEDf = ledout( dec1[ 3  -:4 ] );    
   assign LEDg = ledout( dec2[ 11 -:4 ] );   
   assign LEDh = ledout( dec2[ 7  -:4 ] );   
   
   function [7:0] ledout;
      input [3:0] num;
      case(num)
	4'd0 : ledout = 8'b1111_1100;
	4'd1 : ledout = 8'b0110_0000;
	4'd2 : ledout = 8'b1101_1010;
	4'd3 : ledout = 8'b1111_0010;
	4'd4 : ledout = 8'b0110_0110;
	4'd5 : ledout = 8'b1011_0110;
	4'd6 : ledout = 8'b1011_1110;
	4'd7 : ledout = 8'b1110_0000;
	4'd8 : ledout = 8'b1111_1110;
	4'd9 : ledout = 8'b1111_0110;
	default: ledout=8'b1111_1111;
      endcase // case (num)
   endfunction // case
   
endmodule // vga
