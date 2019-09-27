/****************************Copyright**********************************
**                           
**               
**
**------------------------File Infomation-------------------------------
** FileName     :       mpt_decode.v
** Author       :       
** Data         :       
** Version      :       
** Description  :       
**                      
***********************************************************************/
`timescale 1ns/1ps 
module mpt_decode#(                            
   parameter  VID_HACT                          = 12'd1288   , 
   parameter  VID_VACT                          = 12'd720    , 
   parameter  SEG_X_WIDTH                       = 8'd128     , 
   parameter  SEG_X_NUMBER                      = 8'd10       
   ) (     
    input  wire                                 axi_clk              , 
    input  wire                                 axi_arst             , 
   (*mark_debug = "true"*) output reg                                  mpt_axi_req          , 
   (*mark_debug = "true"*) output reg  [7:0]                           mpt_axi_arlen        , 
   (*mark_debug = "true"*) output reg  [31:0]                          mpt_axi_addr         , 
    input  wire                                 mpt_axi_busy         , 
    input  wire                                 mpt_ram_wr_en        , 
    input  wire  [31:0]                         mpt_ram_wr_data      , 
                                                                       
    input  wire                                 mpt_clk              , 
    input  wire                                 mpt_arst             , 
    input  wire                                 vid_vs_in            , 
   (*mark_debug = "true"*) input  wire                                 vid_locked           , 
   (*mark_debug = "true"*) output reg                                  mpt_check_ok         , 
                                                                       
    output reg   [10:0]                         mpt_sum_out_lx_int   ,
    output reg   [10:0]                         mpt_sum_out_ly_int   ,
    output reg   [5:0]                          mpt_sum_out_lx_float ,
    output reg   [5:0]                          mpt_sum_out_ly_float ,
    output reg   [10:0]                         mpt_sum_out_rx_int   ,
    output reg   [10:0]                         mpt_sum_out_ry_int   ,
    output reg   [5:0]                          mpt_sum_out_rx_float ,
    output reg   [5:0]                          mpt_sum_out_ry_float , 
    output reg                                  mpt_sum_out_vld      , 
                                                                       
    input  wire                                 rmp_L_read_ack       ,  
    input  wire                                 rmp_R_read_ack       ,  
    output reg                                  mpt_sum_xy_LA_rdy    , 
    output wire [7:0]                           mpt_sum_lx_LA0_cnt   , 
    output wire [7:0]                           mpt_sum_lx_LA1_cnt   , 
    output wire [7:0]                           mpt_sum_lx_LA2_cnt   , 
    output wire [7:0]                           mpt_sum_lx_LA3_cnt   , 
    output wire [7:0]                           mpt_sum_lx_LA4_cnt   , 
    output wire [7:0]                           mpt_sum_lx_LA5_cnt   , 
    output wire [7:0]                           mpt_sum_lx_LA6_cnt   , 
    output wire [7:0]                           mpt_sum_lx_LA7_cnt   , 
    output wire [7:0]                           mpt_sum_lx_LA8_cnt   , 
    output wire [7:0]                           mpt_sum_lx_LA9_cnt   , 
    output wire [10:0]                          mpt_sum_ly_LA0_min   , 
    output wire [10:0]                          mpt_sum_ly_LA1_min   , 
    output wire [10:0]                          mpt_sum_ly_LA2_min   , 
    output wire [10:0]                          mpt_sum_ly_LA3_min   , 
    output wire [10:0]                          mpt_sum_ly_LA4_min   , 
    output wire [10:0]                          mpt_sum_ly_LA5_min   , 
    output wire [10:0]                          mpt_sum_ly_LA6_min   , 
    output wire [10:0]                          mpt_sum_ly_LA7_min   , 
    output wire [10:0]                          mpt_sum_ly_LA8_min   , 
    output wire [10:0]                          mpt_sum_ly_LA9_min   , 
    output wire [10:0]                          mpt_sum_ly_LA0_max   , 
    output wire [10:0]                          mpt_sum_ly_LA1_max   , 
    output wire [10:0]                          mpt_sum_ly_LA2_max   , 
    output wire [10:0]                          mpt_sum_ly_LA3_max   , 
    output wire [10:0]                          mpt_sum_ly_LA4_max   , 
    output wire [10:0]                          mpt_sum_ly_LA5_max   , 
    output wire [10:0]                          mpt_sum_ly_LA6_max   , 
    output wire [10:0]                          mpt_sum_ly_LA7_max   , 
    output wire [10:0]                          mpt_sum_ly_LA8_max   , 
    output wire [10:0]                          mpt_sum_ly_LA9_max   , 
    output wire [7:0]                           mpt_sum_rx_LA0_cnt   , 
    output wire [7:0]                           mpt_sum_rx_LA1_cnt   , 
    output wire [7:0]                           mpt_sum_rx_LA2_cnt   , 
    output wire [7:0]                           mpt_sum_rx_LA3_cnt   , 
    output wire [7:0]                           mpt_sum_rx_LA4_cnt   , 
    output wire [7:0]                           mpt_sum_rx_LA5_cnt   , 
    output wire [7:0]                           mpt_sum_rx_LA6_cnt   , 
    output wire [7:0]                           mpt_sum_rx_LA7_cnt   , 
    output wire [7:0]                           mpt_sum_rx_LA8_cnt   , 
    output wire [7:0]                           mpt_sum_rx_LA9_cnt   ,
    output wire [10:0]                          mpt_sum_ry_LA0_min   , 
    output wire [10:0]                          mpt_sum_ry_LA1_min   , 
    output wire [10:0]                          mpt_sum_ry_LA2_min   , 
    output wire [10:0]                          mpt_sum_ry_LA3_min   , 
    output wire [10:0]                          mpt_sum_ry_LA4_min   , 
    output wire [10:0]                          mpt_sum_ry_LA5_min   , 
    output wire [10:0]                          mpt_sum_ry_LA6_min   , 
    output wire [10:0]                          mpt_sum_ry_LA7_min   , 
    output wire [10:0]                          mpt_sum_ry_LA8_min   , 
    output wire [10:0]                          mpt_sum_ry_LA9_min   , 
    output wire [10:0]                          mpt_sum_ry_LA0_max   , 
    output wire [10:0]                          mpt_sum_ry_LA1_max   , 
    output wire [10:0]                          mpt_sum_ry_LA2_max   , 
    output wire [10:0]                          mpt_sum_ry_LA3_max   , 
    output wire [10:0]                          mpt_sum_ry_LA4_max   , 
    output wire [10:0]                          mpt_sum_ry_LA5_max   , 
    output wire [10:0]                          mpt_sum_ry_LA6_max   , 
    output wire [10:0]                          mpt_sum_ry_LA7_max   , 
    output wire [10:0]                          mpt_sum_ry_LA8_max   , 
    output wire [10:0]                          mpt_sum_ry_LA9_max   , 
    (*mark_debug = "true"*)output reg  [7:0]                           MPT_X_NUM            , 
    (*mark_debug = "true"*)output reg  [7:0]                           MPT_Y_NUM            , 
    (*mark_debug = "true"*)output reg  [15:0]                          MPT_ONELINE_Y_MAX          
    );                                                                 
 
  reg                                           vid_locked_1d        ; 
  reg                                           vid_locked_2d        ; 
  reg                                           vid_vs_in_1p         ; 

  (*mark_debug = "true"*)reg                                           fifo_rst             ; 
  (*mark_debug = "true"*)reg                                           fifo_wr_en           ;
  (*mark_debug = "true"*)reg   [31:0]                                  fifo_din             ;
  (*mark_debug = "true"*)wire                                          fifo_full            ; 
  (*mark_debug = "true"*)wire                                          fifo_progfull        ; 
  (*mark_debug = "true"*)wire                                          fifo_empty           ; 
  (*mark_debug = "true"*)reg                                           fifo_rd_en           ; 
  (*mark_debug = "true"*)wire  [15:0]                                  fifo_data_out        ; 
  (*mark_debug = "true"*)wire                                          fifo_data_out_valid  ; 
  (*mark_debug = "true"*)reg   [11:0]                                  fifo_rd_xcnt         ;  
  (*mark_debug = "true"*)reg   [11:0]                                  fifo_vld_xcnt        ;  
  (*mark_debug = "true"*)reg   [5:0]                                   mpt_head_rd_cnt      ; 
  (*mark_debug = "true"*)reg   [5:0]                                   mpt_head_vld_cnt     ; 
  (*mark_debug = "true"*)reg   [10:0]                                  fifo_rd_ycnt         ;  
  (*mark_debug = "true"*)reg   [2:0]                                   mpt_head_check       ; 
  (*mark_debug = "true"*)reg   [15:0]                                  d_fifo_data_out        ; 
  (*mark_debug = "true"*)reg                                           d_fifo_data_out_valid  ; 
  (*mark_debug = "true"*)reg   [11:0]                                  d_fifo_vld_xcnt    ;  
  (*mark_debug = "true"*)reg                                           vid_vs_in_1d      ; 
  (*mark_debug = "true"*)reg                                           rmp_read_ack      ;
  reg                                           rmp_read_ack_1d   ; 
  reg                                           rmp_read_ack_2d   ; 
  reg                                           rmp_readack_pos   ; 
  reg                                           rmp_readack_LA_pos; 
                
  parameter  HEADER_NUM                         = 8'd8  ; 

  always@(posedge axi_clk)  vid_locked_1d       <= vid_locked    ; 
  always@(posedge axi_clk)  vid_locked_2d       <= vid_locked_1d ; 
  always@(posedge axi_clk)  vid_vs_in_1p        <= vid_vs_in     ; 
  always@(posedge axi_clk)  fifo_wr_en          <= mpt_ram_wr_en   ; 
  // always@(posedge axi_clk)  fifo_din            <= mpt_ram_wr_data ; 
  always@(posedge axi_clk)  fifo_din            <= {mpt_ram_wr_data[7:0],mpt_ram_wr_data[15:8],mpt_ram_wr_data[23:16],mpt_ram_wr_data[31:24] }; 
  always@(posedge axi_clk or posedge axi_arst)
    if(axi_arst) begin
        mpt_axi_req                             <= 1'b0 ;
        mpt_axi_arlen                           <= 8'b0 ;
        mpt_axi_addr                            <= 32'hffff_ffff;
    end else begin
        mpt_axi_arlen                           <= 8'd128 ;
      if(!vid_locked_2d || mpt_axi_addr > (VID_HACT * VID_VACT*4 + 8) )
        mpt_axi_req                             <= 1'b0;
      else if(!mpt_axi_busy && fifo_progfull == 1'b0)  
        mpt_axi_req                             <= 1'b1;
      else  
        mpt_axi_req                             <= 1'b0;
      if(!vid_locked_2d)
        mpt_axi_addr                            <= 32'hffff_ffff;
      else if(vid_vs_in_1p)
        mpt_axi_addr                            <= 32'b0;
      else if(mpt_ram_wr_en)  
        mpt_axi_addr                            <= mpt_axi_addr + 8'd4; 
    end
         
  always@(posedge axi_clk or posedge axi_arst)
    if(axi_arst)
      fifo_rst                                  <= 1'b1;
    else if(vid_vs_in_1p)
      fifo_rst                                  <= 1'b1;
    else  
      fifo_rst                                  <= 1'b0;
         
    fifo_mpt_in  u_fifo_mpt_in (   
      .wr_clk                                   ( axi_clk              ), 
      .rst                                      (fifo_rst              ),
      .wr_en                                    (fifo_wr_en            ), 
      .din                                      (fifo_din              ), //input [31:0]
      .full                                     (fifo_full             ), 
      .prog_full                                (fifo_progfull         ), //300
      .rd_clk                                   (mpt_clk               ), 
      .rd_en                                    (fifo_rd_en            ),  
      .dout                                     (fifo_data_out         ), //output [15:0] 
      .valid                                    (fifo_data_out_valid   ), 
      .empty                                    (fifo_empty            )  
      );  
  
  always@(posedge mpt_clk)  vid_vs_in_1d        <= vid_vs_in          ; 
  always@(posedge mpt_clk)  rmp_read_ack_1d     <= rmp_read_ack       ; 
  always@(posedge mpt_clk)  rmp_read_ack_2d     <= rmp_read_ack_1d    ;  
  always@(posedge mpt_clk)  rmp_readack_pos     <= rmp_readack_LA_pos ;  
  always@(posedge mpt_clk or posedge mpt_arst)                             
    if(mpt_arst) begin                                                     
        rmp_read_ack                            <=  1'b0;                   
        rmp_readack_LA_pos                      <=  1'b0;                 
    end else begin                                                         
      if(rmp_L_read_ack && rmp_R_read_ack)                                                   
        rmp_read_ack                            <= 1'b1;                    
      else                                                                 
        rmp_read_ack                            <= 1'b0;                  
      if({rmp_read_ack_2d,rmp_read_ack_1d} == 2'b01)                                                   
        rmp_readack_LA_pos                      <= 1'b1;                    
      else                                                                 
        rmp_readack_LA_pos                      <= 1'b0;                 
    end                                                             
  always@(posedge mpt_clk or posedge mpt_arst)                             
    if(mpt_arst) begin                                                     
        mpt_sum_xy_LA_rdy                        <=  1'b0;                  
    end else begin                                        
      if(vid_vs_in_1d || (rmp_L_read_ack && rmp_R_read_ack))                                         
        mpt_sum_xy_LA_rdy                        <= 1'b0 ;                    
      else if(fifo_vld_xcnt == VID_HACT-1 && fifo_data_out_valid) 
        mpt_sum_xy_LA_rdy                        <= 1'b1 ;                
    end                                                                       
  always@(posedge mpt_clk or posedge mpt_arst)                             
    if(mpt_arst) begin                                                     
        fifo_rd_en                              <=  1'b0;                             
        mpt_head_rd_cnt                         <=  6'b0;    
        mpt_head_vld_cnt                        <=  6'b0;    
        fifo_rd_xcnt                            <= 12'd0;  
        fifo_vld_xcnt                           <= 12'd0;                  
        fifo_rd_ycnt                            <= 11'b0;                
    end else begin       
      if(!vid_locked_2d || vid_vs_in_1d)                                                   
        fifo_rd_en                              <= 1'b0;                   
      else if(fifo_empty == 1'b0 && (mpt_head_rd_cnt < HEADER_NUM || (fifo_rd_xcnt < VID_HACT - 1'd1 && fifo_rd_ycnt < VID_VACT)))            
        fifo_rd_en                              <= 1'b1;                   
      else                                                                 
        fifo_rd_en                              <= 1'b0;                   
                                   
      if(!vid_locked_2d || vid_vs_in_1d )                                                    
        mpt_head_rd_cnt                        <= 6'b0;                   
      else if(fifo_empty == 1'b0 && fifo_rd_en && mpt_head_rd_cnt < HEADER_NUM )                    
        mpt_head_rd_cnt                        <= mpt_head_rd_cnt + 1'b1;  
                                           
      if(mpt_head_rd_cnt < HEADER_NUM || rmp_readack_pos)               
        fifo_rd_xcnt                            <= 12'h0  ; 
      else if(fifo_empty == 1'b0 && fifo_rd_en && fifo_rd_xcnt < VID_HACT) 
        fifo_rd_xcnt                            <= fifo_rd_xcnt + 1'b1;   
                                          
      if(!vid_locked_2d || vid_vs_in_1d )                                                    
        mpt_head_vld_cnt                        <= 6'b0;                   
      else if(fifo_data_out_valid && mpt_head_vld_cnt < HEADER_NUM )                    
        mpt_head_vld_cnt                        <= mpt_head_vld_cnt + 1'b1;  
                 
      if(mpt_head_vld_cnt < HEADER_NUM - 1'b1)  
        fifo_vld_xcnt                           <= 12'hfff  ; 
      else if((mpt_head_vld_cnt == HEADER_NUM - 1'b1 || fifo_vld_xcnt == VID_HACT - 1'b1) && fifo_data_out_valid) 
        fifo_vld_xcnt                           <= 12'h0    ; 
      else if(fifo_data_out_valid) 
        fifo_vld_xcnt                           <= fifo_vld_xcnt + 1'b1  ;  
        
      if(vid_vs_in_1d)                                                    
        fifo_rd_ycnt                            <= 12'h0  ;                   
      else if(fifo_vld_xcnt == VID_HACT - 1'b1 && fifo_data_out_valid)                                             
        fifo_rd_ycnt                            <= fifo_rd_ycnt + 1'b1;  
    end                                                    
                                                          
  always@(posedge mpt_clk or posedge mpt_arst)            
    if(mpt_arst) begin                                    
        mpt_head_check                          <= 3'b0 ; 
        mpt_check_ok                            <= 1'b0 ; 
    end else begin                                        
      if(fifo_data_out_valid && mpt_head_vld_cnt == 6'd0&& fifo_data_out == 16'haaaa)
        mpt_head_check                          <= 3'd1;
      else if((fifo_data_out_valid && mpt_head_vld_cnt == 6'd1 && fifo_data_out == 16'haaaa) || 
         (fifo_data_out_valid && (mpt_head_vld_cnt == 6'd2 || mpt_head_vld_cnt == 6'd3) && fifo_data_out == 16'h5555))
        mpt_head_check                          <= mpt_head_check + 1'b1; 
                                                                      
        mpt_check_ok                            <= mpt_head_check[2] ;
    end 

  always@(posedge mpt_clk) d_fifo_data_out            <= fifo_data_out       ; 
  always@(posedge mpt_clk) d_fifo_data_out_valid      <= fifo_data_out_valid ; 
  always@(posedge mpt_clk) d_fifo_vld_xcnt            <= fifo_vld_xcnt       ; 

////-------------------------------------------------------------------------------------------------------------
////----
////-------------------------------------------------------------------------------------------------------------
 (*mark_debug = "true"*) reg    [6:0]                                CON_X_LEVEL      ; 
 (*mark_debug = "true"*) reg    [6:0]                                CON_Y_LEVEL      ; 
 (*mark_debug = "true"*) reg                                         CON_X_LEVEL_sign ; 
 (*mark_debug = "true"*) reg                                         CON_Y_LEVEL_sign ; 
 (*mark_debug = "true"*) reg                                         MPT_X_NUM_16_EN  ;
 (*mark_debug = "true"*) reg                                         MPT_X_NUM_32_EN  ;
 (*mark_debug = "true"*) reg                                         MPT_X_NUM_64_EN  ;
 (*mark_debug = "true"*) reg                                         MPT_Y_NUM_16_EN  ;
 (*mark_debug = "true"*) reg                                         MPT_Y_NUM_32_EN  ;
 (*mark_debug = "true"*) reg                                         MPT_Y_NUM_64_EN  ;
  always@(posedge mpt_clk or posedge mpt_arst)  
    if(mpt_arst) begin
      MPT_X_NUM                               <= 8'd0    ;   
      MPT_Y_NUM                               <= 8'd0    ;  
      CON_X_LEVEL                             <= 7'd0    ;   
      CON_Y_LEVEL                             <= 7'd0    ;  
      CON_X_LEVEL_sign                        <= 1'd0    ;  
      CON_Y_LEVEL_sign                        <= 1'd0    ;  
      MPT_ONELINE_Y_MAX                       <= 16'd400 ;  
    end else begin
      if(d_fifo_data_out_valid && mpt_head_vld_cnt == 6'd5) begin
        MPT_X_NUM                             <= d_fifo_data_out[ 7:0] ; //8'd32 
        MPT_Y_NUM                             <= d_fifo_data_out[15:8] ; //8'd32  
      end 
      if(d_fifo_data_out_valid && mpt_head_vld_cnt == 6'd6) begin 
        CON_X_LEVEL_sign                      <= d_fifo_data_out[7]    ;  
        CON_X_LEVEL                           <= d_fifo_data_out[6:0]  ; //8'd32 
        CON_Y_LEVEL_sign                      <= d_fifo_data_out[15]   ; 
        CON_Y_LEVEL                           <= d_fifo_data_out[14:8] ; //8'd32  
      end
      if(d_fifo_data_out_valid && mpt_head_vld_cnt == 6'd7) begin
        MPT_ONELINE_Y_MAX                     <= d_fifo_data_out[15:0] ; //8'd32  
      end 
    end  
  always@(posedge mpt_clk)
    begin
        if(MPT_X_NUM == 8'd16) 
            MPT_X_NUM_16_EN                     <= 1'b1;
        else   
            MPT_X_NUM_16_EN                     <= 1'b0;
        if(MPT_X_NUM == 8'd32) 
            MPT_X_NUM_32_EN                     <= 1'b1;
        else   
            MPT_X_NUM_32_EN                     <= 1'b0;
        if(MPT_X_NUM == 8'd64) 
            MPT_X_NUM_64_EN                     <= 1'b1;
        else   
            MPT_X_NUM_64_EN                     <= 1'b0;
        if(MPT_Y_NUM == 8'd16) 
            MPT_Y_NUM_16_EN                     <= 1'b1;
        else   
            MPT_Y_NUM_16_EN                     <= 1'b0;
        if(MPT_Y_NUM == 8'd32) 
            MPT_Y_NUM_32_EN                     <= 1'b1;
        else   
            MPT_Y_NUM_32_EN                     <= 1'b0;
        if(MPT_Y_NUM == 8'd64) 
            MPT_Y_NUM_64_EN                     <= 1'b1;
        else   
            MPT_Y_NUM_64_EN                     <= 1'b0;
    end 
////-------------------------------------------------------------------------------------------------------------
////----
////-------------------------------------------------------------------------------------------------------------
  reg   [17:0]                                  mpt_sum_lx         ; 
  reg   [17:0]                                  mpt_sum_ly         ; 
  reg   [17:0]                                  mpt_sum_rx         ; 
  reg   [17:0]                                  mpt_sum_ry         ; 
  reg                                           mpt_sum_vld        ;
  reg   [10:0]                                  mpt_sum_lx_int     ;
  reg   [10:0]                                  mpt_sum_ly_int     ;
  reg   [10:0]                                  mpt_sum_rx_int     ;
  reg   [10:0]                                  mpt_sum_ry_int     ;
  reg   [5:0]                                   mpt_sum_lx_float   ;
  reg   [5:0]                                   mpt_sum_ly_float   ;
  reg   [5:0]                                   mpt_sum_rx_float   ;
  reg   [5:0]                                   mpt_sum_ry_float   ;
  reg                                           mpt_sum_vld_int    ;
  reg   [11:0]                                  mpt_sum_vld_cnt    ; 
always@(posedge mpt_clk or posedge mpt_arst)
    if(mpt_arst)
        mpt_sum_lx                              <= 18'b0; 
    else if(d_fifo_data_out_valid && d_fifo_vld_xcnt >= 12'd0 && d_fifo_vld_xcnt < 12'd4)
        mpt_sum_lx                              <= {2'b0,d_fifo_data_out[15:12],mpt_sum_lx[15:4]};
    else if(d_fifo_data_out_valid && CON_X_LEVEL_sign)
        mpt_sum_lx                              <= mpt_sum_lx + d_fifo_data_out[15:12] + CON_X_LEVEL;
    else if(d_fifo_data_out_valid)
        mpt_sum_lx                              <= mpt_sum_lx + d_fifo_data_out[15:12] - CON_X_LEVEL;
 
always@(posedge mpt_clk or posedge mpt_arst)
    if(mpt_arst)
        mpt_sum_ly                              <= 18'b0;    
    else if(d_fifo_data_out_valid && d_fifo_vld_xcnt >= 12'd0 && d_fifo_vld_xcnt < 12'd4)
        mpt_sum_ly                              <= {2'b0,d_fifo_data_out[11:8],mpt_sum_ly[15:4]};
    else if(d_fifo_data_out_valid && CON_Y_LEVEL_sign)
        mpt_sum_ly                              <= mpt_sum_ly + d_fifo_data_out[11:8] + CON_Y_LEVEL;
    else if(d_fifo_data_out_valid)
        mpt_sum_ly                              <= mpt_sum_ly + d_fifo_data_out[11:8] - CON_Y_LEVEL;
         
always@(posedge mpt_clk or posedge mpt_arst)
    if(mpt_arst)
        mpt_sum_rx                              <= 18'b0;     
    else if(d_fifo_data_out_valid && d_fifo_vld_xcnt >= 12'd0 && d_fifo_vld_xcnt < 12'd4)
        mpt_sum_rx                              <= {2'b0,d_fifo_data_out[7:4],mpt_sum_rx[15:4]};
    else if(d_fifo_data_out_valid && CON_X_LEVEL_sign)
        mpt_sum_rx                              <= mpt_sum_rx + d_fifo_data_out[7:4] + CON_X_LEVEL;
    else if(d_fifo_data_out_valid)
        mpt_sum_rx                              <= mpt_sum_rx + d_fifo_data_out[7:4] - CON_X_LEVEL;
 
always@(posedge mpt_clk or posedge mpt_arst)
    if(mpt_arst)
        mpt_sum_ry                              <= 18'b0;     
    else if(d_fifo_data_out_valid && d_fifo_vld_xcnt >= 12'd0 && d_fifo_vld_xcnt < 12'd4)
        mpt_sum_ry                              <= {2'b0,d_fifo_data_out[3:0],mpt_sum_ry[15:4]}   ;
    else if(d_fifo_data_out_valid && CON_Y_LEVEL_sign)
        mpt_sum_ry                              <= mpt_sum_ry + d_fifo_data_out[3:0] + CON_Y_LEVEL;  
    else if(d_fifo_data_out_valid)
        mpt_sum_ry                              <= mpt_sum_ry + d_fifo_data_out[3:0] - CON_Y_LEVEL;        
     
always@(posedge mpt_clk or posedge mpt_arst)
    if(mpt_arst)
        mpt_sum_vld                             <= 1'b0;
    else if(vid_vs_in_1d)
        mpt_sum_vld                             <= 1'b0;        
    else if(d_fifo_data_out_valid && d_fifo_vld_xcnt > 12'd2 && d_fifo_vld_xcnt < 12'd1283)
        mpt_sum_vld <= 1'b1;
    else
        mpt_sum_vld                             <= 1'b0;
            
always@(posedge mpt_clk or posedge mpt_arst)                     
    if(mpt_arst)                                              
        mpt_sum_vld_cnt                         <= 12'b0; 
    else if(vid_vs_in_1d || rmp_readack_pos)                                 
        mpt_sum_vld_cnt                         <= 12'b0; 
    else if(mpt_sum_vld)                                  
        mpt_sum_vld_cnt                         <= mpt_sum_vld_cnt + 1'b1; 
                              
  always@(posedge mpt_clk or posedge mpt_arst)
    if(mpt_arst) begin
        mpt_sum_vld_int                         <= 1'b0 ;
        mpt_sum_lx_int                          <= 11'b0;
        mpt_sum_rx_int                          <= 11'b0;
        mpt_sum_ly_int                          <= 11'b0;
        mpt_sum_ry_int                          <= 11'b0;
        mpt_sum_lx_float                        <= 6'b0 ;
        mpt_sum_rx_float                        <= 6'b0 ;
        mpt_sum_ly_float                        <= 6'b0 ;
        mpt_sum_ry_float                        <= 6'b0 ;
    end else begin
        mpt_sum_vld_int                         <= mpt_sum_vld;
      if(MPT_X_NUM_16_EN)
        mpt_sum_lx_int                          <= mpt_sum_lx[14:4];        
      else if(MPT_X_NUM_32_EN)
        mpt_sum_lx_int                          <= mpt_sum_lx[15:5];
      else
        mpt_sum_lx_int                          <= mpt_sum_lx[16:6]; 
      if(MPT_X_NUM_16_EN)
        mpt_sum_rx_int                          <= mpt_sum_rx[14:4];        
      else if(MPT_X_NUM_32_EN)
        mpt_sum_rx_int                          <= mpt_sum_rx[15:5];
      else
        mpt_sum_rx_int                          <= mpt_sum_rx[16:6];
      if(MPT_Y_NUM_16_EN)
        mpt_sum_ly_int                          <= mpt_sum_ly[14:4];        
      else if(MPT_Y_NUM_32_EN)
        mpt_sum_ly_int                          <= mpt_sum_ly[15:5];
      else
        mpt_sum_ly_int                          <= mpt_sum_ly[16:6];
      if(MPT_Y_NUM_16_EN)
        mpt_sum_ry_int                          <= mpt_sum_ry[14:4];        
      else if(MPT_Y_NUM_32_EN)
        mpt_sum_ry_int                          <= mpt_sum_ry[15:5];
      else
        mpt_sum_ry_int                          <= mpt_sum_ry[16:6]; 

      if(MPT_X_NUM_16_EN)
        mpt_sum_lx_float                        <= {2'b0,mpt_sum_lx[3:0]};
      else if(MPT_X_NUM_32_EN)                                             
        mpt_sum_lx_float                        <= {1'b0,mpt_sum_lx[4:0]};
      else                                                                 
        mpt_sum_lx_float                        <= mpt_sum_lx[5:0]       ;
      if(MPT_X_NUM_16_EN)                                                  
        mpt_sum_rx_float                        <= {2'b0,mpt_sum_rx[3:0]};
      else if(MPT_X_NUM_32_EN)                                             
        mpt_sum_rx_float                        <= {1'b0,mpt_sum_rx[4:0]};
      else                                                                 
        mpt_sum_rx_float                        <= mpt_sum_rx[5:0]       ;
      if(MPT_Y_NUM_16_EN)                                                  
        mpt_sum_ly_float                        <= {2'b0,mpt_sum_ly[3:0]};
      else if(MPT_Y_NUM_32_EN)                                             
        mpt_sum_ly_float                        <= {1'b0,mpt_sum_ly[4:0]};
      else                                                                 
        mpt_sum_ly_float                        <= mpt_sum_ly[5:0]       ;
      if(MPT_Y_NUM_16_EN)                                                  
        mpt_sum_ry_float                        <= {2'b0,mpt_sum_ry[3:0]};
      else if(MPT_Y_NUM_32_EN)                                             
        mpt_sum_ry_float                        <= {1'b0,mpt_sum_ry[4:0]};
      else                                                                 
        mpt_sum_ry_float                        <= mpt_sum_ry[5:0]       ;
    end              
 
mpt_decode_analysis#(                            
    .SEG_X_WIDTH                                ( SEG_X_WIDTH          )    
    ) uL_mpt_decode_analysis (     
    .mpt_clk                                    ( mpt_clk              ), //input  wire        
    .mpt_arst                                   ( mpt_arst             ), //input  wire        
    .vid_vs_in                                  ( vid_vs_in_1d         ), //input  wire        
    .rmp_readack_pos                            ( rmp_readack_pos      ), //input  wire        
    .rmp_readack_LA_pos                         ( rmp_readack_LA_pos   ), //input  wire        
    .mpt_sum_vld_int                            ( mpt_sum_vld_int      ), //input  wire        
    .mpt_sum_lx_int                             ( mpt_sum_lx_int       ), //input  wire        
    .mpt_sum_ly_int                             ( mpt_sum_ly_int       ), //input  wire        
    .mpt_sum_lx_float                           ( mpt_sum_lx_float     ), //input  wire        
    .mpt_sum_ly_float                           ( mpt_sum_ly_float     ), //input  wire        
    .mpt_sum_lx_LA0_cnt                         ( mpt_sum_lx_LA0_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA1_cnt                         ( mpt_sum_lx_LA1_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA2_cnt                         ( mpt_sum_lx_LA2_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA3_cnt                         ( mpt_sum_lx_LA3_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA4_cnt                         ( mpt_sum_lx_LA4_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA5_cnt                         ( mpt_sum_lx_LA5_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA6_cnt                         ( mpt_sum_lx_LA6_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA7_cnt                         ( mpt_sum_lx_LA7_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA8_cnt                         ( mpt_sum_lx_LA8_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA9_cnt                         ( mpt_sum_lx_LA9_cnt   ), //output reg  [7:0]  
    .mpt_sum_ly_LA0_min                         ( mpt_sum_ly_LA0_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA1_min                         ( mpt_sum_ly_LA1_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA2_min                         ( mpt_sum_ly_LA2_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA3_min                         ( mpt_sum_ly_LA3_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA4_min                         ( mpt_sum_ly_LA4_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA5_min                         ( mpt_sum_ly_LA5_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA6_min                         ( mpt_sum_ly_LA6_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA7_min                         ( mpt_sum_ly_LA7_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA8_min                         ( mpt_sum_ly_LA8_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA9_min                         ( mpt_sum_ly_LA9_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA0_max                         ( mpt_sum_ly_LA0_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA1_max                         ( mpt_sum_ly_LA1_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA2_max                         ( mpt_sum_ly_LA2_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA3_max                         ( mpt_sum_ly_LA3_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA4_max                         ( mpt_sum_ly_LA4_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA5_max                         ( mpt_sum_ly_LA5_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA6_max                         ( mpt_sum_ly_LA6_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA7_max                         ( mpt_sum_ly_LA7_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA8_max                         ( mpt_sum_ly_LA8_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA9_max                         ( mpt_sum_ly_LA9_max   )  //output reg  [10:0] 
    );    
   
mpt_decode_analysis#(                            
    .SEG_X_WIDTH                                ( SEG_X_WIDTH          )    
    ) uR_mpt_decode_analysis (     
    .mpt_clk                                    ( mpt_clk              ), //input  wire        
    .mpt_arst                                   ( mpt_arst             ), //input  wire        
    .vid_vs_in                                  ( vid_vs_in_1d         ), //input  wire        
    .rmp_readack_pos                            ( rmp_readack_pos      ), //input  wire        
    .rmp_readack_LA_pos                         ( rmp_readack_LA_pos   ), //input  wire        
    .mpt_sum_vld_int                            ( mpt_sum_vld_int      ), //input  wire        
    .mpt_sum_lx_int                             ( mpt_sum_rx_int       ), //input  wire        
    .mpt_sum_ly_int                             ( mpt_sum_ry_int       ), //input  wire        
    .mpt_sum_lx_float                           ( mpt_sum_rx_float     ), //input  wire        
    .mpt_sum_ly_float                           ( mpt_sum_ry_float     ), //input  wire        
    .mpt_sum_lx_LA0_cnt                         ( mpt_sum_rx_LA0_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA1_cnt                         ( mpt_sum_rx_LA1_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA2_cnt                         ( mpt_sum_rx_LA2_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA3_cnt                         ( mpt_sum_rx_LA3_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA4_cnt                         ( mpt_sum_rx_LA4_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA5_cnt                         ( mpt_sum_rx_LA5_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA6_cnt                         ( mpt_sum_rx_LA6_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA7_cnt                         ( mpt_sum_rx_LA7_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA8_cnt                         ( mpt_sum_rx_LA8_cnt   ), //output reg  [7:0]  
    .mpt_sum_lx_LA9_cnt                         ( mpt_sum_rx_LA9_cnt   ), //output reg  [7:0]  
    .mpt_sum_ly_LA0_min                         ( mpt_sum_ry_LA0_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA1_min                         ( mpt_sum_ry_LA1_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA2_min                         ( mpt_sum_ry_LA2_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA3_min                         ( mpt_sum_ry_LA3_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA4_min                         ( mpt_sum_ry_LA4_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA5_min                         ( mpt_sum_ry_LA5_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA6_min                         ( mpt_sum_ry_LA6_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA7_min                         ( mpt_sum_ry_LA7_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA8_min                         ( mpt_sum_ry_LA8_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA9_min                         ( mpt_sum_ry_LA9_min   ), //output reg  [10:0] 
    .mpt_sum_ly_LA0_max                         ( mpt_sum_ry_LA0_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA1_max                         ( mpt_sum_ry_LA1_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA2_max                         ( mpt_sum_ry_LA2_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA3_max                         ( mpt_sum_ry_LA3_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA4_max                         ( mpt_sum_ry_LA4_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA5_max                         ( mpt_sum_ry_LA5_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA6_max                         ( mpt_sum_ry_LA6_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA7_max                         ( mpt_sum_ry_LA7_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA8_max                         ( mpt_sum_ry_LA8_max   ), //output reg  [10:0] 
    .mpt_sum_ly_LA9_max                         ( mpt_sum_ry_LA9_max   )  //output reg  [10:0] 
    );    
   
                      
  always@(posedge mpt_clk) mpt_sum_out_lx_int   <= mpt_sum_lx_int   ;
  always@(posedge mpt_clk) mpt_sum_out_ly_int   <= mpt_sum_ly_int   ;
  always@(posedge mpt_clk) mpt_sum_out_rx_int   <= mpt_sum_rx_int   ;
  always@(posedge mpt_clk) mpt_sum_out_ry_int   <= mpt_sum_ry_int   ;
  always@(posedge mpt_clk) mpt_sum_out_lx_float <= mpt_sum_lx_float ;
  always@(posedge mpt_clk) mpt_sum_out_ly_float <= mpt_sum_ly_float ;
  always@(posedge mpt_clk) mpt_sum_out_rx_float <= mpt_sum_rx_float ;
  always@(posedge mpt_clk) mpt_sum_out_ry_float <= mpt_sum_ry_float ;
  always@(posedge mpt_clk) mpt_sum_out_vld      <= mpt_sum_vld_int  ;
   
  
endmodule
