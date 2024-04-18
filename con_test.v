`timescale 1ps / 1ps

module con_test;
    reg ck;
    reg aclk;
    reg areset_n;
    reg [25:0] awaddr;
    reg awvalid;

    reg[15:0] wdata;
    reg wvalid;
    reg bready;

    reg rready;

    wire[15:0] rdata;
    wire rvalid;
    wire rresp;

// Intermediate latches between modules
    reg   irst_n;
    reg   icke;
    reg   ics_n;
    reg   iras_n;
    reg   icas_n;
    reg   iwe_n;
    reg   [1:0]   idm_tdqs;
    reg   [2:0]   iba;
    reg   [12:0]  iaddr;
    reg    [15:0]   idq;
    reg    [1:0]  idqs;
    reg    [1:0]  idqs_n;

    always
        begin
            aclk=1b'0;
            #3300
            aclk=~aclk
        end

    always
        begin
            ck=1b'0;
            #1650
            ck=~ck
        end

initial
    begin
        areset_n=1b'0;
        #10000
        areset_n=1'b1;
        #10000

        awvalid=1b'01
        awaddr<=$urandom(1<<25)
        wdata<=$urandom(1<<15)
        
    end

always @ posedge
ddr3_controller memory_cont(
    .aclk(aclk),
    .areset_n(areset_n),
    .araddr(araddr),
    .arvalid(arvalid),
    .arready(arready),
    .rdata(rdata),
    .rvalid(rvalid),
    .rready(rready),
    .rresp(rresp),
    .awaddr(awaddr),
    .awvalid(awvalid),
    .awready(awready),
    .wdata(wdata),
    .wvalid(wvalid),
    .wready(wready),
    .bvalid(bvalid),
    .bready(bready),
    .bresp(bresp),
    .rst_n(irst_n),
    .cke(icke),
    .cs_n(ics_n),
    .ras_n(iras_n),
    .cas_n(icas_n),
    .we_n(iwe_n),
    .dm_tdqs(idm_tdqs),
    .ba(iba),
    .addr(iaddr),
    .dq(idq),
    .dqs(idqs),
    .dqs_n(idqs_n))   
    
ddr3 memory(
    .rst_n(irst_n),
    .ck(ck),
    .cs_n(ics_n),
    .ras_n(iras_n),
    .cas_n(icas_n),
    .we_n(iwe_n),
    .dm_tdqs(idm_tdqs),
    .ba(iba),
    .addr(.iaddr),
    .dq(idq),
    .dqs(idqs),
    .dqs_n(idqs_n),
    .odt(odt)
)

$dumpfile(waveforms.vcd)
$dumpvars(0,con_test)

endmodule