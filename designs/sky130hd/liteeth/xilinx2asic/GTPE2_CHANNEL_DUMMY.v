module GTPE2_CHANNEL_DUMMY #(
  parameter [0:0] ACJTAG_DEBUG_MODE = 1'b0,
  parameter [0:0] ACJTAG_MODE = 1'b0,
  parameter [0:0] ACJTAG_RESET = 1'b0,
  parameter [19:0] ADAPT_CFG0 = 20'b00000000000000000000,
  parameter ALIGN_COMMA_DOUBLE = "FALSE",
  parameter [9:0] ALIGN_COMMA_ENABLE = 10'b0001111111,
  parameter integer ALIGN_COMMA_WORD = 1,
  parameter ALIGN_MCOMMA_DET = "TRUE",
  parameter [9:0] ALIGN_MCOMMA_VALUE = 10'b1010000011,
  parameter ALIGN_PCOMMA_DET = "TRUE",
  parameter [9:0] ALIGN_PCOMMA_VALUE = 10'b0101111100,
  parameter CBCC_DATA_SOURCE_SEL = "DECODED",
  parameter [42:0] CFOK_CFG = 43'b1001001000000000000000001000000111010000000,
  parameter [6:0] CFOK_CFG2 = 7'b0100000,
  parameter [6:0] CFOK_CFG3 = 7'b0100000,
  parameter [0:0] CFOK_CFG4 = 1'b0,
  parameter [1:0] CFOK_CFG5 = 2'b00,
  parameter [3:0] CFOK_CFG6 = 4'b0000,
  parameter CHAN_BOND_KEEP_ALIGN = "FALSE",
  parameter integer CHAN_BOND_MAX_SKEW = 7,
  parameter [9:0] CHAN_BOND_SEQ_1_1 = 10'b0101111100,
  parameter [9:0] CHAN_BOND_SEQ_1_2 = 10'b0000000000,
  parameter [9:0] CHAN_BOND_SEQ_1_3 = 10'b0000000000,
  parameter [9:0] CHAN_BOND_SEQ_1_4 = 10'b0000000000,
  parameter [3:0] CHAN_BOND_SEQ_1_ENABLE = 4'b1111,
  parameter [9:0] CHAN_BOND_SEQ_2_1 = 10'b0100000000,
  parameter [9:0] CHAN_BOND_SEQ_2_2 = 10'b0100000000,
  parameter [9:0] CHAN_BOND_SEQ_2_3 = 10'b0100000000,
  parameter [9:0] CHAN_BOND_SEQ_2_4 = 10'b0100000000,
  parameter [3:0] CHAN_BOND_SEQ_2_ENABLE = 4'b1111,
  parameter CHAN_BOND_SEQ_2_USE = "FALSE",
  parameter integer CHAN_BOND_SEQ_LEN = 1,
  parameter [0:0] CLK_COMMON_SWING = 1'b0,
  parameter CLK_CORRECT_USE = "TRUE",
  parameter CLK_COR_KEEP_IDLE = "FALSE",
  parameter integer CLK_COR_MAX_LAT = 20,
  parameter integer CLK_COR_MIN_LAT = 18,
  parameter CLK_COR_PRECEDENCE = "TRUE",
  parameter integer CLK_COR_REPEAT_WAIT = 0,
  parameter [9:0] CLK_COR_SEQ_1_1 = 10'b0100011100,
  parameter [9:0] CLK_COR_SEQ_1_2 = 10'b0000000000,
  parameter [9:0] CLK_COR_SEQ_1_3 = 10'b0000000000,
  parameter [9:0] CLK_COR_SEQ_1_4 = 10'b0000000000,
  parameter [3:0] CLK_COR_SEQ_1_ENABLE = 4'b1111,
  parameter [9:0] CLK_COR_SEQ_2_1 = 10'b0100000000,
  parameter [9:0] CLK_COR_SEQ_2_2 = 10'b0100000000,
  parameter [9:0] CLK_COR_SEQ_2_3 = 10'b0100000000,
  parameter [9:0] CLK_COR_SEQ_2_4 = 10'b0100000000,
  parameter [3:0] CLK_COR_SEQ_2_ENABLE = 4'b1111,
  parameter CLK_COR_SEQ_2_USE = "FALSE",
  parameter integer CLK_COR_SEQ_LEN = 1,
  parameter DEC_MCOMMA_DETECT = "TRUE",
  parameter DEC_PCOMMA_DETECT = "TRUE",
  parameter DEC_VALID_COMMA_ONLY = "TRUE",
  parameter [23:0] DMONITOR_CFG = 24'h000A00,
  parameter [0:0] ES_CLK_PHASE_SEL = 1'b0,
  parameter [5:0] ES_CONTROL = 6'b000000,
  parameter ES_ERRDET_EN = "FALSE",
  parameter ES_EYE_SCAN_EN = "FALSE",
  parameter [11:0] ES_HORZ_OFFSET = 12'h010,
  parameter [9:0] ES_PMA_CFG = 10'b0000000000,
  parameter [4:0] ES_PRESCALE = 5'b00000,
  parameter [79:0] ES_QUALIFIER = 80'h00000000000000000000,
  parameter [79:0] ES_QUAL_MASK = 80'h00000000000000000000,
  parameter [79:0] ES_SDATA_MASK = 80'h00000000000000000000,
  parameter [8:0] ES_VERT_OFFSET = 9'b000000000,
  parameter [3:0] FTS_DESKEW_SEQ_ENABLE = 4'b1111,
  parameter [3:0] FTS_LANE_DESKEW_CFG = 4'b1111,
  parameter FTS_LANE_DESKEW_EN = "FALSE",
  parameter [2:0] GEARBOX_MODE = 3'b000,
  parameter [0:0] IS_CLKRSVD0_INVERTED = 1'b0,
  parameter [0:0] IS_CLKRSVD1_INVERTED = 1'b0,
  parameter [0:0] IS_DMONITORCLK_INVERTED = 1'b0,
  parameter [0:0] IS_DRPCLK_INVERTED = 1'b0,
  parameter [0:0] IS_RXUSRCLK2_INVERTED = 1'b0,
  parameter [0:0] IS_RXUSRCLK_INVERTED = 1'b0,
  parameter [0:0] IS_SIGVALIDCLK_INVERTED = 1'b0,
  parameter [0:0] IS_TXPHDLYTSTCLK_INVERTED = 1'b0,
  parameter [0:0] IS_TXUSRCLK2_INVERTED = 1'b0,
  parameter [0:0] IS_TXUSRCLK_INVERTED = 1'b0,
  parameter [0:0] LOOPBACK_CFG = 1'b0,
  parameter [1:0] OUTREFCLK_SEL_INV = 2'b11,
  parameter PCS_PCIE_EN = "FALSE",
  parameter [47:0] PCS_RSVD_ATTR = 48'h000000000000,
  parameter [11:0] PD_TRANS_TIME_FROM_P2 = 12'h03C,
  parameter [7:0] PD_TRANS_TIME_NONE_P2 = 8'h19,
  parameter [7:0] PD_TRANS_TIME_TO_P2 = 8'h64,
  parameter [0:0] PMA_LOOPBACK_CFG = 1'b0,
  parameter [31:0] PMA_RSV = 32'h00000333,
  parameter [31:0] PMA_RSV2 = 32'h00002050,
  parameter [1:0] PMA_RSV3 = 2'b00,
  parameter [3:0] PMA_RSV4 = 4'b0000,
  parameter [0:0] PMA_RSV5 = 1'b0,
  parameter [0:0] PMA_RSV6 = 1'b0,
  parameter [0:0] PMA_RSV7 = 1'b0,
  parameter [4:0] RXBUFRESET_TIME = 5'b00001,
  parameter RXBUF_ADDR_MODE = "FULL",
  parameter [3:0] RXBUF_EIDLE_HI_CNT = 4'b1000,
  parameter [3:0] RXBUF_EIDLE_LO_CNT = 4'b0000,
  parameter RXBUF_EN = "TRUE",
  parameter RXBUF_RESET_ON_CB_CHANGE = "TRUE",
  parameter RXBUF_RESET_ON_COMMAALIGN = "FALSE",
  parameter RXBUF_RESET_ON_EIDLE = "FALSE",
  parameter RXBUF_RESET_ON_RATE_CHANGE = "TRUE",
  parameter integer RXBUF_THRESH_OVFLW = 61,
  parameter RXBUF_THRESH_OVRD = "FALSE",
  parameter integer RXBUF_THRESH_UNDFLW = 4,
  parameter [4:0] RXCDRFREQRESET_TIME = 5'b00001,
  parameter [4:0] RXCDRPHRESET_TIME = 5'b00001,
  parameter [82:0] RXCDR_CFG = 83'h0000107FE406001041010,
  parameter [0:0] RXCDR_FR_RESET_ON_EIDLE = 1'b0,
  parameter [0:0] RXCDR_HOLD_DURING_EIDLE = 1'b0,
  parameter [5:0] RXCDR_LOCK_CFG = 6'b001001,
  parameter [0:0] RXCDR_PH_RESET_ON_EIDLE = 1'b0,
  parameter [15:0] RXDLY_CFG = 16'h0010,
  parameter [8:0] RXDLY_LCFG = 9'h020,
  parameter [15:0] RXDLY_TAP_CFG = 16'h0000,
  parameter RXGEARBOX_EN = "FALSE",
  parameter [4:0] RXISCANRESET_TIME = 5'b00001,
  parameter [6:0] RXLPMRESET_TIME = 7'b0001111,
  parameter [0:0] RXLPM_BIAS_STARTUP_DISABLE = 1'b0,
  parameter [3:0] RXLPM_CFG = 4'b0110,
  parameter [0:0] RXLPM_CFG1 = 1'b0,
  parameter [0:0] RXLPM_CM_CFG = 1'b0,
  parameter [8:0] RXLPM_GC_CFG = 9'b111100010,
  parameter [2:0] RXLPM_GC_CFG2 = 3'b001,
  parameter [13:0] RXLPM_HF_CFG = 14'b00001111110000,
  parameter [4:0] RXLPM_HF_CFG2 = 5'b01010,
  parameter [3:0] RXLPM_HF_CFG3 = 4'b0000,
  parameter [0:0] RXLPM_HOLD_DURING_EIDLE = 1'b0,
  parameter [0:0] RXLPM_INCM_CFG = 1'b0,
  parameter [0:0] RXLPM_IPCM_CFG = 1'b0,
  parameter [17:0] RXLPM_LF_CFG = 18'b000000001111110000,
  parameter [4:0] RXLPM_LF_CFG2 = 5'b01010,
  parameter [2:0] RXLPM_OSINT_CFG = 3'b100,
  parameter [6:0] RXOOB_CFG = 7'b0000110,
  parameter RXOOB_CLK_CFG = "PMA",
  parameter [4:0] RXOSCALRESET_TIME = 5'b00011,
  parameter [4:0] RXOSCALRESET_TIMEOUT = 5'b00000,
  parameter integer RXOUT_DIV = 2,
  parameter [4:0] RXPCSRESET_TIME = 5'b00001,
  parameter [23:0] RXPHDLY_CFG = 24'h084000,
  parameter [23:0] RXPH_CFG = 24'hC00002,
  parameter [4:0] RXPH_MONITOR_SEL = 5'b00000,
  parameter [2:0] RXPI_CFG0 = 3'b000,
  parameter [0:0] RXPI_CFG1 = 1'b0,
  parameter [0:0] RXPI_CFG2 = 1'b0,
  parameter [4:0] RXPMARESET_TIME = 5'b00011,
  parameter [0:0] RXPRBS_ERR_LOOPBACK = 1'b0,
  parameter integer RXSLIDE_AUTO_WAIT = 7,
  parameter RXSLIDE_MODE = "OFF",
  parameter [0:0] RXSYNC_MULTILANE = 1'b0,
  parameter [0:0] RXSYNC_OVRD = 1'b0,
  parameter [0:0] RXSYNC_SKIP_DA = 1'b0,
  parameter [15:0] RX_BIAS_CFG = 16'b0000111100110011,
  parameter [5:0] RX_BUFFER_CFG = 6'b000000,
  parameter integer RX_CLK25_DIV = 7,
  parameter [0:0] RX_CLKMUX_EN = 1'b1,
  parameter [1:0] RX_CM_SEL = 2'b11,
  parameter [3:0] RX_CM_TRIM = 4'b0100,
  parameter integer RX_DATA_WIDTH = 20,
  parameter [5:0] RX_DDI_SEL = 6'b000000,
  parameter [13:0] RX_DEBUG_CFG = 14'b00000000000000,
  parameter RX_DEFER_RESET_BUF_EN = "TRUE",
  parameter RX_DISPERR_SEQ_MATCH = "TRUE",
  parameter [12:0] RX_OS_CFG = 13'b0001111110000,
  parameter integer RX_SIG_VALID_DLY = 10,
  parameter RX_XCLK_SEL = "RXREC",
  parameter integer SAS_MAX_COM = 64,
  parameter integer SAS_MIN_COM = 36,
  parameter [3:0] SATA_BURST_SEQ_LEN = 4'b1111,
  parameter [2:0] SATA_BURST_VAL = 3'b100,
  parameter [2:0] SATA_EIDLE_VAL = 3'b100,
  parameter integer SATA_MAX_BURST = 8,
  parameter integer SATA_MAX_INIT = 21,
  parameter integer SATA_MAX_WAKE = 7,
  parameter integer SATA_MIN_BURST = 4,
  parameter integer SATA_MIN_INIT = 12,
  parameter integer SATA_MIN_WAKE = 4,
  parameter SATA_PLL_CFG = "VCO_3000MHZ",
  parameter SHOW_REALIGN_COMMA = "TRUE",
  parameter SIM_RECEIVER_DETECT_PASS = "TRUE",
  parameter SIM_RESET_SPEEDUP = "TRUE",
  parameter SIM_TX_EIDLE_DRIVE_LEVEL = "X",
  parameter SIM_VERSION = "1.0",
  parameter [14:0] TERM_RCAL_CFG = 15'b100001000010000,
  parameter [2:0] TERM_RCAL_OVRD = 3'b000,
  parameter [7:0] TRANS_TIME_RATE = 8'h0E,
  parameter [31:0] TST_RSV = 32'h00000000,
  parameter TXBUF_EN = "TRUE",
  parameter TXBUF_RESET_ON_RATE_CHANGE = "FALSE",
  parameter [15:0] TXDLY_CFG = 16'h0010,
  parameter [8:0] TXDLY_LCFG = 9'h020,
  parameter [15:0] TXDLY_TAP_CFG = 16'h0000,
  parameter TXGEARBOX_EN = "FALSE",
  parameter [0:0] TXOOB_CFG = 1'b0,
  parameter integer TXOUT_DIV = 2,
  parameter [4:0] TXPCSRESET_TIME = 5'b00001,
  parameter [23:0] TXPHDLY_CFG = 24'h084000,
  parameter [15:0] TXPH_CFG = 16'h0400,
  parameter [4:0] TXPH_MONITOR_SEL = 5'b00000,
  parameter [1:0] TXPI_CFG0 = 2'b00,
  parameter [1:0] TXPI_CFG1 = 2'b00,
  parameter [1:0] TXPI_CFG2 = 2'b00,
  parameter [0:0] TXPI_CFG3 = 1'b0,
  parameter [0:0] TXPI_CFG4 = 1'b0,
  parameter [2:0] TXPI_CFG5 = 3'b000,
  parameter [0:0] TXPI_GREY_SEL = 1'b0,
  parameter [0:0] TXPI_INVSTROBE_SEL = 1'b0,
  parameter TXPI_PPMCLK_SEL = "TXUSRCLK2",
  parameter [7:0] TXPI_PPM_CFG = 8'b00000000,
  parameter [2:0] TXPI_SYNFREQ_PPM = 3'b000,
  parameter [4:0] TXPMARESET_TIME = 5'b00001,
  parameter [0:0] TXSYNC_MULTILANE = 1'b0,
  parameter [0:0] TXSYNC_OVRD = 1'b0,
  parameter [0:0] TXSYNC_SKIP_DA = 1'b0,
  parameter integer TX_CLK25_DIV = 7,
  parameter [0:0] TX_CLKMUX_EN = 1'b1,
  parameter integer TX_DATA_WIDTH = 20,
  parameter [5:0] TX_DEEMPH0 = 6'b000000,
  parameter [5:0] TX_DEEMPH1 = 6'b000000,
  parameter TX_DRIVE_MODE = "DIRECT",
  parameter [2:0] TX_EIDLE_ASSERT_DELAY = 3'b110,
  parameter [2:0] TX_EIDLE_DEASSERT_DELAY = 3'b100,
  parameter TX_LOOPBACK_DRIVE_HIZ = "FALSE",
  parameter [0:0] TX_MAINCURSOR_SEL = 1'b0,
  parameter [6:0] TX_MARGIN_FULL_0 = 7'b1001110,
  parameter [6:0] TX_MARGIN_FULL_1 = 7'b1001001,
  parameter [6:0] TX_MARGIN_FULL_2 = 7'b1000101,
  parameter [6:0] TX_MARGIN_FULL_3 = 7'b1000010,
  parameter [6:0] TX_MARGIN_FULL_4 = 7'b1000000,
  parameter [6:0] TX_MARGIN_LOW_0 = 7'b1000110,
  parameter [6:0] TX_MARGIN_LOW_1 = 7'b1000100,
  parameter [6:0] TX_MARGIN_LOW_2 = 7'b1000010,
  parameter [6:0] TX_MARGIN_LOW_3 = 7'b1000000,
  parameter [6:0] TX_MARGIN_LOW_4 = 7'b1000000,
  parameter [0:0] TX_PREDRIVER_MODE = 1'b0,
  parameter [13:0] TX_RXDETECT_CFG = 14'h1832,
  parameter [2:0] TX_RXDETECT_REF = 3'b100,
  parameter TX_XCLK_SEL = "TXUSR",
  parameter [0:0] UCODEER_CLR = 1'b0,
  parameter [0:0] USE_PCS_CLK_PHASE_SEL = 1'b0
)(
  output [14:0] DMONITOROUT,
  output [15:0] DRPDO,
  output DRPRDY,
  output EYESCANDATAERROR,
  output GTPTXN,
  output GTPTXP,
  output [15:0] PCSRSVDOUT,
  output PHYSTATUS,
  output PMARSVDOUT0,
  output PMARSVDOUT1,
  output [2:0] RXBUFSTATUS,
  output RXBYTEISALIGNED,
  output RXBYTEREALIGN,
  output RXCDRLOCK,
  output RXCHANBONDSEQ,
  output RXCHANISALIGNED,
  output RXCHANREALIGN,
  output [3:0] RXCHARISCOMMA,
  output [3:0] RXCHARISK,
  output [3:0] RXCHBONDO,
  output [1:0] RXCLKCORCNT,
  output RXCOMINITDET,
  output RXCOMMADET,
  output RXCOMSASDET,
  output RXCOMWAKEDET,
  output [31:0] RXDATA,
  output [1:0] RXDATAVALID,
  output [3:0] RXDISPERR,
  output RXDLYSRESETDONE,
  output RXELECIDLE,
  output [2:0] RXHEADER,
  output RXHEADERVALID,
  output [3:0] RXNOTINTABLE,
  output RXOSINTDONE,
  output RXOSINTSTARTED,
  output RXOSINTSTROBEDONE,
  output RXOSINTSTROBESTARTED,
  output RXOUTCLK,
  output RXOUTCLKFABRIC,
  output RXOUTCLKPCS,
  output RXPHALIGNDONE,
  output [4:0] RXPHMONITOR,
  output [4:0] RXPHSLIPMONITOR,
  output RXPMARESETDONE,
  output RXPRBSERR,
  output RXRATEDONE,
  output RXRESETDONE,
  output [1:0] RXSTARTOFSEQ,
  output [2:0] RXSTATUS,
  output RXSYNCDONE,
  output RXSYNCOUT,
  output RXVALID,
  output [1:0] TXBUFSTATUS,
  output TXCOMFINISH,
  output TXDLYSRESETDONE,
  output TXGEARBOXREADY,
  output TXOUTCLK,
  output TXOUTCLKFABRIC,
  output TXOUTCLKPCS,
  output TXPHALIGNDONE,
  output TXPHINITDONE,
  output TXPMARESETDONE,
  output TXRATEDONE,
  output TXRESETDONE,
  output TXSYNCDONE,
  output TXSYNCOUT,
  input CFGRESET,
  input CLKRSVD0,
  input CLKRSVD1,
  input DMONFIFORESET,
  input DMONITORCLK,
  input [8:0] DRPADDR,
  input DRPCLK,
  input [15:0] DRPDI,
  input DRPEN,
  input DRPWE,
  input EYESCANMODE,
  input EYESCANRESET,
  input EYESCANTRIGGER,
  input GTPRXN,
  input GTPRXP,
  input GTRESETSEL,
  input [15:0] GTRSVD,
  input GTRXRESET,
  input GTTXRESET,
  input [2:0] LOOPBACK,
  input [15:0] PCSRSVDIN,
  input PLL0CLK,
  input PLL0REFCLK,
  input PLL1CLK,
  input PLL1REFCLK,
  input PMARSVDIN0,
  input PMARSVDIN1,
  input PMARSVDIN2,
  input PMARSVDIN3,
  input PMARSVDIN4,
  input RESETOVRD,
  input RX8B10BEN,
  input [13:0] RXADAPTSELTEST,
  input RXBUFRESET,
  input RXCDRFREQRESET,
  input RXCDRHOLD,
  input RXCDROVRDEN,
  input RXCDRRESET,
  input RXCDRRESETRSV,
  input RXCHBONDEN,
  input [3:0] RXCHBONDI,
  input [2:0] RXCHBONDLEVEL,
  input RXCHBONDMASTER,
  input RXCHBONDSLAVE,
  input RXCOMMADETEN,
  input RXDDIEN,
  input RXDFEXYDEN,
  input RXDLYBYPASS,
  input RXDLYEN,
  input RXDLYOVRDEN,
  input RXDLYSRESET,
  input [1:0] RXELECIDLEMODE,
  input RXGEARBOXSLIP,
  input RXLPMHFHOLD,
  input RXLPMHFOVRDEN,
  input RXLPMLFHOLD,
  input RXLPMLFOVRDEN,
  input RXLPMOSINTNTRLEN,
  input RXLPMRESET,
  input RXMCOMMAALIGNEN,
  input RXOOBRESET,
  input RXOSCALRESET,
  input RXOSHOLD,
  input [3:0] RXOSINTCFG,
  input RXOSINTEN,
  input RXOSINTHOLD,
  input [3:0] RXOSINTID0,
  input RXOSINTNTRLEN,
  input RXOSINTOVRDEN,
  input RXOSINTPD,
  input RXOSINTSTROBE,
  input RXOSINTTESTOVRDEN,
  input RXOSOVRDEN,
  input [2:0] RXOUTCLKSEL,
  input RXPCOMMAALIGNEN,
  input RXPCSRESET,
  input [1:0] RXPD,
  input RXPHALIGN,
  input RXPHALIGNEN,
  input RXPHDLYPD,
  input RXPHDLYRESET,
  input RXPHOVRDEN,
  input RXPMARESET,
  input RXPOLARITY,
  input RXPRBSCNTRESET,
  input [2:0] RXPRBSSEL,
  input [2:0] RXRATE,
  input RXRATEMODE,
  input RXSLIDE,
  input RXSYNCALLIN,
  input RXSYNCIN,
  input RXSYNCMODE,
  input [1:0] RXSYSCLKSEL,
  input RXUSERRDY,
  input RXUSRCLK,
  input RXUSRCLK2,
  input SETERRSTATUS,
  input SIGVALIDCLK,
  input [19:0] TSTIN,
  input [3:0] TX8B10BBYPASS,
  input TX8B10BEN,
  input [2:0] TXBUFDIFFCTRL,
  input [3:0] TXCHARDISPMODE,
  input [3:0] TXCHARDISPVAL,
  input [3:0] TXCHARISK,
  input TXCOMINIT,
  input TXCOMSAS,
  input TXCOMWAKE,
  input [31:0] TXDATA,
  input TXDEEMPH,
  input TXDETECTRX,
  input [3:0] TXDIFFCTRL,
  input TXDIFFPD,
  input TXDLYBYPASS,
  input TXDLYEN,
  input TXDLYHOLD,
  input TXDLYOVRDEN,
  input TXDLYSRESET,
  input TXDLYUPDOWN,
  input TXELECIDLE,
  input [2:0] TXHEADER,
  input TXINHIBIT,
  input [6:0] TXMAINCURSOR,
  input [2:0] TXMARGIN,
  input [2:0] TXOUTCLKSEL,
  input TXPCSRESET,
  input [1:0] TXPD,
  input TXPDELECIDLEMODE,
  input TXPHALIGN,
  input TXPHALIGNEN,
  input TXPHDLYPD,
  input TXPHDLYRESET,
  input TXPHDLYTSTCLK,
  input TXPHINIT,
  input TXPHOVRDEN,
  input TXPIPPMEN,
  input TXPIPPMOVRDEN,
  input TXPIPPMPD,
  input TXPIPPMSEL,
  input [4:0] TXPIPPMSTEPSIZE,
  input TXPISOPD,
  input TXPMARESET,
  input TXPOLARITY,
  input [4:0] TXPOSTCURSOR,
  input TXPOSTCURSORINV,
  input TXPRBSFORCEERR,
  input [2:0] TXPRBSSEL,
  input [4:0] TXPRECURSOR,
  input TXPRECURSORINV,
  input [2:0] TXRATE,
  input TXRATEMODE,
  input [6:0] TXSEQUENCE,
  input TXSTARTSEQ,
  input TXSWING,
  input TXSYNCALLIN,
  input TXSYNCIN,
  input TXSYNCMODE,
  input [1:0] TXSYSCLKSEL,
  input TXUSERRDY,
  input TXUSRCLK,
  input TXUSRCLK2
);

  reg [14:0] dmonitorout_reg;
  reg [15:0] drpdo_reg;
  reg drprdy_reg;
  reg [15:0] pcsrsvdout_reg;
  reg [1:0] rxclkcorcnt_reg;
  reg [1:0] rxdatavalid_reg;
  reg [1:0] rxstartofseq_reg;
  reg [1:0] txbufstatus_reg;
  reg [2:0] rxbufstatus_reg;
  reg [2:0] rxheader_reg;
  reg [2:0] rxstatus_reg;
  reg [31:0] rxdata_reg;
  reg [3:0] rxchariscomma_reg;
  reg [3:0] rxcharisk_reg;
  reg [3:0] rxchbondo_reg;
  reg [3:0] rxdisperr_reg;
  reg [3:0] rxnotintable_reg;
  reg [4:0] rxphmonitor_reg;
  reg [4:0] rxphslipmonitor_reg;
  reg eyescandataerror_reg;
  reg phystatus_reg;
  reg pmarsvdout0_reg;
  reg pmarsvdout1_reg;
  reg rxbyteisaligned_reg;
  reg rxbyterealign_reg;
  reg rxcdrlock_reg;
  reg rxchanbondseq_reg;
  reg rxchanisaligned_reg;
  reg rxchanrealign_reg;
  reg rxcominitdet_reg;
  reg rxcommadet_reg;
  reg rxcomsasdet_reg;
  reg rxcomwakedet_reg;
  reg rxdlysresetdone_reg;
  reg rxelecidle_reg;
  reg rxheadervalid_reg;
  reg rxosintdone_reg;
  reg rxosintstarted_reg;
  reg rxosintstrobedone_reg;
  reg rxosintstrobestarted_reg;
  reg rxphaligndone_reg;
  reg rxpmaresetdone_reg;
  reg rxprbserr_reg;
  reg rxratedone_reg;
  reg rxresetdone_reg;
  reg rxsyncdone_reg;
  reg rxsyncout_reg;
  reg rxvalid_reg;
  reg txcomfinish_reg;
  reg txdlysresetdone_reg;
  reg txgearboxready_reg;
  reg txphaligndone_reg;
  reg txphinitdone_reg;
  reg txpmaresetdone_reg;
  reg txratedone_reg;
  reg txresetdone_reg;
  reg txsyncdone_reg;
  reg txsyncout_reg;

  wire gtprxn_int;
  wire gtprxp_int;
  wire rxusrclk_int;
  wire rxusrclk2_int;
  wire txusrclk_int;
  wire txusrclk2_int;
  wire drpclk_int;
  wire rxoutclk_int;
  wire txoutclk_int;
  wire tx_rst_sync;
  wire rx_rst_sync;
  wire pll0clk_int;
  wire pll1clk_int;

  wire [4:0] clk_cnt;
  reg [31:0] rx_prbs_cnt;
  reg [31:0] tx_prbs_cnt;
  
  wire loopback_en;
  assign loopback_en = (LOOPBACK != 3'b000);

  wire clkinsel_int;
  sky130_fd_sc_hd__buf_1 clkinsel_buf (.A(IS_CLKRSVD0_INVERTED ^ CLKRSVD0), .X(clkinsel_int));
  
  sky130_fd_sc_hd__buf_1 buf_gtprxn (.A(GTPRXN), .X(gtprxn_int));
  sky130_fd_sc_hd__buf_1 buf_gtprxp (.A(GTPRXP), .X(gtprxp_int));
  sky130_fd_sc_hd__buf_1 buf_rxusrclk (.A(IS_RXUSRCLK_INVERTED ^ RXUSRCLK), .X(rxusrclk_int));
  sky130_fd_sc_hd__buf_1 buf_rxusrclk2 (.A(IS_RXUSRCLK2_INVERTED ^ RXUSRCLK2), .X(rxusrclk2_int));
  sky130_fd_sc_hd__buf_1 buf_txusrclk (.A(IS_TXUSRCLK_INVERTED ^ TXUSRCLK), .X(txusrclk_int));
  sky130_fd_sc_hd__buf_1 buf_txusrclk2 (.A(IS_TXUSRCLK2_INVERTED ^ TXUSRCLK2), .X(txusrclk2_int));
  sky130_fd_sc_hd__buf_1 buf_drpclk (.A(IS_DRPCLK_INVERTED ^ DRPCLK), .X(drpclk_int));
  sky130_fd_sc_hd__buf_1 buf_pll0clk (.A(PLL0CLK), .X(pll0clk_int));
  sky130_fd_sc_hd__buf_1 buf_pll1clk (.A(PLL1CLK), .X(pll1clk_int));
  sky130_fd_sc_hd__buf_1 buf_txrst (.A(GTTXRESET), .X(tx_rst_sync));
  sky130_fd_sc_hd__buf_1 buf_rxrst (.A(GTRXRESET), .X(rx_rst_sync));

  reg [4:0] reset_cnt_rx;
  reg [4:0] reset_cnt_tx;
  wire rx_reset_done;
  wire tx_reset_done;

  always @(posedge rxusrclk2_int or posedge rx_rst_sync) begin
    if (rx_rst_sync) begin
      reset_cnt_rx <= 5'b00000;
    end else if (reset_cnt_rx != 5'b11111) begin
      reset_cnt_rx <= reset_cnt_rx + 1'b1;
    end
  end

  always @(posedge txusrclk2_int or posedge tx_rst_sync) begin
    if (tx_rst_sync) begin
      reset_cnt_tx <= 5'b00000;
    end else if (reset_cnt_tx != 5'b11111) begin
      reset_cnt_tx <= reset_cnt_tx + 1'b1;
    end
  end

  assign rx_reset_done = (reset_cnt_rx == 5'b11111);
  assign tx_reset_done = (reset_cnt_tx == 5'b11111);

  reg [19:0] rx_bit_cnt;
  reg [19:0] tx_bit_cnt;
  
  always @(posedge rxusrclk2_int or posedge rx_rst_sync) begin
    if (rx_rst_sync) begin
      rx_bit_cnt <= 20'b0;
    end else begin
      rx_bit_cnt <= rx_bit_cnt + 1'b1;
    end
  end

  always @(posedge txusrclk2_int or posedge tx_rst_sync) begin
    if (tx_rst_sync) begin
      tx_bit_cnt <= 20'b0;
    end else begin
      tx_bit_cnt <= tx_bit_cnt + 1'b1;
    end
  end

  reg [31:0] tx_data_delay;
  reg [3:0] tx_charisk_delay;
  reg [2:0] tx_header_delay;
  
  always @(posedge txusrclk2_int) begin
    tx_data_delay <= TXDATA;
    tx_charisk_delay <= TXCHARISK;
    tx_header_delay <= TXHEADER;
  end

  always @(posedge rxusrclk2_int or posedge rx_rst_sync) begin
    if (rx_rst_sync) begin
      rxdata_reg <= 32'b0;
      rxcharisk_reg <= 4'b0;
      rxchariscomma_reg <= 4'b0;
      rxdisperr_reg <= 4'b0;
      rxnotintable_reg <= 4'b0;
      rxdatavalid_reg <= 2'b0;
      rxheader_reg <= 3'b0;
      rxheadervalid_reg <= 1'b0;
      rxstartofseq_reg <= 2'b0;
      rxchbondo_reg <= 4'b0;
      rxbyteisaligned_reg <= 1'b0;
      rxbyterealign_reg <= 1'b0;
      rxcdrlock_reg <= 1'b0;
      rxchanbondseq_reg <= 1'b0;
      rxchanisaligned_reg <= 1'b0;
      rxchanrealign_reg <= 1'b0;
      rxcominitdet_reg <= 1'b0;
      rxcommadet_reg <= 1'b0;
      rxcomsasdet_reg <= 1'b0;
      rxcomwakedet_reg <= 1'b0;
      rxelecidle_reg <= 1'b1;
      rxosintdone_reg <= 1'b0;
      rxosintstarted_reg <= 1'b0;
      rxosintstrobedone_reg <= 1'b0;
      rxosintstrobestarted_reg <= 1'b0;
      rxphaligndone_reg <= 1'b0;
      rxpmaresetdone_reg <= 1'b0;
      rxprbserr_reg <= 1'b0;
      rxratedone_reg <= 1'b0;
      rxresetdone_reg <= 1'b0;
      rxsyncdone_reg <= 1'b0;
      rxsyncout_reg <= 1'b0;
      rxvalid_reg <= 1'b0;
      rxdlysresetdone_reg <= 1'b0;
      rxbufstatus_reg <= 3'b0;
      rxclkcorcnt_reg <= 2'b0;
      rxstatus_reg <= 3'b0;
      rxphmonitor_reg <= 5'b0;
      rxphslipmonitor_reg <= 5'b0;
    end else begin
      if (rx_reset_done && RXUSERRDY) begin
        rxbyteisaligned_reg <= 1'b1;
        rxcdrlock_reg <= 1'b1;
        rxchanisaligned_reg <= 1'b1;
        rxelecidle_reg <= 1'b0;
        rxpmaresetdone_reg <= 1'b1;
        rxratedone_reg <= 1'b1;
        rxresetdone_reg <= 1'b1;
        rxsyncdone_reg <= 1'b1;
        rxvalid_reg <= 1'b1;
        rxdlysresetdone_reg <= 1'b1;
        rxdatavalid_reg <= 2'b11;
        rxheadervalid_reg <= 1'b1;
      end
      
      if (loopback_en) begin
        rxdata_reg <= tx_data_delay;
        rxcharisk_reg <= tx_charisk_delay;
        rxheader_reg <= tx_header_delay;
      end else begin
        rxdata_reg <= {rx_bit_cnt[11:0], rx_bit_cnt[19:0]};
        rxcharisk_reg <= rx_bit_cnt[3:0];
        rxheader_reg <= rx_bit_cnt[2:0];
      end
      
      rxchbondo_reg <= RXCHBONDI;
      rxosintdone_reg <= RXOSINTEN;
      rxphaligndone_reg <= RXPHALIGNEN;
      
      if (RXCOMMADETEN && (rxdata_reg[7:0] == ALIGN_COMMA_VALUE[7:0])) begin
        rxcommadet_reg <= 1'b1;
        rxchariscomma_reg[0] <= 1'b1;
      end else begin
        rxcommadet_reg <= 1'b0;
        rxchariscomma_reg <= 4'b0;
      end
    end
  end

  always @(posedge txusrclk2_int or posedge tx_rst_sync) begin
    if (tx_rst_sync) begin
      txcomfinish_reg <= 1'b0;
      txdlysresetdone_reg <= 1'b0;
      txgearboxready_reg <= 1'b0;
      txphaligndone_reg <= 1'b0;
      txphinitdone_reg <= 1'b0;
      txpmaresetdone_reg <= 1'b0;
      txratedone_reg <= 1'b0;
      txresetdone_reg <= 1'b0;
      txsyncdone_reg <= 1'b0;
      txsyncout_reg <= 1'b0;
      txbufstatus_reg <= 2'b0;
    end else begin
      if (tx_reset_done && TXUSERRDY) begin
        txdlysresetdone_reg <= 1'b1;
        txgearboxready_reg <= 1'b1;
        txpmaresetdone_reg <= 1'b1;
        txratedone_reg <= 1'b1;
        txresetdone_reg <= 1'b1;
        txsyncdone_reg <= 1'b1;
      end
      txphaligndone_reg <= TXPHALIGNEN;
      txphinitdone_reg <= TXPHINIT;
      txcomfinish_reg <= TXCOMINIT | TXCOMSAS | TXCOMWAKE;
    end
  end

  reg drp_rdy_dly;
  always @(posedge drpclk_int) begin
    drp_rdy_dly <= DRPEN;
    drprdy_reg <= drp_rdy_dly & ~DRPEN;
    
    if (DRPEN && !DRPWE) begin
      drpdo_reg <= {7'b0, DRPADDR};
    end else if (DRPEN && DRPWE) begin
      drpdo_reg <= DRPDI;
    end
  end

  always @(posedge SIGVALIDCLK) begin
    eyescandataerror_reg <= 1'b0;
    phystatus_reg <= 1'b0;
    pmarsvdout0_reg <= PMARSVDIN0;
    pmarsvdout1_reg <= PMARSVDIN1;
    pcsrsvdout_reg <= PCSRSVDIN;
    dmonitorout_reg <= 15'b0;
  end

  wire rxclk_sel;
  wire txclk_sel;
  assign rxclk_sel = RXSYSCLKSEL[0];
  assign txclk_sel = TXSYSCLKSEL[0];
  
  assign rxoutclk_int = rxclk_sel ? pll1clk_int : pll0clk_int;
  assign txoutclk_int = txclk_sel ? pll1clk_int : pll0clk_int;

  sky130_fd_sc_hd__buf_1 buf_rxoutclk (.A(rxoutclk_int), .X(RXOUTCLK));
  sky130_fd_sc_hd__buf_1 buf_rxoutclkfabric (.A(rxoutclk_int), .X(RXOUTCLKFABRIC));
  sky130_fd_sc_hd__buf_1 buf_rxoutclkpcs (.A(rxoutclk_int), .X(RXOUTCLKPCS));
  sky130_fd_sc_hd__buf_1 buf_txoutclk (.A(txoutclk_int), .X(TXOUTCLK));
  sky130_fd_sc_hd__buf_1 buf_txoutclkfabric (.A(txoutclk_int), .X(TXOUTCLKFABRIC));
  sky130_fd_sc_hd__buf_1 buf_txoutclkpcs (.A(txoutclk_int), .X(TXOUTCLKPCS));

  assign GTPTXN = TXPOLARITY ? gtprxp_int : ~gtprxp_int;
  assign GTPTXP = TXPOLARITY ? ~gtprxp_int : gtprxp_int;

  assign DMONITOROUT = dmonitorout_reg;
  assign DRPDO = drpdo_reg;
  assign DRPRDY = drprdy_reg;
  assign EYESCANDATAERROR = eyescandataerror_reg;
  assign PCSRSVDOUT = pcsrsvdout_reg;
  assign PHYSTATUS = phystatus_reg;
  assign PMARSVDOUT0 = pmarsvdout0_reg;
  assign PMARSVDOUT1 = pmarsvdout1_reg;
  assign RXBUFSTATUS = rxbufstatus_reg;
  assign RXBYTEISALIGNED = rxbyteisaligned_reg;
  assign RXBYTEREALIGN = rxbyterealign_reg;
  assign RXCDRLOCK = rxcdrlock_reg;
  assign RXCHANBONDSEQ = rxchanbondseq_reg;
  assign RXCHANISALIGNED = rxchanisaligned_reg;
  assign RXCHANREALIGN = rxchanrealign_reg;
  assign RXCHARISCOMMA = rxchariscomma_reg;
  assign RXCHARISK = rxcharisk_reg;
  assign RXCHBONDO = rxchbondo_reg;
  assign RXCLKCORCNT = rxclkcorcnt_reg;
  assign RXCOMINITDET = rxcominitdet_reg;
  assign RXCOMMADET = rxcommadet_reg;
  assign RXCOMSASDET = rxcomsasdet_reg;
  assign RXCOMWAKEDET = rxcomwakedet_reg;
  assign RXDATA = rxdata_reg;
  assign RXDATAVALID = rxdatavalid_reg;
  assign RXDISPERR = rxdisperr_reg;
  assign RXDLYSRESETDONE = rxdlysresetdone_reg;
  assign RXELECIDLE = rxelecidle_reg;
  assign RXHEADER = rxheader_reg;
  assign RXHEADERVALID = rxheadervalid_reg;
  assign RXNOTINTABLE = rxnotintable_reg;
  assign RXOSINTDONE = rxosintdone_reg;
  assign RXOSINTSTARTED = rxosintstarted_reg;
  assign RXOSINTSTROBEDONE = rxosintstrobedone_reg;
  assign RXOSINTSTROBESTARTED = rxosintstrobestarted_reg;
  assign RXPHALIGNDONE = rxphaligndone_reg;
  assign RXPHMONITOR = rxphmonitor_reg;
  assign RXPHSLIPMONITOR = rxphslipmonitor_reg;
  assign RXPMARESETDONE = rxpmaresetdone_reg;
  assign RXPRBSERR = rxprbserr_reg;
  assign RXRATEDONE = rxratedone_reg;
  assign RXRESETDONE = rxresetdone_reg;
  assign RXSTARTOFSEQ = rxstartofseq_reg;
  assign RXSTATUS = rxstatus_reg;
  assign RXSYNCDONE = rxsyncdone_reg;
  assign RXSYNCOUT = rxsyncout_reg;
  assign RXVALID = rxvalid_reg;
  assign TXBUFSTATUS = txbufstatus_reg;
  assign TXCOMFINISH = txcomfinish_reg;
  assign TXDLYSRESETDONE = txdlysresetdone_reg;
  assign TXGEARBOXREADY = txgearboxready_reg;
  assign TXPHALIGNDONE = txphaligndone_reg;
  assign TXPHINITDONE = txphinitdone_reg;
  assign TXPMARESETDONE = txpmaresetdone_reg;
  assign TXRATEDONE = txratedone_reg;
  assign TXRESETDONE = txresetdone_reg;
  assign TXSYNCDONE = txsyncdone_reg;
  assign TXSYNCOUT = txsyncout_reg;

endmodule
