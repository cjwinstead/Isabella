`timescale 1ns/1ps

// timer: trigger alarm after given number of clock cycles

module timer (
	      input 	  clk,
	      input 	  clr,
	      input [1:0] scale, // 0(us),1(ms),2(s)
	      input [7:0] duration,
	      output reg  t
	 );

   reg [7:0] 		 clkcount;
   reg [9:0] 		 uscount;
   reg [9:0] 		 mscount;
   reg [7:0] 		 scount;
   
   initial begin
      t = 0;
      clkcount = 0;
      uscount = 0;
      mscount = 0;
      scount = 0;
   end

   always @(posedge clk) begin
      if (clr) begin
	 // Reset behavior:
	 t        <= 0;
	 clkcount <= 0;
	 uscount  <= 0;
	 mscount  <= 0;
	 scount   <= 0;
	 
      end
      else begin
	 // Normal behavior:
	 if (clkcount == 100) begin
	    clkcount <= 0;

	    if ((scale == 0) && (uscount == duration) ||
		(scale == 1) && (mscount == duration) ||
		(scale == 2) && (scount == duration)
		) begin
	       t <= 1;	       
	    end
	    else if (uscount == 1000) begin
	       uscount <= 0;
	       if (mscount == 1000) begin
		  mscount <= 0;		  
		  scount <= scount + 1;
	       end
	       else
		 mscount <= mscount + 1;
	    end	    	      
	    else begin
	       uscount++;	       
	    end
	 end
	 else begin
	    clkcount++;	    
	 end
      end
   end
   

endmodule
    
