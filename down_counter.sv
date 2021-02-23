module down_counter #(parameter MAX = 50000000) (clk, reset, pulse);
   input logic clk, reset;
   output logic pulse;

   logic[26:0] count;

   // Reset the count to the max value when start is true or 
   // when count hits 0, otherwise decrement count by 1.
   always_ff @(posedge clk) begin
      if (reset) begin
         count <= MAX;
      end else if (count == 0) begin
         count <= MAX;
      end else begin
         count <= count - 27'h0000001;
      end
   end

   assign pulse = (count == 0);
endmodule
