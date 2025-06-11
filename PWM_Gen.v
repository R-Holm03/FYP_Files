module PWM_Generator (
	input clk,
	input [7:0] DUTY_CYCLE,
	input [15:0] ADC,
	input [9:0] PWM_PERIOD, DEAD_TIME,
	output reg PWM_UP, PWM_DOWN, Complete, ADC_Test
);
	reg [9:0] counter = 10'd0;
	reg [17:0] up_time;
	reg [9:0] high_end;
	reg [17:0] product;
	reg [15:0] ADC_cycle;
	reg Fault = 0;
	reg next_UP, next_DOWN;
	
	always@(posedge clk)begin 
		
		next_UP <= 0;
		next_DOWN <= 0;
		
		if(!Fault)begin
			if(counter < PWM_PERIOD -1)begin
				counter <= counter + 1;
				Complete <= 0;
			end
			else begin
				counter <= 0;
				Complete <= 1;
				up_time <= (PWM_PERIOD * DUTY_CYCLE) >> 8;
				ADC_cycle <= ADC;
			end
			
			
			if(up_time > (DEAD_TIME / 2))
				high_end <= up_time - (DEAD_TIME/2);
			else
				high_end <= 9'd0;
			
			if((counter < high_end) && (counter >= (DEAD_TIME / 2)))
				next_UP <= 1;
			else next_UP <= 0;
					
			if((counter >= ((up_time) + (DEAD_TIME / 2))) && (counter < (PWM_PERIOD - (DEAD_TIME /2))))
				next_DOWN <= 1;
			else next_DOWN <= 0;
				
			if(16'd10 < ADC_cycle)begin
				ADC_Test <= 1;
			end		
			else 
				ADC_Test <= 0;
			
			PWM_UP <= next_UP;
			PWM_DOWN <= next_DOWN;
			
			if(next_UP && next_DOWN)begin
				Fault <= 1;
			end
		end
		else begin
			PWM_UP <= 0;
			PWM_DOWN <= 0;
		end
	end
	
endmodule 


