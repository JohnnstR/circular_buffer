`timescale 1ns/100ps

`define FIFO_LEN 8; //MUST BE A POWER OF TWO, OR ELSE CIRCULAR ADDITION OF POINTERS DOES NOT WORK WITH OVERFLOW
`define PTR_LEN $clog2(`FIFO_LEN);

module circular_buffer(
    //i/o
    input clock,
    input reset,
    input rd,       //get rid of data
    input wr,       //expect data
    input [2:0] din, // data that comes in when wr is high
    
    output [2:0] dout, //data that leaves when rd is high
    output empty,
    output full
);
    //registers, comb, and ff's
    logic [7:0][2:0] buffer;
    logic [2:0] wr_ptr, rd_ptr, next_wr_ptr, next_rd_ptr;
    logic next_empty, next_full, empty_reg, full_reg;
    logic [2:0] out_reg;

    assign wr_en = wr & ~full;
    assign rd_en = rd & ~empty;

    always_comb begin //or always @(*)
        //default vars:
        next_wr_ptr = wr_ptr;
        next_rd_ptr = rd_ptr;
        next_empty = empty;
        next_full = full;        

        case({rd, wr})
            2'b00: begin
                //do nothing
            end
            2'b01: begin
                if (full) begin
                    //buffer is full, don't write;
                end
                else begin
                    next_wr_ptr = wr_ptr + 1;
                    if (next_wr_ptr == rd_ptr) begin
                        next_full = 1;
                    end
                end

            end
            2'b10: begin
                //check and set empty
                if (empty) begin
                    //empty, read nothing
                end
                else begin
                    next_rd_ptr = rd_ptr + 1;
                    if (next_rd_ptr == wr_ptr) begin
                        next_empty = 1;
                    end
                end
            end
            2'b11: begin
                //neither check - can't become empty or full
                next_rd_ptr = rd_ptr + 1; 
                next_wr_ptr = wr_ptr + 1;
            end

        endcase
    end

    always_ff@(posedge clock or posedge reset) begin //
        if (wr_en) begin
            buffer[wr_ptr] <= din;
        end
        if (rd_en) begin //use a register for out, so that the module remembers it. 
            out_reg <= buffer[rd_ptr];
        end
        if (reset) begin
            //don't need to invalidate the copies currently inside buffer! they will be overwritten now.
            rd_ptr <= 0;
            wr_ptr <= 0;
            empty_reg <= 1;
            full_reg <= 0;
        end
        else begin //make sure you update internal registers:
            empty_reg <= next_empty;
            full_reg <= next_full; 
            rd_ptr <= next_rd_ptr;
            wr_ptr <= next_wr_ptr;
        end
    end

    assign empty = empty_reg;
    assign full = full_reg;
    assign dout = out_reg;


//end
endmodule