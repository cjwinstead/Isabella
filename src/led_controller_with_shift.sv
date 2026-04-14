`timescale 1ns/1ps

module led_controller_with_shift  (
   input 	     clk,
   input 	     rst,
   input 	     intr,
   input [7:0] 	     iadr,
   output reg 	     ready,
// no special inputs for this controller
output reg [15:0] led
);

// program memory
reg [7:0] 	     pmem[255:0];


reg [2:0] 	     state;
reg [7:0] 	     padr;  // program memory address pointer
reg [7:0] 	     cmd;   // command code register
reg [7:0] 	     data;  // data byte register

reg [7:0] 	     data_bytes; // count of data bytes retrieved

// timer signals
reg [7:0] 	     duration;
reg 		     tclr;
wire 	     t;
reg [1:0] 	     timerUnits;

localparam WAIT      = 0;
localparam CMD_START = 1;
localparam CMD_DONE  = 2;
localparam DATA_BYTE = 3;
localparam SLEEP     = 4;

// import list of command codes and aliases:
`include "inc/flow_command_codes.sv"
`include "inc/led_controller_with_shift_command_codes.sv"

initial begin
   state = WAIT;
   ready = 0;
   timerUnits = 0; // default micro-seconds
   $readmemh("programs/led_controller_with_shift_program.mem",pmem,0,255);
led = 0;
   end   

   timer T1
     (
      .clk(clk),
      .clr(tclr),
      .duration(duration),
      .t(t),
      .scale(timerUnits)
      );
   
   
   always @(posedge clk) begin
      if (rst) begin
	 ready <= 0;
	 state <= WAIT;
	 tclr <= 1;
	 padr <= 0;
         led <= 0;
      end
      else begin
      case (state)
	WAIT: begin
	   tclr  <= 1; // Reset the timer
	   cmd   <= pmem[iadr];
	   data_bytes <= 0;
	   
	   // a new "interrupt" arrives
	   if (intr) begin
	      padr  <= iadr;

	      state <= CMD_START;
	      ready <= 0;
	   end
	   else
	     ready <= 1;
	end
	CMD_START: begin
	   ready <= 0;
	   
	   case (cmd)
	     // import program control commands
             `include "inc/flow_commands.sv"
             `include "inc/led_controller_with_shift_commands.sv"
	   endcase
	end
	CMD_DONE: begin
	   ready <= 0;
	   
	   padr       <= padr + 1;
	   cmd        <= pmem[padr + 1];
	   data_bytes <= 0;
	   state      <= CMD_START;
	end
	DATA_BYTE: begin
	   ready <= 0;
	   
	   //padr <= padr + 1;
	   data <= pmem[padr];
	   data_bytes <= data_bytes + 1;
	   if (cmd == SLEEP_US || cmd == SLEEP_MS || cmd == SLEEP_S) begin
	      state <= SLEEP;
	   end
	   else begin
	     state <= CMD_START;
           end
	end
	SLEEP: begin

	   
	   if (intr) begin
	      ready <= 0;
	      padr  <= iadr;
	      cmd   <= pmem[iadr];
	      state <= CMD_START;
	      tclr  <= 1;
	      data <= 0;
	      data_bytes <= 0;
	   end
	   else if (t) begin
	      tclr <= 1;
	      cmd <= pmem[padr+1];
              padr++;
	      data_bytes <= 0;
	      ready <= 0;	      
	      state <= CMD_START;
	   end
	   else begin
	      ready <= 1;	      
	      tclr <= 0;
	      duration <= data;
	   end
	end
      endcase
   end
   end

endmodule
