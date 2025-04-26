`timescale 1ns / 1ps
module transmitter_controller(input logic clk_in,input logic reset,input logic [1:0]S,input logic Load,input [7:0]data_board,output logic ser_out,output logic check=1'b0,output logic status);
logic [3:0]state=4'b0000;
logic transmit;
//logic [7:0]data_1=8'b010101010;
logic clk_out;
logic run=1'b1;
logic [7:0]data_1;
baud_rate_selector s_1(.clk_in(clk_in),.reset(reset),.S(S),.clk_out(clk_out));
 //clock_divider m_9(.clk_in,reset,clk_t,000_000_100);
  logic [1:0]a;
always_ff @(posedge clk_out)
begin
//if (run)
//begin
      case(state)
      4'b0000: begin  ser_out=1'b1;  if(transmit)  state=4'b0001;    else state=4'b0000; end 
      4'b0001: begin  ser_out=1'b0;  state=4'b0010; end
      4'b0010: begin  ser_out=data_1[7];   state=4'b0011;  end
      4'b0011: begin  ser_out=data_1[6];   state=4'b0100; end
      4'b0100: begin  ser_out=data_1[5];   state=4'b0101; end
      4'b0101: begin  ser_out=data_1[4];   state=4'b0110; end
      4'b0110: begin  ser_out=data_1[3];   state=4'b0111; end
      4'b0111: begin  ser_out=data_1[2];   state=4'b1000;  end
      4'b1000: begin  ser_out=data_1[1];   state=4'b1001; end
      4'b1001: begin  ser_out=data_1[0];   state=4'b1010; end
      4'b1010: begin  ser_out=1'b1;  state=4'b0000; end
      default: begin  ser_out=1'b1; state=4'b0000;  end
      endcase
      end
      assign status=(state==4'b000)?(1'b1):(1'b0);
// end
//  always_ff @(posedge clk_t)
//begin 
//          if(Load==1'b1&&state==4'b0000) begin  data_1=data_board; run=1'b0;transmit =1'b1; a=2'b00;end  
//          else if(!Load&&!run&&a==2'd0) begin transmit =1'b1;run=1'b1;  a=2'd1; end
//          else if(!Load&&a==2'd1&&state==4'b0000&&!run) begin   run=1'b1; transmit =1'b0;a=2'b11;  end
         
//end
      
 
 always_ff @(posedge clk_out) 
begin
      case(state)
      4'b0000: begin  if(Load) begin data_1=data_board; a=1'b1; end  else begin transmit =1'b1;        if(a)begin transmit =1'b1;a=1'b0; end else begin transmit =1'b0;  end                      end       end
      4'b0001: begin  end
      4'b0010: begin    end
      4'b0011: begin   end
      4'b0100: begin   end
      4'b0101: begin   end
      4'b0110: begin   end
      4'b0111: begin    end
      4'b1000: begin   end
      4'b1001: begin   end
      4'b1010: begin  end
      default: begin    end
      endcase
end
 
 always_ff @(posedge clk_out) 
begin
     check=~check;
end
 
 
      
endmodule




