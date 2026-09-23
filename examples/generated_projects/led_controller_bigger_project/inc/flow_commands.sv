NULL_CMD: begin
   state <= WAIT;
end 
SLEEP_US: begin
   timerUnits <= 0;
   padr++;
   
   state <= DATA_BYTE;
end
SLEEP_MS: begin
   timerUnits <= 1;
   padr++;
   state <= DATA_BYTE;
end
SLEEP_S: begin
   timerUnits <= 2;
   padr++;
   state <= DATA_BYTE;
end 
JUMP: begin
   if (data_bytes == 1) begin
      state <= CMD_START;
      padr  <= data;
      cmd   <= pmem[data];
      data_bytes <= 0;
   end
   else begin
      padr <= padr + 1;      
      state <= DATA_BYTE;
   end
   
end
