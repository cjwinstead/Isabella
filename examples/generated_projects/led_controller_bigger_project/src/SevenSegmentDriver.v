`timescale 1ns / 1ps


module SevenSegmentDriver (
			   input 	clk,
			   input [15:0] din,
			   input 	bcd,
			   input [1:0] 	dec,
			   input 	enable,
			   output [3:0] an, 
			   output [6:0] seg,
			   output 	dp,
			   output [3:0] ones,
			   output [3:0] tens,
			   output [3:0] hundreds,
			   output [3:0] thousands
			   );
   
   //used to bring .display_digit in and to seg
   wire [6:0] 				ones_place;
   wire [6:0] 				tens_place;
   wire [6:0] 				hundreds_place;
   wire [6:0] 				thousands_place;
   
   //used to bring bcd in and to .digit in for conversion
   /*
   wire [3:0] 				ones;
   wire [3:0] 				tens;
   wire [3:0] 				hundreds;
   wire [3:0] 				thousands;
*/
   
   reg [3:0] 				ones_sel;
   reg [3:0] 				tens_sel;
   reg [3:0] 				hundreds_sel;
   reg [3:0] 				thousands_sel;

   wire [3:0] 				_an;
   assign an = {4{~enable}} | {4{enable}}&_an;
   
   wire 				refclk;	
   //display is active low, inversion needed
   wire [6:0] 				segNot;
   assign seg[0] = ~segNot[6];
   assign seg[1] = ~segNot[5];
   assign seg[2] = ~segNot[4];
   assign seg[3] = ~segNot[3];
   assign seg[4] = ~segNot[2];
   assign seg[5] = ~segNot[1];
   assign seg[6] = ~segNot[0];
   
   
   // Display Mux
   ThePlexer Mux(
		 .disp1(ones_place),
		 .disp10(tens_place),
		 .disp100(hundreds_place),
		 .disp1000(thousands_place),
		 .clk(refclk),
		 .disp(segNot), //segNot
		 .anode(_an),
		 .dec(dec),
		 .dp(dp)
		 );
   
   
   // clkB, the system clk divided
   clkB clkInst (
		 .sysClk(clk),
		 .refClk(refclk)
		 );
   
   
   /******************************************************************
    *		Three instances of in->out truth table for 7-seg display		*
    * 	--------------------------------------------------------		*
    * 		(one instance per digit)											*
    *			## uncomment the module you want to use						*
    ******************************************************************/
   SevenSegmentTruthTable digit1s( 
				   //ONES PLACE
      
				   //BCD
				   .digit_in(ones_sel),				//in  4-bit
				   .display_digit(ones_place)	//out	7-bit

      
				   /*
				    //HEX
				    .digit_in(NumberIn[3:0]),
				    .display_digit(1s_place[6:0])
				    */
				   );
   
   SevenSegmentTruthTable digit10s(
				   //TENS PLACE
      
				   //BCD
				   .digit_in(tens_sel),				//in	4-bit
				   .display_digit(tens_place)	//out	7-bit
      
				   /*
				    //HEX
				    .digit_in(NumberIn[7:4]),
				    .display_digit(10s_place[6:0])
				    */
				   );
   
   SevenSegmentTruthTable digit100s(
				    //HUNDREDS PLACE

				    //BCD
				    .digit_in(hundreds_sel),			//in	4-bit
				    .display_digit(hundreds_place) //out	7-bit
      
				    /*
				     //HEX
				     .digit_in(NumberIn[11:8]),
				     .display_digit(100s_place[6:0])
				     */
				    );

   SevenSegmentTruthTable digit1000s(
				     //HUNDREDS PLACE

				     //BCD
				     .digit_in(thousands_sel),			//in	4-bit
				     .display_digit(thousands_place) //out	7-bit
      
				     /*
				      //HEX
				      .digit_in(NumberIn[11:8]),
				      .display_digit(100s_place[6:0])
				      */
				     );
   
   
   
   
   /******************************
    *		INTERFACE INSTANCES		*
    *		-------------------		*
    *			(1) HEX					*
    *			(2) BCD					*
    *										*
    *  ## uncomment the one		*
    *			you want to use		*
    ******************************/
   
   /*
    //NOTE: may need other modifications to work
    // (1) HEX interface	
    SwitchIn SI(.NumberIn(sw1))	//out
    */
   
   // (2) BCD interface
   bcd bcd_in(
	      .sw(din),			    //in	16-bit
	      .ones(ones),			//out	4-bit
	      .tens(tens),			//out	4-bit
	      .hundreds(hundreds)	,    //out	4-bit
	      .thousands(thousands)	//out	4-bit
	      );

   always @* begin
      if (bcd) begin
         ones_sel <= ones;
         tens_sel <= tens;
         hundreds_sel <= hundreds;
         thousands_sel <= thousands;
      end
      else begin
         ones_sel <= din[3:0];
         tens_sel <= din[7:4];
         hundreds_sel <= din[11:8];
         thousands_sel <= din[15:12];
      end
   end
endmodule
`timescale 1ns / 1ps
/***************************************************************
 *	This module takes in a 4-bit Binary Coded Decimal value	 	*
 *		and assigns it a 7-bit value for display on a 7-segment	*
 *		display.																	*
 ***************************************************************/
  module SevenSegmentTruthTable(
				input [3:0] 	 digit_in, 
				output reg [6:0] display_digit
				);
   
   always @(*) begin //* run when any input changes
      case (digit_in)
	4'b0000 : display_digit = 7'b1111110; //0
	4'b0001 : display_digit = 7'b0110000; //1
	4'b0010 : display_digit = 7'b1101101; //2
	4'b0011 : display_digit = 7'b1111001; //3
	4'b0100 : display_digit = 7'b0110011; //4
	4'b0101 : display_digit = 7'b1011011; //5
	4'b0110 : display_digit = 7'b1011111; //6
	4'b0111 : display_digit = 7'b1110000; //7
	4'b1000 : display_digit = 7'b1111111; //8
	4'b1001 : display_digit = 7'b1111011; //9
	4'b1010 : display_digit = 7'b1110111; //a
	4'b1011 : display_digit = 7'b0011111; //b
	4'b1100 : display_digit = 7'b0001101; //c
	4'b1101 : display_digit = 7'b0111101; //d
	4'b1110 : display_digit = 7'b1001111; //e
	4'b1111 : display_digit = 7'b1000111; //f
	// default case to catch unexpected or invalid inputs :
	default : display_digit = 7'b0000000;
      endcase
   end
 
endmodule
`timescale 1ns / 1ps


/******************************************
 *	This Multiplexer switches the 			*
 *		4 place values across the four		*
 *		anodes for display.  Note that		*
 *		the right most place value will		*
 *		always be an "F" to represent			*
 *		degrees Farenheit.						*
 *******************************************/

module ThePlexer(
		 input [6:0] 	  disp1,
		 input [6:0] 	  disp10,
		 input [6:0] 	  disp100,
		 input [6:0] 	  disp1000,
		 input [1:0] 	  dec,
		 input 		  clk,
		 output reg [6:0] disp,
		 output reg [3:0] anode,
		 output reg 	  dp
		 );
   
   /*
    // Clk for Simulation. In REAL WORLD, use divided 
    //		clock value the main module.
    wire clk;
    clkA clkInst (
    .clk(clk)
    );
    */
   
   // rotating select, 2-bits
   reg [1:0] 			  sel;
   
   // initialize select value
   initial begin
      sel <= 0;
   end
   
   // rotate select as the divided clock value changes
   always @ (posedge clk)
     begin
	sel <= sel + 1;
     end
   
   // Plexage
   //		This assigns the place value data and the anode control
   //		to its correct display digit.
   always @(*) begin //* run when any input changes
      case (sel)
	2'b00 : begin //thousands
           // This if statement makes the value 0 not display
           if (disp1000 == 7'b1111110) begin
              //anode = 4'b1111; //1111
              disp = 7'b0000000;
           end
           
           else    begin
              disp = disp1000;
           end
           anode = 4'b0111; //0111                
           if (dec==2'b11)
             dp = 0;
           else
             dp = 1;
        end
        
	2'b01 : begin //hundreds
	   // This if statement makes the value 0 not display
	   if ((disp100== 7'b1111110) & (disp1000 == 7'b1111110)) begin
	      //anode = 4'b1111; //1111
	      disp = 7'b0000000;
	   end
	   
	   else	begin
	      disp = disp100;
	   end
	   anode = 4'b1011; //0111
           if (dec==2'b10)
             dp = 0;
           else
             dp = 1;					
	end
	
	2'b10 : begin //tens
	   // This if statement makes the value 0 not display
	   //		ONLY if hundreds place is also 0
	   if ((disp10== 7'b1111110) & (disp100== 7'b1111110) & (disp1000== 7'b1111110)) begin
	      //anode = 4'b1111; //1111
	      disp = 7'b0000000;
	   end
	   
	   else	begin
	      disp = disp10;
	   end
	   anode = 4'b1101; //1011
           if (dec==2'b01)
             dp = 0;
           else
             dp = 1;                    
	   
	end	

	
	2'b11 : begin  //ones
	   // will always display 0 if it is 0
	   disp = disp1;
	   anode = 4'b1110; //1101
	   if (dec==2'b00)
             dp = 0;
           else
             dp = 1;
	end
	/*
	 2'b11 : begin
	 // Fahrenheit symbol
	 disp = 7'b1000111; //F
	 anode = 4'b1110; //1110
				end
	 */			
	// If the sh** hits the fan with the
	//		rotating select, display an "E"
	// 	for "Error" in the hundreds place
	default : begin
	   disp = 7'b1001111;
	   anode = 4'b0111; //0111
	end
      endcase
   end
endmodule
`timescale 1ns / 1ps

/***************************************************************
 *	This module takes in an 8-bit binary value and converts		*
 * 	it to three 4-bit Binary Coded Decimal Values. The			*
 *		algorithm used is a variation on the Dibble-Dabble.		*
 ***************************************************************/
module bcd(
	   //*NOTE: If this input is set to "sw" then it will be
	   //		recieveing input from the 8 onborard toggle switches
	   //		as an 8-bit input.
	   input [15:0]     sw, //8-bit binary in
	   output reg [3:0] thousands, //4-bit hundereds, 1st column
	   output reg [3:0] hundreds, //4-bit hundereds, 1st column
	   output reg [3:0] tens, //4-bit tens, 2nd column
	   output reg [3:0] ones		//4-bit ones, 3rd column
	   );
   
   integer 		    index; // to decrement with for loop
   
   always @(sw) //only change when binary element changes
     begin
	//set 100's, 10's, and 1's to 0
	thousands = 4'd0; 	//4-bit decimal = 0
	hundreds = 4'd0; 	//4-bit decimal = 0
	tens = 4'd0; 		//4-bit decimal = 0
	ones = 4'd0; 		//4-bit decimal = 0
	
	for (index = 15; index >= 0; index = index - 1) //decrement to start with highest place value
	  begin
	     
	     //add 3 to each column if the value is >= 5
	     if (thousands >= 5)
               thousands =  thousands + 3;

	     if (hundreds >= 5)
	       hundreds =  hundreds + 3;
	     
	     if (tens >= 5)
	       tens =  tens + 3;
	     
	     if (ones >= 5)
	       ones =  ones + 3;
	     
	     //shift to the left 1 ALWAYS
	     //shift the biggest values first so they are out of the way
	     thousands = thousands << 1;	//shift hundreds 1 to left
             thousands[0] = hundreds[3];         //highest value in the tens column is assigned to the lowest place value in the hundreds column

	     hundreds = hundreds << 1;	//shift hundreds 1 to left
	     hundreds[0] = tens[3]; 		//highest value in the tens column is assigned to the lowest place value in the hundreds column
	     
	     tens = tens << 1; 	//shift tens 1 to left
	     tens[0] = ones[3]; 	//lowest of tens is assigned the highest of the ones
	     
	     ones = ones << 1;		//shift ones 1 to left
	     ones[0] = sw[index]; //lowest of ones is assigned next value in binary
	  end //for
     end //always
   
   
   
endmodule //bcd
`timescale 1ns / 1ps
/******************************************
 *	This module divides the system clock	*
 *		values (@50hz) into arbitrarily		*
 *		lower frequencies for a balanced		*
 *		length of time for anode control		*
 *		on a 7-segment display.					*
 ******************************************/

module clkB(
	    input      sysClk,
	    output reg refClk
	    );

   reg [23:0] 	       count;
   
   initial begin
      count = 0;
      refClk = 0;
   end

   always @ (posedge sysClk) begin
      //edit the "count up to" value to change anode display rate
      if (count == 24'd100000) begin 
	 count <= 0;
	 refClk <= ~refClk;			
      end
      
      else begin
	 count <= count + 1;
      end
   end
   
   
   
endmodule
