// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	// datapath d0(...);
	
	wire ld_x, ld_y, ld_c, alu_select;
	
	datapath d1(.data_in(SW[6:0]), 
					.colour(SW[9:7]), 
					.reset(resetn), 
					.alu_select(alu_select),
					.clk(CLOCK_50),
					.ld_x(ld_x), 
					.ld_y(ld_y), 
					.ld_c(ld_c),
					.xout(x), 
					.yout(y), 
					.colourout(colour));


    // Instansiate FSM control
    // control c0(...);
	 
	 control c1(
    .clk(CLOCK_50),
    .reset(resetn),
    .go(~KEY[1]),
    .ld_y(ld_y),.ld_x(ld_x),.ld_c(ld_c),
	 .plot(writeEn),
    .alu_select(alu_select)
    );

    
endmodule

module control(
    input clk,
    input reset,
    input go,
    output reg  ld_y, ld_x, ld_c,
    output reg  plot,
    output reg alu_select
    );

    reg [3:0] current_state, next_state; 
    
    localparam  LOAD_DATA	= 4'd0,
		DRAW_COL1	= 4'd1,
		DRAW_COL2	= 4'd2,
		DRAW_COL3	= 4'd3,
		DRAW_COL4	= 4'd4,
		DRAW_COL5	= 4'd5,
		DRAW_COL6	= 4'd6,
		DRAW_COL7	= 4'd7,
		DRAW_COL8	= 4'd8,

		DRAW_ROW1	= 4'd9,
		DRAW_ROW2	= 4'd10,
		DRAW_ROW3	= 4'd11,
		DRAW_ROW4	= 4'd12,
		DRAW_ROW5	= 4'd13,
		DRAW_ROW6	= 4'd14,
		DRAW_ROW6	= 4'd15;
		//more to come

					 
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
		LOAD_DATA: next_state = DRAW_COL1;
		DRAW_COL1: next_state = DRAW_COL2;
		DRAW_COL2: next_state = DRAW_COL3;
		DRAW_COL3: next_state = DRAW_COL4;
		DRAW_COL4: next_state = DRAW_COL5;
		DRAW_COL5: next_state = DRAW_COL6;
		DRAW_COL6: next_state = DRAW_COL7;
		DRAW_COL7: next_state = DRAW_COL8;
		DRAW_COL8: next_state = LOAD_DATA;

		LOAD_DATA: next_state = DRAW_ROW1;
		
		DRAW_ROW1: next_state = DRAW_ROW2;
		DRAW_ROW2: next_state = DRAW_ROW3;
		DRAW_ROW3: next_state = DRAW_ROW4;
		DRAW_ROW4: next_state = DRAW_ROW5;
		DRAW_ROW5: next_state = DRAW_ROW6;
		DRAW_ROW6: next_state = DRAW_ROW7;
		DRAW_ROW7: next_state = //DRAW_FIRST_CHIP;

            default:     next_state = LOAD_DATA;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        plot = 1'b0;
        ld_x = 1'b0;
        ld_y = 1'b0;
        ld_c = 1'b0;
        alu_select = 1'b0;
	x_plus = 1'b0;
	y_plus = 1'b0;
	counter = 1'd0;

        case (current_state)
            LOAD_DATA: begin
                ld_x = 1'b1;
		ld_y = 1'b1;
		ld_c = 1'b1;
					 plot = 1'b1;
                end
            DRAW_COL1: begin
                alu_select = 1'b1;
		x_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end
            DRAW_COL2: begin
                alu_select = 1'b1;
		x_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end
            DRAW_COL3: begin
                alu_select = 1'b1;
		x_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end
	    DRAW_COL4: begin
                alu_select = 1'b1;
		x_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end
	    DRAW_COL5: begin
                alu_select = 1'b1;
		x_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end
	    DRAW_COL6: begin
                alu_select = 1'b1;
		x_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end
	    DRAW_COL7: begin
                alu_select = 1'b1;
		x_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end
	    DRAW_COL8: begin
                alu_select = 1'b1;
		x_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end	


	    DRAW_ROW1: begin
                alu_select = 1'b0;
		y_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end
            DRAW_ROW2: begin
                alu_select = 1'b0;
		y_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end
	    DRAW_ROW3: begin
                alu_select = 1'b0;
		y_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end
	    DRAW_ROW4: begin
                alu_select = 1'b0;
		y_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end
	    DRAW_ROW5: begin
                alu_select = 1'b0;
		y_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end
	    DRAW_ROW6: begin
                alu_select = 1'b0;
		y_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end
	    DRAW_ROW7: begin
                alu_select = 1'b0;
		y_plus = 1'b1;
		counter = 1'd1;
					 plot = 1'b1;
                end	
	
				
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!reset)
            current_state <= S_LOAD_X;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module datapath(input [6:0]data_in, 
					input [2:0]colour, 
					input reset, 
					input alu_select,
					input clk,
					input ld_x, ld_y, ld_c,
					output reg [7:0]xout, 
					output reg [6:0]yout, 
					output reg [2:0]colourout);
					
					
					// input registers
					reg [7:0] x;
					reg [6:0] y;
					reg [2:0] c;
					reg [1:0] counter;

    // output of the alu
    
    // Registers a, b, c, x with respective input logic
    always @ (posedge clk) begin
        if (!reset) begin
            y <= 7'd0;  
            x <= 8'd0;
				c <= 3'd0;
        end
        else begin
            if (ld_x)
                x <= {1'd0, data_in}; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if (ld_y)
                y <= data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if (ld_c)
                c <= colour;
        end
    end
 
    // Output result register
    always @ (posedge clk) begin
        if (!reset) begin
				xout <= 8'd0;
				yout <= 7'd0;
				colourout <= 3'd0;
				end 
				else 
            if(alu_select && counter < 36)
                begin
					 xout <= x;
						 yout <= y;
						 colourout <= c;
					 counter <= counter + 1;
					 end
	    if(x_plus)
		begin
			x <= x + 4;
		end
	    if(y_plus)
		begin
			y <= y + 4;
    end

    // The ALU input multiplexers
    always @(*)
    begin
	case (alu_select)
	    1'b0:
		
	    1'b1:
		

    // The ALU 
    always @(*)
    begin : ALU
	case (plot)
	    0: begin
		alu_out = 1'b0
	    1: begin
		alu_out = 1'b1
		    

					

endmodule
