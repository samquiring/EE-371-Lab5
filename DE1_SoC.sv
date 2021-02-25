/* Top level module of the FPGA that takes the onboard resources 
 * as input and outputs the lines drawn from the VGA port.
 *
 * Inputs:
 *   KEY 			- On board keys of the FPGA
 *   SW 			- On board switches of the FPGA
 *   CLOCK_50 		- On board 50 MHz clock of the FPGA
 *
 * Outputs:
 *   HEX 			- On board 7 segment displays of the FPGA
 *   LEDR 			- On board LEDs of the FPGA
 *   VGA_R 			- Red data of the VGA connection
 *   VGA_G 			- Green data of the VGA connection
 *   VGA_B 			- Blue data of the VGA connection
 *   VGA_BLANK_N 	- Blanking interval of the VGA connection
 *   VGA_CLK 		- VGA's clock signal
 *   VGA_HS 		- Horizontal Sync of the VGA connection
 *   VGA_SYNC_N 	- Enable signal for the sync of the VGA connection
 *   VGA_VS 		- Vertical Sync of the VGA connection
 */
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	logic[20:0] counter;
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign LEDR[8:0] = SW[8:0];
	
	logic reset;
	assign reset = SW[8];
	
	logic [10:0] x0, y0, x1, y1, x, y, x0_nxt, x1_nxt, y0_nxt, y1_nxt;
	logic pixel_color;
	logic erase;
	assign erase = SW[9] ? 1'b0 : pixel_color;
	
	
	VGA_framebuffer fb (
		.clk50			(CLOCK_50), 
		.reset			(1'b0), 
		.x, 
		.y,
		.pixel_color	(erase), 
		.pixel_write	(1'b1),
		.VGA_R, 
		.VGA_G, 
		.VGA_B, 
		.VGA_CLK, 
		.VGA_HS, 
		.VGA_VS,
		.VGA_BLANK_n	(VGA_BLANK_N), 
		.VGA_SYNC_n		(VGA_SYNC_N));
				
	logic done;

	line_drawer lines (.clk(CLOCK_50), .reset(reset),.x0, .y0, .x1, .y1, .x, .y, .done);
	assign LEDR[9] = done;
	enum{init,draw} ps, ns;
	enum{left_up,left_down,right_up,right_down} pixel_ps,pixel_ns;
	
	logic isSteep; //tells us to make a steep function
	always_comb begin
		case(ps)
			init: ns = draw;
			draw: ns = draw;
		endcase
		case(pixel_ps)
			left_up: pixel_ns = isSteep ? left_down : left_up;
			left_down: pixel_ns = isSteep ? right_up : left_down;
			right_up: pixel_ns = isSteep ? right_down : right_up;
			right_down: pixel_ns = isSteep ? left_up : right_down;
		endcase
	end
	always_comb begin
		if(pixel_ps == left_up) begin
			if(isSteep) begin
				x0 = 0;
				y0 = 0;
				x1 = 200;
				y1 = 400;
			end else begin
				x0 = 0;
				y0 = 0;
				x1 = 200;
				y1 = 200;
			end
		end else if(pixel_ps == left_down) begin
			if(isSteep) begin
				x0 = 0;
				y0 = 400;
				x1 = 200;
				y1 = 0;
			end else begin
				x0 = 0;
				y0 = 400;
				x1 = 200;
				y1 = 0;
			end
		end else if(pixel_ps == right_up) begin
			if(isSteep) begin
				x0 = 200;
				y0 = 0;
				x1 = 0;
				y1 = 400;
			end else begin
				x0 = 200;
				y0 = 0;
				x1 = 0;
				y1 = 200;
			end
		end else begin
			if(isSteep) begin
				x0 = 0;
				y0 = 0;
				x1 = 200;
				y1 = 400;
			end else begin
				x0 = 0;
				y0 = 0;
				x1 = 200;
				y1 = 200;
			end
		end		
	end
	
	always_ff @(posedge CLOCK_50) begin
		if(reset) begin
			ps<= init;
			isSteep <=0;
		end else begin
			ps<=ns;
		end
		if(ps == init) begin
			pixel_ps <= left_up;
			pixel_color <= 1'b1;
			counter <= 0;
			isSteep <= 0;
		end else if(ps == draw) begin
			if(done) begin
			counter <= counter + 1;
			if(counter[17] == 1) begin //take away for simulation
				counter <= 0;
				pixel_color <= !pixel_color;
			end
				if(!pixel_color) begin
					isSteep <= !isSteep;
					pixel_ps <= pixel_ns;
				end
			end
		end
	end

endmodule  // DE1_SoC

module DE1_SoC_testbench();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic clk;
	logic [7:0] VGA_R, VGA_G, VGA_B;
	logic VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS;
	DE1_SoC dut(HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, clk, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period/2) clk <= ~clk;
	end
	integer i;
	initial begin
		SW[8] = 1;  @(posedge clk);
		SW[8] = 0;  @(posedge clk);
		for(i = 0; i < 4000; i++)
			@(posedge clk);
																			
		$stop;
	end
endmodule
	