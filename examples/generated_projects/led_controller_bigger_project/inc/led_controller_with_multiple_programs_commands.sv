LED_CLEAR: begin
//padr++;
if (data_bytes==0) begin
led <= 0;      state <= CMD_DONE;
   end
   else begin
      padr++;
      state<=DATA_BYTE;
   end
end
LED_SET_LOW_BYTE: begin
//padr++;
if (data_bytes==1) begin
led[7:0] <= data;      state <= CMD_DONE;
   end
   else begin
      padr++;
      state<=DATA_BYTE;
   end
end
LED_SET_HIGH_BYTE: begin
//padr++;
if (data_bytes==1) begin
led[15:8] <= data;      state <= CMD_DONE;
   end
   else begin
      padr++;
      state<=DATA_BYTE;
   end
end
LED_OR_LOW_BYTE: begin
//padr++;
if (data_bytes==1) begin
led[7:0] <= led[7:0] | data;      state <= CMD_DONE;
   end
   else begin
      padr++;
      state<=DATA_BYTE;
   end
end
LED_OR_HIGH_BYTE: begin
//padr++;
if (data_bytes==1) begin
led[15:8] <= led[15:8]|data;      state <= CMD_DONE;
   end
   else begin
      padr++;
      state<=DATA_BYTE;
   end
end
LED_NAND_LOW_BYTE: begin
//padr++;
if (data_bytes==1) begin
led[7:0] <= led[7:0]&data;      state <= CMD_DONE;
   end
   else begin
      padr++;
      state<=DATA_BYTE;
   end
end
LED_NAND_HIGH_BYTE: begin
//padr++;
if (data_bytes==1) begin
led[15:8] <= led[15:8]&data;      state <= CMD_DONE;
   end
   else begin
      padr++;
      state<=DATA_BYTE;
   end
end
LED_FLOOD: begin
//padr++;
if (data_bytes==0) begin
led <= 16'hffff;      state <= CMD_DONE;
   end
   else begin
      padr++;
      state<=DATA_BYTE;
   end
end
LED_RIGHT_SHIFT: begin
//padr++;
if (data_bytes==0) begin
led <= {led[0],led[15:1]};      state <= CMD_DONE;
   end
   else begin
      padr++;
      state<=DATA_BYTE;
   end
end
LED_LEFT_SHIFT: begin
//padr++;
if (data_bytes==0) begin
led <= {led[14:0],led[15]};      state <= CMD_DONE;
   end
   else begin
      padr++;
      state<=DATA_BYTE;
   end
end
LED_SET: begin
//padr++;
if (data_bytes==0) begin
led <= data_in;      state <= CMD_DONE;
   end
   else begin
      padr++;
      state<=DATA_BYTE;
   end
end
LED_NOT: begin
//padr++;
if (data_bytes==0) begin
led <= ~led;      state <= CMD_DONE;
   end
   else begin
      padr++;
      state<=DATA_BYTE;
   end
end
LED_SET_B: begin
//padr++;
if (data_bytes==0) begin
led[7:0] <= _B;      state <= CMD_DONE;
   end
   else begin
      padr++;
      state<=DATA_BYTE;
   end
end
LED_LOAD_B: begin
//padr++;
if (data_bytes==0) begin
_B  <= data_in[7:0];      state <= CMD_DONE;
   end
   else begin
      padr++;
      state<=DATA_BYTE;
   end
end
