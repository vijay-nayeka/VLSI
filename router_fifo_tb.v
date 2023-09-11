module router_fifo_tb();

reg clock,resetn,write_enb,soft_reset,read_enb,lfd_state;
reg [7:0]data_in;
wire [7:0]data_out;
wire empty,full;
integer i,k;
router_fifo dut(clock,resetn,write_enb,soft_reset,read_enb,data_in,lfd_state,empty,data_out,full);

always
begin
clock=1'b0;
#10;
clock=~clock;
#10;
end

task initialize;
begin
{clock,resetn,soft_reset,write_enb,read_enb}=0;
end
endtask

task rst;
begin
@(negedge clock)
resetn=1'b0;
@(negedge clock)
resetn=1'b1;
end
endtask

task softreset;
begin
@(negedge clock)
soft_reset=1'b1;
@(negedge clock)
soft_reset=1'b0;
end
endtask

////task writing into memory location
task write_fifo();
reg [7:0]payload_data,parity,header;
reg [7:0]payload_len;
reg [1:0]addr;
begin
@(negedge clock)
payload_len=6'd14;
addr=2'b01;
header={payload_len,addr};
data_in=header;
$display("datain=%b is payload  last two are addr",data_in); 
lfd_state=1'b1;
write_enb=1'b1;
for(k=0;k<payload_len;k=k+1)
begin
@(negedge clock)
lfd_state=1'b0;
payload_data={$random}%256;///////random data for 8 bits one
data_in=payload_data;
end
@(negedge clock)
lfd_state=1'b0;
parity={$random}%256;
data_in=parity;
$display("last data_in =%b ,is parity bit",data_in);
end
endtask

//////task for reading from memory location
task read_fifo();
begin
@(negedge clock)
write_enb=1'b0;
read_enb=1'b1;
end
endtask

///task for delay
task delay();
begin
#50;
end
endtask

///process to call the task from writing & reading of memory location
initial
begin
initialize;
delay();
rst;
softreset;
write_fifo();
for(i=0;i<17;i=i+1)
read_fifo();
delay();
read_enb=1'b0;
$finish;
end

initial
$monitor("datain=%b,\t dataout=%b",data_in,data_out);
endmodule

