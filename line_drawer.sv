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
	logic is_steep, y_abs, x_abs;
	logic [10:0] x0_temp, x1_temp, y0_temp, y1_temp, delta_x, delta_y;
	
	/* You'll need to create some registers to keep track of things
	 * such as error and direction.
	 */
	logic signed [11:0] error;  // example - feel free to change/delete
	logic signed [1:0] y_step;
	
	assign y_abs = (y1 > y0) ? (y1 - y0) : (y0 - y1);
	assign x_abs = (x1 > x0) ? (x1 - x0) : (x0 - x1);
	assign is_steep = y_abs > x_abs;
	
	always_ff @(posedge clk) begin
		if (ps == start) begin
			if (is_steep) begin
				x0_temp <= y0; y0_temp <= x0; x1_temp <= y1; y1_temp <= x1;
			end else begin
				x0_temp <= x0; x1_temp <= x1; y0_temp <= y0; y1_temp <= y1;
			end if (x0_temp > x1_temp) begin
				x0_temp <= x1_temp; x1_temp <= x0_temp; y0_temp <= y1_temp;  y1_temp <= y0_temp;
			end else begin
			x0_temp <= x0_temp; x1_temp <= x1_temp; y0_temp <= y0_temp; y1_temp <= y1_temp;
			end
			y_step <= y0_temp < y1_temp ? 1 : -1;
			delta_x <= (x1_temp - x0_temp);
			delta_y <= (y1_temp > y0_temp) ? (y1_temp - y0_temp) : (y0_temp - y1_temp);
		end
	end 

	enum {start, draw, finish} ps, ns;

	always_comb begin
		case(ps)
			start: ns = draw;
			draw:  ns = done ? finish : draw;
			finish: ns = start;
		endcase
	end
	
	always_ff @(posedge clk) begin
		if (ps == start) begin
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
			end if (error + delta_y >= 0) begin
				y_next <= y_next + y_step;
				error <= error + delta_y - delta_x;
			end else begin
				error <= error + delta_y;
			end
			x_next <= x_next + 1;
		   if (x_next == x1) begin
				done <= 1;
			end
			ps <= ns;
		end //else if (ps == finish) begin
		//end
	end  // always_ff
	
endmodule  // line_drawer