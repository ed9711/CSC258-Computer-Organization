module connect4(
		CLOCK_50,						//	On Board 50 MHz
		KEY,							//	Push Button[3:0]
		SW,								//	DPDT Switch[17:0]
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,								//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);
	
	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;					//	Button[3:0]
	input	[9:0]	SW;						//	Switches[0:0]
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[3];
	
	// Create the color, x, y and writeEn wires that are inputs to the controller.

	//wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire [2:0]colour;

	
//	vga_adapter VGA(
//			.resetn(resetn),
//			.clock(CLOCK_50),
//			.colour(colour),
//			.x(x),
//			.y(y),
//			.plot(writeEn),
//			/* Signals for the DAC to drive the monitor. */
//			.VGA_R(VGA_R),
//			.VGA_G(VGA_G),
//			.VGA_B(VGA_B),
//			.VGA_HS(VGA_HS),
//			.VGA_VS(VGA_VS),
//			.VGA_BLANK(VGA_BLANK_N),
//			.VGA_SYNC(VGA_SYNC_N),
//			.VGA_CLK(VGA_CLK));
//		defparam VGA.RESOLUTION = "160x120";
//		defparam VGA.MONOCHROME = "FALSE";
//		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1; //can change to up to 7
//		defparam VGA.BACKGROUND_IMAGE = "black.mif";

		wire inable, ld_col, check, delete, start, grid, del, checkwin;
		wire [1:0]ending;
		//wire [2:0]xcheck, ycheck;
		wire [1:0]win;
		//assign win = 2'b00;
		
	//wincheck w1(.x(xcheck), .y(ycheck), .colour(colour), .win(win));
	
	datapath d1(
			 .clk(CLOCK_50),
			 .columns(SW[6:0]), //SW[6:0]
			 .resetn(resetn),
			 .inable(inable), 
			 .ld_col(ld_col),
			 .check(check),
			 .delete(delete),
			 .checkwin(checkwin),
			 .ending(ending[1:0]), 
			 .start(start),
			 .colour(colour[2:0]),
			 .datax(x),
			 .datay(y),
			 .grid(grid),
			 .del(del),
			 //.xcheck(xcheck[2:0]),
			 //.ycheck(ycheck[2:0]),
			 .win(win)
			 );
			 
			 
	control c1(
    .clk(CLOCK_50),
    .reset(resetn),
    .go(KEY[0]),
	 .win(win[1:0]), //1 decimal
	 .draw(KEY[1]),
	 .restart(KEY[2]),
	 .grid(grid),
	 .del(del),
    .colour(colour),
    .plot(writeEn),
	 .inable(inable),
	 .ld_col(ld_col),
	 .delete(delete),
	 .check(check),
	 .ending(ending[1:0]),
	 .start(start),
	 .checkwin(checkwin)
    );

endmodule 



module control(
    input clk,
    input reset,
    input go,
	 input [1:0]win, //1 decimal
	 input draw,
	 input restart,
	 input grid,
	 input del,
    output reg  [2:0]colour,
    output reg  plot,
	 output reg  inable,
	 output reg  ld_col,
	 output reg  delete,
	 output reg  check,
	 output reg  [1:0]ending,
	 output reg  start,
	 output reg checkwin
    );
	 
    reg [3:0] current_state, next_state;

    
    localparam  START        = 4'd0,
                DRAW_GRID   = 4'd1,
                PLAYER1        = 4'd2,
                PLAYER2   = 4'd3,
					 CHECK1        = 4'd4,
                CHECK2   = 4'd5,
                P1WIN       = 4'd6,
					 DELETE	=4'd7,
					 P2WIN	=4'd8,
					 TIE 		=4'd9,
					 CHECK1_WAIT = 4'd10,
					 CHECK2_WAIT = 4'd11;
					 
	
	 always@(*)
    begin: state_table 
            case (current_state)
                START: next_state = go ? START : DRAW_GRID; // Loop in current state until value is input
                DRAW_GRID: begin
					 if (grid)
						next_state = PLAYER1;
					 else if (!grid)
						next_state = DRAW_GRID; // Loop in current state until go signal goes low
					 if (!restart)
						next_state = DELETE;
                end
					 PLAYER1: begin
					 if (draw)
						next_state = PLAYER1;
					 else if (!draw)
						next_state = CHECK1; // Loop in current state until value is input
					 if (!restart)
						next_state = DELETE;
                end
                CHECK1: begin
					 if (win == 0)
						next_state = CHECK1_WAIT;
					 else if (win == 1)
						next_state = P2WIN; // win might be too slow for current state, might affect next check
 					 else if (win == 2)
						next_state = TIE;// Loop in current state until go signal goes low
					 end
					 
					 CHECK1_WAIT: begin
					 if (draw)
						next_state = PLAYER2;
					 else if (!draw)
						next_state = CHECK1_WAIT; // Loop in current state until value is input
					 if (!restart)
						next_state = DELETE;
                end
                PLAYER2: begin
					 if (draw)
						next_state = PLAYER2;
					 else if (!draw)
						next_state = CHECK2; // Loop in current state until value is input
					 if (!restart)
						next_state = DELETE;
                end
					 
                CHECK2: begin
					 if (win == 0)
						next_state = CHECK2_WAIT;
					 else if (win == 1)
						next_state = P1WIN;
					 else if (win == 2)
						next_state = TIE;// Loop in current state until go signal goes low
					 end
					 
					 CHECK2_WAIT: begin
					 if (draw)
						next_state = PLAYER1;
					 else if (!draw)
						next_state = CHECK2_WAIT; // Loop in current state until value is input
					 if (!restart)
						next_state = DELETE;
                end
					 
                P1WIN: next_state = restart ? P1WIN : DELETE; // Loop in current state until value is input
					 P2WIN: next_state = restart ? P2WIN : DELETE;
					 TIE: next_state = restart ? TIE : DELETE;
                DELETE: next_state = del ? DRAW_GRID : DELETE; // Loop in current state until go signal goes low
            default:     next_state = START;
        endcase
    end // state_table
	 
	 
	 always @(*)
    begin: enable_signals
        // By default make all our signals 0
		  plot = 1'b0;
		  inable = 1'b0;
		  colour = 3'b000;
        ld_col = 1'b0;
		  delete = 1'b0;
		  check = 1'b0;
		  ending = 1'b00;
		  start = 1'b0;
		  checkwin = 1'b0;

        case (current_state)
            START: begin
                plot = 1'b1;
					 start = 1'b1;
                end
            DRAW_GRID: begin
                plot = 1'b1;
					 inable = 1'b1;
					 colour = 3'b111;
                end
            PLAYER1: begin
					 ld_col = 1'b1;
                end
            PLAYER2: begin
					ld_col = 1'b1;
                end
            CHECK1: begin  
                plot = 1'b1;
					 colour = 3'b110;
					 check = 1'b1;
					 end
            CHECK2: begin  
                plot = 1'b1;
					 colour = 3'b001;
					 check = 1'b1;
					 end
				P1WIN: begin 
                plot = 1'b1;
					 colour = 3'b110;
					 ending = 2'b01; //print win in 110
            end
				P2WIN: begin 
                plot = 1'b1;
					 colour = 3'b001;
					 ending = 2'b10; //print win in 001
            end
				TIE: begin 
                plot = 1'b1;
					 colour = 3'b111;
					 ending = 2'b11; //print tie in 111
            end
				DELETE: begin
                plot = 1'b1;
					 delete = 1'b1;
					 colour = 3'b000;
					 start = 1'b1;
            end
				
				CHECK1_WAIT: begin  
					 colour = 3'b110;
					 checkwin = 1'b1;
					 end
            CHECK2_WAIT: begin  
					 colour = 3'b001;
					 checkwin = 1'b1;
					 end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
	 //wire new_clock = 1'b0;
	 //rate_divider2 r1(.clk_in(clk), .clk_out(new_clock), .reset(resetn)); //might be problem
	 
	 always@(posedge clk)
    begin: state_FFs
        if(!reset)
            current_state <= START;
        else
            current_state <= next_state;
    end // state_FFS
					 
					 
endmodule



module datapath(
    input clk,
	 input [6:0]columns, //SW[6:0]
    input resetn,
    input inable, 
    input ld_col,
    input check,
    input delete,
	 input checkwin,
	 input [1:0]ending, 
	 input start,
	 input [2:0]colour,
    output reg [7:0]datax,
	 output reg [6:0]datay,
	 output reg grid,
	 output reg del,
	 //output reg [2:0]xcheck,
	 //output reg [2:0]ycheck,
	 output reg [1:0]win
    );
	 
	reg [5:0]tie = 6'b0;
	reg [9:0] c = 0;
	integer i = 0;
	integer j = 0;
	initial win = 0;
    
	 reg [7:0]chip_x;
	 reg [6:0]curry= 7'b1011000;
	 reg [6:0]y1 = 7'b1011000;
	 reg [6:0]y2 = 7'b1011000;
	 reg [6:0]y3 = 7'b1011000;
	 reg [6:0]y4 = 7'b1011000;
	 reg [6:0]y5 = 7'b1011000;
	 reg [6:0]y6 = 7'b1011000;
	 reg [6:0]y7 = 7'b1011000;

	 reg [7:0]col1 = 8'b00011000 + 3'b111;
	 reg [7:0]col2 = 8'b00011000 + 3'b111 + 5'b01110;
	 reg [7:0]col3 = 8'b00011000 + 3'b111 + 5'b01110 + 5'b01110;
	 reg [7:0]col4 = 8'b00011000 + 3'b111 + 5'b01110 + 5'b01110 + 5'b01110;
	 reg [7:0]col5 = 8'b00011000 + 3'b111 + 5'b01110 + 5'b01110 + 5'b01110 + 5'b01110;
	 reg [7:0]col6 = 8'b00011000 + 3'b111 + 5'b01110 + 5'b01110 + 5'b01110 + 5'b01110 + 5'b01110;
	 reg [7:0]col7 = 8'b00011000 + 3'b111 + 5'b01110 + 5'b01110 + 5'b01110 + 5'b01110 + 5'b01110 + 5'b01110;
    // input registers
	 reg [7:0]x = 8'b00011000;
	 reg [6:0]y = 7'b0001011;
	 
	 
	 reg enable  = 1'b1;
	 reg enable1 = 1'b0;
	 
	 reg [7:0]x0 = 8'b00011000;
	 reg [6:0]y0 = 7'b0001011;
	 
	 reg enable2 = 1'b1;
	 
	 reg count = 1'd0;
	 reg count1 = 1'd0;
	 
	 reg enable3 = 1'b1;
	 
	 reg [2:0]xcheck;
	 reg [2:0]ycheck;
	 
	 reg [0:6] list1[0:5];
	 initial begin
	 for (i = 0; i < 6; i= i + 1)
	 begin
		list1[i] = 7'h0;
//{7'h0, 7'h0, 7'h0, 7'h0, 7'h0, 7'h0};
	end
end

reg [0:6] list2[0:5];
initial begin
	for (i = 0; i < 6; i= i + 1)
	begin
		list2[i] = 7'h0;
//{7'h0, 7'h0, 7'h0, 7'h0, 7'h0, 7'h0};
	end
end
	 
	 
	 //wire result; // output of check win function
	 
    
	 always @(posedge clk)//&& (enable||enable1))
		begin
			if (!resetn) begin
				x <= 8'b00011000;
				y <= 7'b0001011;
				x0 <= 8'b00011000;
				y0 <= 7'b0001011;
				enable1 <= 1'b0;
				curry <= 7'b1011000;
				y1 <= 7'b1011000;
				y2 <= 7'b1011000;
				y3 <= 7'b1011000;
				y4 <= 7'b1011000;
				y5 <= 7'b1011000;
				y6 <= 7'b1011000;
				y7 <= 7'b1011000;
				enable <= 1'b1;
				chip_x <= 8'b0;
				enable2 <= 1'b1;
				count <= 1'd0;
				count1 <= 1'd0;
				enable3 <= 1'b1;
				end
				
			if (start)
				begin
				grid <= 1'b0;
				del <= 1'b0;
				//defparam VGA.BACKGROUND_IMAGE = "start.mif";	
				end
			
			if (inable)
				begin
				if (enable)
					begin
					x <= x + 8'b00000001;
					datax[7:0] <= x[7:0];
					datay[6:0] <= y[6:0];
					end
		 
				if (x > 8'b10001000 - 4'b1110 && enable) begin
					x <= 8'b00011000;
					datax[7:0] <= x;
					y <= y + 7'b0001110;
					datay[6:0] <= y;
					
					end
				if (y > 7'b1101101 - 4'b1110 && enable)
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
					
				if (y > 7'b1101101 - 4'b1110 && enable1) begin
					y <= 7'b0001011;
					datay[6:0] <= y;
					x <= x + 8'b00001110;
					datax[7:0] <= x;
					
					end
					
				if (x > 8'b10001000 - 4'b1110 && enable1)
					begin
					enable1 <= 1'b0;
					x <= 8'b00011000;
					datax[7:0] <= x;
					grid <= 1'b1;
					del <= 1'b0;
					end
				end
			
			if (check)
				begin
				enable3 <= 1'b1;
				if (curry < 7'b0001011)
					begin
					datax[7:0] <= 8'b0;
					datay[6:0] <= 7'b0;
					end
				else
					begin
					datax[7:0] <= chip_x[7:0];
					datay[6:0] <= curry[6:0];
					if (chip_x[7:0] == col1[7:0])
						begin
						xcheck <= 3'b000;
						end
					else if (chip_x[7:0] == col2[7:0])
						begin
						xcheck <= 3'b001;
						end
					else if (chip_x[7:0] == col3[7:0])
						begin
						xcheck <= 3'b010;
						end
					else if (chip_x[7:0] == col4[7:0])
						begin
						xcheck <= 3'b011;
						end
					else if (chip_x[7:0] == col5[7:0])
						begin
						xcheck <= 3'b100;
						end
					else if (chip_x[7:0] == col6[7:0])
						begin
						xcheck <= 3'b101;
						end
					else if (chip_x[7:0] == col7[7:0])
						begin
						xcheck <= 3'b110;
						end
					
					if (curry[6:0] == 7'b1011000)
						begin
						ycheck <= 3'b101;
						end
					else if (curry[6:0] == 7'b1011000 - 4'b1110)
						begin
						ycheck <= 3'b100;
						end
					else if (curry[6:0] == 7'b1011000 - 4'b1110 - 4'b1110)
						begin
						ycheck <= 3'b011;
						end
					else if (curry[6:0] == 7'b1011000 - 4'b1110 - 4'b1110 - 4'b1110)
						begin
						ycheck <= 3'b010;
						end
					else if (curry[6:0] == 7'b1011000 - 4'b1110 - 4'b1110 - 4'b1110 - 4'b1110)
						begin
						ycheck <= 3'b001;
						end
					else if (curry[6:0] == 7'b1011000 - 4'b1110 - 4'b1110 - 4'b1110 - 4'b1110 - 4'b1110)
						begin
						ycheck <= 3'b000;
						end
					
					end
				//call check win function
				end
				
			if (delete)
				begin
					if (enable2)
						begin
						x0 <= x0 + 8'b00000001;
						datax[7:0] <= x0[7:0];
						datay[6:0] <= y0[6:0];
						end
					if (x0 > 8'b10001000 && enable2) begin
						x0 <= 8'b00011000;
						datax[7:0] <= x0;
						y0 <= y0 + 7'b0000001;
						datay[6:0] <= y0;
						end
					if (y0 > 7'b1101101 && enable2)
						begin
						enable2 <= 1'b0;
						y0 <= 7'b0001011;
						datay[6:0] <= y0;
						x0 <= 8'b00011000;
						count <= 1'd0;
						count1 <= 1'd0;
						del <= 1'b1;
						enable <= 1'b1;
						x <= 8'b00011000;
						y <= 7'b0001011;
						x0 <= 8'b00011000;
						y0 <= 7'b0001011;
						enable1 <= 1'b0;
						curry <= 7'b1101101 - 3'b111;
						y1 <= 7'b1011000;
						y2 <= 7'b1011000;
						y3 <= 7'b1011000;
						y4 <= 7'b1011000;
						y5 <= 7'b1011000;
						y6 <= 7'b1011000;
						y7 <= 7'b1011000;
						enable <= 1'b1;
						chip_x <= 8'b0;
						enable2 <= 1'b1;
						count <= 1'd0;
						count1 <= 1'd0;
						enable3 <= 1'b1;
						end
				end
			if (ending == 1 || ending == 2)
				begin
				if (count == 0)
					begin
						datax[7:0] <= 8'b01010000;
						datay[6:0] <= 7'b0111100;
					end
				else if (count == 1)
					begin
						datax[7:0] <= 8'b01010001;
						datay[6:0] <= 7'b0111101;
					end
				else if (count == 2)
					begin
						datax[7:0] <= 8'b01010010;
						datay[6:0] <= 7'b0111110;
					end
				else if (count == 3)
					begin
						datax[7:0] <= 8'b01001111;
						datay[6:0] <= 7'b0111011;
					end
				else if (count == 4)
					begin
						datax[7:0] <= 8'b01001110;
						datay[6:0] <= 7'b0111010;
					end
				count <= count + 1'd1;
				
				end
			else if (ending == 3)
				begin
				if (count1 == 0)
					begin
						datax[7:0] <= 8'b01010000;
						datay[6:0] <= 7'b0111100;
					end
				else if (count1 == 1)
					begin
						datax[7:0] <= 8'b01010001;
						datay[6:0] <= 7'b0111100;
					end
				else if (count1 == 2)
					begin
						datax[7:0] <= 8'b01010010;
						datay[6:0] <= 7'b0111100;
					end
				else if (count1 == 3)
					begin
						datax[7:0] <= 8'b01001111;
						datay[6:0] <= 7'b0111100;
					end
				else if (count1 == 4)
					begin
						datax[7:0] <= 8'b01001110;
						datay[6:0] <= 7'b0111100;
					end
				count1 <= count1 + 1'd1;
				end
			if(ld_col && enable3)
				begin
				case (columns)
					7'b0000001: begin
									chip_x[7:0] <= col1[7:0];
									curry[6:0] <= y1;
									if (y1 > 7'b0001011)
										begin
										y1 <= y1 - 4'b1110;
										end
									enable3 <= 1'b0;
									end
					
					7'b0000010: begin
									chip_x[7:0] <= col2[7:0];
									curry[6:0] <= y2;
									if (y2 > 7'b0001011)
										begin
										y2 <= y2 - 4'b1110;
										end
										enable3 <= 1'b0;
									end
					
					7'b0000100: begin
									chip_x[7:0] <= col3[7:0];
									curry[6:0] <= y3;
									if (y3 > 7'b0001011)
										begin
										y3 <= y3 - 4'b1110;
										end
										enable3 <= 1'b0;
									end
					
					7'b0001000: begin
									chip_x[7:0] <= col4[7:0];
									curry[6:0] <= y4;
									if (y4 > 7'b0001011)
										begin
										y4 <= y4 - 4'b1110;
										end
										enable3 <= 1'b0;
									end
					
					7'b0010000: begin
									chip_x[7:0] <= col5[7:0];
									curry[6:0] <= y5;
									if (y5 > 7'b0001011)
										begin
										y5 <= y5 - 4'b1110;
										end
										enable3 <= 1'b0;
									end
					
					7'b0100000: begin
									chip_x[7:0] <= col6[7:0];
									curry[6:0] <= y6;
									if (y6 > 7'b0001011)
										begin
										y6 <= y6 - 4'b1110;
										end
										enable3 <= 1'b0;
									end
					
					7'b1000000: begin
									chip_x[7:0] <= col7[7:0];
									curry[6:0] <= y7;
									if (y7 > 7'b0001011)
										begin
										y7 <= y7 - 4'b1110;
										end
										enable3 <= 1'b0;
									end
					default: begin
								chip_x[7:0] <= 8'b0;
								curry[6:0] <= 7'b0;
								end
					endcase
				end
				if (checkwin) begin
					if (colour == 3'b110)
					begin
						if(list1[ycheck][xcheck] == 1'b0)
						begin
						list1[ycheck][xcheck] = 1'b1;
						tie = tie + 1;
						end
					end
					else
					begin
						if(list2[ycheck][xcheck] == 1'b0)
						begin
						list2[ycheck][xcheck] = 1'b1;
						tie = tie + 1;
						end
					end
	
// Horizontal check
for (j = 0; j<4 ; j = j + 1) begin
   for (i = 0; i< 6; i = i + 1) begin
      if (list1[i][j] == 1'b1 && list1[i][j+1] == 1'b1 && list1[i][j+2] == 1'b1
		&& list1[i][j+3] == 1'b1)
          win = 2'b01;
	end
end

//Vertical check
for (i = 0; i< 3 ; i = i + 1 ) begin
    for (j = 0; j<7; j = j + 1) begin
            if (list1[i][j] == 1'b1 && list1[i+1][j] == 1'b1 && list1[i+2][j] == 1'b1 && 
				list1[i+3][j] == 1'b1)
                win = 2'b01;
	end
end
	
for (i = 3; i < 6; i = i + 1)
begin
	for (j=0; j< 4; j = j + 1)
	begin
		if (list1[i][j] == 1'b1 && list1[i-1][j+1] == 1'b1 
			&& list1[i-2][j+2] == 1'b1 && list1[i-3][j+3] == 1'b1)
                win = 2'b01;
	end
end

for (i = 3; i < 6; i= i + 1)
begin
	for (j = 3; j < 7; j = j + 1)
	begin
		if (list1[i][j] == 1'b1 && list1[i-1][j-1] == 1'b1 
			&& list1[i-2][j-2] == 1'b1 && list1[i-3][j-3] == 1'b1)
				win = 2'b01;
	end
end
					 
// Horizontal check
for (j = 0; j<4 ; j = j + 1) begin
   for (i = 0; i< 6; i = i + 1) begin
      if (list2[i][j] == 1'b1 && list2[i][j+1] == 1'b1 && list2[i][j+2] == 1'b1
		&& list2[i][j+3] == 1'b1)
          win = 2'b01;
	end
end

//Vertical check
for (i = 0; i< 3 ; i = i + 1) begin
    for (j = 0; j<7; j = j + 1) begin
            if (list2[i][j] == 1'b1 && list2[i+1][j] == 1'b1 && list2[i+2][j] == 1'b1 && 
				list2[i+3][j] == 1'b1)
                win = 2'b01;
	end
end

//c = 0;
for (i = 3; i < 6; i = i + 1)
begin
	for (j=0; j< 4; j= j + 1)
	begin
		if (list2[i][j] == 1'b1 && list2[i-1][j+1] == 1'b1 
			&& list2[i-2][j+2] == 1'b1 && list2[i-3][j+3] == 1'b1)
                win = 2'b01;
	end
end

//c = 0;
for (i = 3; i < 6; i = i + 1)
begin
	for (j = 3; j < 7; j = j + 1)
	begin
		if (list2[i][j] == 1'b1 && list2[i-1][j-1] == 1'b1 
			&& list2[i-2][j-2] == 1'b1 && list2[i-3][j-3] == 1'b1)
				win = 2'b01;
		  end
end
if (tie == 42)
	win = 2'b10;
end
					
					
					
	
//			if (ld_col)
//				begin
//				if(columns[0] == 1)
//					begin
//					chip_x[7:0] <= col1[7:0];
//					end
//					
//				else if(columns[1] == 1)
//					begin
//					chip_x[7:0] <= col2[7:0];
//					end
//					
//				else if(columns[2] == 1)
//					begin
//					chip_x[7:0] <= col3[7:0];
//					end
//					
//				else if(columns[3] == 1)
//					begin
//					chip_x[7:0] <= col4[7:0];
//					end
//					
//				else if(columns[4] == 1)
//					begin
//					chip_x[7:0] <= col5[7:0];
//					end
//					
//				else if(columns[5] == 1)
//					begin
//					chip_x[7:0] <= col6[7:0];
//					end
//					
//				else if(columns[6] == 1)
//					begin
//					chip_x[7:0] <= col7[7:0];
//					end
//				end
		end
	
	
////	always @(*)
////	begin
//		if(ld_col)
//			begin
//			case (columns)
//				7'b0000001: begin
//								chip_x[7:0] = col1[7:0];
//								curry[6:0] = y1;
//								y1 = y1 - 4'b1110;
//								end
//				
//				7'b0000010: begin
//								chip_x[7:0] = col2[7:0];
//								curry[6:0] = y2;
//								y2 = y2 - 4'b1110;
//								end
//				
//				7'b0000100: begin
//								chip_x[7:0] = col3[7:0];
//								curry[6:0] = y3;
//								y3 = y3 - 4'b1110;
//								end
//				
//				7'b0001000: begin
//								chip_x[7:0] = col4[7:0];
//								curry[6:0] = y4;
//								y4 = y4 - 4'b1110;
//								end
//				
//				7'b0010000: begin
//								chip_x[7:0] = col5[7:0];
//								curry[6:0] = y5;
//								y5 = y5 - 4'b1110;
//								end
//				
//				7'b0100000: begin
//								chip_x[7:0] = col6[7:0];
//								curry[6:0] = y6;
//								y6 = y6 - 4'b1110;
//								end
//				
//				7'b1000000: begin
//								chip_x[7:0] = col7[7:0];
//								curry[6:0] = y7;
//								y7 = y7 - 4'b1110;
//								end
//				default: begin
//							chip_x[7:0] = 8'b0;
//							curry[6:0] = 7'b0;
//							end
//				endcase
//			end
//	 end
endmodule

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


