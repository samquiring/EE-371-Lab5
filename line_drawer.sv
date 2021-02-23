/* Given two points on the screen this module draws a line between
 * those two points by coloring necessary pixels
 *
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   reset  - resets the module and starts over the drawing process
 *	 x0 	- x coordinate of the first end point
 *   y0 	- y coordinate of the first end point
 *   x1 	- x coordinate of the second end point
 *   y1 	- y coordinate of the second end point
 *
 * Outputs:
 *   x 		- x coordinate of the pixel to color
 *   y 		- y coordinate of the pixel to color
 *   done	- flag that line has finished drawing
 *
 */
module line_drawer(clk, reset, x0, y0, x1, y1, x, y, done);
	input logic clk, reset;
	input logic [10:0]	x0, y0, x1, y1;
	output logic done;
	output logic [10:0]	x, y;
	logic [10:0] x_next, y_next;
	logic is_steep, init;
	logic [10:0] x0_temp, x1_temp, y0_temp, y1_temp, delta_x, delta_y, y_abs, x_abs;
	
	/* You'll need to create some registers to keep track of things
	 * such as error and direction.
	 */
	logic signed [11:0] error;  // example - feel free to change/delete
	logic signed [1:0] y_step;
	
	assign y_abs = (y1 > y0) ? (y1 - y0) : (y0 - y1);
	assign x_abs = (x1 > x0) ? (x1 - x0) : (x0 - x1);
	assign is_steep = y_abs > x_abs;
	

	enum {idle, draw, finish} ps, ns;
	
	// performs our swaps
	always_comb begin
		if (is_steep) begin
			if (y0 > y1) begin
				x0_temp = y1; x1_temp = y0; y0_temp = x1;  y1_temp = x0;
            y_step = x1 < x0 ? 1 : -1;
            delta_x = (y0 - y1);
         end else begin
            x0_temp = y0; y0_temp = x0; x1_temp = y1; y1_temp = x1;
            y_step = x0 < x1 ? 1 : -1;
            delta_x = (y1 - y0);
			end
			delta_y = (x1 > x0) ? (x1 - x0) : (x0 - x1);
		end else begin
			if (x0 > x1) begin
				x0_temp = x1; x1_temp = x0; y0_temp = y1;  y1_temp = y0;
            y_step = y1 < y0 ? 1 : -1;
            delta_x = (x0 - x1);
         end else begin
            x0_temp = x0; x1_temp = x1; y0_temp = y0; y1_temp = y1;
            y_step = y0 < y1 ? 1 : -1;
            delta_x = (x1 - x0);
         end
			delta_y = (y1 > y0) ? (y1 - y0) : (y0 - y1);
		end
	end

	always_comb begin
		case(ps)
			idle: ns = init ? draw : idle;
			draw:  ns = (x_next == x1_temp) ? finish : draw;
			finish: ns = done ? finish : idle;
		endcase
	end
	
	always_ff @(posedge clk) begin
		if (reset) begin
			ps <= idle;
			init <= 1;
			done <= 0;
			x_next <= x0_temp;
			y_next <= y0_temp;
		end
		if (ps == idle) begin
			x <= x0_temp;
			y <= y0_temp;
			x_next <= x0_temp;
			y_next <= y0_temp;
			done <= 0;
			error <= -(delta_x / 2);
			ps <= ns;
		end else if (ps == draw) begin
			if (is_steep) begin
				x <= y_next;
				y <= x_next;
			end else begin
				x <= x_next;
				y <= y_next;
			end if ($signed(error + delta_y) >= 0) begin
				y_next <= y_next + y_step;
				error <= error + delta_y - delta_x;
			end else begin
				error <= error + delta_y;
			end
			x_next <= x_next + 1'b1;
		   if (x_next == x1_temp) begin
				done <= 1;
			end
			ps <= ns;
		end else if (ps == finish) begin
			ps <= ns;
			done <= 0;
			init <= 1;
		
		end
	end  // always_ff
	
endmodule  // line_drawer

module line_drawer_testbench();
	logic clk, reset;
	logic [10:0] x0, y0, x1, y1;
	logic done;
	logic [10:0] x, y;
	
	line_drawer dut (clk, reset, x0, y0, x1, y1, x, y, done);

	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period/2) clk <= ~clk;
	end
	integer i;
	initial begin
		reset <= 0; x0 <= 0; y0 <= 0; x1 <= 240; y1 <= 640; 	@(posedge clk);
		reset <= 0;															@(posedge clk);
																				@(posedge clk);
																				@(posedge clk);
																				@(posedge clk);
																				@(posedge done);
																				@(posedge clk);
																				@(posedge clk);
																				@(posedge clk);
		reset <= 1; x0 <= 640; y0 <= 50; x1 <= 0; y1 <= 300; 	@(posedge clk);
		reset<=0;												         @(posedge clk);
																			   @(posedge clk);
																				@(posedge clk);
																				@(posedge clk);
																				@(posedge clk);
																			
		$stop;
	end
endmodule