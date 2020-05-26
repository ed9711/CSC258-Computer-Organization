module final
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,
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

	
	wire [2:0]colour;
	assign colour = 3'b101;
	wire [7:0]datax;
	wire [7:0]datay;
	print_grid print1(.clk(CLOCK_50), .reset(KEY[0]), .datax(datax), .datay(datay));
	
	part2 p1(
		.CLOCK_50(CLOCK_50),	
        .KEY(KEY[3:0]),
        .x_in(datax), .y_in(datay), .colour_in(colour),
		.VGA_CLK(VGA_CLK),   						
		.VGA_HS(VGA_HS),							
		.VGA_VS(VGA_VS),							
		.VGA_BLANK_N(VGA_BLANK_N),						
		.VGA_SYNC_N(VGA_SYNC_N),						
		.VGA_R(VGA_R),   						
		.VGA_G(VGA_G),	 						
		.VGA_B(VGA_B)   						
	);
	
	
	
endmodule





module print_grid(
    input clk,
    input reset,
    output reg [7:0]datax,
	 output reg [7:0]datay
    );
	 reg [7:0]x = 8'b00011000;
	 reg [7:0]y = 8'b00001011;

	reg enable = 1'b1;
	reg enable1 = 1'b0;
	
	always @(posedge clk && (enable||enable1))
	begin
		if (!reset) begin
			x <= 8'b00011000;
			y <= 8'b00001011;
			end
		
		if (enable)
			begin
			x <= x + 8'b00000001;
			datax[7:0] <= x[7:0];
			datay[7:0] <= y[7:0];
			end
 
		if (x > 8'b10001000 && enable) begin
			x <= 8'b00011000;
			datax[7:0] <= x;
			y <= y + 8'b00001110;
			datay[7:0] <= y;
			
			end
		if (y > 8'b01101101 && enable)
			begin
			enable <= 1'b0;
			y <= 8'b00001011;
			datay[7:0] <= y;
			enable1 <= 1'b1;
			x <= 8'b00011000;
			end
			
		if (enable1)
			begin
			y <= y + 8'b00000001;
			datax[7:0] <= x[7:0];
			datay[7:0] <= y[7:0];
			end
			
		if (y > 8'b01101101 && enable1) begin
			y <= 8'b00001011;
			datax[7:0] <= y;
			x <= x + 8'b00001110;
			datay[7:0] <= x;
			
			end
			
		if (x > 8'b10001000 && enable1)
			begin
			enable1 <= 1'b0;
			x <= 8'b00011000;
			datay[7:0] <= x;
			end
	end
	
endmodule


    // current_state registers






// Part 2 skeleton

module rate_divider2(clk_in, clk_out, reset);
		input clk_in;
		input reset;
		output reg clk_out;
		reg [1:0]count_2;
		
		always @(posedge clk_in) 
		begin
			if(!reset)
				clk_out <= 1'b0;
			else
				begin
				clk_out <= !clk_out;
				end
		end
	
endmodule


module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        x_in, y_in, colour_in,
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
	input   [7:0]   x_in;
	input   [7:0]	 y_in;
	input   [2:0] 	 colour_in;
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
	wire [7:0] y;
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
		defparam VGA.RESOLUTION = "160*120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	// datapath d0(...);
	
	wire ld_x, ld_y, ld_c, alu_select, go;
	
	rate_divider2 r1(.clk_in(CLOCK_50), .clk_out(go), .reset(resetn));
	
	datapath d1(.data_inx(x_in[7:0]), 
					.data_iny(y_in[7:0]),
					.colour(colour_in[2:0]), 
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
    .go(go),
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
    
    localparam  S_LOAD_X        = 4'd0,
                S_LOAD_X_WAIT   = 4'd1,
                S_LOAD_Y        = 4'd2,
                S_LOAD_Y_WAIT   = 4'd3,
					 S_LOAD_C        = 4'd4,
                S_LOAD_C_WAIT   = 4'd5,
                S_CYCLE_0       = 4'd6,
					 S_CYCLE_1       = 4'd7;
					 
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
                S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_Y; // Loop in current state until go signal goes low
                S_LOAD_Y: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_Y; // Loop in current state until value is input
                S_LOAD_Y_WAIT: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_C; // Loop in current state until go signal goes low
                S_LOAD_C: next_state = go ? S_LOAD_C_WAIT : S_LOAD_C; // Loop in current state until value is input
                S_LOAD_C_WAIT: next_state = go ? S_LOAD_C_WAIT : S_CYCLE_0; // Loop in current state until go signal goes low
                S_CYCLE_0: next_state = S_CYCLE_1;
					 S_CYCLE_1: next_state = S_LOAD_X; // we will be done our two operations, start over after
            default:     next_state = S_LOAD_X;
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

        case (current_state)
            S_LOAD_X: begin
                ld_x = 1'b1;
					 plot = 1'b0;
                end
            S_LOAD_Y: begin
                ld_y = 1'b1;
					 plot = 1'b0;
                end
            S_LOAD_C: begin
                ld_c = 1'b1;
					 plot = 1'b0;
                end
            S_CYCLE_0: begin // Do B <- B * x 
                alu_select = 1'b1;
					 plot = 1'b0;
            end
				S_CYCLE_1: begin
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

module datapath(input [7:0]data_inx,
					input [7:0]data_iny,
					input [2:0]colour, 
					input reset, 
					input alu_select,
					input clk,
					input ld_x, ld_y, ld_c,
					output reg [7:0]xout, 
					output reg [7:0]yout, 
					output reg [2:0]colourout);
					
					
					// input registers
					reg [7:0] x;
					reg [7:0] y;
					reg [2:0] c;

    // output of the alu
    
    // Registers a, b, c, x with respective input logic
    always @ (posedge clk) begin
        if (!reset) begin
            y <= 8'b0;  
            x <= 8'b0;
				c <= 3'b0;
        end
        else begin
            if (ld_x)
                x <= data_inx; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if (ld_y)
                y <= data_iny; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if (ld_c)
                c <= colour;
        end
    end
 
    // Output result register
    always @ (posedge clk) begin
        if (!reset) begin
				xout <= 8'b0;
				yout <= 8'b0;
				colourout <= 3'b0;
				end 
				else 
            if(alu_select)
                begin
					 xout <= x;
						 yout <= y;
						 colourout <= c;
					 end
    end

    // The ALU input multiplexers
    

    // The ALU 
    
					

endmodule
