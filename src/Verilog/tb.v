`timescale 1ns/1ps

module FIFO_tb();

    parameter DSIZE = 8;
    parameter ASIZE = 3;
    parameter DEPTH = 1 << ASIZE;

    reg [DSIZE-1:0] wdata;
    wire [DSIZE-1:0] rdata;
    wire wfull, rempty;

    reg winc, rinc, wclk, rclk, wrst_n, rrst_n;

    integer i;

    // ? FIXED: module name + port mapping
    fifo #(DSIZE, ASIZE) fifo_inst (
        .rdata(rdata),
        .wdata(wdata),
        .full(wfull),
        .empty(rempty),
        .winc(winc),
        .rinc(rinc),
        .wclk(wclk),
        .rclk(rclk),
        .wrst_n(wrst_n),
        .rrst_n(rrst_n)
    );

    // Clocks
    always #5 wclk = ~wclk;    // fast
    always #10 rclk = ~rclk;   // slow

    initial begin
        // Init
        wclk = 0; rclk = 0;
        wrst_n = 0; rrst_n = 0;
        winc = 0; rinc = 0;
        wdata = 0;

        // Release reset
        #20;
        wrst_n = 1; rrst_n = 1;

        // ---------------- TEST 1 ----------------
        // Write and read simultaneously
        $display("TEST 1: Write + Read");

        rinc = 1;
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge wclk);
            wdata = i;
            winc = 1;
            @(posedge wclk);
            winc = 0;
        end

        #50;

        // ---------------- TEST 2 ----------------
        // Fill FIFO and try extra writes
        $display("TEST 2: Full condition");

        rinc = 0;
        for (i = 0; i < DEPTH + 3; i = i + 1) begin
            @(posedge wclk);
            wdata = i + 20;
            winc = 1;
            @(posedge wclk);
            winc = 0;
        end

        #50;

        // ---------------- TEST 3 ----------------
        // Empty FIFO and try extra reads
        $display("TEST 3: Empty condition");

        winc = 0;
        rinc = 1;
        for (i = 0; i < DEPTH + 3; i = i + 1) begin
            @(posedge rclk);
        end

        rinc = 0;

        #50;
        $finish;
    end

endmodule