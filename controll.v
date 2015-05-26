`define L 47
`define ADR_BITS 6
`define N 10
`define RAMDELAY 2
module controll(clk, rst, clk_fast,sum_rdadd_ctrl, sum_q);

   input clk_fast;
   input [`ADR_BITS-1 : 0] sum_rdadd_ctrl;
   output [`N-1:0] 	  sum_q;   
   
   parameter L = `L; // WANT_TO_CALC_DIGIT(DEC)=100, L -(100/3 +1)+1+1
   parameter N = 10;
   input clk;
   input rst;
   //output [L*N-1:0] sum;
   reg [L*N-1:0]    sum;
   parameter INIT       = 4'h0,
	       DIV1       = 4'h1,
	       DIV2       = 4'h2,
	       DIV3       = 4'h3,
	       SUB        = 4'h4,
	       DIV4       = 4'h5,
	       MERGEPLUS  = 4'h6,
  	       MERGEMINUS = 4'h7,
	       END        = 4'h8,
	       PREINIT    = 4'h a;
reg [3:0] state;
wire [9:0] initdiv1,initdiv2, constdiv1,constdiv2;
assign initdiv1 = 10'd 80; //16*5
assign initdiv2 = 10'd 956; //4*239
assign constdiv1 = 10'd 25;
assign constdiv2 = 10'd 239;
assign merged_clk = (state!=END)? clk : clk_fast; //INPORTANT

reg signed [ 31:0 ] count, endct; // count 0 ~~ L //! 2^bit > L + RAMDELAY

parameter NTIMES = 109; // 3*L/1.4+1 ~= 100/1.4 +1 ???   OVERFLOOOOOOOOOOOOOOOOOOOOOO!!!

wire [N-1:0]  sum_dsig,div1_dsig,div1_q,div2_dsig,div2_q,sub_dsig,sub_q; // CAUTION!
//wire [N-1:0] sum_q;
wire [5:0]  sum_rdadd,sum_wradd,div1_rdadd,div1_wradd,div2_rdadd,div2_wradd,sub_rdadd,sub_wradd;
wire [N-1:0] div1dsigtmp,div2dsigtmp;
reg sum_wren, div1_wren, div2_wren, sub_wren;
ram2port ram2p_sum (merged_clk,sum_dsig, sum_rdadd, sum_wradd, sum_wren, sum_q); // reg [L*N-1:0] sum;
ram2port ram2p_div1 (clk,div1dsigtmp, div1_rdadd, div1_wradd, div1_wren, div1_q); // reg [L*N-1:0] div1;
ram2port ram2p_div2 (clk,div2dsigtmp, div2_rdadd, div2_wradd, div2_wren, div2_q); // reg [L*N-1:0] div2;
ram2port ram2p_sub (clk,sub_dsig, sub_rdadd, sub_wradd, sub_wren, sub_q); // reg [L*N-1:0] sub;
assign sum_rdadd = (state!=END)? count : sum_rdadd_ctrl;
assign sub_rdadd = count; assign div1_rdadd = count; assign div2_rdadd = count;
assign sum_wradd = count-`RAMDELAY;        assign sub_wradd = (state==DIV4)? count+`RAMDELAY : count-`RAMDELAY;
assign div1_wradd = (state==INIT)? (`L-1): (count+`RAMDELAY);
assign div2_wradd = (state==INIT)? (`L-1): (count+`RAMDELAY);
assign div1dsigtmp = div1_dsig;assign div2dsigtmp = div2_dsig;

wire [N-1:0] div1quo; reg [N-1:0] div1quo_mem;//TODO
wire [10+N-1:0] div1rem;
reg [10+N-1:0] div1remm;
assign div1_dsig = (state==PREINIT)? 0 : (state==INIT) ? initdiv1 : div1quo_mem; //TODO
assign div2_dsig = (state==PREINIT)? 0 : (state==INIT) ? initdiv2 : div1quo_mem;


reg [N-1:0] div3valk;
wire [N-1:0] param2k;
assign param2k = div3valk * 2 - 1 ; //OVERFLOW AND DIE

wire [L*N-1:0] divseln;
wire [N-1:0] div1Nbitn,div1Nbitd;
// divider2(unit) is used at DIV1 and DIV3 ,input differs
assign divseln   = (state==DIV1)? div1_q    : (state==DIV2 || state==DIV3)? div2_q : sub_q;
assign div1Nbitn = divseln;
assign div1Nbitd = (state==DIV1)? constdiv1 : (state==DIV2 || state==DIV3)? constdiv2         : param2k;

divider10a divider1 ( div1remm, div1Nbitn , div1Nbitd, div1quo,div1rem );
reg  subcin;
wire subcoutw;
wire [N-1:0] subNbita,subNbitb, subq; reg[N-1:0] subq_mem;
assign subNbita = (state==SUB) ? div1_q : sum_q;
assign subNbitb = (state==SUB) ? div2_q : sub_q;
sub10bitD subsracter( subNbita,subNbitb, subq, subcin,subcoutw  );

// only used at MERGE
reg addcin;
wire addcoutw;
wire [N-1:0] addq; reg[N-1:0] addq_mem;
add10bitD adder10D( sum_q,sub_q, addq, addcin,addcoutw );


assign sum_dsig = (state==PREINIT)? 10'd0 : (state==MERGEMINUS)? subq_mem: (state==MERGEPLUS)? addq_mem : 10'bx;
assign sub_dsig = (state==PREINIT)? 10'd0 : (state==SUB)? subq_mem : (state==DIV4) ? div1quo_mem : 10'bx;



always @(negedge merged_clk) begin //remove or megedge rst
   
   if (!rst) begin
      // reset
      // note: [MSB:LSB], calc MSB->LSB whe div, LSB->MSB when sub/add
      // 2.5 -> [<2>,<.5>, ...]

      //div1 <= { initdiv1,{(N*L-10){1'b0}} }; div1remm <= 0;
      //div2 <= { initdiv2,{(N*L-10){1'b0}} };
      count <= L+ `RAMDELAY +1;
      sum_wren<=0;div1_wren<=0;div2_wren<=0;sub_wren<=0;
      state <= PREINIT;
      div3valk<=0;		        
   end else begin // if (!rst)

      // every negedge, below is done
      div1quo_mem <= div1quo;	
      addq_mem <= addq;
      subq_mem <= subq;
      
      case(state)
	PREINIT: begin
	   // sum <= { (N*L){1'b0} };
	   count <= count -1;
	   sum_wren<=1;div1_wren<=1;div2_wren<=1;sub_wren<=1;
	   if( count == (32'd0 - `RAMDELAY - 1 ) ) begin
	      sum_wren<=0;div1_wren<=0;div2_wren<=0;sub_wren<=0;
	      state <= INIT; count <= 0;			      

	   end
	end
	
	INIT: begin

  	   div3valk <= 10'd 0;
	   count <= count -1;
	   div1_wren <=1;div2_wren<=1;			   
	   if(count==0-`RAMDELAY) begin
	      div1remm<=0;
	      div1_wren <=0;div2_wren<=0;	
	      count <= L-1; state <= DIV1; 
	   end
	end
	DIV1: begin // div1 /= divider1, div2 /= divider2, ct:L-1->0
	   // div1[N*count +:N] <= div1quo;
	   div1remm <= div1rem;
	   if(count != 0-`RAMDELAY-1) begin
	      count <= count-1;
	      if(count == L-1 -`RAMDELAY+1)div1_wren<=1;				   
	   end else begin //ct==0-`ramdelay
	      count <= L-1;div1_wren<=0;				   
	      state <= DIV2; div1remm<=0;
	   end
	end

	DIV2: begin // div2 /= divider2, ct:L-1->0
	   //	div2[N*count +:N] <= div1quo; 
           div1remm <= div1rem;
	   if(count != 0-`RAMDELAY-1) begin
	      count <= count-1;
	      if(count == L-1-`RAMDELAY+1)div2_wren<=1;				   
	   end else begin
	      count <=  L-1;div2_wren<=0;				   
	      state <= DIV3; div1remm <= 0;	
	   end
	end
	DIV3: begin // div2 /= divider2, ct:L-1->0
	   //div2[N*count +:N] <= div1quo;
           div1remm <= div1rem;
	   if(count != 0-`RAMDELAY-1) begin
	      count <= count-1;
	      if(count == L-1-`RAMDELAY+1)div2_wren<=1;
	   end else begin
	      count <= 0;div2_wren<=0;				   
	      state <= SUB; subcin <= 0;	
	   end
	end

	SUB: begin // sub <- div1- div2, ct:0->L-1
	   //sub[N*count +:N] <= subq; 
	   subcin <= subcoutw;				
	   if(count != L-1 +`RAMDELAY+1) begin
	      count <= count +1;
	      if(count == 0+`RAMDELAY-1)sub_wren<=1;				   
	   end else begin
	      count <= L-1;sub_wren<=0;
	      div3valk <= div3valk +1;
	      state <= DIV4; div1remm<=0;
	   end
	end

	DIV4: begin // sub /= 2*k-1, ct:L-1->0
	   //! TODO
	   //sub[N*count +:N] <= div1quo;
	   div1remm <= div1rem;
	   if(count != 0-`RAMDELAY-1) begin
	      count <= count-1;
	      if(count == L-1-`RAMDELAY+1)sub_wren<=1;
	   end else begin
	      if ( (div3valk[0]) == 1'b0) begin
		 state <= MERGEMINUS; count <=0; subcin<=0;sub_wren<=0;
	      end else begin
		 state <= MERGEPLUS;  count <=0; addcin<=0;sub_wren<=0;
	      end
	   end
	end	
	MERGEPLUS: begin // sum <- sum + sub
	   //sum[N*count +:N] <= addq; 
	   addcin <= addcoutw;				
	   count <= count +1;
	   if(count == 0+`RAMDELAY-1)begin 
	      sum_wren<=1;
	   end else if(count == L-1 +`RAMDELAY+1 ) begin
	      if(div3valk == NTIMES)begin
		 div1remm<=0;
		 sum_wren<=0;
		 count<=0;
		 state <= END;	
              end else begin
 		 div1remm<=0;
		 sum_wren<=0;
		 count<=L-1;
		 state <= DIV1;
	      end
           end
        end  
        MERGEMINUS: begin // sum <- sum - sub
	   subcin <= subcoutw;				
	   count <= count +1;
	   if(count == 0+`RAMDELAY-1)begin 
	      sum_wren<=1;
	   end else if(count == L-1 +`RAMDELAY+1) begin
	      if(div3valk == NTIMES) begin
		 div1remm<=0;
		 sum_wren<=0;
		 count<=0;
		 state <= END;
              end else begin
 		 div1remm<=0;
		 sum_wren<=0;
		 count<=L-1;
		 state <= DIV1;	
              end // else: !if(count == L-1 +`RAMDELAY+1)
	   end
        end
        END: begin
	   if(count == L-1 +`RAMDELAY+1  ||  (endct == N*L) )begin
	      count <= 0; endct <= 0;				   
	   end else begin
   	      // count <= count+1;  ////ASSERTION, this comment-out wil stop the process in <END>
	      if(count  >= `RAMDELAY-1)begin
		 //sum[endct +: N] <= sum_q;
		 sum[endct +: `N] <= sum_q;
		 endct <= endct + `N;				      
	      end
	   end
	end
	
      endcase // case (state)
   end
end

endmodule

module seldigit(in, sel, out); //select digit[10bit]
   parameter L = 100, N = 10;
   input [L*N-1:0] in;
   input [ 7:0 ]   sel;
   output [N-1:0]  out;
   assign out = in[ N*(sel) +: N ];
endmodule