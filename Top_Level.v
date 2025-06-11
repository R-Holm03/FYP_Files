module Top_Level (
	input clk, INT,
	input ADC0, ADC1, ADC2, ADC3, ADC4, ADC5, ADC6, ADC7,
	output PWM_UP, PWM_DOWN, 
	output reg PWM_50U, PWM_50D,
	output WR, 
	output duty_test
);

	// NEED TO SOLVE ISSUE ABOUT STARTING IN IDLE MODE AND SENDING CONVERT HIGH SOME HOW TO INITIATE COMMUNICATION 
	// could have an enable pin that is attached to a 3.3V supply or something
	
	parameter FREQ = 10'd800;
	parameter CURRENT = 16'd20;
	parameter DEAD_TIME = 10'd20;

	wire [15:0] ADC;
	
	assign ADC = {8'd0,ADC7, ADC6, ADC5, ADC4, ADC3, ADC2, ADC1, ADC0};
	
	reg READ = 1'b1;
	reg CONVERT = 1'b0;
	wire COMPLETE;
	wire [7:0] duty_cycle;
	reg Control = 1'b0;
	
	PWM_Generator Gen1 (
			.clk(clk), 
			.DUTY_CYCLE(duty_cycle),
			.ADC(ADC),
			.PWM_PERIOD(FREQ),
			.DEAD_TIME(DEAD_TIME),
			.PWM_UP(PWM_UP),
			.PWM_DOWN(PWM_DOWN),
			.Complete(COMPLETE),
			.ADC_Test(duty_test)
	);
	
	ADC_Communicator Com1 (
			.clk(clk),
			.CONVERT(CONVERT),
			.WR(WR),
			.DONE(DONE)
	);
	
	PI_Controller PI1 (
		.set_point(CURRENT),
		.current_point(ADC),
		.clk(clk),
		.Control(Control),
		.duty_cycle(duty_cycle)
	);
	
	parameter IDLE = 2'b00, WAIT = 2'b01, PROCESS = 2'b10;
	
	reg [1:0] state = IDLE;
	reg [1:0] next_state;
	reg [1:0] prev_state = PROCESS;
	
	
	always@(posedge clk)begin 
		prev_state <= state;
		state <= next_state;
	end
	
	always@(posedge clk)begin 
		CONVERT <= 1'b0;
		Control <= 1'b0;
		if(state == IDLE && prev_state != IDLE)begin
			CONVERT <= 1'b1;
		end
		if(state == PROCESS && prev_state != PROCESS)begin 
			Control <= 1'b1;
		end
	end
		
	
	always@(*)begin 
		next_state = state;
	
		case(state)
			IDLE: begin 
				if(DONE)
					next_state = WAIT;
			end
			
			WAIT: begin 
				if(INT == 1'b0)
					next_state = PROCESS;
			end
			
			PROCESS: begin 
				if(COMPLETE)
					next_state = IDLE;
			end
			
			default: next_state = IDLE;
		endcase
	end	
	
	
	parameter PWM_PERIOD = 12'd800;
	
	reg [11:0] counter = 12'd0;
	
	always@(posedge clk)begin 
		if(counter < PWM_PERIOD -1)begin
			counter <= counter + 1;
		end
		else begin
			counter <= 0;
		end
		
		if((counter < ((PWM_PERIOD / 2)-(DEAD_TIME/2))) && (counter >= (DEAD_TIME / 2)))
			PWM_50U <= 1;
		else PWM_50U <= 0;
				
		if((counter >= ((PWM_PERIOD / 2) + (DEAD_TIME / 2))) && (counter < (PWM_PERIOD - (DEAD_TIME /2))))
			PWM_50D <= 1;
		else PWM_50D <= 0;
	end

endmodule


