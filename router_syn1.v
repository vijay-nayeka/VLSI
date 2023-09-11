module router_syn(detect_add,data_in,write_enb_reg,clock,resetn,vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);
input [1:0]data_in;
output reg [2:0]write_enb;
input detect_add,clock,resetn,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2;
output reg fifo_full,soft_reset_0,soft_reset_1,soft_reset_2;
output vld_out_0,vld_out_1,vld_out_2;

reg [1:0]int_addr_reg;
reg [4:0]counter0,counter1,counter2;

////logic for latching address
always@(posedge clock)
begin
if(!resetn)
	int_addr_reg<=2'b11;
else if(detect_add)
	int_addr_reg<=data_in;
else
	int_addr_reg<=int_addr_reg;
end

/////valid out
assign vld_out_0=!empty_0;
assign vld_out_1=!empty_1;
assign vld_out_2=!empty_2;


/////write enable logic
always@(*)
begin
if(!resetn)
write_enb=3'b0;
else if(write_enb_reg)
	begin
		case(int_addr_reg)
			2'b00:write_enb=3'b001;
			2'b01:write_enb=3'b010;
			2'b10:write_enb=3'b100;
			default: write_enb=3'b000;
		endcase
	end
else
write_enb=3'b0;
end


////////fifo full

always@(*)
begin
	if(!resetn)
		fifo_full=1'b0;
	else
		begin
			case(int_addr_reg)
				2'b00:fifo_full<=full_0;
				2'b01:fifo_full<=full_1;
				2'b10:fifo_full<=full_2;
				default:fifo_full<=0;
			endcase
		end
end	
		
///////soft_reset


always@(posedge clock)
	begin
		if(!resetn)
			counter0<=5'b0;
		else if(vld_out_0)
			begin
				if(!read_enb_0)
					begin
						if(counter0==5'b11110)	
							begin
								soft_reset_0<=1'b1;
								counter0<=1'b0;
							end
						else
							begin
								counter0<=counter0+1'b1;
								soft_reset_0<=1'b0;
							end
					end
				else counter0<=5'd0;
			end
		else counter0<=5'd0;
	end
	
always@(posedge clock)
	begin
		if(!resetn)
			counter1<=5'b0;
		else if(vld_out_1)
			begin
				if(!read_enb_1)
					begin
						if(counter1==5'b11110)	
							begin
								soft_reset_1<=1'b1;
								counter1<=1'b0;
							end
						else
							begin
								counter1<=counter1+1'b1;
								soft_reset_1<=1'b0;
							end
					end
				else counter1<=5'd0;
			end
		else counter1<=5'd0;
	end
	
always@(posedge clock)
	begin
		if(!resetn)
			counter2<=5'b0;
		else if(vld_out_2)
			begin
				if(!read_enb_2)
					begin
						if(counter2==5'b11110)	
							begin
								soft_reset_2<=1'b1;
								counter2<=1'b0;
							end
						else
							begin
								counter2<=counter2+1'b1;
								soft_reset_2<=1'b0;
							end
					end
				else counter2<=5'd0;
			end
		else counter2<=5'd0;
	end
	
	
endmodule