/****************************Copyright**********************************
**                           
**               
**
**------------------------File Infomation-------------------------------
** FileName     :       remap_top.v
** Author       :       
** Data         :       
** Version      :       
** Version      :       
** Description  :       
**                      
***********************************************************************/
module remap_ps_top #( 
   parameter  REMAP_OUT_HACT                    = 16'd6000    
    )( 
    input    wire                               mpt_clk            , 
    input    wire                               mpt_arst           , 
                                                                     
    input    wire                               cam_vs_in          , 
    input    wire                               cam_de_in          , 
    input    wire                               video_locked       , 

    input  wire                                 axi_clk            , 
    input  wire                                 axi_arst           , 
    output wire                                 mpt_axi_req        , 
    output wire [7:0]                           mpt_axi_arlen      , 
    output wire [31:0]                          mpt_axi_addr       , 
    input  wire                                 mpt_axi_busy       , 
    input  wire                                 mpt_ram_wr_en      , 
    input  wire [31:0]                          mpt_ram_wr_data    , 
                                                                     
    output wire                                 usr_L_axi_req      , 
    output wire  [7:0]                          usr_L_axi_arlen    , 
    output wire  [31:0]                         usr_L_axi_addr     , 
    input  wire                                 usr_L_axi_busy     , 
    input  wire                                 usr_L_ram_wr_en    , 
    input  wire  [9:0]                          usr_L_ram_wr_addr  , 
    input  wire  [31:0]                         usr_L_ram_wr_data  , 
                                                                     
    output wire                                 usr_R_axi_req      , 
    output wire  [7:0]                          usr_R_axi_arlen    , 
    output wire  [31:0]                         usr_R_axi_addr     , 
    input  wire                                 usr_R_axi_busy     , 
    input  wire                                 usr_R_ram_wr_en    , 
    input  wire  [9:0]                          usr_R_ram_wr_addr  , 
    input  wire  [31:0]                         usr_R_ram_wr_data  , 
                                                                     
    output wire                                 remap_out_vs       , 
    output wire                                 remap_out_hvld     , 
    output wire                                 remap_out_dvld     , 
    output wire  [7:0]                          remap_L_out_data   , 
    output wire  [7:0]                          remap_R_out_data       
    );

   parameter  VID_HACT                          = 12'd1280   ;
   parameter  VID_VACT                          = 12'd720    ;
   parameter  SEG_X_WIDTH                       = 8'd128     ;
   parameter  SEG_X_NUMBER                      = 8'd10      ; 
  wire                                          rmp_vs_in            ;
  wire                                          mpt_check_ok         ; 
  wire  [10:0]                                  mpt_sum_out_lx_int   ;
  wire  [10:0]                                  mpt_sum_out_ly_int   ;
  wire  [5:0]                                   mpt_sum_out_lx_float ;
  wire  [5:0]                                   mpt_sum_out_ly_float ;
  wire  [10:0]                                  mpt_sum_out_rx_int   ;
  wire  [10:0]                                  mpt_sum_out_ry_int   ;
  wire  [5:0]                                   mpt_sum_out_rx_float ;
  wire  [5:0]                                   mpt_sum_out_ry_float ; 
  wire                                          mpt_sum_out_vld      ; 
  wire                                          rmp_L_read_ack       ;
  wire                                          rmp_R_read_ack       ;
  wire                                          mpt_sum_xy_LA_rdy    ;
  wire  [7:0]                                   mpt_sum_lx_LA0_cnt   ;
  wire  [7:0]                                   mpt_sum_lx_LA1_cnt   ;
  wire  [7:0]                                   mpt_sum_lx_LA2_cnt   ;
  wire  [7:0]                                   mpt_sum_lx_LA3_cnt   ;
  wire  [7:0]                                   mpt_sum_lx_LA4_cnt   ;
  wire  [7:0]                                   mpt_sum_lx_LA5_cnt   ;
  wire  [7:0]                                   mpt_sum_lx_LA6_cnt   ;
  wire  [7:0]                                   mpt_sum_lx_LA7_cnt   ;
  wire  [7:0]                                   mpt_sum_lx_LA8_cnt   ;
  wire  [7:0]                                   mpt_sum_lx_LA9_cnt   ;
  wire  [10:0]                                  mpt_sum_ly_LA0_min   ;
  wire  [10:0]                                  mpt_sum_ly_LA1_min   ;
  wire  [10:0]                                  mpt_sum_ly_LA2_min   ;
  wire  [10:0]                                  mpt_sum_ly_LA3_min   ;
  wire  [10:0]                                  mpt_sum_ly_LA4_min   ;
  wire  [10:0]                                  mpt_sum_ly_LA5_min   ;
  wire  [10:0]                                  mpt_sum_ly_LA6_min   ;
  wire  [10:0]                                  mpt_sum_ly_LA7_min   ;
  wire  [10:0]                                  mpt_sum_ly_LA8_min   ;
  wire  [10:0]                                  mpt_sum_ly_LA9_min   ;
  wire  [10:0]                                  mpt_sum_ly_LA0_max   ;
  wire  [10:0]                                  mpt_sum_ly_LA1_max   ;
  wire  [10:0]                                  mpt_sum_ly_LA2_max   ;
  wire  [10:0]                                  mpt_sum_ly_LA3_max   ;
  wire  [10:0]                                  mpt_sum_ly_LA4_max   ;
  wire  [10:0]                                  mpt_sum_ly_LA5_max   ;
  wire  [10:0]                                  mpt_sum_ly_LA6_max   ;
  wire  [10:0]                                  mpt_sum_ly_LA7_max   ;
  wire  [10:0]                                  mpt_sum_ly_LA8_max   ;
  wire  [10:0]                                  mpt_sum_ly_LA9_max   ;
  wire  [7:0]                                   mpt_sum_rx_LA0_cnt   ;
  wire  [7:0]                                   mpt_sum_rx_LA1_cnt   ;
  wire  [7:0]                                   mpt_sum_rx_LA2_cnt   ;
  wire  [7:0]                                   mpt_sum_rx_LA3_cnt   ;
  wire  [7:0]                                   mpt_sum_rx_LA4_cnt   ;
  wire  [7:0]                                   mpt_sum_rx_LA5_cnt   ;
  wire  [7:0]                                   mpt_sum_rx_LA6_cnt   ;
  wire  [7:0]                                   mpt_sum_rx_LA7_cnt   ;
  wire  [7:0]                                   mpt_sum_rx_LA8_cnt   ;
  wire  [7:0]                                   mpt_sum_rx_LA9_cnt   ;
  wire  [10:0]                                  mpt_sum_ry_LA0_min   ;
  wire  [10:0]                                  mpt_sum_ry_LA1_min   ;
  wire  [10:0]                                  mpt_sum_ry_LA2_min   ;
  wire  [10:0]                                  mpt_sum_ry_LA3_min   ;
  wire  [10:0]                                  mpt_sum_ry_LA4_min   ;
  wire  [10:0]                                  mpt_sum_ry_LA5_min   ;
  wire  [10:0]                                  mpt_sum_ry_LA6_min   ;
  wire  [10:0]                                  mpt_sum_ry_LA7_min   ;
  wire  [10:0]                                  mpt_sum_ry_LA8_min   ;
  wire  [10:0]                                  mpt_sum_ry_LA9_min   ;
  wire  [10:0]                                  mpt_sum_ry_LA0_max   ;
  wire  [10:0]                                  mpt_sum_ry_LA1_max   ;
  wire  [10:0]                                  mpt_sum_ry_LA2_max   ;
  wire  [10:0]                                  mpt_sum_ry_LA3_max   ;
  wire  [10:0]                                  mpt_sum_ry_LA4_max   ;
  wire  [10:0]                                  mpt_sum_ry_LA5_max   ;
  wire  [10:0]                                  mpt_sum_ry_LA6_max   ;
  wire  [10:0]                                  mpt_sum_ry_LA7_max   ;
  wire  [10:0]                                  mpt_sum_ry_LA8_max   ;
  wire  [10:0]                                  mpt_sum_ry_LA9_max   ;
  wire  [7:0]                                   MPT_X_NUM            ;
  wire  [7:0]                                   MPT_Y_NUM            ;
  wire  [15:0]                                  MPT_ONELINE_Y_MAX    ;

  wire                                          rmp_L_out_fifo_full  ;
  wire  [7:0]                                   rmp_L_out_data       ; 
  wire                                          rmp_L_out_vld        ; 
  wire                                          rmp_L_out_vs         ; 
  wire                                          rmp_L_first_line     ; 
  wire                                          rmp_R_out_fifo_full  ;
  wire  [7:0]                                   rmp_R_out_data       ; 
  wire                                          rmp_R_out_vld        ; 
  wire                                          rmp_R_out_vs         ; 
  wire                                          rmp_R_first_line     ; 
  wire                                          rmp_out_ready        ;
  remap_ctrl#(                            
    .VID_HACT_SHIFT                             ( 8'd250             )
    ) U_remap_ctrl (           
    .mpt_clk                                    ( mpt_clk            ), //input  wire        
    .mpt_arst                                   ( mpt_arst           ), //input  wire        
    .vid_vs_in                                  ( cam_vs_in          ), //input  wire        
    .vid_de_in                                  ( cam_de_in          ), //input  wire        
    .vid_locked                                 ( video_locked       ), //input  wire        
    .MPT_ONELINE_Y_MAX                          ( MPT_ONELINE_Y_MAX  ), //input  wire  [15:0]
    .vid_vs_out                                 ( rmp_vs_in          )  //output reg         
    );
  mpt_decode#(                            
    .VID_HACT                                   ( VID_HACT + 8   ), 
    .VID_VACT                                   ( VID_VACT       ), 
    .SEG_X_WIDTH                                ( SEG_X_WIDTH    ), 
    .SEG_X_NUMBER                               ( SEG_X_NUMBER   ) 
    ) u_mpt_decode(     
    .axi_clk                                    ( axi_clk             ), //input  wire        
    .axi_arst                                   ( axi_arst            ), //input  wire        
    .mpt_axi_req                                ( mpt_axi_req         ), //output reg         
    .mpt_axi_arlen                              ( mpt_axi_arlen       ), //output reg  [7:0]  
    .mpt_axi_addr                               ( mpt_axi_addr        ), //output reg  [31:0] 
    .mpt_axi_busy                               ( mpt_axi_busy        ), //input  wire        
    .mpt_ram_wr_en                              ( mpt_ram_wr_en       ), //input  wire        
    .mpt_ram_wr_data                            ( mpt_ram_wr_data     ), //input  wire  [31:0]
    .mpt_clk                                    ( mpt_clk             ), //input  wire        
    .mpt_arst                                   ( mpt_arst            ), //input  wire        
    .vid_vs_in                                  ( rmp_vs_in           ), //input  wire        
    .vid_locked                                 ( video_locked        ), //input  wire        
    .mpt_check_ok                               ( mpt_check_ok        ), //output reg         
    .mpt_sum_out_lx_int                         ( mpt_sum_out_lx_int  ), //output reg   [10:0]
    .mpt_sum_out_ly_int                         ( mpt_sum_out_ly_int  ), //output reg   [10:0]
    .mpt_sum_out_lx_float                       ( mpt_sum_out_lx_float), //output reg   [5:0] 
    .mpt_sum_out_ly_float                       ( mpt_sum_out_ly_float), //output reg   [5:0] 
    .mpt_sum_out_rx_int                         ( mpt_sum_out_rx_int  ), //output reg   [10:0]
    .mpt_sum_out_ry_int                         ( mpt_sum_out_ry_int  ), //output reg   [10:0]
    .mpt_sum_out_rx_float                       ( mpt_sum_out_rx_float), //output reg   [5:0] 
    .mpt_sum_out_ry_float                       ( mpt_sum_out_ry_float), //output reg   [5:0] 
    .mpt_sum_out_vld                            ( mpt_sum_out_vld     ), //output reg         
    .rmp_L_read_ack                             ( rmp_L_read_ack      ), //input  wire        
    .rmp_R_read_ack                             ( rmp_R_read_ack      ), //input  wire        
    .mpt_sum_xy_LA_rdy                          ( mpt_sum_xy_LA_rdy   ), //output reg         
    .mpt_sum_lx_LA0_cnt                         ( mpt_sum_lx_LA0_cnt  ), //output reg  [7:0]  
    .mpt_sum_lx_LA1_cnt                         ( mpt_sum_lx_LA1_cnt  ), //output reg  [7:0]  
    .mpt_sum_lx_LA2_cnt                         ( mpt_sum_lx_LA2_cnt  ), //output reg  [7:0]  
    .mpt_sum_lx_LA3_cnt                         ( mpt_sum_lx_LA3_cnt  ), //output reg  [7:0]  
    .mpt_sum_lx_LA4_cnt                         ( mpt_sum_lx_LA4_cnt  ), //output reg  [7:0]  
    .mpt_sum_lx_LA5_cnt                         ( mpt_sum_lx_LA5_cnt  ), //output reg  [7:0]  
    .mpt_sum_lx_LA6_cnt                         ( mpt_sum_lx_LA6_cnt  ), //output reg  [7:0]  
    .mpt_sum_lx_LA7_cnt                         ( mpt_sum_lx_LA7_cnt  ), //output reg  [7:0]  
    .mpt_sum_lx_LA8_cnt                         ( mpt_sum_lx_LA8_cnt  ), //output reg  [7:0]  
    .mpt_sum_lx_LA9_cnt                         ( mpt_sum_lx_LA9_cnt  ), //output reg  [7:0]  
    .mpt_sum_ly_LA0_min                         ( mpt_sum_ly_LA0_min  ), //output reg  [10:0] 
    .mpt_sum_ly_LA1_min                         ( mpt_sum_ly_LA1_min  ), //output reg  [10:0] 
    .mpt_sum_ly_LA2_min                         ( mpt_sum_ly_LA2_min  ), //output reg  [10:0] 
    .mpt_sum_ly_LA3_min                         ( mpt_sum_ly_LA3_min  ), //output reg  [10:0] 
    .mpt_sum_ly_LA4_min                         ( mpt_sum_ly_LA4_min  ), //output reg  [10:0] 
    .mpt_sum_ly_LA5_min                         ( mpt_sum_ly_LA5_min  ), //output reg  [10:0] 
    .mpt_sum_ly_LA6_min                         ( mpt_sum_ly_LA6_min  ), //output reg  [10:0] 
    .mpt_sum_ly_LA7_min                         ( mpt_sum_ly_LA7_min  ), //output reg  [10:0] 
    .mpt_sum_ly_LA8_min                         ( mpt_sum_ly_LA8_min  ), //output reg  [10:0] 
    .mpt_sum_ly_LA9_min                         ( mpt_sum_ly_LA9_min  ), //output reg  [10:0] 
    .mpt_sum_ly_LA0_max                         ( mpt_sum_ly_LA0_max  ), //output reg  [10:0] 
    .mpt_sum_ly_LA1_max                         ( mpt_sum_ly_LA1_max  ), //output reg  [10:0] 
    .mpt_sum_ly_LA2_max                         ( mpt_sum_ly_LA2_max  ), //output reg  [10:0] 
    .mpt_sum_ly_LA3_max                         ( mpt_sum_ly_LA3_max  ), //output reg  [10:0] 
    .mpt_sum_ly_LA4_max                         ( mpt_sum_ly_LA4_max  ), //output reg  [10:0] 
    .mpt_sum_ly_LA5_max                         ( mpt_sum_ly_LA5_max  ), //output reg  [10:0] 
    .mpt_sum_ly_LA6_max                         ( mpt_sum_ly_LA6_max  ), //output reg  [10:0] 
    .mpt_sum_ly_LA7_max                         ( mpt_sum_ly_LA7_max  ), //output reg  [10:0] 
    .mpt_sum_ly_LA8_max                         ( mpt_sum_ly_LA8_max  ), //output reg  [10:0] 
    .mpt_sum_ly_LA9_max                         ( mpt_sum_ly_LA9_max  ), //output reg  [10:0] 
    .mpt_sum_rx_LA0_cnt                         ( mpt_sum_rx_LA0_cnt  ), //output reg  [7:0]  
    .mpt_sum_rx_LA1_cnt                         ( mpt_sum_rx_LA1_cnt  ), //output reg  [7:0]  
    .mpt_sum_rx_LA2_cnt                         ( mpt_sum_rx_LA2_cnt  ), //output reg  [7:0]  
    .mpt_sum_rx_LA3_cnt                         ( mpt_sum_rx_LA3_cnt  ), //output reg  [7:0]  
    .mpt_sum_rx_LA4_cnt                         ( mpt_sum_rx_LA4_cnt  ), //output reg  [7:0]  
    .mpt_sum_rx_LA5_cnt                         ( mpt_sum_rx_LA5_cnt  ), //output reg  [7:0]  
    .mpt_sum_rx_LA6_cnt                         ( mpt_sum_rx_LA6_cnt  ), //output reg  [7:0]  
    .mpt_sum_rx_LA7_cnt                         ( mpt_sum_rx_LA7_cnt  ), //output reg  [7:0]  
    .mpt_sum_rx_LA8_cnt                         ( mpt_sum_rx_LA8_cnt  ), //output reg  [7:0]  
    .mpt_sum_rx_LA9_cnt                         ( mpt_sum_rx_LA9_cnt  ), //output reg  [7:0]  
    .mpt_sum_ry_LA0_min                         ( mpt_sum_ry_LA0_min  ), //output reg  [10:0] 
    .mpt_sum_ry_LA1_min                         ( mpt_sum_ry_LA1_min  ), //output reg  [10:0] 
    .mpt_sum_ry_LA2_min                         ( mpt_sum_ry_LA2_min  ), //output reg  [10:0] 
    .mpt_sum_ry_LA3_min                         ( mpt_sum_ry_LA3_min  ), //output reg  [10:0] 
    .mpt_sum_ry_LA4_min                         ( mpt_sum_ry_LA4_min  ), //output reg  [10:0] 
    .mpt_sum_ry_LA5_min                         ( mpt_sum_ry_LA5_min  ), //output reg  [10:0] 
    .mpt_sum_ry_LA6_min                         ( mpt_sum_ry_LA6_min  ), //output reg  [10:0] 
    .mpt_sum_ry_LA7_min                         ( mpt_sum_ry_LA7_min  ), //output reg  [10:0] 
    .mpt_sum_ry_LA8_min                         ( mpt_sum_ry_LA8_min  ), //output reg  [10:0] 
    .mpt_sum_ry_LA9_min                         ( mpt_sum_ry_LA9_min  ), //output reg  [10:0] 
    .mpt_sum_ry_LA0_max                         ( mpt_sum_ry_LA0_max  ), //output reg  [10:0] 
    .mpt_sum_ry_LA1_max                         ( mpt_sum_ry_LA1_max  ), //output reg  [10:0] 
    .mpt_sum_ry_LA2_max                         ( mpt_sum_ry_LA2_max  ), //output reg  [10:0] 
    .mpt_sum_ry_LA3_max                         ( mpt_sum_ry_LA3_max  ), //output reg  [10:0] 
    .mpt_sum_ry_LA4_max                         ( mpt_sum_ry_LA4_max  ), //output reg  [10:0] 
    .mpt_sum_ry_LA5_max                         ( mpt_sum_ry_LA5_max  ), //output reg  [10:0] 
    .mpt_sum_ry_LA6_max                         ( mpt_sum_ry_LA6_max  ), //output reg  [10:0] 
    .mpt_sum_ry_LA7_max                         ( mpt_sum_ry_LA7_max  ), //output reg  [10:0] 
    .mpt_sum_ry_LA8_max                         ( mpt_sum_ry_LA8_max  ), //output reg  [10:0] 
    .mpt_sum_ry_LA9_max                         ( mpt_sum_ry_LA9_max  ), //output reg  [10:0] 
    .MPT_X_NUM                                  ( MPT_X_NUM           ), //output reg  [7:0]  
    .MPT_Y_NUM                                  ( MPT_Y_NUM           ), //output reg  [7:0]  
    .MPT_ONELINE_Y_MAX                          ( MPT_ONELINE_Y_MAX   )  //output reg  [15:0] 
    );   
      
  mpt_remap#(                            
    .VID_HACT                                   ( VID_HACT               ), 
    .VID_VACT                                   ( VID_VACT               ), 
    .SEG_X_WIDTH                                ( SEG_X_WIDTH            ), 
    .SEG_X_NUMBER                               ( SEG_X_NUMBER           )  
    ) uL_mpt_remap (           
    .mpt_clk                                    ( mpt_clk                ), //input  wire          
    .mpt_arst                                   ( mpt_arst               ), //input  wire          
    .vid_vs_in                                  ( rmp_vs_in              ), //input  wire          
    .axi_clk                                    ( axi_clk                ), //input  wire 
    .axi_arst                                   ( axi_arst               ), //input  wire 
    .usr_axi_req                                ( usr_L_axi_req          ), //output reg           
    .usr_axi_arlen                              ( usr_L_axi_arlen        ), //output reg   [7:0]   
    .usr_axi_addr                               ( usr_L_axi_addr         ), //output reg   [31:0]  
    .usr_axi_busy                               ( usr_L_axi_busy         ), //input  wire          
    .usr_ram_wr_en                              ( usr_L_ram_wr_en        ), //input  wire          
    .usr_ram_wr_addr                            ( usr_L_ram_wr_addr      ), //input  wire  [9:0]   
    .usr_ram_wr_data                            ( usr_L_ram_wr_data      ), //input  wire  [31:0]  
    .mpt_sum_out_x_int                          ( mpt_sum_out_lx_int     ), //input  wire  [10:0]  
    .mpt_sum_out_y_int                          ( mpt_sum_out_ly_int     ), //input  wire  [10:0]  
    .mpt_sum_out_x_float                        ( mpt_sum_out_lx_float   ), //input  wire  [5:0]   
    .mpt_sum_out_y_float                        ( mpt_sum_out_ly_float   ), //input  wire  [5:0]   
    .mpt_sum_out_vld                            ( mpt_sum_out_vld        ), //input  wire          
    .rmp_read_ack                               ( rmp_L_read_ack         ), //output reg           
    .mpt_sum_xy_LA_rdy                          ( mpt_sum_xy_LA_rdy      ), //input  wire          
    .mpt_sum_x_LA0_cnt                          ( mpt_sum_lx_LA0_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA1_cnt                          ( mpt_sum_lx_LA1_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA2_cnt                          ( mpt_sum_lx_LA2_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA3_cnt                          ( mpt_sum_lx_LA3_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA4_cnt                          ( mpt_sum_lx_LA4_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA5_cnt                          ( mpt_sum_lx_LA5_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA6_cnt                          ( mpt_sum_lx_LA6_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA7_cnt                          ( mpt_sum_lx_LA7_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA8_cnt                          ( mpt_sum_lx_LA8_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA9_cnt                          ( mpt_sum_lx_LA9_cnt     ), //input  wire [7:0]    
    .mpt_sum_y_LA0_min                          ( mpt_sum_ly_LA0_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA1_min                          ( mpt_sum_ly_LA1_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA2_min                          ( mpt_sum_ly_LA2_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA3_min                          ( mpt_sum_ly_LA3_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA4_min                          ( mpt_sum_ly_LA4_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA5_min                          ( mpt_sum_ly_LA5_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA6_min                          ( mpt_sum_ly_LA6_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA7_min                          ( mpt_sum_ly_LA7_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA8_min                          ( mpt_sum_ly_LA8_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA9_min                          ( mpt_sum_ly_LA9_min     ), //input  wire [10:0]     
    .mpt_sum_y_LA0_max                          ( mpt_sum_ly_LA0_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA1_max                          ( mpt_sum_ly_LA1_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA2_max                          ( mpt_sum_ly_LA2_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA3_max                          ( mpt_sum_ly_LA3_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA4_max                          ( mpt_sum_ly_LA4_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA5_max                          ( mpt_sum_ly_LA5_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA6_max                          ( mpt_sum_ly_LA6_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA7_max                          ( mpt_sum_ly_LA7_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA8_max                          ( mpt_sum_ly_LA8_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA9_max                          ( mpt_sum_ly_LA9_max     ), //input  wire [10:0]   
    .MPT_X_NUM                                  ( MPT_X_NUM              ), //input  wire  [7:0]   
    .MPT_Y_NUM                                  ( MPT_Y_NUM              ), //input  wire  [7:0]   
    .rmp_out_fifo_full                          ( rmp_L_out_fifo_full    ), //input  wire                
    .rmp_out_ready                              ( rmp_out_ready          ), //input  wire     
    .rmp_out_data                               ( rmp_L_out_data         ), //output reg   [7:0]   
    .rmp_out_vld                                ( rmp_L_out_vld          ), //output reg           
    .rmp_out_vs                                 ( rmp_L_out_vs           ), //output reg           
    .rmp_first_line                             ( rmp_L_first_line       )  //output reg           
    );                                                                                             
                                                                                                   
  mpt_remap#(                                                                                      
    .VID_HACT                                   ( VID_HACT               ),                        
    .VID_VACT                                   ( VID_VACT               ),                        
    .SEG_X_WIDTH                                ( SEG_X_WIDTH            ),                        
    .SEG_X_NUMBER                               ( SEG_X_NUMBER           )                         
    ) uR_mpt_remap (                                                                               
    .mpt_clk                                    ( mpt_clk                ), //input  wire          
    .mpt_arst                                   ( mpt_arst               ), //input  wire          
    .vid_vs_in                                  ( rmp_vs_in              ), //input  wire            
    .axi_clk                                    ( axi_clk                ), //input  wire 
    .axi_arst                                   ( axi_arst               ), //input  wire      
    .usr_axi_req                                ( usr_R_axi_req          ), //output reg           
    .usr_axi_arlen                              ( usr_R_axi_arlen        ), //output reg   [7:0]   
    .usr_axi_addr                               ( usr_R_axi_addr         ), //output reg   [31:0]  
    .usr_axi_busy                               ( usr_R_axi_busy         ), //input  wire          
    .usr_ram_wr_en                              ( usr_R_ram_wr_en        ), //input  wire          
    .usr_ram_wr_addr                            ( usr_R_ram_wr_addr      ), //input  wire  [9:0]   
    .usr_ram_wr_data                            ( usr_R_ram_wr_data      ), //input  wire  [31:0]  
    .mpt_sum_out_x_int                          ( mpt_sum_out_rx_int     ), //input  wire  [10:0]  
    .mpt_sum_out_y_int                          ( mpt_sum_out_ry_int     ), //input  wire  [10:0]  
    .mpt_sum_out_x_float                        ( mpt_sum_out_rx_float   ), //input  wire  [5:0]   
    .mpt_sum_out_y_float                        ( mpt_sum_out_ry_float   ), //input  wire  [5:0]   
    .mpt_sum_out_vld                            ( mpt_sum_out_vld        ), //input  wire          
    .rmp_read_ack                               ( rmp_R_read_ack         ), //output reg           
    .mpt_sum_xy_LA_rdy                          ( mpt_sum_xy_LA_rdy      ), //input  wire          
    .mpt_sum_x_LA0_cnt                          ( mpt_sum_rx_LA0_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA1_cnt                          ( mpt_sum_rx_LA1_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA2_cnt                          ( mpt_sum_rx_LA2_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA3_cnt                          ( mpt_sum_rx_LA3_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA4_cnt                          ( mpt_sum_rx_LA4_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA5_cnt                          ( mpt_sum_rx_LA5_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA6_cnt                          ( mpt_sum_rx_LA6_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA7_cnt                          ( mpt_sum_rx_LA7_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA8_cnt                          ( mpt_sum_rx_LA8_cnt     ), //input  wire [7:0]    
    .mpt_sum_x_LA9_cnt                          ( mpt_sum_rx_LA9_cnt     ), //input  wire [7:0]    
    .mpt_sum_y_LA0_min                          ( mpt_sum_ry_LA0_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA1_min                          ( mpt_sum_ry_LA1_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA2_min                          ( mpt_sum_ry_LA2_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA3_min                          ( mpt_sum_ry_LA3_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA4_min                          ( mpt_sum_ry_LA4_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA5_min                          ( mpt_sum_ry_LA5_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA6_min                          ( mpt_sum_ry_LA6_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA7_min                          ( mpt_sum_ry_LA7_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA8_min                          ( mpt_sum_ry_LA8_min     ), //input  wire [10:0]   
    .mpt_sum_y_LA9_min                          ( mpt_sum_ry_LA9_min     ), //input  wire [10:0]  
    .mpt_sum_y_LA0_max                          ( mpt_sum_ry_LA0_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA1_max                          ( mpt_sum_ry_LA1_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA2_max                          ( mpt_sum_ry_LA2_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA3_max                          ( mpt_sum_ry_LA3_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA4_max                          ( mpt_sum_ry_LA4_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA5_max                          ( mpt_sum_ry_LA5_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA6_max                          ( mpt_sum_ry_LA6_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA7_max                          ( mpt_sum_ry_LA7_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA8_max                          ( mpt_sum_ry_LA8_max     ), //input  wire [10:0]   
    .mpt_sum_y_LA9_max                          ( mpt_sum_ry_LA9_max     ), //input  wire [10:0]   
    .MPT_X_NUM                                  ( MPT_X_NUM              ), //input  wire  [7:0]   
    .MPT_Y_NUM                                  ( MPT_Y_NUM              ), //input  wire  [7:0]   
    .rmp_out_fifo_full                          ( rmp_R_out_fifo_full    ), //input  wire               
    .rmp_out_ready                              ( rmp_out_ready          ), //input  wire   
    .rmp_out_data                               ( rmp_R_out_data         ), //output reg   [7:0]   
    .rmp_out_vld                                ( rmp_R_out_vld          ), //output reg           
    .rmp_out_vs                                 ( rmp_R_out_vs           ), //output reg           
    .rmp_first_line                             ( rmp_R_first_line       )  //output reg           
    ); 

remap_output#(                            
    .VID_VACT                                   ( VID_VACT             ), 
    .VID_HACT                                   ( VID_HACT             ), 
    .REMAP_OUT_HACT                             ( REMAP_OUT_HACT       )  
   ) u_remap_output(                                                      
    .mpt_clk                                    ( mpt_clk              ), //input  wire       
    .mpt_arst                                   ( mpt_arst             ), //input  wire       
    .vid_vs_in                                  ( rmp_vs_in            ), //input  wire         
    .rmp_L_read_ack                             ( rmp_L_read_ack      ), //input  wire        
    .rmp_R_read_ack                             ( rmp_R_read_ack      ), //input  wire       
    .rmp_out_ready                              ( rmp_out_ready        ), //output wire
    .rmp_L_vs                                   ( rmp_L_out_vs         ), //input  wire       
    .rmp_L_first_line                           ( rmp_L_first_line     ), //input  wire       
    .rmp_L_in_fifo_full                         ( rmp_L_out_fifo_full  ), //output wire       
    .rmp_L_in_data                              ( rmp_L_out_data       ), //input  wire [7:0]      
    .rmp_L_in_vld                               ( rmp_L_out_vld        ), //input  wire       
    .rmp_R_vs                                   ( rmp_R_out_vs         ), //input  wire          
    .rmp_R_first_line                           ( rmp_R_first_line     ), //input  wire    
    .rmp_R_in_fifo_full                         ( rmp_R_out_fifo_full  ), //output wire       
    .rmp_R_in_data                              ( rmp_R_out_data       ), //input  wire [7:0]       
    .rmp_R_in_vld                               ( rmp_R_out_vld        ), //input  wire       
    .remap_out_vs                               ( remap_out_vs         ), //output reg        
    .remap_out_hvld                             ( remap_out_hvld       ), //output reg        
    .remap_out_dvld                             ( remap_out_dvld       ), //output reg        
    .remap_L_out_data                           ( remap_L_out_data     ), //output reg   [7:0]
    .remap_R_out_data                           ( remap_R_out_data     )  //output reg   [7:0]
    );   
         
         
video_detect#(                          
  .H_ACT                                (12'd1280         ),      
  .WIDTH                                ( 8'd8            )       
  )uL0_remap_video_detect(                                        
  .wclk                                 (mpt_clk          ),//i,1 
  .arst                                 (mpt_arst         ),//i,1 
  .vd_in_vsync                          (rmp_L_out_vs     ),//i,1 
  .vd_in_hsync                          (1'b0             ),//i,1 
  .vd_dvalid                            (rmp_L_out_vld    ),//i,1 
  .vd_disp                              (rmp_L_out_data   ) //i,8 
  );                                                              
video_detect#(                                                    
  .H_ACT                                (12'd1280         ),      
  .WIDTH                                ( 8'd8            )       
  )uR0_remap_video_detect(                                        
  .wclk                                 (mpt_clk          ),//i,1 
  .arst                                 (mpt_arst         ),//i,1 
  .vd_in_vsync                          (rmp_R_out_vs     ),//i,1 
  .vd_in_hsync                          (1'b0             ),//i,1 
  .vd_dvalid                            (rmp_R_out_vld    ),//i,1 
  .vd_disp                              (rmp_R_out_data   ) //i,8 
  );
         
endmodule
