module router_fifo(clock,resetn,write_enb,soft_reset,read_enb,data_in,lfd_state,empty,data_out,full);

input [7:0]data_in;
output reg [7:0]data_out;
output empty,full;
input clock,resetn,write_enb,soft_reset,read_enb,lfd_state;


reg[8:0]mem[15:0];//9 bit data width one extra for header & 16 bit depth
reg [6:0]fifo_counter;
reg [4:0]wr_ptr,rd_ptr;
integer i;

///logic for implementing pointer
always@(posedge clock)
begin
if(!resetn)
begin
	wr_ptr<=5'b0;
	rd_ptr<=5'b0;
end
else if(soft_reset)
begin
	wr_ptr<=5'b0;
	rd_ptr<=5'b0;
end
else
	begin
		begin
		if(!full && write_enb)
			wr_ptr<=wr_ptr+1'b1;
		else
			wr_ptr<=wr_ptr;
		end
		begin
		if(!empty&&read_enb)
			rd_ptr<=rd_ptr+1'b1;
		else
			rd_ptr<=rd_ptr;
		end
	end
end

//////logic for counter
always@(posedge clock)
begin
if(!resetn)
	fifo_counter<=0;
else if(soft_reset)
	fifo_counter<=0;
else 
	begin
	if(read_enb &&!empty)
		begin
			if(mem[rd_ptr[3:0]][8]==1'b1)  
				fifo_counter<=mem[rd_ptr[3:0]][7:2]+1'b1; 
	
			else if(fifo_counter!=0)
				fifo_counter<=fifo_counter-1'b1;
		end
	else
		fifo_counter<=fifo_counter;
		
	end
	
end

///////////write operation
always@(posedge clock)
begin
if(!resetn)
begin
	for(i=0;i<16;i=i+1)
	mem[i]=0;
end
else if(soft_reset)
begin
	for(i=0;i<16;i=i+1)
	mem[i]=0;
end
else if(write_enb&&!full)
	{mem[wr_ptr[3:0]][8],mem[wr_ptr[3:0]][7:0]}<={lfd_state,data_in};

end

//////read operation
always@(posedge clock)
begin
if(!resetn)
	data_out<=0;
else if(soft_reset)
	data_out<=8'bz;
else
begin
	if(fifo_counter==0)
		data_out<=8'bz;
	else if(read_enb &&!empty)
		data_out<=mem[rd_ptr[3:0]];
	else
		data_out<=0;
end
end

assign empty=(wr_ptr==rd_ptr)?1'b1:1'b0;
assign full=(wr_ptr=={~rd_ptr[4],rd_ptr[3:0]})?1'b1:1'b0;

endmodule
	
