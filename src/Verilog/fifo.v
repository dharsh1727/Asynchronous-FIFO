module fifo #(
    parameter D_WIDTH = 8,
    parameter A_WIDTH = 3
)(
    input wclk, rclk,
    input [D_WIDTH-1:0] wdata,
    output [D_WIDTH-1:0] rdata,
    output full, empty,
    input rrst_n, wrst_n,
    input rinc, winc
);
    wire [A_WIDTH-1:0] waddr, raddr;
    wire [A_WIDTH:0] rptr_sync, wptr_sync,wptr,rptr;
    
    fifo_memory #(.DATA_WIDTH(D_WIDTH), .ADDR_WIDTH(A_WIDTH)) fifo_inst (
        .wclk(wclk),
        .rclk(rclk),
        .waddr(waddr),
        .raddr(raddr),
        .wdata(wdata),
        .wen(winc & ~full),
        .ren(rinc & ~empty),
        .rdata(rdata)
    );

    wptr_full #(.ADDR_WIDTH(A_WIDTH)) wptr_inst (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .winc(winc),
        .rptr_sync(rptr_sync),
        .full(full),
        .wptr(wptr),
        .waddr(waddr)
    );

    rptr_empty #(.ADDR_WIDTH(A_WIDTH)) rptr_inst (
        .rclk(rclk),
        .rrst_n(rrst_n),
        .rinc(rinc),
        .wptr_sync(wptr_sync),
        .empty(empty),
        .rptr(rptr),
        .raddr(raddr)
    );

    two_ff_sync #(.PTR_WIDTH(A_WIDTH)) sync_r2w (
        .clk(wclk),
        .rst_n(rrst_n),
        .d(rptr),
        .q(rptr_sync)
    );

    two_ff_sync #(.PTR_WIDTH(A_WIDTH)) sync_w2r (
        .clk(rclk),
        .rst_n(wrst_n),
        .d(wptr),
        .q(wptr_sync)
    );

endmodule