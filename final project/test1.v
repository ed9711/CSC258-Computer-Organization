// Etch-and-sketch

module test1
	(
		CLOCK_50,						//	On Board 50 MHz
		KEY,							//	Push Button[3:0]
		SW,							//	DPDT Switch[17:0]
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
	input [9:0] SW;//	Switches[0:0]
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
	wire [2:0]colour;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
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
	
	//print_grid print1(.clk(CLOCK_50), .reset(KEY[0]), .datax(x), .datay(y));
	print_chip print2(.clk(CLOCK_50), .reset(KEY[0]), .KEY(KEY[3:0]), .colour(colour), .datax(x), .datay(y));
	
	
	
	
	
	
	
endmodule





module print_chip(input clk,
    input reset,
	 input [3:0]KEY,
	 output reg [2:0]colour,
    output reg [7:0]datax,
	 output reg [6:0]datay);
	 
	 reg enable = 1'b0;
	 reg enable1 = 1'b0;
	 reg enable2 = 1'b0;

	reg [7:0]currCol = 8'b010001111;
	reg [7:0]col1 = 8'b010001111;
	reg [7:0]col2 = 8'b010001111 + 5'b01110;
	reg [7:0]col3 = 8'b010001111 + 5'b01110 + 5'b01110;
	reg [7:0]col4 = 8'b010001111 + 5'b01110 + 5'b01110 + 5'b01110;
	reg [7:0]col5 = 8'b010001111 + 5'b01110 + 5'b01110 + 5'b01110 + 5'b01110;
	reg [7:0]col6 = 8'b010001111 + 5'b01110 + 5'b01110 + 5'b01110 + 5'b01110 + 5'b01110;
	reg [7:0]col7 = 8'b010001111 + 5'b01110 + 5'b01110 + 5'b01110 + 5'b01110 + 5'b01110 + 5'b01110;
	reg [7:0]curry = 8'b01101101 - 3'b111;
	reg [6:0]y1 = 7'b1101101 - 3'b111;
	reg [6:0]y2 = 7'b1101101 - 3'b111;
	reg [6:0]y3 = 7'b1101101 - 3'b111;
	reg [6:0]y4 = 7'b1101101 - 3'b111;
	reg [6:0]y5 = 7'b1101101 - 3'b111;
	reg [6:0]y6 = 7'b1101101 - 3'b111;
	reg [6:0]y7 = 7'b1101101 - 3'b111;
	reg [2:0]c = 3'b111;
	
	
	always @(posedge clk)
		begin
		if (KEY[3] && enable)
		begin
			if (currCol == col1)
				begin	
				currCol <= col7;
				enable <= ~enable;
				end

			else
				begin
				currCol <= currCol - 5'b01110;
				enable <= ~enable;
				end
		end
		
			
		
		if (KEY[1] && enable2)
		begin 
			if (currCol == col7)
			begin
				currCol <= col1;
				enable2 <= ~enable2;
				end
			else
			begin
				currCol <= currCol + 5'b01110;
				enable2 <= ~enable2;
				end
		end
		
		if (KEY[1]==0)
			enable <= 1'b0;
		if (KEY[3]==0)
			enable <= 1'b0;
	end
		
	always @(posedge clk)
		begin
			
		if (KEY[2] & enable1)
			c <= !c;
		begin
			if(currCol == col1)
			begin
				curry <= y1;
				datax[7:0] <= col1[7:0];
				datay[6:0] <= curry[6:0];
				y1 <= y1 - 4'b1110;
				colour[2:0] <= c[2:0];
				end
				
			else if (currCol == col2)
			begin
				curry <= y2;
				datax[7:0] <= col2[7:0];
				datay[6:0] <= curry[6:0];
				y2 <= y2 - 4'b1110;
				colour[2:0] <= c[2:0];
				end
				
			else if(currCol == col3)
			begin
				curry <= y3;
				datax[7:0] <= col3[7:0];
				datay[6:0] <= curry[6:0];
				y3 <= y3 - 4'b1110;
				colour[2:0] <= c[2:0];
				end
				
			else if (currCol == col4)
			begin
				curry <= y4;
				datax[7:0] <= col4[7:0];
				datay[6:0] <= curry[6:0];
				y4 <= y4 - 4'b1110;
				colour[2:0] <= c[2:0];
				end
				
			else if(currCol == col5)
			begin
				curry <= y5;
				datax[7:0] <= col5[7:0];
				datay[6:0] <= curry[6:0];
				y5 <= y5 - 4'b1110;
				colour[2:0] <= c[2:0];
				end
				
			else if (currCol == col6)
			begin
				curry <= y6;
				datax[7:0] <= col6[7:0];
				datay[6:0] <= curry[6:0];
				y6 <= y6 - 4'b1110;
				colour[2:0] <= c[2:0];
				end
				
			else if(currCol == col7)
			begin
				curry <= y7;
				datax[7:0] <= col7[7:0];
				datay[6:0] <= curry[6:0];
				y7 <= y7 - 4'b1110;
				colour[2:0] <= c[2:0];
				end
				enable1 <= 1'b1;
			end
			if (KEY[2] == 1)
				enable1 <= 1'b0;	
		end
		
		
//		print_chip pc1(
//				.CLOCK_50(CLOCK_50),
//				.KEY(KEY[3:0]),
//				.x(currCol), .y(curry), .colour(c),
//				.VGA_CLK(VGA_CLK),
//				.VGA_HS(VGA_HS),
//				.VGA_VS(VGA_VS),
//				.VGA_BLANK_N(VGA_BLANK_N),	
//				.VGA_SYNC_N(VGA_SYNC_N),
//				.VGA_R(VGA_R), 
//				.VGA_G(VGA_G),
//				.VGA_B(VGA_B));

endmodule
