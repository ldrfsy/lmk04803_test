`timescale 1ns / 1ps
// Create Date: 2024/09/23 20:19:35
// Design Name: 
// Module Name: tb
module tb();
wire         cs        ;
wire         sck       ;
wire         mosi      ;
wire         sync      ;
wire         LEuWire   ;
wire         CLKuWire  ;
wire [26:0]  Back_data ;
wire  PLL_READBACK     ;
parameter     SYS_CLK               = 100_000_000 ,
               SPI_CLK               = 10_000_000  ;
localparam     delay = SYS_CLK/SPI_CLK-1; //sys_clk divide parameter 
reg [5:0] cnt,cnt_sck;
reg [31:0]PLL_READBACK_REG   ;

reg    clk       ;
reg    rst       ;
//wire  spi_clk_pos;
reg   CLKu;

always@(posedge clk or negedge rst)
    if(~rst)
        cnt = 0;
    else if(cnt == delay)
        cnt = 0;
    else
        cnt = cnt + 1;

always@(posedge clk or negedge rst)
   if(~rst)  
    cnt_sck = 0;
   else if(cnt == delay)
    cnt_sck = cnt_sck + 1;
   else if(cnt_sck == 26)
    cnt_sck = 0;
   else
    cnt_sck = cnt_sck;

always@(posedge clk or negedge rst)
    if(~rst)
        CLKu = 0;
    else if(cnt_sck == 26)
        CLKu = 0;
    else if(cnt==delay/2||cnt==delay)
        CLKu = ~CLKu;
    else
        CLKu = CLKu;
 
//assign spi_clk_pos = (cnt == delay/2)?1:0;   

//initial begin

//    repeat(28)
//        begin
//            @(spi_clk_pos);
//         end
//    #20
//     @(spi_clk_pos);
//     PLL_READBACK_REG = {10'b0,1'b1,5'b00010,11'b0,5'b11111};
//     while(cnt_sck != 28)begin
//        @(spi_clk_pos);
//        PLL_READBACK_REG = {PLL_READBACK_REG[30:0],1'b0};
//     end       
//end
//assign  PLL_READBACK = PLL_READBACK_REG[31]; 

initial begin
clk = 0;
rst = 0;
PLL_READBACK_REG = 0;
#100
rst=1;
PLL_READBACK_REG = {10'b0,1'b1,5'b00010,11'b0,5'b11111};

while(cnt_sck != 26)begin
      @(posedge CLKu);
      PLL_READBACK_REG = PLL_READBACK_REG<<1;
   end   
end
always#10 clk = ~clk;

top top_inst(
.clk         (clk       )    ,
.rst         (rst       )    ,
.cs          (cs        )    ,
.sck         (sck       )    ,
.sync        (sync      )    ,
.mosi        (mosi      )    ,
.PLL_READBACK(PLL_READBACK_REG[31])       ,//Status_Holdover(指示设备是否处于保持模式）
.LEuWire     (LEuWire   )    ,
.CLKuWire    (CLKuWire  )    ,
.Back_data   (Back_data )      //寄存器回读输出
);






endmodule
