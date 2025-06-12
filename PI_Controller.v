module PI_Controller (
	input wire [7:0] current_value[7:0],
	input wire [7:0] desired_value[7:0],
	input wire start,
	output wire [7:0] PI_result[7:0]
);
	
	parameter [7:0] Kp = 8'd2; 
	parameter [7:0] Ki = 8'd2; 
	
	
	reg signed [8:0] error;
	reg signed integal;
	
	always@(posedge clk) begin 
		error <= $signed(desired_value) - $signed(current_value);
		
		integral <= integral + error;
		
		PI_result <= (Kp*error) + (Ki*integral);
	end
	
endmodule


		
		
	
