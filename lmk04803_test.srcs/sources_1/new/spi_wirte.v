`timescale 1ns / 1ps

module spi_write (
    input        clk,
    input        rst,
    input  [5:0] cnt_reg,
    input        init_done,
    input        init_spi_end,
    output reg [31:0] data_reg
);

localparam R0_VAL  = 32'h0016_3200; // R0  输出CW(1X):(16X)最大128M，这里取80M,故1X为：80M/16=5M
localparam R1_VAL  = 32'h0014_3201; // R1  输出5M
localparam R2_VAL  = 32'h0014_0322; // R2  输出80M(CW 16X)
localparam R3_VAL  = 32'h0014_0323; // R3  输出80M(CW 16X)
localparam R4_VAL  = 32'h0014_0144; // R4  输出200M(TXCLK_BUFINO_P/N)
localparam R5_VAL  = 32'h0014_0645; // R5  输出40M（只针对pin10，pin11关闭,SMPCLK_BUFIN_P/N)
localparam R6_VAL  = 32'h1111_0006; // R6  输出LVDS
localparam R7_VAL  = 32'h1111_0007; // R7  输出LVDS
localparam R8_VAL  = 32'h0111_0008; // R8  输出LVDS
localparam R9_VAL  = 32'h5555_5549; // R9  固定值
localparam R10_VAL = 32'h9141_410A; // R10 输出40M（只针对OSCout0_P/N，OSCout1_P/N关闭),默认FEEDBACK_MUX为CLKout0,VCO_MUX为VCO
localparam R11_VAL = 32'h3401_C00B; // R11 MODE:PLL2 IntVCO，产生同步信号SYNC，高电平有效，如果SYNC_EN_AUTO=0，则需要手动产生Sync(400B),SYNC_EN_AUTO=1时，自动生成Sync(C00B)
localparam R12_VAL = 32'h040C_00AC; // R12 产生Status_LD信号电平，高电平有效
localparam R13_VAL = 32'h2302_880D; // R13 产生Status_Holdover信号电平，高电平有效,并且关闭CLKin0,1(23:代表Holdover_mode;3B:uWire_Readback)(3B00_880D)
localparam R14_VAL = 32'h0000_000E; // R14 产生Status_CLK_in0/1类型以及输出电平，该引脚设置输入input_enable,表示不使用该引脚
localparam R15_VAL = 32'h8000_800F; // R15 在PLL1的锁定之前的计数值
localparam R16_VAL = 32'hC155_0410; // R16 固定值
localparam R24_VAL = 32'h0000_0058; // R24 PLL_WND_SIZE 大小：设置为10ns
localparam R25_VAL = 32'h0049_C419; // R25 PLL_DLD_CNT设置为10000，PLL1分频系数为1
localparam R26_VAL = 32'hAFA8_001A; // R26 选择EN_PLL2_REF_2X，可以获得最佳的PLL2的带内噪声
localparam R27_VAL = 32'h1000_005B; // R27 选择CLKin0 PreR DIV分频系数
localparam R28_VAL = 32'h0020_005C; // R28 PLL2设置的R系数位2，PLL1设置的N系数为1
localparam R29_VAL = 32'h0000_033D; // R29 设置输入频率范围和PLL2_N_CAL=25
localparam R30_VAL = 32'h0200_033E; // R30 设置PLL2的P和N系数
localparam R31_VAL = 32'h001F_001F; // R31 设置是否回读，以及回读的地址，这里回读的地址为（11111），未设置回读


always @(posedge clk or negedge rst) begin
    if (!rst) begin
        data_reg <= 32'h8016_0100;      // 复位默认值：R0(INT)
    end
    else if (init_spi_end) begin
        case (cnt_reg)
            6'd0  : data_reg <= R0_VAL;
            6'd1  : data_reg <= R1_VAL;
            6'd2  : data_reg <= R2_VAL;
            6'd3  : data_reg <= R3_VAL;
            6'd4  : data_reg <= R4_VAL;
            6'd5  : data_reg <= R5_VAL;
            6'd6  : data_reg <= R6_VAL;
            6'd7  : data_reg <= R7_VAL;
            6'd8  : data_reg <= R8_VAL;
            6'd9  : data_reg <= R9_VAL;
            6'd10 : data_reg <= R10_VAL;
            6'd11 : data_reg <= R11_VAL;
            6'd12 : data_reg <= R12_VAL;
            6'd13 : data_reg <= R13_VAL;
            6'd14 : data_reg <= R14_VAL;
            6'd15 : data_reg <= R15_VAL;
            6'd16 : data_reg <= R16_VAL;
            6'd17 : data_reg <= R24_VAL;  // 注意：原代码索引17对应R24
            6'd18 : data_reg <= R25_VAL;
            6'd19 : data_reg <= R26_VAL;
            6'd20 : data_reg <= R27_VAL;
            6'd21 : data_reg <= R28_VAL;
            6'd22 : data_reg <= R29_VAL;
            6'd23 : data_reg <= R30_VAL;
            6'd24 : data_reg <= R31_VAL;
            default : data_reg <= 32'h0000_0000;
        endcase
    end
    else if (init_done) begin
        data_reg <= 32'h0000_0000;      
    end
end

endmodule