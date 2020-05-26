// Etch-and-sketch

module test
	(
		CLOCK_50,						//	On Board 50 MHz
		KEY,							//	Push Button[3:0]
		SW,								//	DPDT Switch[17:0]
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;					//	Button[3:0]
	input	[0:0]	SW;						//	Switches[0:0]
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the color, x, y and writeEn wires that are inputs to the controller.

	//wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(3'b111),
			.x(x),
			.y(y),
			.plot(1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,color and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	print_grid print1(.clk(CLOCK_50), .reset(KEY[0]), .datax(x), .datay(y));
	//print_chip print2(.clk(CLOCK_50), .reset(KEY[0]), .KEY(KEY[3:0]), .colour(colour), .datax(x), .datay(y));
	
//	test1 t1(
//				.CLOCK_50(CLOCK_50),
//				.KEY(KEY[3:0]),
//				.VGA_CLK(VGA_CLK),
//				.VGA_HS(VGA_HS),
//				.VGA_VS(VGA_VS),
//				.VGA_BLANK(VGA_BLANK),	
//				.VGA_SYNC(VGA_SYNC),
//				.VGA_R(VGA_R), 
//				.VGA_G(VGA_G),
//				.VGA_B(VGA_B));
	
	
	
	
	
	
	
endmodule


module print_grid(
    input clk,
    input reset,
    output reg [7:0]datax,
	 output reg [6:0]datay
    );
	 reg [7:0]x = 8'b00011000;
	 reg [6:0]y = 7'b0001011;

	reg enable = 1'b1;
	reg enable1 = 1'b0;
	
	always @(posedge clk && (enable||enable1))
	begin
		if (!reset) begin
			x <= 8'b00011000;
			y <= 7'b0001011;
			end
		
		if (enable)
			begin
			x <= x + 8'b00000001;
			datax[7:0] <= x[7:0];
			datay[6:0] <= y[6:0];
			end
 
		if (x > 8'b10001000 && enable) begin
			x <= 8'b00011000;
			datax[7:0] <= x;
			y <= y + 7'b0001110;
			datay[6:0] <= y;
			
			end
		if (y > 7'b1101101 && enable)
			begin
			enable <= 1'b0;
			y <= 7'b0001011;
			datay[6:0] <= y;
			enable1 <= 1'b1;
			x <= 8'b00011000;
			end
			
		if (enable1)
			begin
			y <= y + 7'b0000001;
			datax[7:0] <= x[7:0];
			datay[6:0] <= y[6:0];
			end
			
		if (y > 7'b1101101 && enable1) begin
			y <= 7'b0001011;
			datay[6:0] <= y;
			x <= x + 8'b00001110;
			datax[7:0] <= x;
			
			end
			
		if (x > 8'b10001000 && enable1)
			begin
			enable1 <= 1'b0;
			x <= 8'b00011000;
			datax[7:0] <= x;
			end
	end
	
endmodule
