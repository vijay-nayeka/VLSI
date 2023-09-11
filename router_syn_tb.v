module router_syn_tb();

reg [1:0]data_in;
reg detect_add,write_enb_reg,clock,resetn,read_enb_0,read_enb_1,read_enb_2,full_0,full_1,full_2,empty_0,empty_1,empty_2;

wire [2:0]write_enb;
wire fifo_full,soft_reset_0,soft_reset_1,soft_reset_2,vld_out_0,vld_out_1,vld_out_2;

parameter T=20;

router_syn dut(detect_add,data_in,write_enb_reg,clock,resetn,vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);

//clock generation
always
begin
clock=1'b0;
#(T/2);
clock=1'b1;
#(T/2);
end

/////////////////initialize task
task initialize;
begin
{resetn,write_enb_reg,detect_add,data_in}=0;
{read_enb_0,read_enb_1,read_enb_2}=1;
{empty_0,empty_1,empty_2}=3'b111;
{full_0,full_1,full_2}=0;
end
endtask

///////////reset task
task rst;
begin
@(negedge clock)
resetn=1'b0;
@(negedge clock)
resetn=1'b1;
end
endtask

//////////////data_in task
task dataip(input[1:0]i);
begin
@(negedge clock)
data_in=i;
end
endtask

initial
begin
initialize;
rst;
dataip(11);
detect_add=1'b1;
write_enb_reg=1'b1;
#T;
dataip(10);
full_0=1;
#T;
full_2=1;
#T; 
full_1=1;
#50;
empty_0=0;
#640;
read_enb_0=1'b0;
#40;
$finish;
end
endmodule



