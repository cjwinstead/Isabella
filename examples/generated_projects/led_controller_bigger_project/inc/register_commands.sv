LOAD_A: begin
   if (data_bytes == 1) begin
      _A    <= data;
      state <= CMD_DONE;
   end else begin
      padr++;   
      state <= DATA_BYTE;
   end
end 
LOAD_B: begin
   if (data_bytes == 1) begin
      _B    <= data;
      state <= CMD_DONE;
   end else begin
      padr++;   
      state <= DATA_BYTE;
   end
end
INCR_B: begin
   _B++;
   state <= CMD_DONE;
end
DECR_B: begin
   _B--;
   state <= CMD_DONE;
end
ADD_AB: begin
   _B <= _A + _B;
   state <= CMD_DONE;
end 
SUB_AB: begin
   _B <= _A - _B;
   state <= CMD_DONE;
end 
SWAP_AB: begin
   _B <= _A;
   _A <= _B;
   state <= CMD_DONE;
end 
JZ: begin
   if ((data_bytes == 1) && (_B==0)) begin
      state <= CMD_START;
      padr  <= data;
      cmd   <= pmem[data];
      data_bytes <= 0;
   end else if ((data_bytes == 1) && (_B!=0)) begin
      state <= CMD_DONE;
   end else begin
      padr <= padr + 1;      
      state <= DATA_BYTE;
   end   
end
JLZ: begin
   if ((data_bytes == 1) && (_B<0)) begin
      state <= CMD_START;
      padr  <= data;
      cmd   <= pmem[data];
      data_bytes <= 0;
   end else if ((data_bytes == 1) && (_B>=0)) begin
      state <= CMD_DONE;
   end else begin
      padr <= padr + 1;      
      state <= DATA_BYTE;
   end   
end
JGZ: begin
   if (data_bytes == 1) begin
      if (_B > 0) begin
         state <= CMD_START;
         padr  <= data;
         cmd   <= pmem[data];
         data_bytes <= 0;
      end else begin
         state <= CMD_START;
         data_bytes <= 0;
         padr <= padr + 1;
         cmd <= pmem[padr+1];
      end
   end else begin
      padr <= padr + 1;      
      state <= DATA_BYTE;
   end   
end
