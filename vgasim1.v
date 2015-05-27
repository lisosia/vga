`timescale 1ns / 1ns
module vgasim1;
   reg clk,RSTn;
   wire hsync,vsync,  r,g,b;
   wire [10:0] hcnt,vcnt;
   vga vga_inst(clk,RSTn, hsync,vsync, r,g,b);
   parameter L = 36;
   
   initial begin
      clk<=0;
      RSTn<=1;
      #15 RSTn<=0;
      #25 RSTn<=1;

      #(20*6*L*72 * 100   *4) $finish;
   end

   always #10 begin
      clk <= ~clk;      
   end
   
endmodule