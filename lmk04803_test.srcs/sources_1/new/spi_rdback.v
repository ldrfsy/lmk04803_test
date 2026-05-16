`timescale 1ns / 1ps
// Create Date: 2024/09/24 20:53:09
// Design Name: 
// Module Name: spi_rdback
module spi_rdback(
input           clk                   ,
input           rst                   ,
//通过HOLDOVER_MUX或LD_MUX寄存器编程为"保持状态"
//input             PLL_LD             ,//Status_LD(指示设备是否被锁定）
input  [4:0]       addr               ,
input              PLL_READBACK       ,//Status_Holdover(指示设备是否处于保持模式）
output reg         LEuWire            ,
output reg         CLKuWire           ,
output reg [31:0]  rdback_reg         ,
output reg [26:0]  Back_data          //寄存器回读输出
    );
parameter     SYS_CLK               = 100_000_000 ,
               SPI_CLK               = 10_000_000  ;
localparam     delay = SYS_CLK/SPI_CLK-1; //sys_clk divide parameter 
reg init_spi_end;   
reg [5:0] cnt,cnt_sck;
reg [26:0]Back_data_reg;
//reg [31:0] Data;
 //reg  init_spi_start;
always@(posedge clk or negedge rst)
    if(~rst)
        cnt <= 0;
    else if(cnt == delay)
        cnt <= 0;
    else
        cnt <= cnt + 1;
//spi_cnt_sck
always@(posedge clk or negedge rst)
   if(~rst)  
    cnt_sck <= 0;
   else if(cnt == delay)
    cnt_sck <= cnt_sck + 1;
   else if(cnt_sck == 26)
    cnt_sck <= 0;
   else
    cnt_sck <= cnt_sck;
    
//spi_sck   
always@(posedge clk or negedge rst)
    if(~rst)
        CLKuWire <= 0;
    else if(cnt_sck == 26)
        CLKuWire <= 0;
    else if(cnt==delay/2||cnt==delay)
        CLKuWire <= ~CLKuWire;
    else
        CLKuWire <= CLKuWire;


//done signal
always@(posedge clk or negedge rst)
   if(~rst) 
    init_spi_end <= 0;
   else if(cnt_sck == 26 )
    init_spi_end <= 1;
   else
    init_spi_end <= 0;

//spi_cs    
always@(posedge clk or negedge rst)
    if(~rst)
       LEuWire <= 0;
	else if(init_spi_end)
	   LEuWire <= 0;
	 else
	   LEuWire <= 1;

wire [31:0] addr_reg;//需要输入的地址
assign addr_reg = {27'b0,addr};

//将Data中包含的寄存器地址写入到LMK04803中
always@(posedge clk or negedge rst)
    if(~rst)
        rdback_reg<=32'h0020_001f;//开始的回读的寄存器的默认值
    else
        rdback_reg<=rdback_reg|(addr_reg<<16);


always@(posedge clk or negedge rst)
    if(~rst)
        Back_data <= 0;
    else if(cnt_sck == 26)
        Back_data <= Back_data_reg;
    else
        Back_data <= Back_data;

always@(negedge CLKuWire or negedge rst)
    if(~rst)
        Back_data_reg <= 0;
    else 
        Back_data_reg <= {Back_data_reg[25:0],PLL_READBACK};
//    else
//        Back_data_reg<= Back_data_reg;


         
endmodule
