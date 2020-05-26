module win(x, y, colour, win, restart);

input [2:0]x;
input [2:0]y;
input [2:0]colour;
input restart;
output reg win;
reg [5:0]tie = 6'b0;
reg [9:0] c = 0;
integer i = 0;
integer j = 0;
 
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



always @(*)
begin
if (restart)
	begin
	for (i = 0; i < 6; i= i + 1)
		begin
		list1[i] <= 7'h0;
//{7'h0, 7'h0, 7'h0, 7'h0, 7'h0, 7'h0};
		end
	for (i = 0; i < 6; i= i + 1)
		begin
		list2[i] <= 7'h0;
//{7'h0, 7'h0, 7'h0, 7'h0, 7'h0, 7'h0};
		end
	end

if (colour == 3'b110)
begin
	if (list1[y][x] == 1'b0)
	begin
	list1[y][x] = 1'b1;
	tie = tie + 1;
	end
end
else
begin
	if (list2[y][x] == 1'b0)
	begin
	list2[y][x] = 	1'b1;
	tie = tie + 1;
	end
end

end
	
// Horizontal check
always @(*)
begin
c = 0;
for (i=0;i< 7;i = i + 1)
begin
    if (list1[y][i]== 1'b1)
        c = c + 1;
    else
        c = 0;

    if (c >= 4)
        win = 2'b01;
end

//Vertical check
c = 0;
for (i=0;i< 6;i= i + 1)
begin
    if (list2[i][x] == 1'b1)
        c = c + 1;
    else
        c = 0;

    if (c >= 4)
        win = 2'b01;
end
	
c = 0;
for (i = 3; i < 6; i = i + 1)
begin
	for (j=0; j< 4; j = j + 1)
	begin
		if (list1[i][j] == 1'b1 && list1[i-1][j+1] == 1'b1 
			&& list1[i-2][j+2] == 1'b1 && list1[i-3][j+3] == 1'b1)
                win = 2'b01;
	end
end

c = 0;
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
c = 0;
for (i=0;i< 7;i= i + 1)
begin
    if (list2[y][i]== 1'b1)
        c= c + 1;
    else
        c = 0;

    if (c >= 4)
        win = 2'b01;
end

//Vertical check
c = 0;
for (i=0;i< 6;i= i + 1)
begin
    if (list2[i][x] == 1'b1)
        c = c + 1;
    else
        c = 0;

    if (c >= 4)
        win = 2'b01;
end

c = 0;
for (i = 3; i < 6; i = i + 1)
begin
	for (j=0; j< 4; j= j + 1)
	begin
		if (list2[i][j] == 1'b1 && list2[i-1][j+1] == 1'b1 
			&& list2[i-2][j+2] == 1'b1 && list2[i-3][j+3] == 1'b1)
                win = 2'b01;
	end
end

c = 0;
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
 
endmodule