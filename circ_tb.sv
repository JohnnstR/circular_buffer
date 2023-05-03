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


    logic [7:0][2:0] bufferOut;
    logic [2:0] rd_ptrOut;
    logic [2:0] wr_ptrOut;


    circular_buffer circ1(
        .clock(clock),
        .reset(reset),
        .rd(rd_req),
        .wr(wr_req),
        .din(din),
        .dout(dout),
        .empty(empty),
        .full(full),
        .bufferOut(bufferOut),
        .wr_ptrOut(wr_ptrOut),
        .rd_ptrOut(rd_ptrOut)
    );

    always #5 clock = ~clock;

    task print_state;
        $display("PRINTING BUFFFER: \n");
        for (int i = 0; i < 8; i++) begin
            $display("buffer at index: %b: ", i);
            $display("%b", bufferOut[i]);
        end
        $display("HEAD PTR INDEX: %b", rd_ptrOut);
        $display("TAIL PTR INDEX: %b", wr_ptrOut);
        $display("EMPTY: %b", empty);
        $display("FULL: %b", full);
    endtask

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
        // circ_reset;
        // fill_buffer_basic;
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
        print_state;
        @(negedge clock);
        print_state;
        @(negedge clock);
        print_state;
        @(negedge clock);
        print_state;
        @(negedge clock);
        print_state;
        @(negedge clock);
        din = 3'b110; //7
        print_state;
        @(negedge clock);
        din = 3'b111; //8 (BLOCKED unless overflow bug is allowed!)
        print_state;
        @(negedge clock);
        #1
        assert (full) else exitOnError;
        
        //begin reading, stop writing:
        wr_req = 0;
        rd_req = 1;
        $display ("%b", dout);
        print_state;

        @(negedge clock);
        print_state;
        #1
        $display ("%b", dout);
        // assert (dout == 3'b111) else exitOnError;
        sum += dout; //7

        @(negedge clock);
        print_state;
        $display ("%b", dout);
        assert (dout == 3'b111) else exitOnError;
        sum += dout; //14

        @(negedge clock);
        print_state;
        assert (dout == 3'b111) else exitOnError;
        sum += dout; //21

        @(negedge clock);
        print_state;
        assert (dout == 3'b111) else exitOnError;
        sum += dout; //28

        @(negedge clock);
        print_state;
        assert (dout == 3'b111) else exitOnError;
        sum += dout; //35

        @(negedge clock);
        print_state;
        assert (dout == 3'b111) else exitOnError;
        sum += dout; //42

        @(negedge clock);
        print_state;
        assert (dout == 3'b110) else exitOnError;
        sum += dout; //48 <- make sure 7 is added, and not 8!

        @(negedge clock);
        print_state;
        assert (dout == 3'b111) else exitOnError;
        sum += dout; //55 

        if (sum == 56) begin
            $display("BUFFER OVERFLOW BUG");
            exitOnError;
        end
        assert (sum == 55) else exitOnError;
        assert (empty) else exitOnError;

    endtask

endmodule