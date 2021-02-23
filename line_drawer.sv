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
	logic is_steep, init, drawing;
	logic [10:0] x0_temp, x1_temp, y0_temp, y1_temp, y_abs, x_abs;
	
	/* You'll need to create some registers to keep track of things
	 * such as error and direction.
	 */
	logic signed [11:0] error, delta_x, delta_y;  // example - feel free to change/delete
	logic signed [1:0] y_step;
	
	assign y_abs = (y1 > y0) ? (y1 - y0) : (y0 - y1);
	assign x_abs = (x1 > x0) ? (x1 - x0) : (x0 - x1);
	assign is_steep = y_abs > x_abs;
	assign y_step = y1 < y0 ? 2'b01 : 2'b11;
	

	enum {idle, draw, finish} ps, ns;
	
	// performs our swaps
	always_comb begin
		if (is_steep) begin
			if (y0 > y1) begin
				x0_temp = y1; x1_temp = y0; y0_temp = x1;  y1_temp = x0;
            delta_x = (y0 - y1);
				delta_y = (x0 > x1) ? (x0 - x1) : (x1 - x0);
         end else begin
            x0_temp = y0; y0_temp = x0; x1_temp = y1; y1_temp = x1;
            delta_x = (y1 - y0);
				delta_y = (x1 > x0) ? (x1 - x0) : (x0 - x1);
			end
			x = y_next;
			y = x_next;
		end else begin
			if (x0 > x1) begin
				x0_temp = x1; x1_temp = x0; y0_temp = y1;  y1_temp = y0;
            delta_x = (x0 - x1);
				delta_y = (y0 > y1) ? (y0 - y1) : (y1 - y0);
         end else begin
            x0_temp = x0; x1_temp = x1; y0_temp = y0; y1_temp = y1;
            delta_x = (x1 - x0);
				delta_y = (y1 > y0) ? (y1 - y0) : (y0 - y1);
         end
			x = x_next;
			y = y_next;
		end
	end

	// 
	always_comb begin
		case(ps)
			idle: begin ns = (init) ? draw : idle;
							drawing = 0;
							done = 0;
					end
			draw: begin ns = (x_next < x1_temp) ? draw : finish;
							drawing = 1;
							done = 0;
					end
			finish: begin ns = (init) ? draw : finish;
							  drawing = 0;
							  done = 1;
					  end
		endcase
	end
	
	
	always_ff @(posedge clk) begin
		if (reset) begin
			init <= 1;
			ps <= idle;
		end else begin
			init <= 0;
			ps <= ns;
		end
	end
	

	always_ff @(posedge clk) begin
		if (reset) begin
			x_next <= x0_temp;
			y_next <= y0_temp;
			error <= {delta_x[11], delta_x[11:1]};
		end else if (drawing & (error + delta_y >= 0)) begin
			y_next <= y_next + y_step;
			error <= error + delta_y - delta_x;
			x_next <= x_next + 1'b1;
		end else if (drawing) begin
			error <= error + delta_y;
			y_next <= y_next;
			x_next <= x_next + 1'b1;
		end else if (x_next == x1_temp) begin
			x_next <= x1_temp;
			y_next <= y1_temp;
		end else begin
			x_next <= x_next;
			y_next <= y_next;
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
		reset <= 1; x0 <= 0; y0 <= 0; x1 <= 220; y1 <= 240; 	@(posedge clk);
		reset <= 0;															@(posedge clk);
																				@(posedge clk);
																				@(posedge clk);
																				@(posedge clk);
																				@(posedge done);
																				@(posedge clk);
		reset <= 1; x0 <= 640; y0 <= 50; x1 <= 0; y1 <= 300; 	@(posedge clk);
		reset<=0;												         @(posedge clk);
																			   @(posedge clk);
																				@(posedge clk);
																				@(posedge clk);
																				@(posedge clk);
																				@(posedge done);
		$stop;
	end
endmodule
