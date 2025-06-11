module ADC_Communicator (
	input clk, CONVERT,
	output reg WR, DONE
);
		reg [2:0] counter = 5'd0;
		reg counting = 1'b0;
		
		always@(posedge clk)begin 
			if(CONVERT == 1 && !counting)begin  
				counting <= 1'b1;
				counter <= 5'd20;
			end
			if(counting)begin
				WR <= 1'b0;
				if (counter > 0)
					counter <= counter - 1;
				else begin
					WR <= 1'b1;
					counting <= 1'b0;
					DONE <= 1'b1;
				end
			end
			else begin
				WR <= 1'b1;
				DONE <= 1'b0;
			end
		end
		
endmodule 

