/****************************Copyright**********************************
**                           
**               
**
**------------------------File Infomation-------------------------------
** FileName     :       mpt_remap.v
** Author       :       huawei.liang
** Data         :       2018-12-16
** Version      :       v1.0
** Description  :       
**                      
***********************************************************************/
`timescale 1ns/1ps 
module mpt_remap#(                            
   parameter  VID_HACT                          = 16'd1280   , 
   parameter  VID_VACT                          = 16'd720    , 
   parameter  SEG_X_WIDTH                       = 16'd128    ,
   parameter  SEG_X_NUMBER                      = 8'd10        
   ) (           
    input  wire                                 mpt_clk             , 
    input  wire                                 mpt_arst            , 
    input  wire                                 vid_vs_in           , 
                                                                      
    input  wire                                 axi_clk             , 
    input  wire                                 axi_arst            ,
    (*mark_debug = "true"*)output reg                                  usr_axi_req         , 
    (*mark_debug = "true"*)output reg   [7:0]                          usr_axi_arlen       , 
    (*mark_debug = "true"*)output reg   [31:0]                         usr_axi_addr        , 
    (*mark_debug = "true"*)input  wire                                 usr_axi_busy        , 
    (*mark_debug = "true"*)input  wire                                 usr_ram_wr_en       , 
    (*mark_debug = "true"*)input  wire  [9:0]                          usr_ram_wr_addr     , 
    (*mark_debug = "true"*)input  wire  [31:0]                         usr_ram_wr_data     , 
                                                                      
    input  wire  [10:0]                         mpt_sum_out_x_int   , 
    input  wire  [10:0]                         mpt_sum_out_y_int   , 
    input  wire  [5:0]                          mpt_sum_out_x_float , 
    input  wire  [5:0]                          mpt_sum_out_y_float , 
    input  wire                                 mpt_sum_out_vld     , 
    output reg                                  rmp_read_ack        , 
    input  wire                                 mpt_sum_xy_LA_rdy   , 
    input  wire [7:0]                           mpt_sum_x_LA0_cnt   , 
    input  wire [7:0]                           mpt_sum_x_LA1_cnt   , 
    input  wire [7:0]                           mpt_sum_x_LA2_cnt   , 
    input  wire [7:0]                           mpt_sum_x_LA3_cnt   , 
    input  wire [7:0]                           mpt_sum_x_LA4_cnt   , 
    input  wire [7:0]                           mpt_sum_x_LA5_cnt   , 
    input  wire [7:0]                           mpt_sum_x_LA6_cnt   , 
    input  wire [7:0]                           mpt_sum_x_LA7_cnt   , 
    input  wire [7:0]                           mpt_sum_x_LA8_cnt   , 
    input  wire [7:0]                           mpt_sum_x_LA9_cnt   , 
    input  wire [10:0]                          mpt_sum_y_LA0_min   , 
    input  wire [10:0]                          mpt_sum_y_LA1_min   , 
    input  wire [10:0]                          mpt_sum_y_LA2_min   , 
    input  wire [10:0]                          mpt_sum_y_LA3_min   , 
    input  wire [10:0]                          mpt_sum_y_LA4_min   , 
    input  wire [10:0]                          mpt_sum_y_LA5_min   , 
    input  wire [10:0]                          mpt_sum_y_LA6_min   , 
    input  wire [10:0]                          mpt_sum_y_LA7_min   , 
    input  wire [10:0]                          mpt_sum_y_LA8_min   , 
    input  wire [10:0]                          mpt_sum_y_LA9_min   , 
    input  wire [10:0]                          mpt_sum_y_LA0_max   , 
    input  wire [10:0]                          mpt_sum_y_LA1_max   , 
    input  wire [10:0]                          mpt_sum_y_LA2_max   , 
    input  wire [10:0]                          mpt_sum_y_LA3_max   , 
    input  wire [10:0]                          mpt_sum_y_LA4_max   , 
    input  wire [10:0]                          mpt_sum_y_LA5_max   , 
    input  wire [10:0]                          mpt_sum_y_LA6_max   , 
    input  wire [10:0]                          mpt_sum_y_LA7_max   , 
    input  wire [10:0]                          mpt_sum_y_LA8_max   , 
    input  wire [10:0]                          mpt_sum_y_LA9_max   , 
                                                                                             
    (*mark_debug = "true"*)input  wire  [7:0]                          MPT_X_NUM           , 
    (*mark_debug = "true"*)input  wire  [7:0]                          MPT_Y_NUM           , 
    (*mark_debug = "true"*)input  wire                                 rmp_out_fifo_full   , 
    (*mark_debug = "true"*)input  wire                                 rmp_out_ready       , 
    (*mark_debug = "true"*)output reg   [7:0]                          rmp_out_data        , 
    (*mark_debug = "true"*)output reg                                  rmp_out_vld         , 
    (*mark_debug = "true"*)output reg                                  rmp_out_vs          , 
    (*mark_debug = "true"*)output reg                                  rmp_first_line        
    );                                                                 
                                                                      
  reg                                           vid_vs_in_1d           ;
  reg                                           vid_vs_in_2d           ;
  reg                                           fifo_read_en_int       ; 
(*mark_debug = "true"*)  wire  [10:0]                                  fifo_read_data_Xint    ;
(*mark_debug = "true"*)  wire  [10:0]                                  fifo_read_data_Yint    ;
  reg                                           fifo_read_en_int_1     ; 
(*mark_debug = "true"*)  wire  [10:0]                                  fifo_read_data_Xint_1  ;
(*mark_debug = "true"*)  wire  [10:0]                                  fifo_read_data_Yint_1  ;
(*mark_debug = "true"*)  wire  [5:0]                                   fifo_read_data_Xfloat  ;
(*mark_debug = "true"*)  wire  [5:0]                                   fifo_read_data_Yfloat  ;
  wire                                          fifo_read_valid_Xint   ;
  wire                                          fifo_read_valid_Yint   ;
  wire                                          fifo_read_valid_Xint_1 ;
  wire                                          fifo_read_valid_Yint_1 ;
  wire                                          fifo_read_valid_Xfloat ;
  wire                                          fifo_read_valid_Yfloat ; 
  wire                                          fifo_empty_Xint   ;
  wire                                          fifo_empty_Yint   ;
  wire                                          fifo_empty_Xint_1 ;
  wire                                          fifo_empty_Yint_1 ;
  wire                                          fifo_empty_Xfloat ;
  wire                                          fifo_empty_Yfloat ; 

////============================================================================================
////== == 
////============================================================================================
 parameter RAM_Y_ADDR_MAX                       =  8'd32                ; 
 parameter RAM_Y_ADDR_SLACK                     =  8'd4                 ; 
 parameter RAM_OUT_XCNT_DELAY                   =  9'd16                ; 
(*mark_debug = "true"*)  reg   [10:0]                                  cam_in_ymin_LA          ; 
(*mark_debug = "true"*)  reg   [10:0]                                  mpt_ymin_LA             ; 
(*mark_debug = "true"*)  reg   [10:0]                                  cam_in_ymax_LA          ; 
(*mark_debug = "true"*)  reg   [10:0]                                  mpt_ymax_LA             ; 
(*mark_debug = "true"*)  reg   [4:0]                                   ram_ymax_add            ; 
(*mark_debug = "true"*)  reg   [4:0]                                   ram_ymin_add            ; 
(*mark_debug = "true"*)  reg   [5:0]                                   ram_in_buf_cnt          ; 
  reg   [3:0]                                   seg_head_cnt            ; 
(*mark_debug = "true"*)  reg                                           rmp_vs_initial          ; 
(*mark_debug = "true"*)  reg                                           rmp_line_rdy            ; 
(*mark_debug = "true"*)  reg                                           ram_in_seg_rdy          ; 
(*mark_debug = "true"*)  reg                                           ram_buf_rdy             ; 
(*mark_debug = "true"*)  reg                                           ram_out_seg_rdy         ; 
(*mark_debug = "true"*)  reg                                           ram_inout_seg_ack       ; 
(*mark_debug = "true"*)  reg                                           ram_in_buf_ack          ; 
                                                                          
  reg   [10:0]                                  ddr_rd_yaddr_base       ; 
  wire  [23:0]                                  ddr_Y_addr_base         ; 
  wire  [23:0]                                  ddr_X_addr_base         ; 
(*mark_debug = "true"*)  reg   [4:0]                                   ram_in_ybuf_min         ; 
(*mark_debug = "true"*)  reg   [4:0]                                   ram_in_ybuf_max         ; 
(*mark_debug = "true"*)  wire  [4:0]                                   ram_in_xaddr            ; 
(*mark_debug = "true"*)  reg   [4:0]                                   ram_in_yaddr            ; 
(*mark_debug = "true"*)  reg   [3:0]                                   seg_num_cnt             ; 
(*mark_debug = "true"*)  wire  [4:0]                                   ram_out_yaddr           ;
(*mark_debug = "true"*)  wire  [4:0]                                   ram_out_yaddr_1         ;
  reg                                           ram_enb                 ; 
(*mark_debug = "true"*)  wire  [10:0]                                  ram_out_xaddr           ;  
(*mark_debug = "true"*)  wire  [10:0]                                  ram_out_xaddr_add1      ;  
(*mark_debug = "true"*)  reg   [7:0]                                   ram_out_xcnt_LA         ; 
(*mark_debug = "true"*)  reg   [8:0]                                   ram_out_seg_xcnt        ; 
(*mark_debug = "true"*)  reg   [4:0]                                   ram_out_ybuf_min        ; 
  (*mark_debug = "true"*)reg   [10:0]                                  cam_out_ymin_base       ; 
  (*mark_debug = "true"*)wire  [10:0]                                  ram_out_yaddr_shift     ;
  (*mark_debug = "true"*)wire  [10:0]                                  ram_out_xaddr_shift     ;
  (*mark_debug = "true"*)wire  [10:0]                                  ram_out_yaddr_shift_1   ;
  (*mark_debug = "true"*)reg                                           ram0_out_xaddr_overflow ;  
  (*mark_debug = "true"*)reg                                           ram1_out_xaddr_overflow ;   
  
(*mark_debug = "true"*)  reg   [7:0]                                   ram_out_douta     ;
(*mark_debug = "true"*)  reg   [7:0]                                   ram_out_doutb     ;
(*mark_debug = "true"*)  reg                                           fifo0_wr_en     ;
(*mark_debug = "true"*)  reg   [7:0]                                   fifo0_din       ;
(*mark_debug = "true"*)  reg                                           fifo1_wr_en     ;
(*mark_debug = "true"*)  reg   [7:0]                                   fifo1_din       ;
(*mark_debug = "true"*)  wire                                          fifo_calc_rd_en ;
(*mark_debug = "true"*)  wire  [15:0]                                  fifo0_dout      ;
(*mark_debug = "true"*)  wire                                          fifo0_valid     ;
(*mark_debug = "true"*)  wire  [15:0]                                  fifo1_dout      ;
(*mark_debug = "true"*)  wire                                          fifo1_valid     ;
  wire                                          fifo0_empty     ;
  wire                                          fifo1_empty     ;
  wire  [10:0]                                  fifo0_rd_data_count ;
  wire  [10:0]                                  fifo1_rd_data_count ;
  wire                                          fifo0_almost_empty  ;
  wire                                          fifo1_almost_empty  ;
  wire                                          fifo0_full      ;
  wire                                          fifo1_full      ;
    
  reg   [11:0]   ram_read_addr         ;           
  reg   [11:0]   ram_read_addr_add1    ; 
  reg   [31:0]   ram_dina      ;                          
  wire  [11:0]   ram_addra_wr  ; 
  reg   [11:0]   ram_addra_rd  ;
  reg   [11:0]   ram_addrb_rd  ;
  reg   [11:0]   ram_addrb     ; 
  reg   [11:0]   ram0_addra, ram1_addra, ram2_addra, ram3_addra, ram4_addra, ram5_addra, ram6_addra, ram7_addra, ram8_addra, ram9_addra ;
  reg            ram0_wea   ,ram1_wea   ,ram2_wea   ,ram3_wea   ,ram4_wea   ,ram5_wea   ,ram6_wea   ,ram7_wea   ,ram8_wea   ,ram9_wea   ;
  reg            ram0_ena   ,ram1_ena   ,ram2_ena   ,ram3_ena   ,ram4_ena   ,ram5_ena   ,ram6_ena   ,ram7_ena   ,ram8_ena   ,ram9_ena   ;
  reg            ram0_enb   ,ram1_enb   ,ram2_enb   ,ram3_enb   ,ram4_enb   ,ram5_enb   ,ram6_enb   ,ram7_enb   ,ram8_enb   ,ram9_enb   ;
  wire  [7:0]    ram0_douta ,ram1_douta ,ram2_douta ,ram3_douta ,ram4_douta ,ram5_douta ,ram6_douta ,ram7_douta ,ram8_douta ,ram9_douta ; 
  wire  [7:0]    ram0_doutb ,ram1_doutb ,ram2_doutb ,ram3_doutb ,ram4_doutb ,ram5_doutb ,ram6_doutb ,ram7_doutb ,ram8_doutb ,ram9_doutb ; 


  // reg   [10:0]   ram_0_addrb   ;
  // reg   [10:0]   ram_1_addrb   ; 

  // wire  [7:0]    ram00_doutb ,ram01_doutb ,ram10_doutb ,ram11_doutb ,ram20_doutb ,ram21_doutb ,ram30_doutb ,ram31_doutb ,ram40_doutb ,ram41_doutb ; 
  // wire  [7:0]    ram50_doutb ,ram51_doutb ,ram61_doutb ,ram60_doutb ,ram70_doutb ,ram71_doutb ,ram80_doutb ,ram81_doutb ,ram90_doutb ,ram91_doutb ;

(*mark_debug = "true"*)  reg   [7:0]                                   remap_calc_din00    ; 
(*mark_debug = "true"*)  reg   [7:0]                                   remap_calc_din01    ; 
(*mark_debug = "true"*)  reg   [7:0]                                   remap_calc_din10    ; 
(*mark_debug = "true"*)  reg   [7:0]                                   remap_calc_din11    ; 
(*mark_debug = "true"*)  reg   [5:0]                                   remap_calc_xf       ; 
(*mark_debug = "true"*)  reg   [5:0]                                   remap_calc_yf       ; 
(*mark_debug = "true"*)  reg                                           remap_calc_din_vld  ;  
  reg   [1:0]                                   flag_oddeven            ;   
  reg                                           fifo_read_en_int_1d     ; 
  reg                                           fifo_read_en_int_2d     ; 
  reg                                           fifo_read_en_int_3d     ; 
  reg                                           fifo_read_en_int_4d     ; 
  reg                                           fifo_read_en_int_5d     ; 
  reg                                           fifo_read_en_int_6d     ; 
  reg                                           fifo_read_en_int_7d     ; 
  reg                                           fifo_read_en_int_8d     ; 
  reg                                           fifo_read_en_int_1_1d   ; 
  reg                                           fifo_read_en_int_1_2d   ; 
  reg                                           fifo_read_en_int_1_3d   ; 
  reg                                           fifo_read_en_int_1_4d   ; 
  reg                                           fifo_read_en_int_1_5d   ; 
  reg                                           fifo_read_en_int_1_6d   ; 
  reg                                           fifo_read_en_int_1_7d   ; 
  reg                                           fifo_read_en_int_1_8d   ; 
  wire  [7:0]                                   remap_calc_dout         ;
  wire                                          remap_calc_vld_out      ;
  reg                                           ram_first_seg           ;  
  reg   [4:0]                                   ram_in_yaddr0           ;   

  reg   [10:0]                                  cam_in_ymin_LA0         ; 
  reg   [10:0]                                  cam_in_ymin_LA1         ; 
  reg   [10:0]                                  cam_in_ymin_LA2         ; 
  reg   [10:0]                                  cam_in_ymin_LA3         ; 
  reg   [10:0]                                  cam_in_ymin_LA4         ; 
  reg   [10:0]                                  cam_in_ymin_LA5         ; 
  reg   [10:0]                                  cam_in_ymin_LA6         ; 
  reg   [10:0]                                  cam_in_ymin_LA7         ; 
  reg   [10:0]                                  cam_in_ymin_LA8         ; 
  reg   [10:0]                                  cam_in_ymin_LA9         ; 
  reg   [10:0]                                  cam_in_ymax_LA0         ; 
  reg   [10:0]                                  cam_in_ymax_LA1         ; 
  reg   [10:0]                                  cam_in_ymax_LA2         ; 
  reg   [10:0]                                  cam_in_ymax_LA3         ; 
  reg   [10:0]                                  cam_in_ymax_LA4         ; 
  reg   [10:0]                                  cam_in_ymax_LA5         ; 
  reg   [10:0]                                  cam_in_ymax_LA6         ; 
  reg   [10:0]                                  cam_in_ymax_LA7         ; 
  reg   [10:0]                                  cam_in_ymax_LA8         ; 
  reg   [10:0]                                  cam_in_ymax_LA9         ; 
  reg   [4:0]                                   ram_in_ybuf_min0        ; 
  reg   [4:0]                                   ram_in_ybuf_min1        ; 
  reg   [4:0]                                   ram_in_ybuf_min2        ; 
  reg   [4:0]                                   ram_in_ybuf_min3        ; 
  reg   [4:0]                                   ram_in_ybuf_min4        ; 
  reg   [4:0]                                   ram_in_ybuf_min5        ; 
  reg   [4:0]                                   ram_in_ybuf_min6        ; 
  reg   [4:0]                                   ram_in_ybuf_min7        ; 
  reg   [4:0]                                   ram_in_ybuf_min8        ; 
  reg   [4:0]                                   ram_in_ybuf_min9        ; 
  reg   [4:0]                                   ram_in_ybuf_max0        ; 
  reg   [4:0]                                   ram_in_ybuf_max1        ; 
  reg   [4:0]                                   ram_in_ybuf_max2        ; 
  reg   [4:0]                                   ram_in_ybuf_max3        ; 
  reg   [4:0]                                   ram_in_ybuf_max4        ; 
  reg   [4:0]                                   ram_in_ybuf_max5        ; 
  reg   [4:0]                                   ram_in_ybuf_max6        ; 
  reg   [4:0]                                   ram_in_ybuf_max7        ; 
  reg   [4:0]                                   ram_in_ybuf_max8        ; 
  reg   [4:0]                                   ram_in_ybuf_max9        ; 
  wire                                          seg_ack_en0             ; 
  wire                                          seg_ack_en1             ; 
  wire                                          seg_ack_en2             ; 
  wire                                          seg_ack_en3             ; 
  wire                                          seg_ack_en4             ; 
  wire                                          seg_ack_en5             ; 
  wire                                          seg_ack_en6             ; 
  wire                                          seg_ack_en7             ; 
  wire                                          seg_ack_en8             ; 
  wire                                          seg_ack_en9             ; 

  reg                                           mpt_sum_xy_LA_rdy_1d    ; 
  reg                                           usr_axi_busy_1d         ; 
  reg                                           usr_axi_busy_2d         ; 
  reg                                           ram_inout_seg_ack_d     ; 
  reg                                           rmp_line_rdy_d          ; 
  reg                                           usr_axi_req_1d          ; 
  reg                                           usr_axi_req_2d          ; 
  reg                                           usr_axi_req_3d          ; 
  
  always@(posedge mpt_clk)  vid_vs_in_1d        <= vid_vs_in            ; 
  always@(posedge mpt_clk)  vid_vs_in_2d        <= vid_vs_in_1d         ; 
                    
  fifo_mpt_table_int  u0X_fifo_mpt_table_int (                   
    .wr_clk                                     ( mpt_clk              ), 
    .rst                                        (vid_vs_in_1d          ), 
    .wr_en                                      (mpt_sum_out_vld       ), 
    .din                                        (mpt_sum_out_x_int     ), 
    .full                                       (                      ), 
    .rd_clk                                     (mpt_clk               ), 
    .rd_en                                      (fifo_read_en_int      ), 
    .dout                                       (fifo_read_data_Xint   ), 
    .valid                                      (fifo_read_valid_Xint  ), 
    .empty                                      (fifo_empty_Xint       )  
    );                                                          
  fifo_mpt_table_int  u0Y_fifo_mpt_table_int (                   
    .wr_clk                                     ( mpt_clk              ), 
    .rst                                        (vid_vs_in_1d          ), 
    .wr_en                                      (mpt_sum_out_vld       ), 
    .din                                        (mpt_sum_out_y_int     ), 
    .full                                       (                      ), 
    .rd_clk                                     (mpt_clk               ), 
    .rd_en                                      (fifo_read_en_int      ), 
    .dout                                       (fifo_read_data_Yint   ), 
    .valid                                      (fifo_read_valid_Yint  ), 
    .empty                                      (fifo_empty_Yint       )  
    );                    
  fifo_mpt_table_int  u1X_fifo_mpt_table_int (                   
    .wr_clk                                     ( mpt_clk              ), 
    .rst                                        (vid_vs_in_1d          ), 
    .wr_en                                      (mpt_sum_out_vld       ), 
    .din                                        (mpt_sum_out_x_int + 1'b1 ), 
    .full                                       (                      ), 
    .rd_clk                                     (mpt_clk               ), 
    .rd_en                                      (fifo_read_en_int_1      ), 
    .dout                                       (fifo_read_data_Xint_1   ), 
    .valid                                      (fifo_read_valid_Xint_1  ), 
    .empty                                      (fifo_empty_Xint_1     )  
    );                                                          
  fifo_mpt_table_int  u1Y_fifo_mpt_table_int (                   
    .wr_clk                                     ( mpt_clk              ), 
    .rst                                        (vid_vs_in_1d          ), 
    .wr_en                                      (mpt_sum_out_vld       ), 
    .din                                        (mpt_sum_out_y_int     ), 
    .full                                       (                      ), 
    .rd_clk                                     (mpt_clk               ), 
    .rd_en                                      (fifo_read_en_int_1      ), 
    .dout                                       (fifo_read_data_Yint_1   ), 
    .valid                                      (fifo_read_valid_Yint_1  ), 
    .empty                                      (fifo_empty_Yint_1     )  
    );                                                          
  fifo_mpt_table_float  uX_fifo_mpt_table_float (               
    .wr_clk                                     ( mpt_clk              ), 
    .rst                                        (vid_vs_in_1d          ), 
    .wr_en                                      (mpt_sum_out_vld       ), 
    .din                                        (mpt_sum_out_x_float   ), 
    .full                                       (                      ), 
    .rd_clk                                     (mpt_clk               ), 
    .rd_en                                      (fifo_calc_rd_en       ), 
    .dout                                       (fifo_read_data_Xfloat ), 
    .valid                                      (fifo_read_valid_Xfloat), 
    .empty                                      (fifo_empty_Xfloat     )  
    );                                                          
  fifo_mpt_table_float  uY_fifo_mpt_table_float (               
    .wr_clk                                     ( mpt_clk              ), 
    .rst                                        (vid_vs_in_1d          ), 
    .wr_en                                      (mpt_sum_out_vld       ), 
    .din                                        (mpt_sum_out_y_float   ), 
    .full                                       (                      ), 
    .rd_clk                                     (mpt_clk               ), 
    .rd_en                                      (fifo_calc_rd_en       ), 
    .dout                                       (fifo_read_data_Yfloat ), 
    .valid                                      (fifo_read_valid_Yfloat), 
    .empty                                      (fifo_empty_Yfloat     )  
    );                                                          
////============================================================================================
////== == fifo_remap_data
////============================================================================================
wire                                            fifo_remap_rd_en    ;
wire                                            fifo_remap_empty    ;
wire  [31:0]                                    fifo_remap_data     ;
wire                                            fifo_remap_valid    ;
reg   [7:0]                                     rmp_ram_wr_addr     ; 

  fifo_remap_data  u_fifo_remap_data (               
    .wr_clk                                     (axi_clk               ), 
    .rst                                        (vid_vs_in_1d          ), 
    .wr_en                                      (usr_ram_wr_en         ), 
    .din                                        (usr_ram_wr_data       ), 
    .full                                       (                      ), 
    .rd_clk                                     (mpt_clk               ), 
    .rd_en                                      (fifo_remap_rd_en      ), 
    .dout                                       (fifo_remap_data       ), 
    .valid                                      (fifo_remap_valid      ), 
    .empty                                      (fifo_remap_empty      )  
    );   
  assign fifo_remap_rd_en                       = !fifo_remap_empty ;
  always@(posedge mpt_clk or posedge mpt_arst)                  
    if(mpt_arst) begin                                     
        rmp_ram_wr_addr                         <= 8'b0 ;  
    end else begin                                         
      if({usr_axi_req_3d,usr_axi_req_2d} == 2'b01)           
        rmp_ram_wr_addr                         <= 8'b0 ;  
      else if(fifo_remap_valid)   
        rmp_ram_wr_addr                         <= rmp_ram_wr_addr + 1'b1 ; 
    end  
////============================================================================================
////== == one_line == ram_all_seg == 10 * ram_one_seg == 10 * 32 * ram_one_buf ;
////============================================================================================
  always@(posedge mpt_clk) mpt_sum_xy_LA_rdy_1d <= mpt_sum_xy_LA_rdy    ;  
  always@(posedge mpt_clk) usr_axi_busy_1d      <= usr_axi_busy         ;  
  always@(posedge mpt_clk) usr_axi_busy_2d      <= usr_axi_busy_1d      ;  
  always@(posedge mpt_clk) rmp_out_vs           <= rmp_vs_initial       ; 
  always@(posedge mpt_clk) rmp_out_data         <= remap_calc_dout      ;
  always@(posedge mpt_clk) rmp_out_vld          <= remap_calc_vld_out   ;
  always@(posedge mpt_clk or posedge mpt_arst)                  
    if(mpt_arst) begin                                     
        rmp_vs_initial                          <= 1'b0 ;  
    end else begin                                         
      if({vid_vs_in_2d,vid_vs_in_1d} == 2'b10)         
        rmp_vs_initial                          <= 1'b1 ;  
      else if({mpt_sum_xy_LA_rdy_1d,mpt_sum_xy_LA_rdy} == 2'b10) 
        rmp_vs_initial                          <= 1'b0 ;  
    end  
  always@(posedge mpt_clk or posedge mpt_arst)  //one_line finish ,loop back to mpt read data 
    if(mpt_arst) begin                                     
        rmp_first_line                          <= 1'b0 ;  
    end else begin                                          
      if({mpt_sum_xy_LA_rdy_1d,mpt_sum_xy_LA_rdy} == 2'b10 && rmp_vs_initial)       
        rmp_first_line                          <= 1'b1 ;  
      else if(rmp_line_rdy && mpt_sum_xy_LA_rdy) 
        rmp_first_line                          <= 1'b0 ;   
    end  
  always@(posedge mpt_clk or posedge mpt_arst)  //one_line finish ,loop back to mpt read data 
    if(mpt_arst) begin                                     
        rmp_read_ack                            <= 1'b0 ;   
    end else begin                                          
      if(({mpt_sum_xy_LA_rdy_1d,mpt_sum_xy_LA_rdy} == 2'b01 && rmp_vs_initial) || (rmp_line_rdy && mpt_sum_xy_LA_rdy && rmp_out_ready) )        
        rmp_read_ack                            <= 1'b1 ;  
      else if({mpt_sum_xy_LA_rdy_1d,mpt_sum_xy_LA_rdy} == 2'b10) 
        rmp_read_ack                            <= 1'b0 ;  
    end  

  always@(posedge mpt_clk or posedge mpt_arst)  //one_line finish ,loop back to mpt read data 
    if(mpt_arst) begin                                     
        ram_first_seg                           <= 1'b0 ;  
    end else begin                                          
      if(rmp_vs_initial || ram_in_seg_rdy)       
        ram_first_seg                           <= 1'b1 ;  
      else if(ram_inout_seg_ack) 
        ram_first_seg                           <= 1'b0 ;   
    end  
  always@(posedge mpt_clk or posedge mpt_arst)  //one_line data_in ready 
    if(mpt_arst) begin                                    
        rmp_line_rdy                            <= 1'b0 ; 
    end else begin                                        
      // if(seg_num_cnt == SEG_X_NUMBER -1'b1 && ram_out_seg_rdy && ram_in_seg_rdy) 
      if(seg_num_cnt == SEG_X_NUMBER  && ram_out_seg_rdy) 
        rmp_line_rdy                            <= 1'b1 ; 
      else if(rmp_read_ack)                               
        rmp_line_rdy                            <= 1'b0 ; 
    end    
  always@(posedge mpt_clk or posedge mpt_arst) //ram_one_seg   data_in ready          
    if(mpt_arst) begin                                    
        ram_in_seg_rdy                          <= 1'b0 ; 
    end else begin                                        
      if(rmp_read_ack || ram_inout_seg_ack)                                               
        ram_in_seg_rdy                          <= 1'b0 ; 
      else if(ram_buf_rdy && ram_in_buf_cnt >= ram_ymax_add && seg_num_cnt < SEG_X_NUMBER)                               
        ram_in_seg_rdy                          <= 1'b1 ; 
    end       
  always@(posedge mpt_clk or posedge mpt_arst)  //ram_one_seg  data_in ack_signal        
    if(mpt_arst) begin                                    
        ram_inout_seg_ack                       <= 1'b0 ;  
    end else begin                                         
      // if((rmp_first_line && ram_in_seg_rdy && ram_buf_rdy) || (ram_in_seg_rdy && ram_out_seg_rdy && !rmp_line_rdy) )
      if(ram_in_seg_rdy && ram_out_seg_rdy && !rmp_line_rdy)
        ram_inout_seg_ack                       <= 1'b1 ; 
      else                              
        ram_inout_seg_ack                       <= 1'b0 ; 
    end      
  always@(posedge mpt_clk or posedge mpt_arst) //ram_one_buf  data_in ready          
    if(mpt_arst) begin                                                     
        ram_buf_rdy                             <= 1'b0 ;                  
    end else begin                                                         
      if(rmp_read_ack || ram_inout_seg_ack || ram_in_buf_ack)                                      
        ram_buf_rdy                             <= 1'b0 ;                  
      else if((fifo_remap_valid && rmp_ram_wr_addr == SEG_X_WIDTH/4 - 1'b1 ) || (seg_head_cnt == 4'd6 && ram_ymax_add == 5'd0))
        ram_buf_rdy                             <= 1'b1 ;                  
    end    
  always@(posedge mpt_clk or posedge mpt_arst)  //ram_one_buf  data_in ack_signal            
    if(mpt_arst) begin                                    
        ram_in_buf_ack                          <= 1'b0 ;  
    end else begin                                         
      if(usr_axi_req || (ram_ymax_add == 6'd0 && ram_buf_rdy) ) 
        ram_in_buf_ack                          <= 1'b1 ; 
      else if(ram_buf_rdy == 1'b0)                             
        ram_in_buf_ack                          <= 1'b0 ; 
    end   

  always@(posedge mpt_clk or posedge mpt_arst) //ram_one_seg  data_out ready           
    if(mpt_arst) begin                                    
        ram_out_seg_rdy                        <= 1'b0 ; 
    end else begin                                        
      if(rmp_read_ack || ram_inout_seg_ack)                                               
        ram_out_seg_rdy                        <= 1'b0 ; 
      else if(ram_out_seg_xcnt > ram_out_xcnt_LA + RAM_OUT_XCNT_DELAY &&  flag_oddeven == 2'b11 && rmp_out_fifo_full == 1'b0 )                             
        ram_out_seg_rdy                        <= 1'b1 ; 
    end         
    always@(posedge mpt_clk)  ram_inout_seg_ack_d  <= ram_inout_seg_ack  ;  
    always@(posedge mpt_clk)  rmp_line_rdy_d       <= rmp_line_rdy ;   
////============================================================================================
////== seg  control
////============================================================================================
  always@(posedge mpt_clk or posedge mpt_arst)                                    
    if(mpt_arst) begin                                                            
        seg_head_cnt                            <= 4'b0  ;                        
        seg_num_cnt                             <= 4'd0  ;                        
    end else begin                                                                
      if({mpt_sum_xy_LA_rdy_1d,mpt_sum_xy_LA_rdy} == 2'b10 || ram_inout_seg_ack ) 
        seg_head_cnt                            <= 4'd0 ;                         
      else if(!seg_head_cnt[3])                                                   
        seg_head_cnt                            <= seg_head_cnt + 1'b1 ;          
      if(rmp_read_ack)                                                            
        seg_num_cnt                             <= 4'd0 ;                         
      else if({ram_inout_seg_ack_d,ram_inout_seg_ack} == 2'b10 )                   
        seg_num_cnt                             <= seg_num_cnt + 1'b1 ;           
    end                                                                           
////============================================================================================
////== 
////============================================================================================
  always@(posedge mpt_clk or posedge mpt_arst) //1  line end update 
    if(mpt_arst) begin                                        
        cam_in_ymin_LA0                         <= 11'b0    ;         
        cam_in_ymin_LA1                         <= 11'b0    ;         
        cam_in_ymin_LA2                         <= 11'b0    ;         
        cam_in_ymin_LA3                         <= 11'b0    ;         
        cam_in_ymin_LA4                         <= 11'b0    ;         
        cam_in_ymin_LA5                         <= 11'b0    ;         
        cam_in_ymin_LA6                         <= 11'b0    ;         
        cam_in_ymin_LA7                         <= 11'b0    ;         
        cam_in_ymin_LA8                         <= 11'b0    ;         
        cam_in_ymin_LA9                         <= 11'b0    ; 
        cam_in_ymax_LA0                         <= 11'b0    ;         
        cam_in_ymax_LA1                         <= 11'b0    ;         
        cam_in_ymax_LA2                         <= 11'b0    ;         
        cam_in_ymax_LA3                         <= 11'b0    ;         
        cam_in_ymax_LA4                         <= 11'b0    ;         
        cam_in_ymax_LA5                         <= 11'b0    ;         
        cam_in_ymax_LA6                         <= 11'b0    ;         
        cam_in_ymax_LA7                         <= 11'b0    ;         
        cam_in_ymax_LA8                         <= 11'b0    ;         
        cam_in_ymax_LA9                         <= 11'b0    ;  
    end else begin                              
      if({rmp_line_rdy_d,rmp_line_rdy} == 2'b01)  begin    
        cam_in_ymin_LA0                         <= mpt_sum_y_LA0_min    ;         
        cam_in_ymin_LA1                         <= mpt_sum_y_LA1_min    ;         
        cam_in_ymin_LA2                         <= mpt_sum_y_LA2_min    ;         
        cam_in_ymin_LA3                         <= mpt_sum_y_LA3_min    ;         
        cam_in_ymin_LA4                         <= mpt_sum_y_LA4_min    ;         
        cam_in_ymin_LA5                         <= mpt_sum_y_LA5_min    ;         
        cam_in_ymin_LA6                         <= mpt_sum_y_LA6_min    ;         
        cam_in_ymin_LA7                         <= mpt_sum_y_LA7_min    ;         
        cam_in_ymin_LA8                         <= mpt_sum_y_LA8_min    ;         
        cam_in_ymin_LA9                         <= mpt_sum_y_LA9_min    ;  
        cam_in_ymax_LA0                         <= mpt_sum_y_LA0_max    ;         
        cam_in_ymax_LA1                         <= mpt_sum_y_LA1_max    ;         
        cam_in_ymax_LA2                         <= mpt_sum_y_LA2_max    ;         
        cam_in_ymax_LA3                         <= mpt_sum_y_LA3_max    ;         
        cam_in_ymax_LA4                         <= mpt_sum_y_LA4_max    ;         
        cam_in_ymax_LA5                         <= mpt_sum_y_LA5_max    ;         
        cam_in_ymax_LA6                         <= mpt_sum_y_LA6_max    ;         
        cam_in_ymax_LA7                         <= mpt_sum_y_LA7_max    ;         
        cam_in_ymax_LA8                         <= mpt_sum_y_LA8_max    ;         
        cam_in_ymax_LA9                         <= mpt_sum_y_LA9_max    ;  
      end
    end

  always@(posedge mpt_clk or posedge mpt_arst)                                       
    if(mpt_arst) begin                                      
        ram_out_xcnt_LA                         <= 8'd0  ;                             
        mpt_ymin_LA                             <= 11'b0 ;  
        mpt_ymax_LA                             <= 11'b0 ;  
        cam_in_ymin_LA                          <= 11'd0 ;
        cam_in_ymax_LA                          <= 11'd0 ;
    end else begin                                                                                     
      case(seg_num_cnt)                                      
      4'd1 :   ram_out_xcnt_LA                  <= mpt_sum_x_LA0_cnt ; 
      4'd2 :   ram_out_xcnt_LA                  <= mpt_sum_x_LA1_cnt ; 
      4'd3 :   ram_out_xcnt_LA                  <= mpt_sum_x_LA2_cnt ; 
      4'd4 :   ram_out_xcnt_LA                  <= mpt_sum_x_LA3_cnt ; 
      4'd5 :   ram_out_xcnt_LA                  <= mpt_sum_x_LA4_cnt ; 
      4'd6 :   ram_out_xcnt_LA                  <= mpt_sum_x_LA5_cnt ; 
      4'd7 :   ram_out_xcnt_LA                  <= mpt_sum_x_LA6_cnt ; 
      4'd8 :   ram_out_xcnt_LA                  <= mpt_sum_x_LA7_cnt ; 
      4'd9 :   ram_out_xcnt_LA                  <= mpt_sum_x_LA8_cnt ; 
      4'd10:   ram_out_xcnt_LA                  <= mpt_sum_x_LA9_cnt ; 
      // default: ram_out_xcnt_LA                  <= 8'd0 ; 
      endcase 
      case(seg_num_cnt)                                          
      4'd0:    mpt_ymin_LA                      <= mpt_sum_y_LA0_min ;         
      4'd1:    mpt_ymin_LA                      <= mpt_sum_y_LA1_min ;         
      4'd2:    mpt_ymin_LA                      <= mpt_sum_y_LA2_min ;         
      4'd3:    mpt_ymin_LA                      <= mpt_sum_y_LA3_min ;         
      4'd4:    mpt_ymin_LA                      <= mpt_sum_y_LA4_min ;         
      4'd5:    mpt_ymin_LA                      <= mpt_sum_y_LA5_min ;         
      4'd6:    mpt_ymin_LA                      <= mpt_sum_y_LA6_min ;         
      4'd7:    mpt_ymin_LA                      <= mpt_sum_y_LA7_min ;         
      4'd8:    mpt_ymin_LA                      <= mpt_sum_y_LA8_min ;         
      4'd9:    mpt_ymin_LA                      <= mpt_sum_y_LA9_min ;  
      // default: mpt_ymin_LA                      <= 11'd0 ; 
      endcase   
      case(seg_num_cnt)                                                
      4'd0:    mpt_ymax_LA                      <= mpt_sum_y_LA0_max ; 
      4'd1:    mpt_ymax_LA                      <= mpt_sum_y_LA1_max ; 
      4'd2:    mpt_ymax_LA                      <= mpt_sum_y_LA2_max ; 
      4'd3:    mpt_ymax_LA                      <= mpt_sum_y_LA3_max ; 
      4'd4:    mpt_ymax_LA                      <= mpt_sum_y_LA4_max ; 
      4'd5:    mpt_ymax_LA                      <= mpt_sum_y_LA5_max ; 
      4'd6:    mpt_ymax_LA                      <= mpt_sum_y_LA6_max ; 
      4'd7:    mpt_ymax_LA                      <= mpt_sum_y_LA7_max ; 
      4'd8:    mpt_ymax_LA                      <= mpt_sum_y_LA8_max ; 
      4'd9:    mpt_ymax_LA                      <= mpt_sum_y_LA9_max ; 
      // default: mpt_ymax_LA                      <= 11'd0 ;             
      endcase                                                          
      case(seg_num_cnt)                                          
      4'd0:    cam_in_ymin_LA                   <= cam_in_ymin_LA0    ;         
      4'd1:    cam_in_ymin_LA                   <= cam_in_ymin_LA1    ;         
      4'd2:    cam_in_ymin_LA                   <= cam_in_ymin_LA2    ;         
      4'd3:    cam_in_ymin_LA                   <= cam_in_ymin_LA3    ;         
      4'd4:    cam_in_ymin_LA                   <= cam_in_ymin_LA4    ;         
      4'd5:    cam_in_ymin_LA                   <= cam_in_ymin_LA5    ;         
      4'd6:    cam_in_ymin_LA                   <= cam_in_ymin_LA6    ;         
      4'd7:    cam_in_ymin_LA                   <= cam_in_ymin_LA7    ;         
      4'd8:    cam_in_ymin_LA                   <= cam_in_ymin_LA8    ;         
      4'd9:    cam_in_ymin_LA                   <= cam_in_ymin_LA9    ;  
      // default: cam_in_ymin_LA                   <= 11'd0              ; 
      endcase   
      case(seg_num_cnt)                                          
      4'd0:    cam_in_ymax_LA                   <= cam_in_ymax_LA0    ;         
      4'd1:    cam_in_ymax_LA                   <= cam_in_ymax_LA1    ;         
      4'd2:    cam_in_ymax_LA                   <= cam_in_ymax_LA2    ;         
      4'd3:    cam_in_ymax_LA                   <= cam_in_ymax_LA3    ;         
      4'd4:    cam_in_ymax_LA                   <= cam_in_ymax_LA4    ;         
      4'd5:    cam_in_ymax_LA                   <= cam_in_ymax_LA5    ;         
      4'd6:    cam_in_ymax_LA                   <= cam_in_ymax_LA6    ;         
      4'd7:    cam_in_ymax_LA                   <= cam_in_ymax_LA7    ;         
      4'd8:    cam_in_ymax_LA                   <= cam_in_ymax_LA8    ;         
      4'd9:    cam_in_ymax_LA                   <= cam_in_ymax_LA9    ;  
      // default: cam_in_ymax_LA                   <= 11'd0              ; 
      endcase   
    end
////============================================================================================
////==ram input base address latch
////============================================================================================
  assign  seg_ack_en0 = ({ram_inout_seg_ack_d,ram_inout_seg_ack} == 2'b01 && seg_num_cnt == 4'd0) ? 1'b1 : 1'b0 ;
  assign  seg_ack_en1 = ({ram_inout_seg_ack_d,ram_inout_seg_ack} == 2'b01 && seg_num_cnt == 4'd1) ? 1'b1 : 1'b0 ;
  assign  seg_ack_en2 = ({ram_inout_seg_ack_d,ram_inout_seg_ack} == 2'b01 && seg_num_cnt == 4'd2) ? 1'b1 : 1'b0 ;
  assign  seg_ack_en3 = ({ram_inout_seg_ack_d,ram_inout_seg_ack} == 2'b01 && seg_num_cnt == 4'd3) ? 1'b1 : 1'b0 ;
  assign  seg_ack_en4 = ({ram_inout_seg_ack_d,ram_inout_seg_ack} == 2'b01 && seg_num_cnt == 4'd4) ? 1'b1 : 1'b0 ;
  assign  seg_ack_en5 = ({ram_inout_seg_ack_d,ram_inout_seg_ack} == 2'b01 && seg_num_cnt == 4'd5) ? 1'b1 : 1'b0 ;
  assign  seg_ack_en6 = ({ram_inout_seg_ack_d,ram_inout_seg_ack} == 2'b01 && seg_num_cnt == 4'd6) ? 1'b1 : 1'b0 ;
  assign  seg_ack_en7 = ({ram_inout_seg_ack_d,ram_inout_seg_ack} == 2'b01 && seg_num_cnt == 4'd7) ? 1'b1 : 1'b0 ;
  assign  seg_ack_en8 = ({ram_inout_seg_ack_d,ram_inout_seg_ack} == 2'b01 && seg_num_cnt == 4'd8) ? 1'b1 : 1'b0 ;
  assign  seg_ack_en9 = ({ram_inout_seg_ack_d,ram_inout_seg_ack} == 2'b01 && seg_num_cnt == 4'd9) ? 1'b1 : 1'b0 ;
  always@(posedge mpt_clk or posedge mpt_arst)    // to next  line ram in                                     
    if(mpt_arst) begin                                        
        ram_in_ybuf_min0                        <= 5'b0 ;         
        ram_in_ybuf_min1                        <= 5'b0 ;         
        ram_in_ybuf_min2                        <= 5'b0 ;         
        ram_in_ybuf_min3                        <= 5'b0 ;         
        ram_in_ybuf_min4                        <= 5'b0 ;         
        ram_in_ybuf_min5                        <= 5'b0 ;         
        ram_in_ybuf_min6                        <= 5'b0 ;         
        ram_in_ybuf_min7                        <= 5'b0 ;         
        ram_in_ybuf_min8                        <= 5'b0 ;         
        ram_in_ybuf_min9                        <= 5'b0 ;  
    end else begin                              
      if(rmp_vs_initial)   ram_in_ybuf_min0     <= 5'b0    ;    
      else if(seg_ack_en0) ram_in_ybuf_min0     <= ram_in_ybuf_min + ram_ymin_add ;   
      if(rmp_vs_initial)   ram_in_ybuf_min1     <= 5'b0    ;    
      else if(seg_ack_en1) ram_in_ybuf_min1     <= ram_in_ybuf_min + ram_ymin_add ;  
      if(rmp_vs_initial)   ram_in_ybuf_min2     <= 5'b0    ;    
      else if(seg_ack_en2) ram_in_ybuf_min2     <= ram_in_ybuf_min + ram_ymin_add ;   
      if(rmp_vs_initial)   ram_in_ybuf_min3     <= 5'b0    ;    
      else if(seg_ack_en3) ram_in_ybuf_min3     <= ram_in_ybuf_min + ram_ymin_add ; 
      if(rmp_vs_initial)   ram_in_ybuf_min4     <= 5'b0    ;    
      else if(seg_ack_en4) ram_in_ybuf_min4     <= ram_in_ybuf_min + ram_ymin_add ;   
      if(rmp_vs_initial)   ram_in_ybuf_min5     <= 5'b0    ;    
      else if(seg_ack_en5) ram_in_ybuf_min5     <= ram_in_ybuf_min + ram_ymin_add ; 
      if(rmp_vs_initial)   ram_in_ybuf_min6     <= 5'b0    ;    
      else if(seg_ack_en6) ram_in_ybuf_min6     <= ram_in_ybuf_min + ram_ymin_add ;   
      if(rmp_vs_initial)   ram_in_ybuf_min7     <= 5'b0    ;    
      else if(seg_ack_en7) ram_in_ybuf_min7     <= ram_in_ybuf_min + ram_ymin_add ; 
      if(rmp_vs_initial)   ram_in_ybuf_min8     <= 5'b0    ;    
      else if(seg_ack_en8) ram_in_ybuf_min8     <= ram_in_ybuf_min + ram_ymin_add ;   
      if(rmp_vs_initial)   ram_in_ybuf_min9     <= 5'b0    ;    
      else if(seg_ack_en9) ram_in_ybuf_min9     <= ram_in_ybuf_min + ram_ymin_add ;     
    end 
  always@(posedge mpt_clk or posedge mpt_arst)    // to next  line ram in                                     
    if(mpt_arst) begin                                        
        ram_in_ybuf_max0                        <= 5'b0 ;         
        ram_in_ybuf_max1                        <= 5'b0 ;         
        ram_in_ybuf_max2                        <= 5'b0 ;         
        ram_in_ybuf_max3                        <= 5'b0 ;         
        ram_in_ybuf_max4                        <= 5'b0 ;         
        ram_in_ybuf_max5                        <= 5'b0 ;         
        ram_in_ybuf_max6                        <= 5'b0 ;         
        ram_in_ybuf_max7                        <= 5'b0 ;         
        ram_in_ybuf_max8                        <= 5'b0 ;         
        ram_in_ybuf_max9                        <= 5'b0 ;  
    end else begin                              
      if(rmp_vs_initial)   ram_in_ybuf_max0     <= 5'b0    ;    
      else if(seg_ack_en0) ram_in_ybuf_max0     <= ram_in_ybuf_max + ram_ymax_add ;   
      if(rmp_vs_initial)   ram_in_ybuf_max1     <= 5'b0    ;    
      else if(seg_ack_en1) ram_in_ybuf_max1     <= ram_in_ybuf_max + ram_ymax_add ;  
      if(rmp_vs_initial)   ram_in_ybuf_max2     <= 5'b0    ;    
      else if(seg_ack_en2) ram_in_ybuf_max2     <= ram_in_ybuf_max + ram_ymax_add ;   
      if(rmp_vs_initial)   ram_in_ybuf_max3     <= 5'b0    ;    
      else if(seg_ack_en3) ram_in_ybuf_max3     <= ram_in_ybuf_max + ram_ymax_add ; 
      if(rmp_vs_initial)   ram_in_ybuf_max4     <= 5'b0    ;    
      else if(seg_ack_en4) ram_in_ybuf_max4     <= ram_in_ybuf_max + ram_ymax_add ;   
      if(rmp_vs_initial)   ram_in_ybuf_max5     <= 5'b0    ;    
      else if(seg_ack_en5) ram_in_ybuf_max5     <= ram_in_ybuf_max + ram_ymax_add ; 
      if(rmp_vs_initial)   ram_in_ybuf_max6     <= 5'b0    ;    
      else if(seg_ack_en6) ram_in_ybuf_max6     <= ram_in_ybuf_max + ram_ymax_add ;   
      if(rmp_vs_initial)   ram_in_ybuf_max7     <= 5'b0    ;    
      else if(seg_ack_en7) ram_in_ybuf_max7     <= ram_in_ybuf_max + ram_ymax_add ; 
      if(rmp_vs_initial)   ram_in_ybuf_max8     <= 5'b0    ;    
      else if(seg_ack_en8) ram_in_ybuf_max8     <= ram_in_ybuf_max + ram_ymax_add ;   
      if(rmp_vs_initial)   ram_in_ybuf_max9     <= 5'b0    ;    
      else if(seg_ack_en9) ram_in_ybuf_max9     <= ram_in_ybuf_max + ram_ymax_add ;     
    end 
  always@(posedge mpt_clk or posedge mpt_arst)                    
    if(mpt_arst) begin                                            
        ram_ymin_add                            <= 5'd0  ;     
        ram_ymax_add                            <= 5'd0  ;   
    end else begin       
      if(rmp_first_line)
        ram_ymin_add                            <= 5'd0  ; 
      else      
        ram_ymin_add                            <= mpt_ymin_LA - cam_in_ymin_LA  ; 
      if(rmp_first_line)
        ram_ymax_add                            <= mpt_ymax_LA - mpt_ymin_LA + 2'd2  ; 
      else      
        ram_ymax_add                            <= mpt_ymax_LA - cam_in_ymax_LA  ; 
    end
  always@(posedge mpt_clk or posedge mpt_arst)                    
    if(mpt_arst) begin                                            
        ram_in_ybuf_min                         <= 5'd0  ;     
    end else begin                                                 
      case(seg_num_cnt)                                            
      4'd0:    ram_in_ybuf_min                  <= ram_in_ybuf_min0 ; 
      4'd1:    ram_in_ybuf_min                  <= ram_in_ybuf_min1 ; 
      4'd2:    ram_in_ybuf_min                  <= ram_in_ybuf_min2 ; 
      4'd3:    ram_in_ybuf_min                  <= ram_in_ybuf_min3 ; 
      4'd4:    ram_in_ybuf_min                  <= ram_in_ybuf_min4 ; 
      4'd5:    ram_in_ybuf_min                  <= ram_in_ybuf_min5 ; 
      4'd6:    ram_in_ybuf_min                  <= ram_in_ybuf_min6 ; 
      4'd7:    ram_in_ybuf_min                  <= ram_in_ybuf_min7 ; 
      4'd8:    ram_in_ybuf_min                  <= ram_in_ybuf_min8 ; 
      4'd9:    ram_in_ybuf_min                  <= ram_in_ybuf_min9 ;  
      endcase      
    end
  always@(posedge mpt_clk or posedge mpt_arst)                    
    if(mpt_arst) begin                                            
        ram_in_ybuf_max                         <= 5'd0  ;     
    end else begin                                                 
      case(seg_num_cnt)                                            
      4'd0:    ram_in_ybuf_max                  <= ram_in_ybuf_max0 ; 
      4'd1:    ram_in_ybuf_max                  <= ram_in_ybuf_max1 ; 
      4'd2:    ram_in_ybuf_max                  <= ram_in_ybuf_max2 ; 
      4'd3:    ram_in_ybuf_max                  <= ram_in_ybuf_max3 ; 
      4'd4:    ram_in_ybuf_max                  <= ram_in_ybuf_max4 ; 
      4'd5:    ram_in_ybuf_max                  <= ram_in_ybuf_max5 ; 
      4'd6:    ram_in_ybuf_max                  <= ram_in_ybuf_max6 ; 
      4'd7:    ram_in_ybuf_max                  <= ram_in_ybuf_max7 ; 
      4'd8:    ram_in_ybuf_max                  <= ram_in_ybuf_max8 ; 
      4'd9:    ram_in_ybuf_max                  <= ram_in_ybuf_max9 ;  
      endcase      
    end
  always@(posedge mpt_clk or posedge mpt_arst)                    
    if(mpt_arst) begin                                            
        ram_out_ybuf_min                         <= 5'd0  ;     
    end else begin                                                 
      case(seg_num_cnt)                                            
      4'd1 :    ram_out_ybuf_min                  <= ram_in_ybuf_min0 ; 
      4'd2 :    ram_out_ybuf_min                  <= ram_in_ybuf_min1 ; 
      4'd3 :    ram_out_ybuf_min                  <= ram_in_ybuf_min2 ; 
      4'd4 :    ram_out_ybuf_min                  <= ram_in_ybuf_min3 ; 
      4'd5 :    ram_out_ybuf_min                  <= ram_in_ybuf_min4 ; 
      4'd6 :    ram_out_ybuf_min                  <= ram_in_ybuf_min5 ; 
      4'd7 :    ram_out_ybuf_min                  <= ram_in_ybuf_min6 ; 
      4'd8 :    ram_out_ybuf_min                  <= ram_in_ybuf_min7 ; 
      4'd9 :    ram_out_ybuf_min                  <= ram_in_ybuf_min8 ; 
      4'd10:    ram_out_ybuf_min                  <= ram_in_ybuf_min9 ;  
      endcase      
    end
  always@(posedge mpt_clk or posedge mpt_arst)                    
    if(mpt_arst) begin                                         
        cam_out_ymin_base                       <= 11'd0 ;     
    end else begin                                                 
      if({ram_inout_seg_ack_d,ram_inout_seg_ack} == 2'b01)        
        cam_out_ymin_base                       <= mpt_ymin_LA ;   
    end 

////============================================================================================
////==ram input address calculate
////============================================================================================
  always@(posedge mpt_clk)  usr_axi_req_2d      <= usr_axi_req_1d  ;  
  always@(posedge mpt_clk)  usr_axi_req_3d      <= usr_axi_req_2d  ;  
  always@(posedge mpt_clk)  usr_axi_req         <= usr_axi_req_3d  ;  
  always@(posedge mpt_clk or posedge mpt_arst)             
    if(mpt_arst) begin                                      
        ddr_rd_yaddr_base                       <= 24'b0;  
    end else begin                                          
      if({usr_axi_req_2d,usr_axi_req_1d} == 2'b01 && rmp_first_line)
        ddr_rd_yaddr_base                       <= mpt_ymin_LA + ram_in_buf_cnt    ; 
      else if({usr_axi_req_2d,usr_axi_req_1d} == 2'b01)
        ddr_rd_yaddr_base                       <= cam_in_ymax_LA + ram_in_buf_cnt + 4'd2 ;                  
    end                                                                    
  assign  ddr_Y_addr_base                       =  ddr_rd_yaddr_base * VID_HACT ;
  assign  ddr_X_addr_base                       =  seg_num_cnt * SEG_X_WIDTH    ;
  always@(posedge mpt_clk or posedge mpt_arst)             
    if(mpt_arst) begin                                     
        usr_axi_req_1d                          <= 1'b0 ;  
        usr_axi_arlen                           <= 8'b0 ;  
        usr_axi_addr                            <= 24'b0;  
    end else begin                                         
        usr_axi_arlen                           <= SEG_X_WIDTH; 
        usr_axi_addr                            <= ddr_Y_addr_base + ddr_X_addr_base  ;   
      if(((seg_head_cnt == 4'd4 && ram_ymax_add > 5'd0) || (ram_buf_rdy && ram_in_buf_cnt < ram_ymax_add) )
       && seg_num_cnt < SEG_X_NUMBER && usr_axi_busy_1d == 1'b0)
        usr_axi_req_1d                          <= 1'b1;                   
      else if((vid_vs_in_2d && !usr_axi_busy_2d) || {usr_axi_busy_2d,usr_axi_busy_1d} == 2'b01)                  
        usr_axi_req_1d                          <= 1'b0;                   
    end                                                                    
                                                                           
  always@(posedge mpt_clk or posedge mpt_arst)                             
    if(mpt_arst) begin                                                     
        ram_in_buf_cnt                          <= 6'b0  ;                 
    end else begin                                                         
      if(seg_head_cnt == 4'd2 || ram_inout_seg_ack )                                             
        ram_in_buf_cnt                          <= 6'd0 ;                  
      else if({usr_axi_req_3d,usr_axi_req_2d} == 2'b10)                  
        ram_in_buf_cnt                          <= ram_in_buf_cnt + 1'b1 ; 
    end                                                                    
                                   
////============================================================================================
////==RAM  write
////============================================================================================ 
  always@(posedge mpt_clk)  ram_in_yaddr0       <= ram_in_ybuf_max + ram_in_buf_cnt - 1'b1 ; 
  always@(posedge mpt_clk)  ram_in_yaddr        <= ram_in_yaddr0   ;  
  assign                    ram_in_xaddr        =  rmp_ram_wr_addr[4:0]  ;  
  assign                    ram_addra_wr        = {ram_in_yaddr[4:0],ram_in_xaddr[4:0],2'b0} ;  
  always@(posedge mpt_clk)  ram_dina            <= fifo_remap_data ;  
  always@(posedge mpt_clk or posedge mpt_arst)                    
    if(mpt_arst) begin                                            
        ram0_ena                                     <= 1'b0 ;       
        ram1_ena                                     <= 1'b0 ;           
        ram2_ena                                     <= 1'b0 ;         
        ram3_ena                                     <= 1'b0 ;        
        ram4_ena                                     <= 1'b0 ;       
        ram5_ena                                     <= 1'b0 ;      
        ram6_ena                                     <= 1'b0 ;     
        ram7_ena                                     <= 1'b0 ;     
        ram8_ena                                     <= 1'b0 ;          
        ram9_ena                                     <= 1'b0 ;                
    end else begin                                                
      if(seg_num_cnt == 5'd0)         ram0_ena       <= fifo_remap_valid;  
      else if(seg_num_cnt == 5'd1)    ram0_ena       <= ram_enb      ;          
      else                            ram0_ena       <= 1'b0 ;        
      if(seg_num_cnt == 5'd1)         ram1_ena       <= fifo_remap_valid;  
      else if(seg_num_cnt == 5'd2)    ram1_ena       <= ram_enb      ;         
      else                            ram1_ena       <= 1'b0;     
      if(seg_num_cnt == 5'd2)         ram2_ena       <= fifo_remap_valid; 
      else if(seg_num_cnt == 5'd3)    ram2_ena       <= ram_enb      ;          
      else                            ram2_ena       <= 1'b0;               
      if(seg_num_cnt == 5'd3)         ram3_ena       <= fifo_remap_valid;       
      else if(seg_num_cnt == 5'd4)    ram3_ena       <= ram_enb      ;         
      else                            ram3_ena       <= 1'b0;          
      if(seg_num_cnt == 5'd4)         ram4_ena       <= fifo_remap_valid;    
      else if(seg_num_cnt == 5'd5)    ram4_ena       <= ram_enb      ;            
      else                            ram4_ena       <= 1'b0;                        
      if(seg_num_cnt == 5'd5)         ram5_ena       <= fifo_remap_valid;  
      else if(seg_num_cnt == 5'd6)    ram5_ena       <= ram_enb      ;           
      else                            ram5_ena       <= 1'b0;        
      if(seg_num_cnt == 5'd6)         ram6_ena       <= fifo_remap_valid; 
      else if(seg_num_cnt == 5'd7)    ram6_ena       <= ram_enb      ;            
      else                            ram6_ena       <= 1'b0;            
      if(seg_num_cnt == 5'd7)         ram7_ena       <= fifo_remap_valid; 
      else if(seg_num_cnt == 5'd8)    ram7_ena       <= ram_enb      ;            
      else                            ram7_ena       <= 1'b0;        
      if(seg_num_cnt == 5'd8)         ram8_ena       <= fifo_remap_valid; 
      else if(seg_num_cnt == 5'd9)    ram8_ena       <= ram_enb      ;            
      else                            ram8_ena       <= 1'b0;       
      if(seg_num_cnt == 5'd9)         ram9_ena       <= fifo_remap_valid;
      else if(seg_num_cnt == 5'd10)   ram9_ena       <= ram_enb      ;             
      else                            ram9_ena       <= 1'b0;               
    end    
  always@(posedge mpt_clk or posedge mpt_arst)                    
    if(mpt_arst) begin                                            
        ram0_wea                                     <= 1'b0 ;       
        ram1_wea                                     <= 1'b0 ;           
        ram2_wea                                     <= 1'b0 ;         
        ram3_wea                                     <= 1'b0 ;        
        ram4_wea                                     <= 1'b0 ;       
        ram5_wea                                     <= 1'b0 ;      
        ram6_wea                                     <= 1'b0 ;     
        ram7_wea                                     <= 1'b0 ;     
        ram8_wea                                     <= 1'b0 ;          
        ram9_wea                                     <= 1'b0 ;                
    end else begin                                        
      if(seg_num_cnt == 5'd1)    ram0_wea            <= 1'b0 ;          
      else                       ram0_wea            <= 1'b1 ;        
      if(seg_num_cnt == 5'd2)    ram1_wea            <= 1'b0 ;         
      else                       ram1_wea            <= 1'b1 ;     
      if(seg_num_cnt == 5'd3)    ram2_wea            <= 1'b0 ;          
      else                       ram2_wea            <= 1'b1 ;               
      if(seg_num_cnt == 5'd4)    ram3_wea            <= 1'b0 ;         
      else                       ram3_wea            <= 1'b1 ;          
      if(seg_num_cnt == 5'd5)    ram4_wea            <= 1'b0 ;            
      else                       ram4_wea            <= 1'b1 ;                        
      if(seg_num_cnt == 5'd6)    ram5_wea            <= 1'b0 ;           
      else                       ram5_wea            <= 1'b1 ;        
      if(seg_num_cnt == 5'd7)    ram6_wea            <= 1'b0 ;            
      else                       ram6_wea            <= 1'b1 ;            
      if(seg_num_cnt == 5'd8)    ram7_wea            <= 1'b0 ;            
      else                       ram7_wea            <= 1'b1 ;        
      if(seg_num_cnt == 5'd9)    ram8_wea            <= 1'b0 ;            
      else                       ram8_wea            <= 1'b1 ;       
      if(seg_num_cnt == 5'd10)   ram9_wea            <= 1'b0 ;             
      else                       ram9_wea            <= 1'b1 ;           
    end   
                                               
////============================================================================================
////==RAM  read
////============================================================================================ 
  always@(posedge mpt_clk) fifo_read_en_int_1d    <= fifo_read_en_int      ; 
  always@(posedge mpt_clk) fifo_read_en_int_2d    <= fifo_read_en_int_1d   ; 
  always@(posedge mpt_clk) fifo_read_en_int_3d    <= fifo_read_en_int_2d   ; 
  always@(posedge mpt_clk) fifo_read_en_int_4d    <= fifo_read_en_int_3d   ; 
  always@(posedge mpt_clk) fifo_read_en_int_5d    <= fifo_read_en_int_4d   ; 
  always@(posedge mpt_clk) fifo_read_en_int_6d    <= fifo_read_en_int_5d   ; 
  always@(posedge mpt_clk) fifo_read_en_int_7d    <= fifo_read_en_int_6d   ; 
  always@(posedge mpt_clk) fifo_read_en_int_8d    <= fifo_read_en_int_7d   ; 
  always@(posedge mpt_clk) fifo_read_en_int_1_1d  <= fifo_read_en_int_1    ; 
  always@(posedge mpt_clk) fifo_read_en_int_1_2d  <= fifo_read_en_int_1_1d ; 
  always@(posedge mpt_clk) fifo_read_en_int_1_3d  <= fifo_read_en_int_1_2d ; 
  always@(posedge mpt_clk) fifo_read_en_int_1_4d  <= fifo_read_en_int_1_3d ; 
  always@(posedge mpt_clk) fifo_read_en_int_1_5d  <= fifo_read_en_int_1_4d ; 
  always@(posedge mpt_clk) fifo_read_en_int_1_6d  <= fifo_read_en_int_1_5d ; 
  always@(posedge mpt_clk) fifo_read_en_int_1_7d  <= fifo_read_en_int_1_6d ; 
  always@(posedge mpt_clk) fifo_read_en_int_1_8d  <= fifo_read_en_int_1_7d ; 
  always@(posedge mpt_clk or posedge mpt_arst)                    
    if(mpt_arst) begin  
        flag_oddeven                            <= 2'b0 ; 
        ram_out_seg_xcnt                        <= 9'b0 ; 
        fifo_read_en_int                        <= 1'b0 ;   
        fifo_read_en_int_1                      <= 1'b0 ;   
    end else begin                                                
      if(rmp_read_ack)   
        flag_oddeven                            <= 2'b0 ;          
      else                       
        flag_oddeven                            <= flag_oddeven + 1'b1 ; 
      
      if(vid_vs_in_2d )   
        ram_out_seg_xcnt                        <= 9'h1ff ; 
      else if(ram_inout_seg_ack || seg_num_cnt > SEG_X_NUMBER )   
        ram_out_seg_xcnt                        <= 9'd0   ;          
      else if(flag_oddeven == 2'b11 && !ram_out_seg_xcnt[8])                      
        ram_out_seg_xcnt                        <= ram_out_seg_xcnt + 1'b1 ;  
       
      if(flag_oddeven == 2'b0 && (ram_out_seg_xcnt == RAM_OUT_XCNT_DELAY || 
        (ram_out_xaddr < SEG_X_WIDTH && ram_out_seg_xcnt > RAM_OUT_XCNT_DELAY)) && !ram_out_seg_xcnt[8])   
        fifo_read_en_int                        <= 1'b1 ;          
      else                       
        fifo_read_en_int                        <= 1'b0 ;   
      if(flag_oddeven == 2'b0 && (ram_out_seg_xcnt == RAM_OUT_XCNT_DELAY || 
        (ram_out_xaddr_add1 < SEG_X_WIDTH && ram_out_seg_xcnt > RAM_OUT_XCNT_DELAY)) && !ram_out_seg_xcnt[8])   
        fifo_read_en_int_1                      <= 1'b1 ;          
      else                       
        fifo_read_en_int_1                      <= 1'b0 ;  
    end   
    
  assign  ram_out_xaddr_shift                   = (seg_num_cnt-1) * SEG_X_WIDTH                   ; 
  assign  ram_out_yaddr_shift                   = fifo_read_data_Yint - cam_out_ymin_base         ; 
  assign  ram_out_yaddr                         = ram_out_ybuf_min + ram_out_yaddr_shift[4:0]     ; 
  assign  ram_out_xaddr                         = fifo_read_data_Xint   -  ram_out_xaddr_shift    ; 
  always@(posedge mpt_clk) ram_read_addr        <= {ram_out_yaddr[4:0]  ,ram_out_xaddr[6:0]}      ;

  assign  ram_out_yaddr_shift_1                 = fifo_read_data_Yint_1 - cam_out_ymin_base       ; 
  assign  ram_out_yaddr_1                       = ram_out_ybuf_min + ram_out_yaddr_shift_1[4:0]   ; 
  assign  ram_out_xaddr_add1                    = fifo_read_data_Xint_1 -  ram_out_xaddr_shift    ; 
  always@(posedge mpt_clk) ram_read_addr_add1   <= {ram_out_yaddr_1[4:0],ram_out_xaddr_add1[6:0]} ;

  always@(posedge mpt_clk or posedge mpt_arst)                     
    if(mpt_arst) begin                                             
        ram_enb                                 <= 1'b0 ;        
    end else begin                                                 
      if(ram_out_seg_xcnt > 9'd1 && ram_out_seg_xcnt < ram_out_xcnt_LA + RAM_OUT_XCNT_DELAY + 9'd2) 
        ram_enb                                 <= 1'b1 ;  
      else                           
        ram_enb                                 <= 1'b0 ; 
    end    
  always@(posedge mpt_clk or posedge mpt_arst)                     
    if(mpt_arst) begin                                             
        ram0_out_xaddr_overflow                  <= 1'b0 ;       
    end else begin                 
      if(rmp_vs_initial)               
        ram0_out_xaddr_overflow                  <= 1'b0 ;                  
      else if(ram_out_xaddr > SEG_X_WIDTH - 1'b1 && ram_out_seg_xcnt > RAM_OUT_XCNT_DELAY && !ram_out_seg_xcnt[8] && flag_oddeven == 2'b01) 
        ram0_out_xaddr_overflow                  <= 1'b1 ;  
      else if(ram_out_seg_xcnt == RAM_OUT_XCNT_DELAY - 4'd4)                          
        ram0_out_xaddr_overflow                  <= 1'b0 ;   
    end   
  always@(posedge mpt_clk or posedge mpt_arst)                     
    if(mpt_arst) begin                                             
        ram1_out_xaddr_overflow                  <= 1'b0 ;       
    end else begin                 
      if(rmp_vs_initial)               
        ram1_out_xaddr_overflow                  <= 1'b0 ;                  
      else if(ram_out_xaddr_add1 > SEG_X_WIDTH - 1'b1 && ram_out_seg_xcnt > RAM_OUT_XCNT_DELAY && !ram_out_seg_xcnt[8] && flag_oddeven == 2'b01) 
        ram1_out_xaddr_overflow                  <= 1'b1 ;  
      else if(ram_out_seg_xcnt == RAM_OUT_XCNT_DELAY - 4'd4)                          
        ram1_out_xaddr_overflow                  <= 1'b0 ;   
    end   

  always@(posedge mpt_clk or posedge mpt_arst)                     
    if(mpt_arst) begin                                             
        ram_addra_rd                            <= 12'b0;        
        ram_addrb_rd                            <= 12'b0;     
    end else begin                                                 
      if(flag_oddeven == 2'b11) 
        ram_addra_rd                            <= ram_read_addr[11:0] ; // 
      else if(flag_oddeven == 2'b01) 
        ram_addra_rd                            <= ram_read_addr[11:0] + 9'h80 ; // 

      if(flag_oddeven == 2'b11) 
        ram_addrb_rd                            <= ram_read_addr_add1[11:0] ; // 
      else if(flag_oddeven == 2'b01)   
        ram_addrb_rd                            <= ram_read_addr_add1[11:0] + 9'h80 ; // 
    end                                         
  always@(posedge mpt_clk or posedge mpt_arst)                     
    if(mpt_arst) begin                                           
        ram_addrb                               <= 12'b0;         
        ram0_addra                              <= 12'b0;   
        ram1_addra                              <= 12'b0;  
        ram2_addra                              <= 12'b0;  
        ram3_addra                              <= 12'b0;  
        ram4_addra                              <= 12'b0;  
        ram5_addra                              <= 12'b0;  
        ram6_addra                              <= 12'b0;  
        ram7_addra                              <= 12'b0;  
        ram8_addra                              <= 12'b0;  
        ram9_addra                              <= 12'b0;     
    end else begin                                                 
        ram_addrb                               <= ram_addrb_rd ; //        
      if(seg_num_cnt == 5'd1)    ram0_addra     <= ram_addra_rd;          
      else                       ram0_addra     <= ram_addra_wr;          
      if(seg_num_cnt == 5'd2)    ram1_addra     <= ram_addra_rd;          
      else                       ram1_addra     <= ram_addra_wr;         
      if(seg_num_cnt == 5'd3)    ram2_addra     <= ram_addra_rd;          
      else                       ram2_addra     <= ram_addra_wr;              
      if(seg_num_cnt == 5'd4)    ram3_addra     <= ram_addra_rd;          
      else                       ram3_addra     <= ram_addra_wr;           
      if(seg_num_cnt == 5'd5)    ram4_addra     <= ram_addra_rd;          
      else                       ram4_addra     <= ram_addra_wr;            
      if(seg_num_cnt == 5'd6)    ram5_addra     <= ram_addra_rd;          
      else                       ram5_addra     <= ram_addra_wr;           
      if(seg_num_cnt == 5'd7)    ram6_addra     <= ram_addra_rd;          
      else                       ram6_addra     <= ram_addra_wr;            
      if(seg_num_cnt == 5'd8)    ram7_addra     <= ram_addra_rd;          
      else                       ram7_addra     <= ram_addra_wr;            
      if(seg_num_cnt == 5'd9)    ram8_addra     <= ram_addra_rd;          
      else                       ram8_addra     <= ram_addra_wr;              
      if(seg_num_cnt == 5'd10)   ram9_addra     <= ram_addra_rd;          
      else                       ram9_addra     <= ram_addra_wr;    
    end                                         
  always@(posedge mpt_clk or posedge mpt_arst)                    
    if(mpt_arst) begin                                             
        ram0_enb                                <= 1'b0 ;        
        ram1_enb                                <= 1'b0 ;          
        ram2_enb                                <= 1'b0 ;         
        ram3_enb                                <= 1'b0 ;         
        ram4_enb                                <= 1'b0 ;         
        ram5_enb                                <= 1'b0 ;         
        ram6_enb                                <= 1'b0 ;         
        ram7_enb                                <= 1'b0 ;         
        ram8_enb                                <= 1'b0 ;         
        ram9_enb                                <= 1'b0 ;          
    end else begin                                                 
      if(seg_num_cnt == 5'd1)    ram0_enb       <= ram_enb ;          
      else                       ram0_enb       <= 1'b0;          
      if(seg_num_cnt == 5'd2)    ram1_enb       <= ram_enb;          
      else                       ram1_enb       <= 1'b0;         
      if(seg_num_cnt == 5'd3)    ram2_enb       <= ram_enb;          
      else                       ram2_enb       <= 1'b0;              
      if(seg_num_cnt == 5'd4)    ram3_enb       <= ram_enb;          
      else                       ram3_enb       <= 1'b0;           
      if(seg_num_cnt == 5'd5)    ram4_enb       <= ram_enb;          
      else                       ram4_enb       <= 1'b0;            
      if(seg_num_cnt == 5'd6)    ram5_enb       <= ram_enb;          
      else                       ram5_enb       <= 1'b0;           
      if(seg_num_cnt == 5'd7)    ram6_enb       <= ram_enb;          
      else                       ram6_enb       <= 1'b0;            
      if(seg_num_cnt == 5'd8)    ram7_enb       <= ram_enb;          
      else                       ram7_enb       <= 1'b0;            
      if(seg_num_cnt == 5'd9)    ram8_enb       <= ram_enb;          
      else                       ram8_enb       <= 1'b0;              
      if(seg_num_cnt == 5'd10)   ram9_enb       <= ram_enb;          
      else                       ram9_enb       <= 1'b0;                       
    end       
////============================================================================================
////==RAM OUT calculate
////============================================================================================ 

  always@(posedge mpt_clk )                    
  begin              
    case(seg_num_cnt)                                           
    4'd1 : ram_out_douta                        <= ram0_douta ; 
    4'd2 : ram_out_douta                        <= ram1_douta ; 
    4'd3 : ram_out_douta                        <= ram2_douta ; 
    4'd4 : ram_out_douta                        <= ram3_douta ; 
    4'd5 : ram_out_douta                        <= ram4_douta ; 
    4'd6 : ram_out_douta                        <= ram5_douta ; 
    4'd7 : ram_out_douta                        <= ram6_douta ; 
    4'd8 : ram_out_douta                        <= ram7_douta ; 
    4'd9 : ram_out_douta                        <= ram8_douta ; 
    4'd10: ram_out_douta                        <= ram9_douta ; 
    endcase                                                   
    case(seg_num_cnt)                                         
    4'd1 : ram_out_doutb                        <= ram0_doutb ; 
    4'd2 : ram_out_doutb                        <= ram1_doutb ; 
    4'd3 : ram_out_doutb                        <= ram2_doutb ; 
    4'd4 : ram_out_doutb                        <= ram3_doutb ; 
    4'd5 : ram_out_doutb                        <= ram4_doutb ; 
    4'd6 : ram_out_doutb                        <= ram5_doutb ; 
    4'd7 : ram_out_doutb                        <= ram6_doutb ; 
    4'd8 : ram_out_doutb                        <= ram7_doutb ; 
    4'd9 : ram_out_doutb                        <= ram8_doutb ; 
    4'd10: ram_out_doutb                        <= ram9_doutb ; 
    endcase                                                     
  end      

  always@(posedge mpt_clk or posedge mpt_arst)                     
    if(mpt_arst) begin                                             
        fifo0_wr_en                             <= 1'b0 ;           
        fifo1_wr_en                             <= 1'b0 ;      
        fifo0_din                               <= 8'b0 ;      
        fifo1_din                               <= 8'b0 ;      
    end else begin                                           
        fifo0_din                               <= ram_out_douta ;       
        fifo1_din                               <= ram_out_doutb ;  
      if((!ram0_out_xaddr_overflow && (fifo_read_en_int_6d || fifo_read_en_int_8d)) 
        || (ram0_out_xaddr_overflow && ram_out_seg_xcnt == 9'd5 && !flag_oddeven[0]))
        fifo0_wr_en                             <= 1'b1 ;        
      else   
        fifo0_wr_en                             <= 1'b0 ;        
      if((!ram1_out_xaddr_overflow && (fifo_read_en_int_1_6d || fifo_read_en_int_1_8d)) 
        || (ram1_out_xaddr_overflow && ram_out_seg_xcnt == 9'd5 && !flag_oddeven[0]))
        fifo1_wr_en                             <= 1'b1 ;        
      else   
        fifo1_wr_en                             <= 1'b0 ;    
    end
fifo_remap_din  u0_fifo_remap_din (
    .clk                                        (mpt_clk             ),
    .srst                                       (rmp_vs_initial      ),
    .din                                        (fifo0_din           ),
    .wr_en                                      (fifo0_wr_en         ),
    .rd_en                                      (fifo_calc_rd_en     ),
    .dout                                       (fifo0_dout          ),
    .full                                       (fifo0_full          ),
    .empty                                      (fifo0_empty         ),
    .rd_data_count                              (fifo0_rd_data_count ),
    .almost_empty                               (fifo0_almost_empty  ),
    .valid                                      (fifo0_valid         )
    );
fifo_remap_din  u1_fifo_remap_din (
    .clk                                        (mpt_clk             ),
    .srst                                       (rmp_vs_initial      ),
    .din                                        (fifo1_din           ),
    .wr_en                                      (fifo1_wr_en         ),
    .rd_en                                      (fifo_calc_rd_en     ),
    .dout                                       (fifo1_dout          ),
    .full                                       (fifo1_full          ),
    .empty                                      (fifo1_empty         ),
    .rd_data_count                              (fifo1_rd_data_count ),
    .almost_empty                               (fifo1_almost_empty  ),
    .valid                                      (fifo1_valid         )
    );

  assign fifo_calc_rd_en    = (!fifo0_empty && !fifo1_empty && !fifo_empty_Yfloat && !fifo_empty_Yfloat) ? 1'b1 : 1'b0 ;

  always@(posedge mpt_clk or posedge mpt_arst)                     
    if(mpt_arst) begin                                         
        remap_calc_xf                           <= 6'b0 ;      
        remap_calc_yf                           <= 6'b0 ;        
        remap_calc_din00                        <= 8'b0 ;      
        remap_calc_din01                        <= 8'b0 ;       
        remap_calc_din10                        <= 8'b0 ;      
        remap_calc_din11                        <= 8'b0 ;         
        remap_calc_din_vld                      <= 1'b0 ;   
    end else begin          
        remap_calc_din_vld                      <= fifo0_valid ;
        remap_calc_xf                           <= fifo_read_data_Xfloat  ;   
        remap_calc_yf                           <= fifo_read_data_Yfloat  ; 
        remap_calc_din00                        <= fifo0_dout[15:8] ;      
        remap_calc_din01                        <= fifo0_dout[ 7:0] ;       
        remap_calc_din10                        <= fifo1_dout[15:8] ;      
        remap_calc_din11                        <= fifo1_dout[ 7:0] ;  
    end
   
remap_calcute  u0_remap_calc(
    .wclk                                         (mpt_clk            ),
    .arst                                         (mpt_arst           ),    
    .remap_vsync                                  (rmp_vs_initial     ),
    .remap_calc_xf                                (remap_calc_xf      ),
    .remap_calc_yf                                (remap_calc_yf      ),    
    .remap_calc_din00                             (remap_calc_din00   ),
    .remap_calc_din10                             (remap_calc_din10   ),
    .remap_calc_din01                             (remap_calc_din01   ),
    .remap_calc_din11                             (remap_calc_din11   ),
    .remap_calc_vld_in                            (remap_calc_din_vld ),
    .MPT_X_NUM                                    (MPT_X_NUM          ),
    .MPT_Y_NUM                                    (MPT_Y_NUM          ), 
    .remap_calc_dout                              (remap_calc_dout    ),
    .remap_calc_vld_out                           (remap_calc_vld_out )
    );     
////============================================================================================
////==RAM instantiate 
////============================================================================================        
    
ram_rmp_data   u0_ram_rmp_data (             
    .clka                     (mpt_clk     ),
    .ena                      (ram0_ena    ),
    .wea                      (ram0_wea    ),
    .addra                    (ram0_addra  ),
    .dina                     (ram_dina    ),
    .douta                    (ram0_douta  ),
    .clkb                     (mpt_clk     ),
    .dinb                     (32'd0       ),
    .enb                      (ram0_enb    ),
    .web                      (1'b0        ),
    .addrb                    (ram_addrb   ),
    .doutb                    (ram0_doutb  ) 
    );   
ram_rmp_data   u1_ram_rmp_data (             
    .clka                     (mpt_clk     ),
    .ena                      (ram1_ena    ),
    .wea                      (ram1_wea    ),
    .addra                    (ram1_addra  ),
    .dina                     (ram_dina    ),
    .douta                    (ram1_douta  ),
    .clkb                     (mpt_clk     ),
    .dinb                     (32'd0       ),
    .enb                      (ram1_enb    ),
    .web                      (1'b0        ),
    .addrb                    (ram_addrb   ),
    .doutb                    (ram1_doutb  ) 
    );   
ram_rmp_data   u2_ram_rmp_data (             
    .clka                     (mpt_clk     ),
    .ena                      (ram2_ena    ),
    .wea                      (ram2_wea    ),
    .addra                    (ram2_addra  ),
    .dina                     (ram_dina    ),
    .douta                    (ram2_douta  ),
    .clkb                     (mpt_clk     ),
    .dinb                     (32'd0       ),
    .enb                      (ram2_enb    ),
    .web                      (1'b0        ),
    .addrb                    (ram_addrb   ),
    .doutb                    (ram2_doutb  ) 
    );   
ram_rmp_data   u3_ram_rmp_data (             
    .clka                     (mpt_clk     ),
    .ena                      (ram3_ena    ),
    .wea                      (ram3_wea    ),
    .addra                    (ram3_addra  ),
    .dina                     (ram_dina    ),
    .douta                    (ram3_douta  ),
    .clkb                     (mpt_clk     ),
    .dinb                     (32'd0       ),
    .enb                      (ram3_enb    ),
    .web                      (1'b0        ),
    .addrb                    (ram_addrb   ),
    .doutb                    (ram3_doutb  ) 
    );   
ram_rmp_data   u4_ram_rmp_data (             
    .clka                     (mpt_clk     ),
    .ena                      (ram4_ena    ),
    .wea                      (ram4_wea    ),
    .addra                    (ram4_addra  ),
    .dina                     (ram_dina    ),
    .douta                    (ram4_douta  ),
    .clkb                     (mpt_clk     ),
    .dinb                     (32'd0       ),
    .enb                      (ram4_enb    ),
    .web                      (1'b0        ),
    .addrb                    (ram_addrb   ),
    .doutb                    (ram4_doutb  ) 
    );   
ram_rmp_data   u5_ram_rmp_data (             
    .clka                     (mpt_clk     ),
    .ena                      (ram5_ena    ),
    .wea                      (ram5_wea    ),
    .addra                    (ram5_addra  ),
    .dina                     (ram_dina    ),
    .douta                    (ram5_douta  ),
    .clkb                     (mpt_clk     ),
    .dinb                     (32'd0       ),
    .enb                      (ram5_enb    ),
    .web                      (1'b0        ),
    .addrb                    (ram_addrb   ),
    .doutb                    (ram5_doutb  ) 
    );   
ram_rmp_data   u6_ram_rmp_data (             
    .clka                     (mpt_clk     ),
    .ena                      (ram6_ena    ),
    .wea                      (ram6_wea    ),
    .addra                    (ram6_addra  ),
    .dina                     (ram_dina    ),
    .douta                    (ram6_douta  ),
    .clkb                     (mpt_clk     ),
    .dinb                     (32'd0       ),
    .enb                      (ram6_enb    ),
    .web                      (1'b0        ),
    .addrb                    (ram_addrb   ),
    .doutb                    (ram6_doutb  ) 
    );   
ram_rmp_data   u7_ram_rmp_data (             
    .clka                     (mpt_clk     ),
    .ena                      (ram7_ena    ),
    .wea                      (ram7_wea    ),
    .addra                    (ram7_addra  ),
    .dina                     (ram_dina    ),
    .douta                    (ram7_douta  ),
    .clkb                     (mpt_clk     ),
    .dinb                     (32'd0       ),
    .enb                      (ram7_enb    ),
    .web                      (1'b0        ),
    .addrb                    (ram_addrb   ),
    .doutb                    (ram7_doutb  ) 
    );   
ram_rmp_data   u8_ram_rmp_data (             
    .clka                     (mpt_clk     ),
    .ena                      (ram8_ena    ),
    .wea                      (ram8_wea    ),
    .addra                    (ram8_addra  ),
    .dina                     (ram_dina    ),
    .douta                    (ram8_douta  ),
    .clkb                     (mpt_clk     ),
    .dinb                     (32'd0       ),
    .enb                      (ram8_enb    ),
    .web                      (1'b0        ),
    .addrb                    (ram_addrb   ),
    .doutb                    (ram8_doutb  ) 
    );   
ram_rmp_data   u9_ram_rmp_data (             
    .clka                     (mpt_clk     ),
    .ena                      (ram9_ena    ),
    .wea                      (ram9_wea    ),
    .addra                    (ram9_addra  ),
    .dina                     (ram_dina    ),
    .douta                    (ram9_douta  ),
    .clkb                     (mpt_clk     ),
    .dinb                     (32'd0       ),
    .enb                      (ram9_enb    ),
    .web                      (1'b0        ),
    .addrb                    (ram_addrb   ),
    .doutb                    (ram9_doutb  ) 
    );   

                                    
  
endmodule
