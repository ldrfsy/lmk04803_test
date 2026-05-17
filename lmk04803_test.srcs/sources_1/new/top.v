`timescale 1ns / 1ps
// Create Date: 2024/09/23 20:16:00
// Design Name: 
// Module Name: top
module top(
input              clk                ,
input              rst                ,
input [31:0]       cbus_addr          ,//上位机给的地址
input [31:0]       cbus_data          ,//上位机给的数据，该数据包含寄存器的（数据+地址）
input              cbus_we            ,//上位机使能信号
input              cbus_clk           , 
output             cs                 ,
output             sck                ,
output             mosi               ,
output             sync               ,
//input              PLL_LD           ,
input              PLL_READBACK       ,
output             LEuWire            ,
output             CLKuWire           ,
output     [26:0]  Back_data          //寄存器回读输出
);
wire  data_in             ;
wire  init_spi_end        ;
wire  init_done           ;
wire [5:0] cnt_reg        ;
wire [31:0]data_reg       ;
wire [4:0] addr,rdback_addr    ;
wire [31:0] rdback_reg ,upper_data_reg;

tx_spi tx_spi_inst(
. clk          (clk         )  ,
. rst          (rst         )  ,
. data_in      (data_reg    )  ,
. sync         (sync        )  ,
. init_spi_end (init_spi_end)  ,
. init_done    (init_done   )  ,
. cnt_reg      (cnt_reg     )  ,
. cs           (cs          )  ,
. sck          (sck         )  ,
. mosi         (mosi        )
    );
    
spi_write spi_wirte_inst(  
.clk           (clk         )               ,  
.rst           (rst         )               ,  
.cnt_reg       (cnt_reg     )               ,  
.init_done     (init_done   )               ,  
.init_spi_end  (init_spi_end)               ,  
.data_reg      (data_reg    )               
    ); 
    
spi_rdback spi_rdback_inst(
. clk            (clk         )       ,
. rst            (rst         )       ,
. addr           (rdback_addr )       ,
. PLL_READBACK   (PLL_READBACK)       , //Status_Holdover(指示设备是否处于保持模式）
. LEuWire        (LEuWire     )       ,
. CLKuWire       (CLKuWire    )       ,
. rdback_reg     (rdback_reg  )       , //需要回读，将rdback_reg连data_in
. Back_data      (Back_data   )         //寄存器回读输出
    ); 
 
upper_control upper_control_inst(
.clk           (clk             )     ,
.rst           (rst             )     ,
.cbus_addr     (cbus_addr       )     ,
.cbus_data     (cbus_data       )     ,
.cbus_we       (cbus_we         )     ,
.cbus_clk      (cbus_clk        )     ,
.rdback_addr   (rdback_addr     )     , 
.upper_data_reg(upper_data_reg  )                       
    ); 
  
endmodule
