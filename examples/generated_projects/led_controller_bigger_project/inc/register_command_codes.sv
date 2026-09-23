localparam LOAD_A  = 8'h11;
localparam LOAD_B  = 8'h12;
localparam INCR_B  = 8'h13;  // B++
localparam DECR_B  = 8'h14;  // B--
localparam ADD_AB  = 8'h15;  // B <= A+B
localparam SUB_AB  = 8'h16;  // B <= A-B
localparam SWAP_AB = 8'h17;  // B <= A; A <= B;
localparam JZ      = 8'h18;  // Jump if B==0
localparam JLZ     = 8'h19;  // Jump if B<0
localparam JGZ     = 8'h1A;  // Jump if B>0
