module ddr3_controller(

// Global ports
    input aclk;
    input areset_n;

// Read address ports
    input [25:0] araddr;
    input arvalid;
    output reg arready;

// Read data ports
    output reg [15:0] rdata;
    output reg rvalid;
    input rready;
    output reg rresp;

// Write address ports
    input [25:0] awaddr;
    input awvalid;
    output reg awready;

// Write data ports
    input [15:0] wdata;
    input wvalid;
    output reg wready;

// Write response ports
    output reg bvalid;
    input bready;
    output reg bresp;

//output reg ports to DDR3
    output reg   rst_n;
    output reg   cke;
    output reg   cs_n;
    output reg   ras_n;
    output reg   cas_n;
    output reg   we_n;
    output reg   [1:0]   dm_tdqs;
    output reg   [2:0]   ba;
    output reg   [12:0]  addr;
    inout    [15:0]   dq;
    inout    [1:0]  dqs;
    inout    [1:0]  dqs_n;
    // output reg   [DQS_BITS-1:0]  tdqs_n;

)
always @ (areset_n)
    begin
    if(areset_n)
        begin
            #10000;
            cke<=1b'1;
            command<=4b'0000;
            if(command==4b'0000)
                begin
                case (ba)
                    2b'00:
                        addr<=14'b0_0_000_1_0_000_1_0_00;
                        ba<=2b'01;
                    2b'01:
                        addr<=14'b0000010110;  
                        ba<=2b'10;
                    2b'10:
                        addr<=14'b00001000_000_000;
                        ba<=2b'11;
                    2b'11:
                        addr<=14'b00000000000000;
                        ba<=2b'zz;
                    default: 
                        ba=2b'zz;
                endcase
                end
        end

            else
                begin
                    rst_n <= areset_n;
                    cke<=1b'0;
                end
    end

parameter IDLE = 3d'0 ; 
parameter ACTIVATE = 3d'1;
parameter READ = 3d'2;
parameter WRITE = 3d'3;
parameter PRECHARGE= 3d'4;
parameter REFRESH= 3d'5;

parameter CLOCK_FREQ = 660 //MHz
parameter REFRESH_TIME=7.8 //us
parameter CYCLES_BETWEEN_REFRESH = CLOCK_FREQ * REFRESH_TIME

reg [3:0] command;
reg [10:0] refresh_cnt;
reg [2:0] next_st;
reg [2:0] present_st;
present_st<=IDLE;
next_st<=IDLE;

awready<=1b'1;
arready<=1b'1;
rready<=1b'1;
wready<=1b'1;
rresp<=1b'0


always @ (posedge aclk)
    begin
    {cs_n,ras_n,cas_n,we_n}=command;
    end

always @ (posedge aclk or posedge areset_n) //refresh counter
    begin
            refresh_cnt=refresh_cnt + 1b'1;
    end

always @ (posedge aclk)
    begin
        present_st=next_st;
        cke=1b'1;
        case (present_st)

            IDLE: 
                begin
                    if(refresh_cnt>=CYCLES_BETWEEN_REFRESH)
                        begin
                            next_st<=REFRESH;
                        end
                    else if (arvalid|awvalid)
                        begin
                            next_st<=ACTIVATE;
                        end
                    else
                        begin
                            next_st<=IDLE;
                        end
                end
            
            REFRESH:
                begin
                    command<=4b'0001;
                    refresh_cnt<=10b'0;
                    next_st<=IDLE;
                end

            ACTIVATE:
                begin
                    command<=4b'0011;
                    if(arvalid&~awvalid)
                        begin
                            if(arvalid&arready)
                                begin
                                    arready=1b'0;
                                    ba<=araddr[25:23];
                                    addr<=araddr[22:10];
                                    next_st<=READ;
                                end     
                        end
                    if(awvalid&~arvalid)
                        begin
                            if(awready&awvalid)
                                begin
                                    awready=1b'0;
                                    ba<=awaddr[25:23];
                                    addr<=awaddr[22:10];
                                    next_st<=WRITE;
                                end
                        end
                    if(awvalid&arvalid)
                        begin
                            if(arvalid&arready)
                                begin
                                    arready=1b'0;
                                    ba<=araddr[25:23];
                                    addr<=araddr[22:10];
                                    next_st<=READ;
                                end  
                        end
                    else
                        next_st=IDLE
                end
            
            READ:
                begin
                    command<=4b'0101;
                    addr<=
                //filll
                end
            
            WRITE:
                begin
                    //fill
                end

            PRECHARGE:
                begin
                    command<=4b'0010;
                    addr[10]<=1b'01;
                    if(arvalid|awvalid)
                        next_st<=ACTIVATE;
                    else
                        next_st<=IDLE;
                end
            default: 
                next_st=IDLE;
        endcase
    end

endmodule