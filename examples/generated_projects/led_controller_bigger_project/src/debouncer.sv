`timescale 1ns/1ps


module debouncer (
		  input clk,
		  input rst,
		  input btn,
		  output reg db
);


   localparam		     WAIT = 0;
   localparam		     PRESS = 1;
   localparam		     RELEASE = 2;

   reg [1:0]		     state;   
   reg [15:0]		     count;

   localparam		     PRESS_COUNT = 3200;
   localparam		     RELEASE_COUNT = 9000;
   
   initial begin
      db = 0;
      state = WAIT;
      count = 0;      
   end

   always @(posedge clk) begin
      if (rst) begin
	 state <= WAIT;
	 db    <= 0;
	 count <= 0;	 
      end
      else begin
	 case (state)
	   WAIT: begin
	      if (btn) begin
		 if (count < PRESS_COUNT) begin
		    db    <= 0;		 
		    count <= count + 1;
		 end else begin
		    db    <= 1;		 
		    state <= PRESS;
		    count <= 0;		 
		 end
	      end	      
	      else begin
		 count <= 0;
		 db    <= 0;		 
	      end
	      
	   end
	   PRESS: begin
	      db <= 0;
	      if (!btn) begin
		 if (count < RELEASE_COUNT) begin
		    count <= count + 1;
		 end else begin
		    state <= RELEASE;
		    count <= 0;		 
		 end
	      end	      
	      else begin
		 count <= 0;
	      end
	   end
	   RELEASE: begin
	      db    <= 0;
	      count <= 0;	      
	      state <= WAIT;	      
	   end
	   default: begin
	      db    <= 0;
	      state <= WAIT;
	      count <= 0;	      
	   end	     
	 endcase
      end
   end
   

endmodule //
