/* Given two points on the screen this module draws a line between
 * those two points by coloring necessary pixels
 *
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   reset  - resets the module and starts over the drawing process
 *	  
 *
 * Outputs:
 *   x0 	- x coordinate of the first end point
 *   y0 	- y coordinate of the first end point
 *   x1 	- x coordinate of the second end point
 *   y1 	- y coordinate of the second end point
 *
 */
module animator (clk, reset, x0, y0, x1, y1);
	input logic clk, reset;
	output logic [10:0]	x0, y0, x1, y1;
	logic [2:0] anim_num;
	logic pulse;
	
	//down counter so we hold is position for some time
	down_counter count (clk, reset, pulse);
	
	// updates through all of the positions
	always_ff @(posedge clk) begin
		if (reset) begin
			anim_num <= 0;
		end else if (pulse) begin
			anim_num <= anim_num + 1'b1;
		end else begin
			anim_num <= anim_num;
		end
	end

	// Different sets of coordinates to animate different lines
   always_comb begin
      case(anim_num)
         3'b000: begin
            x0 = 0;
            y0 = 0;
            x1 = 640;
            y1 = 640;
         end
         3'b001: begin
            x0 = 0;
            y0 = 640;
            x1 = 640;
            y1 = 0;
         end
         3'b010: begin
            x0 = 180;
            y0 = 640;
            x1 = 180;
            y1 = 0;
         end
         3'b011: begin
            x0 = 0;
            y0 = 180;
            x1 = 640;
            y1 = 180;
         end
         3'b100: begin
            x0 = 80;
            y0 = 240;
            x1 = 560;
            y1 = 240;
         end
         3'b101: begin
            x0 = 534;
            y0 = 640;
            x1 = 111;
            y1 = 333;
         end
         3'b110: begin
            x0 = 213;
            y0 = 547;
            x1 = 564;
            y1 = 0;
         end
         3'b111: begin
            x0 = 632;
            y0 = 234;
            x1 = 534;
            y1 = 124;
         end
         default: begin
            x0 = 0;
            y0 = 0;
            x1 = 0;
            y1 = 0;
         end
      endcase
   end

endmodule
	
module animator_testbench();
   logic clk, reset;
   logic [10:0] x0, y0, x1, y1;

   animations dut (clk, reset, x0, x1, y0, y1);

   parameter clock_period = 100;
   initial begin
      clk <= 0;
      forever #(clock_period/2) clk <= ~clk;
   end

   integer i;
   initial begin
      reset <= 1;    @(posedge clk);
      reset <= 0;    @(posedge clk);
                     @(posedge clk);
                     @(posedge clk);
							@(posedge clk);
							@(posedge clk);

      $stop;
   end
endmodule
