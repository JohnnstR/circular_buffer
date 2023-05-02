//circular buffer testbench
module circ_tb;

    logic rd_req;
    logic wr_req;
    logic clock;
    logic reset;
    logic [2:0] din;
    logic [2:0] dout;
    logic [6:0] sum;
    logic full;
    logic empty;

    circular_buffer circ1(
        .clock(clock),
        .reset(reset),
        .rd(rd_req),
        .wr(wr_req),
        .din(din),
        .dout(dout),
        .empty(empty),
        .full(full)
    );

    always #5 clock = ~clock;

    task circ_reset;
        reset = 1;
        clock = 0;
        rd_req = 0;
        wr_req = 0;
        din = 3'b000;
        sum = 7'b000000;
        @(negedge clock);
        reset = 0;
    endtask

    task exitOnError;
        begin
        $display("UR SHIT BROKE \n");
        $finish;
        end
    endtask

    initial begin
        $display("BEGINNING TESTBENCH \n");
        circ_reset;
        fill_buffer_basic;
        circ_reset;
        fill_and_empty_addition;

        $display("GREAT SUCCESS \n");
        $finish;
    end

    task fill_buffer_basic; // PASSES!
        //let's fill the buffer all the way:
        $display("BEGINNING BASIC BUFFER TEST \n");
        @(negedge clock);
        din = 3'b111;
        wr_req = 1;
        @(negedge clock);
        @(negedge clock);
        @(negedge clock);
        @(negedge clock);
        @(negedge clock);
        @(negedge clock);
        @(negedge clock);
        @(negedge clock);
        #1
        assert (full) else exitOnError;
    endtask

    task fill_and_empty_addition;
        $display("FILL->EMPTY TEST \n");
        @(negedge clock);
        din = 3'b111; //8
        wr_req = 1;
        @(negedge clock);
        @(negedge clock);
        @(negedge clock);
        @(negedge clock);
        @(negedge clock);
        @(negedge clock);
        din = 3'b110; //7
        @(negedge clock);
        din = 3'b111; //8 (BLOCKED unless overflow bug is allowed!)
        @(negedge clock);
        #1
        assert (full) else exitOnError;
        
        //begin reading, stop writing:
        wr_req = 0;
        rd_req = 1;
        $display ("%b", dout);
        @(negedge clock);
        #1
        $display ("%b", dout)
        assert (dout == 3'b111) else exitOnError;
        sum += dout; //8
        @(negedge clock);
        assert (dout == 3'b111) else exitOnError;
        sum += dout; //16
        @(negedge clock);
        assert (dout == 3'b111) else exitOnError;
        sum += dout; //24
        @(negedge clock);
        assert (dout == 3'b111) else exitOnError;
        sum += dout; //32
        @(negedge clock);
        assert (dout == 3'b111) else exitOnError;
        sum += dout; //40
        @(negedge clock);
        assert (dout == 3'b111) else exitOnError;
        sum += dout; //48
        @(negedge clock);
        assert (dout == 3'b111) else exitOnError;
        sum += dout; //56 
        @(negedge clock);
        assert (dout == 3'b111) else exitOnError;
        sum += dout; //63 <- make sure 7 is added, and not 8!

        if (sum == 64) begin
            $display("BUFFER OVERFLOW BUG");
            exitOnError;
        end
        assert (sum == 63) else exitOnError;
        assert (empty) else exitOnError;

    endtask

endmodule