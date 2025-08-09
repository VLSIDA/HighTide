module GTHE4_CHANNEL_DUMMY #(
  parameter [0:0] ACJTAG_DEBUG_MODE = 1'b0,
  parameter [0:0] ACJTAG_MODE = 1'b0,
  parameter [0:0] ACJTAG_RESET = 1'b0,
  parameter [19:0] ADAPT_CFG0 = 20'h00920,
  parameter [15:0] ADAPT_CFG1 = 16'hF800,
  parameter [19:0] ADAPT_CFG2 = 20'h00801,
  parameter ALIGN_COMMA_DOUBLE = "FALSE",
  parameter [9:0] ALIGN_COMMA_ENABLE = 10'b0001111111,
  parameter integer ALIGN_COMMA_WORD = 1,
  parameter ALIGN_MCOMMA_DET = "TRUE",
  parameter [9:0] ALIGN_MCOMMA_VALUE = 10'b1010000011,
  parameter ALIGN_PCOMMA_DET = "TRUE",
  parameter [9:0] ALIGN_PCOMMA_VALUE = 10'b0101111100,
  parameter [0:0] A_RXOSCALRESET = 1'b0,
  parameter [0:0] A_RXPROGDIVRESET = 1'b0,
  parameter [0:0] A_RXTERMINATION = 1'b1,
  parameter [4:0] A_TXDIFFCTRL = 5'b01100,
  parameter [0:0] A_TXPROGDIVRESET = 1'b0,
  parameter CBCC_DATA_SOURCE_SEL = "DECODED",
  parameter CDR_SWAP_MODE_EN = "FALSE",
  parameter [4:0] CFOK_PWRSVE_EN = 5'b00000,
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
  parameter [15:0] CH_HSPMUX = 16'h2424,
  parameter [0:0] CKCAL1_CFG_0 = 1'b1,
  parameter [0:0] CKCAL1_CFG_1 = 1'b0,
  parameter [0:0] CKCAL1_CFG_2 = 1'b0,
  parameter [0:0] CKCAL1_CFG_3 = 1'b0,
  parameter [0:0] CKCAL2_CFG_0 = 1'b1,
  parameter [0:0] CKCAL2_CFG_1 = 1'b0,
  parameter [0:0] CKCAL2_CFG_2 = 1'b1,
  parameter [0:0] CKCAL2_CFG_3 = 1'b1,
  parameter [0:0] CKCAL2_CFG_4 = 1'b0,
  parameter [6:0] CKCAL_RSVD0 = 7'h00,
  parameter [15:0] CKCAL_RSVD1 = 16'h0000,
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
  parameter [15:0] CPLL_CFG0 = 16'h01FA,
  parameter [15:0] CPLL_CFG1 = 16'h0023,
  parameter [15:0] CPLL_CFG2 = 16'h0002,
  parameter [15:0] CPLL_CFG3 = 16'h0000,
  parameter [0:0] CPLL_FBDIV = 1'b0,
  parameter integer CPLL_FBDIV_45 = 4,
  parameter [15:0] CPLL_INIT_CFG0 = 16'h02B2,
  parameter [7:0] CPLL_LOCK_CFG = 8'h01,
  parameter integer CPLL_REFCLK_DIV = 1,
  parameter [0:0] CTLE3_OCAP_EXT_CTRL = 3'b000,
  parameter [0:0] CTLE3_OCAP_EXT_EN = 1'b0,
  parameter DMONITOR_CFG0 = 10'h000,
  parameter [7:0] DMONITOR_CFG1 = 8'h00,
  parameter [0:0] ES_CLK_PHASE_SEL = 1'b0,
  parameter [0:0] ES_CONTROL = 1'b0,
  parameter ES_ERRDET_EN = "FALSE",
  parameter ES_EYE_SCAN_EN = "FALSE",
  parameter [10:0] ES_HORZ_OFFSET = 11'h000,
  parameter [4:0] ES_PRESCALE = 5'b00000,
  parameter [0:0] ES_PMA_CFG = 1'b0,
  parameter [15:0] ES_QUALIFIER0 = 16'h0000,
  parameter [15:0] ES_QUALIFIER1 = 16'h0000,
  parameter [15:0] ES_QUALIFIER2 = 16'h0000,
  parameter [15:0] ES_QUALIFIER3 = 16'h0000,
  parameter [15:0] ES_QUALIFIER4 = 16'h0000,
  parameter [15:0] ES_QUALIFIER5 = 16'h0000,
  parameter [15:0] ES_QUALIFIER6 = 16'h0000,
  parameter [15:0] ES_QUALIFIER7 = 16'h0000,
  parameter [15:0] ES_QUALIFIER8 = 16'h0000,
  parameter [15:0] ES_QUALIFIER9 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK0 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK1 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK2 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK3 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK4 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK5 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK6 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK7 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK8 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK9 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK0 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK1 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK2 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK3 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK4 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK5 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK6 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK7 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK8 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK9 = 16'h0000,
  parameter [0:0] EYE_SCAN_SWAP_EN = 1'b0,
  parameter [3:0] FTS_DESKEW_SEQ_ENABLE = 4'b1111,
  parameter [3:0] FTS_LANE_DESKEW_CFG = 4'b1111,
  parameter FTS_LANE_DESKEW_EN = "FALSE",
  parameter [2:0] GEARBOX_MODE = 3'b000,
  parameter [0:0] ISCAN_CK_PH_SEL2 = 1'b0,
  parameter [0:0] LOCAL_MASTER = 1'b1,
  parameter [2:0] LPBK_BIAS_CTRL = 3'b100,
  parameter [0:0] LPBK_EN_RCAL_B = 1'b0,
  parameter [3:0] LPBK_EXT_RCAL = 4'b0000,
  parameter [2:0] LPBK_IND_CTRL0 = 3'b000,
  parameter [2:0] LPBK_IND_CTRL1 = 3'b000,
  parameter [2:0] LPBK_IND_CTRL2 = 3'b000,
  parameter [3:0] LPBK_RG_CTRL = 4'b0000,
  parameter [1:0] OOBDIVCTL = 2'b00,
  parameter [0:0] OOB_PWRUP = 1'b0,
  parameter PCI3_AUTO_REALIGN = "OVR_1K_BLK",
  parameter [0:0] PCI3_PIPE_RX_ELECIDLE = 1'b0,
  parameter [1:0] PCI3_RX_ASYNC_EBUF_BYPASS = 2'b00,
  parameter [0:0] PCI3_RX_ELECIDLE_EI2_ENABLE = 1'b0,
  parameter [5:0] PCI3_RX_ELECIDLE_H2L_COUNT = 6'b000000,
  parameter [2:0] PCI3_RX_ELECIDLE_H2L_DISABLE = 3'b000,
  parameter [5:0] PCI3_RX_ELECIDLE_HI_COUNT = 6'b000000,
  parameter [0:0] PCI3_RX_ELECIDLE_LP4_DISABLE = 1'b0,
  parameter [0:0] PCI3_RX_FIFO_DISABLE = 1'b0,
  parameter [4:0] PCIE3_CLK_COR_EMPTY_THRSH = 5'b00000,
  parameter [5:0] PCIE3_CLK_COR_FULL_THRSH = 6'b010000,
  parameter [4:0] PCIE3_CLK_COR_MAX_LAT = 5'b00100,
  parameter [4:0] PCIE3_CLK_COR_MIN_LAT = 5'b00000,
  parameter [5:0] PCIE3_CLK_COR_THRSH_TIMER = 6'b001000,
  parameter [15:0] PCIE_64B_DYN_CLKSW_DIS = 16'h0000,
  parameter [13:0] PCIE_BUFG_DIV_CTRL = 12'h3500,
  parameter [1:0] PCIE_GEN4_64BIT_INT_EN = 2'b00,
  parameter [0:0] PCIE_PLL_SEL_MODE_GEN12 = 1'b0,
  parameter [1:0] PCIE_PLL_SEL_MODE_GEN3 = 2'b00,
  parameter [1:0] PCIE_PLL_SEL_MODE_GEN4 = 2'b00,
  parameter [15:0] PCIE_RXPCS_CFG_GEN3 = 16'h0AA5,
  parameter [15:0] PCIE_RXPMA_CFG = 16'h280A,
  parameter [15:0] PCIE_TXPCS_CFG_GEN3 = 16'h24A4,
  parameter [15:0] PCIE_TXPMA_CFG = 16'h280A,
  parameter PCS_PCIE_EN = "FALSE",
  parameter [15:0] PCS_RSVD0 = 16'h0000,
  parameter [11:0] PD_TRANS_TIME_FROM_P2 = 12'h03C,
  parameter [7:0] PD_TRANS_TIME_NONE_P2 = 8'h19,
  parameter [7:0] PD_TRANS_TIME_TO_P2 = 8'h64,
  parameter [0:0] PREIQ_FREQ_BST = 1'b0,
  parameter [2:0] RATE_SW_USE_DRP = 3'b001,
  parameter [13:0] RCLK_SIPO_DLY_ENB = 14'b00000000000000,
  parameter [15:0] RCLK_SIPO_INV_EN = 16'h0000,
  parameter [0:0] RX_AFE_CM_EN = 1'b0,
  parameter [15:0] RX_BIAS_CFG0 = 16'h12B0,
  parameter [5:0] RX_BUFFER_CFG = 6'b000000,
  parameter [0:0] RX_CAPFF_SARC_ENB = 1'b0,
  parameter integer RX_CLK25_DIV = 8,
  parameter [0:0] RXSYNC_SKIP_DA = 1'b0,
  parameter [0:0] RXSYNC_OVRD = 1'b0,
  parameter [0:0] RXSYNC_MULTILANE = 1'b0,
  parameter [0:0] RX_CDR_CFG0 = 1'b0,
  parameter [15:0] RX_CDR_CFG0_GEN3 = 16'h0000,
  parameter [15:0] RX_CDR_CFG1 = 16'h0000,
  parameter [15:0] RX_CDR_CFG1_GEN3 = 16'h0000,
  parameter [15:0] RX_CDR_CFG2 = 16'h0269,
  parameter [10:0] RX_CDR_CFG2_GEN2 = 11'h269,
  parameter [15:0] RX_CDR_CFG2_GEN3 = 16'h0269,
  parameter [15:0] RX_CDR_CFG2_GEN4 = 16'h0164,
  parameter [15:0] RX_CDR_CFG3 = 16'h0010,
  parameter [5:0] RX_CDR_CFG3_GEN2 = 6'h10,
  parameter [15:0] RX_CDR_CFG3_GEN3 = 16'h0010,
  parameter [15:0] RX_CDR_CFG3_GEN4 = 16'h0010,
  parameter [15:0] RX_CDR_CFG4 = 16'h5CF6,
  parameter [15:0] RX_CDR_CFG4_GEN3 = 16'h5CF6,
  parameter [14:0] RX_CDR_CFG5 = 15'h0146,
  parameter [15:0] RX_CDR_CFG5_GEN3 = 16'h0146,
  parameter [0:0] RX_CDR_LOCK_CFG0 = 1'b0,
  parameter [15:0] RX_CDR_LOCK_CFG1 = 16'h8000,
  parameter [15:0] RX_CDR_LOCK_CFG2 = 16'h0000,
  parameter [15:0] RX_CDR_LOCK_CFG3 = 16'h0000,
  parameter [15:0] RX_CDR_LOCK_CFG4 = 16'h0000,
  parameter [0:0] RX_CDR_PH_RESET_ON_EIDLE = 1'b0,
  parameter [15:0] RX_CFG0 = 16'h0000,
  parameter [15:0] RX_CFG1 = 16'h4002,
  parameter [15:0] RX_CFG2 = 16'h0049,
  parameter [0:0] RX_CLKMUX_EN = 1'b1,
  parameter [15:0] RX_CLK_SLIP_OVRD = 16'h0000,
  parameter [15:0] RX_CM_BUF_CFG = 16'h1010,
  parameter [0:0] RX_CM_BUF_PD = 1'b0,
  parameter [0:0] RX_CM_SEL = 1'b0,
  parameter [0:0] RX_CM_TRIM = 1'b0,
  parameter [7:0] RX_CTLE3_LPF = 8'b00000000,
  parameter [15:0] RX_CTLE_PWR_SAVING = 16'h0000,
  parameter [15:0] RX_CTLE_RES_CTRL = 16'h0314,
  parameter [1:0] RX_DATA_DECODING = 2'b00,
  parameter integer RX_DATA_WIDTH = 20,
  parameter [5:0] RX_DDI_SEL = 6'h000000,
  parameter [13:0] RX_DEFER_RESET_BUF_EN = 14'h0000,
  parameter [2:0] RX_DEGEN_CTRL = 3'b011,
  parameter [15:0] RX_DFELPM_CFG0 = 16'h0006,
  parameter [0:0] RX_DFELPM_CFG1 = 1'b1,
  parameter [0:0] RX_DFELPM_KLKH_AGC_STUP_EN = 1'b1,
  parameter [0:0] RX_DFE_AGC_CFG0 = 1'b0,
  parameter [1:0] RX_DFE_AGC_CFG1 = 2'b10,
  parameter [0:0] RX_DFE_KL_LPM_KH_CFG0 = 1'b0,
  parameter [1:0] RX_DFE_KL_LPM_KH_CFG1 = 2'b00,
  parameter [15:0] RX_DFE_KL_LPM_KL_CFG0 = 16'h0002,
  parameter [1:0] RX_DFE_KL_LPM_KL_CFG1 = 2'b00,
  parameter [0:0] RX_DFE_LPM_HOLD_DURING_EIDLE = 1'b0,
  parameter RX_DISPERR_SEQ_MATCH = "TRUE",
  parameter [15:0] RX_DIV2_MODE_B = 16'h0000,
  parameter [4:0] RX_DIVRESET_TIME = 5'b00001,
  parameter [0:0] RX_EN_CTLE_RCAL_B = 1'b0,
  parameter RX_EN_HI_LR = "FALSE",
  parameter [8:0] RX_EXT_RL_CTRL = 9'b000000000,
  parameter [6:0] RX_EYESCAN_VS_CODE = 7'b0000000,
  parameter [0:0] RX_EYESCAN_VS_NEG_DIR = 1'b0,
  parameter [1:0] RX_EYESCAN_VS_RANGE = 2'b00,
  parameter [0:0] RX_EYESCAN_VS_UT_SIGN = 1'b0,
  parameter [0:0] RX_FABINT_USRCLK_FLOP = 1'b0,
  parameter [0:0] RX_INT_DATAWIDTH = 1'b0,
  parameter [0:0] RX_I2V_FILTER_EN = 1'b1,
  parameter [0:0] RX_INT_DATA_WIDTH = 1'b0,
  parameter [0:0] RX_PMA_POWER_SAVE = 1'b0,
  parameter [15:0] RX_PMA_RSV0 = 16'h0000,
  parameter [15:0] RX_PROGDIV_CFG = 16'h0000,
  parameter [14:0] RX_PROGDIV_RATE = 15'h0001,
  parameter [3:0] RX_RESLOAD_CTRL = 4'b0000,
  parameter [0:0] RX_RESLOAD_OVRD = 1'b0,
  parameter [2:0] RX_SAMPLE_PERIOD = 3'b101,
  parameter [0:0] RX_SIG_VALID_DLY = 1'b0,
  parameter RX_SUM_DFETAPREP_EN = "FALSE",
  parameter [3:0] RX_SUM_RESLOAD_CTRL = 4'b0000,
  parameter [3:0] RX_SUM_IREF_TUNE = 4'b0100,
  parameter [11:0] RX_SUM_RES_CTRL = 12'h0004,
  parameter [3:0] RX_SUM_VCMTUNE = 4'b0110,
  parameter [0:0] RX_SUM_VCM_OVWR = 1'b0,
  parameter [2:0] RX_SUM_VREF_TUNE = 3'b100,
  parameter [1:0] RX_TUNE_AFE_OS = 2'b00,
  parameter [2:0] RX_VREG_CTRL = 3'b101,
  parameter RX_VREG_PDB = "TRUE",
  parameter [1:0] RX_WIDEMODE_CDR = 2'b00,
  parameter [1:0] RX_WIDEMODE_CDR_GEN3 = 2'b00,
  parameter [1:0] RX_WIDEMODE_CDR_GEN4 = 2'b01,
  parameter integer RXSLIDE_AUTO_WAIT = 7,
  parameter RXSLIDE_MODE = "OFF",
  parameter [0:0] RXPRBS_ERR_LOOPBACK = 1'b0,
  parameter RX_XCLK_SEL = "RXDES",
  parameter [0:0] RX_XMODE_SEL = 1'b0,
  parameter integer RXPRBS_LINKACQ_CNT = 15,
  parameter [0:0] SAMPLE_CLK_PHASE = 1'b0,
  parameter [4:0] RXPMARESET_TIME = 5'b00001,
  parameter RXPMACLK_SEL = "DATA",
  parameter [1:0] RXPI_STARTCODE = 2'b00,
  parameter [0:0] RXPI_VREFSEL = 1'b0,
  parameter [0:0] RXPI_AUTO_BW_SEL_BYPASS = 1'b0,
  parameter [1:0] RXPI_SEL_LC = 2'b00,
  parameter [0:0] RXPI_LPM = 1'b0,
  parameter [15:0] RXPI_CFG1 = 16'b0000000000000000,
  parameter [15:0] RXPI_CFG0 = 16'h0002,
  parameter [4:0] RXPCSRESET_TIME = 5'b00001,
  parameter [4:0] RXPH_MONITOR_SEL = 5'b00000,
  parameter [15:0] RXPHSLIP_CFG = 16'h9933,
  parameter [15:0] RXPHBEACON_CFG = 16'h0000,
  parameter [15:0] RXPHDLY_CFG = 16'h2020,
  parameter [15:0] RXPHSAMP_CFG = 16'h2100,
  parameter integer RXOUT_DIV = 4,
  parameter [0:0] SAS_12G_MODE = 1'b0,
  parameter [3:0] SATA_BURST_SEQ_LEN = 4'b1111,
  parameter [2:0] SATA_BURST_VAL = 3'b100,
  parameter SATA_CPLL_CFG = "VCO_3000MHZ",
  parameter [2:0] SATA_EIDLE_VAL = 3'b100,
  parameter [0:0] SHOW_REALIGN_COMMA = 1'b0,
  parameter SIM_DEVICE = "ULTRASCALE_PLUS",
  parameter SIM_MODE = "FAST",
  parameter SIM_RECEIVER_DETECT_PASS = "TRUE",
  parameter SIM_RESET_SPEEDUP = "TRUE",
  parameter SIM_TX_EIDLE_DRIVE_LEVEL = "X",
  parameter SRSTMODE = "FALSE",
  parameter [1:0] TAPDLY_SET_TX = 2'h0,
  parameter [14:0] TEMPERATURE_PAR = 15'h0010,
  parameter [15:0] TERM_RCAL_CFG = 16'b100001000010001,
  parameter [2:0] TERM_RCAL_OVRD = 3'b000,
  parameter [7:0] TRANS_TIME_RATE = 8'h0E,
  parameter [7:0] TST_RSV0 = 8'h00,
  parameter [7:0] TST_RSV1 = 8'h00,
  parameter TXBUF_EN = "TRUE",
  parameter TXBUF_RESET_ON_RATE_CHANGE = "TRUE",
  parameter [15:0] TXDLY_CFG = 16'h8010,
  parameter [8:0] TXDLY_LCFG = 9'h030,
  parameter TXDRVBIAS_N = "FALSE",
  parameter [15:0] TXFIFO_ADDR_CFG = 16'h0000,
  parameter TXGBOX_FIFO_INIT_RD_ADDR = 3,
  parameter TXGEARBOX_EN = "FALSE",
  parameter [4:0] TXOUT_DIV = 5'b00000,
  parameter [4:0] TXPCSRESET_TIME = 5'b00001,
  parameter [15:0] TXPHDLY_CFG0 = 16'h6070,
  parameter [15:0] TXPHDLY_CFG1 = 16'h000E,
  parameter [15:0] TXPH_CFG = 16'h0123,
  parameter [15:0] TXPH_CFG2 = 16'h0000,
  parameter [4:0] TXPH_MONITOR_SEL = 5'b00000,
  parameter [1:0] TXPI_CFG = 2'b00,
  parameter [0:0] TXPI_CFG0 = 1'b0,
  parameter [0:0] TXPI_CFG1 = 1'b0,
  parameter [0:0] TXPI_CFG2 = 1'b0,
  parameter [0:0] TXPI_CFG3 = 1'b0,
  parameter [0:0] TXPI_CFG4 = 1'b1,
  parameter [2:0] TXPI_CFG5 = 3'b000,
  parameter [0:0] TXPI_GRAY_SEL = 1'b0,
  parameter [0:0] TXPI_INVSTROBE_SEL = 1'b0,
  parameter [0:0] TXPI_LPM = 1'b0,
  parameter [7:0] TXPI_PPM = 8'h00,
  parameter [0:0] TXPI_PPM_CFG = 1'b0,
  parameter TXPI_PPMCLK_SEL = "TXUSRCLK2",
  parameter [2:0] TXPI_SYNFREQ_PPM = 3'b001,
  parameter [0:0] TXPI_VREFSEL = 1'b0,
  parameter [4:0] TXPMARESET_TIME = 5'b00001,
  parameter [0:0] TXSYNC_MULTILANE = 1'b0,
  parameter [0:0] TXSYNC_OVRD = 1'b0,
  parameter [0:0] TXSYNC_SKIP_DA = 1'b0,
  parameter [0:0] TX_CLK25_DIV = 1'b0,
  parameter [0:0] TX_CLKMUX_EN = 1'b1,
  parameter integer TX_DATA_WIDTH = 20,
  parameter [15:0] TX_DCC_LOOP_RST_CFG = 16'h0004,
  parameter [5:0] TX_DEEMPH0 = 6'b000000,
  parameter [5:0] TX_DEEMPH1 = 6'b000000,
  parameter [5:0] TX_DEEMPH2 = 6'b000000,
  parameter [5:0] TX_DEEMPH3 = 6'b000000,
  parameter [4:0] TX_DIVRESET_TIME = 5'b00001,
  parameter TX_DRIVE_MODE = "DIRECT",
  parameter [2:0] TX_DRVMUX_CTRL = 3'b010,
  parameter [2:0] TX_EIDLE_ASSERT_DELAY = 3'b110,
  parameter [2:0] TX_EIDLE_DEASSERT_DELAY = 3'b100,
  parameter [0:0] TX_FABINT_USRCLK_FLOP = 1'b0,
  parameter [0:0] TX_FIFO_BYP_EN = 1'b0,
  parameter [0:0] TX_IDLE_DATA_ZERO = 1'b0,
  parameter [0:0] TX_INT_DATAWIDTH = 1'b0,
  parameter TX_LOOPBACK_DRIVE_HIZ = "FALSE",
  parameter [0:0] TX_MAINCURSOR_SEL = 1'b0,
  parameter [6:0] TX_MARGIN_FULL_0 = 7'b1011111,
  parameter [6:0] TX_MARGIN_FULL_1 = 7'b1011110,
  parameter [6:0] TX_MARGIN_FULL_2 = 7'b1011100,
  parameter [6:0] TX_MARGIN_FULL_3 = 7'b1011010,
  parameter [6:0] TX_MARGIN_FULL_4 = 7'b1011000,
  parameter [6:0] TX_MARGIN_LOW_0 = 7'b1000110,
  parameter [6:0] TX_MARGIN_LOW_1 = 7'b1000101,
  parameter [6:0] TX_MARGIN_LOW_2 = 7'b1000011,
  parameter [6:0] TX_MARGIN_LOW_3 = 7'b1000010,
  parameter [6:0] TX_MARGIN_LOW_4 = 7'b1000000,
  parameter [0:0] TX_PHICAL_CFG0 = 1'b0,
  parameter [15:0] TX_PHICAL_CFG1 = 16'h0020,
  parameter [15:0] TX_PHICAL_CFG2 = 16'h0040,
  parameter [0:0] TX_PI_BIASSET = 1'b0,
  parameter [1:0] TX_PI_IBIAS_MID = 2'b00,
  parameter [0:0] TX_PMADATA_OPT = 1'b0,
  parameter [0:0] TX_PMA_POWER_SAVE = 1'b0,
  parameter [15:0] TX_PMA_RSV0 = 16'h0008,
  parameter [0:0] TX_PREDRV_CTRL = 1'b0,
  parameter [13:0] TX_PROGCLK_SEL = 14'h0000,
  parameter [15:0] TX_PROGDIV_CFG = 16'h0000,
  parameter [15:0] TX_PROGDIV_RATE = 16'h0001,
  parameter [0:0] TX_QPI_STATUS_EN = 1'b0,
  parameter [13:0] TX_RXDETECT_CFG = 14'h0032,
  parameter [2:0] TX_RXDETECT_REF = 3'b011,
  parameter [0:0] TX_SAMPLE_PERIOD = 1'b0,
  parameter [0:0] TX_SARC_LPBK_ENB = 1'b0,
  parameter [1:0] TX_SW_MEAS = 2'b00,
  parameter [14:0] TX_VREG_CTRL = 15'h000,
  parameter [0:0] TX_VREG_PDB = 1'b0,
  parameter [1:0] TX_VREG_VREFSEL = 2'b00,
  parameter TX_XCLK_SEL = "TXOUT",
  parameter [0:0] USB_BOTH_BURST_IDLE = 1'b0,
  parameter [6:0] USB_BURSTMAX_U3WAKE = 7'b1111111,
  parameter [6:0] USB_BURSTMIN_U3WAKE = 7'b1100011,
  parameter [0:0] USB_CLK_COR_EQ_EN = 1'b0,
  parameter [0:0] USB_EXT_CNTL = 1'b1,
  parameter [9:0] USB_IDLEMAX_POLLING = 10'b1010111011,
  parameter [9:0] USB_IDLEMIN_POLLING = 10'b0100101011,
  parameter [8:0] USB_LFPSPING_BURST = 9'b000000101,
  parameter [8:0] USB_LFPSPOLLING_BURST = 9'b000110001,
  parameter [8:0] USB_LFPSPOLLING_IDLE_MS = 9'b000100100,
  parameter [8:0] USB_LFPSU1EXIT_BURST = 9'b000011101,
  parameter [8:0] USB_LFPSU2LPEXIT_BURST_MS = 9'b001100011,
  parameter [8:0] USB_LFPSU3WAKE_BURST_MS = 9'b111110011,
  parameter [3:0] USB_LFPS_TPERIOD = 4'b0011,
  parameter [0:0] USB_LFPS_TPERIOD_ACCURATE = 1'b1,
  parameter [0:0] USB_MODE = 1'b0,
  parameter [0:0] USB_PCIE_ERR_REP_DIS = 1'b0,
  //// FIXME:
  parameter [2:0] PROCESS_PAR = 0,
  parameter [0:0] RESET_POWERSAVE_DISABLE = 0,
  parameter [2:0] RTX_BUF_CML_CTRL = 0,
  parameter [1:0] RTX_BUF_TERM_CTRL = 0,
  parameter [4:0] RXBUFRESET_TIME = 0,
  parameter RXBUF_ADDR_MODE = 0,
  parameter [3:0] RXBUF_EIDLE_HI_CNT = 0,
  parameter [3:0] RXBUF_EIDLE_LO_CNT = 0,
  parameter RXBUF_EN = 0,
  parameter RXBUF_RESET_ON_CB_CHANGE = 0,
  parameter RXBUF_RESET_ON_COMMAALIG = 0,
  parameter RXBUF_RESET_ON_EIDLE = 0,
  parameter RXBUF_RESET_ON_RATE_CHANGE = 0,
  parameter RXBUF_THRESH_OVRD = 0,
  parameter [4:0] RXCDRFREQRESET_TIM = 0,
  parameter [4:0] RXCDRPHRESET_TIME = 0,
  parameter [15:0] RXCDR_CFG0 = 0,
  parameter RXOSCALRESET_TIME = 0,
  parameter RXOOB_CLK_CFG = 0,
  parameter RXOOB_CFG = 0,
  parameter RXLPM_OS_CFG1 = 0,
  parameter RXLPM_OS_CFG0 = 0,
  parameter RXLPM_KH_CFG1 = 0,
  parameter RXLPM_KH_CFG0 = 0,
  parameter RXDFE_UT_CFG1 = 0,
  parameter RXDFE_UT_CFG2 = 0,
  parameter RXDFE_VP_CFG0 = 0,
  parameter RXDFE_VP_CFG1 = 0,
  parameter RXDLY_CFG = 0,
  parameter RXDLY_LCFG = 0,
  parameter RXELECIDLE_CFG = 0,
  parameter RXGBOX_FIFO_INIT_RD_ADDR = 0,
  parameter RXGEARBOX_EN = 0,
  parameter RXISCANRESET_TIME = 0,
  parameter RXLPM_CFG = 0,
  parameter RXLPM_GC_CFG = 0,
  parameter RXDFE_CFG0 = 0,
  parameter RXDFE_CFG1 = 0,
  parameter RXDFE_GC_CFG0 = 0,
  parameter RXDFE_GC_CFG1 = 0,
  parameter RXDFE_GC_CFG2 = 0,
  parameter RXDFE_H2_CFG0 = 0,
  parameter RXDFE_H2_CFG1 = 0,
  parameter RXDFE_H3_CFG0 = 0,
  parameter RXDFE_H3_CFG1 = 0,
  parameter RXDFE_H4_CFG0 = 0,
  parameter RXDFE_H4_CFG1 = 0,
  parameter RXDFE_H5_CFG0 = 0,
  parameter RXDFE_H5_CFG1 = 0,
  parameter RXDFE_H6_CFG0 = 0,
  parameter RXDFE_H6_CFG1 = 0,
  parameter RXDFE_H7_CFG0 = 0,
  parameter RXDFE_H7_CFG1 = 0,
  parameter RXDFE_H8_CFG0 = 0,
  parameter RXDFE_H8_CFG1 = 0,
  parameter RXDFE_H9_CFG0 = 0,
  parameter RXDFE_H9_CFG1 = 0,
  parameter RXDFE_HA_CFG0 = 0,
  parameter RXDFE_HA_CFG1 = 0,
  parameter RXDFE_HB_CFG0 = 0,
  parameter RXDFE_HB_CFG1 = 0,
  parameter RXDFE_HC_CFG0 = 0,
  parameter RXDFE_HC_CFG1 = 0,
  parameter RXDFE_HD_CFG0 = 0,
  parameter RXDFE_HD_CFG1 = 0,
  parameter RXDFE_HE_CFG0 = 0,
  parameter RXDFE_HE_CFG1 = 0,
  parameter RXDFE_HF_CFG0 = 0,
  parameter RXDFE_HF_CFG1 = 0,
  parameter RXDFE_KH_CFG0 = 0,
  parameter RXDFE_KH_CFG1 = 0,
  parameter RXDFE_KH_CFG2 = 0,
  parameter RXDFE_KH_CFG3 = 0,
  parameter RXDFE_OS_CFG0 = 0,
  parameter RXDFE_OS_CFG1 = 0,
  parameter RXDFE_PWR_SAVING = 0,
  parameter RXDFE_UT_CFG0 = 0,
  parameter PCIE_PLL_SEL_MODE_GEN12 = 0,
  parameter PCIE_PLL_SEL_MODE_GEN3 = 0,
  parameter PCIE_PLL_SEL_MODE_GEN4 = 0,
  parameter PCIE_RXPCS_CFG_GEN3 = 0,
  parameter PCIE_RXPMA_CFG = 0,
  parameter PCIE_TXPCS_CFG_GEN3 = 0,
  parameter PCIE_TXPMA_CFG = 0,
  parameter PCS_PCIE_EN = 0,
  parameter PCS_RSVD0 = 0,
  parameter PD_TRANS_TIME_FROM_P2 = 0,
  parameter PD_TRANS_TIME_NONE_P2 = 0,
  parameter PD_TRANS_TIME_TO_P2 = 0,
  parameter PREIQ_FREQ_BST = 0,
  parameter PROCESS_PAR = 0,
  parameter RATE_SW_USE_DRP = 0,
  parameter RESET_POWERSAVE_DISABLE = 0,
  parameter RXBUFRESET_TIME = 0,
  parameter RXBUF_ADDR_MODE = 0,
  parameter RXBUF_EIDLE_HI_CNT = 0,
  parameter RXBUF_EIDLE_LO_CNT = 0,
  parameter RXBUF_EN = 0,
  parameter RXBUF_RESET_ON_CB_CHANGE = 0,
  parameter RXBUF_RESET_ON_COMMAALIGN = 0,
  parameter RXBUF_RESET_ON_EIDLE = 0,
  parameter RXBUF_RESET_ON_RATE_CHANGE = 0,
  parameter RXBUF_THRESH_OVFLW = 0,
  parameter RXBUF_THRESH_OVRD = 0,
  parameter RXBUF_THRESH_UNDFLW = 0,
  parameter RXCDRFREQRESET_TIME = 0,
  parameter RXCDRPHRESET_TIME = 0,
  parameter RXCDR_CFG0 = 0,
  parameter RXCDR_CFG0_GEN3 = 0,
  parameter RXCDR_CFG1 = 0,
  parameter RXCDR_CFG1_GEN3 = 0,
  parameter RXCDR_CFG2 = 0,
  parameter RXCDR_CFG2_GEN2 = 0,
  parameter RXCDR_CFG2_GEN3 = 0,
  parameter RXCDR_CFG2_GEN4 = 0,
  parameter RXCDR_CFG3 = 0,
  parameter RXCDR_CFG3_GEN2 = 0,
  parameter RXCDR_CFG3_GEN3 = 0,
  parameter RXCDR_CFG3_GEN4 = 0,
  parameter RXCDR_CFG4 = 0,
  parameter RXCDR_CFG4_GEN3 = 0,
  parameter RXCDR_CFG5 = 0,
  parameter RXCDR_CFG5_GEN3 = 0,
  parameter RXCDR_FR_RESET_ON_EIDLE = 0,
  parameter RXCDR_HOLD_DURING_EIDLE = 0,
  parameter RXCDR_LOCK_CFG0 = 0,
  parameter RXCDR_LOCK_CFG1 = 0,
  parameter RXCDR_LOCK_CFG2 = 0,
  parameter RXCDR_LOCK_CFG3 = 0,
  parameter RXCDR_LOCK_CFG4 = 0,
  parameter RXCDR_PH_RESET_ON_EIDLE = 0,
  parameter RXCFOK_CFG0 = 0,
  parameter RXCFOK_CFG1 = 0,
  parameter RXCFOK_CFG2 = 0,
  parameter RXDFELPMRESET_TIME = 0,
  parameter RXDFELPM_KL_CFG0 = 0,
  parameter RXDFELPM_KL_CFG1 = 0,
  parameter RXDFELPM_KL_CFG2 = 0,
  parameter DELAY_ELEC = 0,
  parameter ACJTAG_DEBUG_MODE = 0,
  parameter ACJTAG_MODE = 0,
  parameter ACJTAG_RESET = 0,
  parameter ADAPT_CFG0 = 0,
  parameter ADAPT_CFG1 = 0,
  parameter ADAPT_CFG2 = 0,
  parameter ALIGN_COMMA_DOUBLE = 0,
  parameter ALIGN_COMMA_ENABLE = 0,
  parameter ALIGN_COMMA_WORD = 0,
  parameter ALIGN_MCOMMA_DET = 0,
  parameter ALIGN_MCOMMA_VALUE = 0,
  parameter ALIGN_PCOMMA_DET = 0,
  parameter ALIGN_PCOMMA_VALUE = 0,
  parameter A_RXOSCALRESET = 0,
  parameter A_RXPROGDIVRESET = 0,
  parameter A_TXPROGDIVRESET = 0,
  parameter CBCC_DATA_SOURCE_SEL = 0,
  parameter CDR_SWAP_MODE_EN = 0,
  parameter CHAN_BOND_KEEP_ALIGN = 0,
  parameter CHAN_BOND_MAX_SKEW = 0,
  parameter CHAN_BOND_SEQ_1_1 = 0,
  parameter CHAN_BOND_SEQ_1_2 = 0,
  parameter CHAN_BOND_SEQ_1_3 = 0,
  parameter CHAN_BOND_SEQ_1_4 = 0,
  parameter CHAN_BOND_SEQ_1_ENABLE = 0,
  parameter CHAN_BOND_SEQ_2_1 = 0,
  parameter CHAN_BOND_SEQ_2_2 = 0,
  parameter CHAN_BOND_SEQ_2_3 = 0,
  parameter CHAN_BOND_SEQ_2_4 = 0,
  parameter CHAN_BOND_SEQ_2_ENABLE = 0,
  parameter CHAN_BOND_SEQ_2_USE = 0,
  parameter CHAN_BOND_SEQ_LEN = 0,
  parameter CH_HSPMUX = 0,
  parameter CKCAL1_CFG_0 = 0,
  parameter CKCAL1_CFG_1 = 0,
  parameter CKCAL1_CFG_2 = 0,
  parameter CKCAL1_CFG_3 = 0,
  parameter CKCAL2_CFG_0 = 0,
  parameter CKCAL2_CFG_1 = 0,
  parameter CKCAL2_CFG_2 = 0,
  parameter CKCAL2_CFG_3 = 0,
  parameter CKCAL2_CFG_4 = 0,
  parameter CKCAL_RSVD0 = 0,
  parameter CKCAL_RSVD1 = 0,
  parameter CLK_CORRECT_USE = 0,
  parameter CLK_COR_KEEP_IDLE = 0,
  parameter CLK_COR_MAX_LAT = 0,
  parameter CLK_COR_MIN_LAT = 0,
  parameter CLK_COR_PRECEDENCE = 0,
  parameter CLK_COR_REPEAT_WAIT = 0,
  parameter CLK_COR_SEQ_1_1 = 0,
  parameter CLK_COR_SEQ_1_2 = 0,
  parameter CLK_COR_SEQ_1_3 = 0,
  parameter CLK_COR_SEQ_1_4 = 0,
  parameter CLK_COR_SEQ_1_ENABLE = 0,
  parameter CLK_COR_SEQ_2_1 = 0,
  parameter CLK_COR_SEQ_2_2 = 0,
  parameter CLK_COR_SEQ_2_3 = 0,
  parameter CLK_COR_SEQ_2_4 = 0,
  parameter CLK_COR_SEQ_2_ENABLE = 0,
  parameter CLK_COR_SEQ_2_USE = 0,
  parameter CLK_COR_SEQ_LEN = 0,
  parameter CPLL_CFG0 = 0,
  parameter CPLL_CFG1 = 0,
  parameter CPLL_CFG2 = 0,
  parameter CPLL_CFG3 = 0,
  parameter CPLL_FBDIV = 0,
  parameter CPLL_FBDIV_45 = 0,
  parameter CPLL_INIT_CFG0 = 0,
  parameter CPLL_LOCK_CFG = 0,
  parameter CPLL_REFCLK_DIV = 0,
  parameter CTLE3_OCAP_EXT_CTRL = 0,
  parameter CTLE3_OCAP_EXT_EN = 0,
  parameter DDI_REALIGN_WAIT = 0,
  parameter DEC_MCOMMA_DETECT = 0,
  parameter DEC_PCOMMA_DETECT = 0,
  parameter DEC_VALID_COMMA_ONLY = 0,
  //////
  parameter USB_PING_SATA_MAX_INIT = 7,
  parameter USB_PING_SATA_MIN_INIT = 4,
  parameter USB_POLL_SATA_MAX_BURST = 8,
  parameter USB_POLL_SATA_MIN_BURST = 4,
  parameter [0:0] USB_RAW_ELEC = 1'b0,
  parameter [0:0] USB_RXIDLE_P0_CTRL = 1'b1,
  parameter [0:0] USB_TXIDLE_TUNE_ENABLE = 1'b1,
  parameter USB_U1_SATA_MAX_WAKE = 7,
  parameter USB_U1_SATA_MIN_WAKE = 4,
  parameter USB_U2_SAS_MAX_COM = 64,
  parameter USB_U2_SAS_MIN_COM = 36,
  parameter [0:0] USE_PCS_CLK_PHASE_SEL = 1'b0,
  parameter [0:0] Y_ALL_MODE = 1'b0
)(
  output [2:0] BUFGTCE,
  output [2:0] BUFGTCEMASK,
  output [8:0] BUFGTDIV,
  output [2:0] BUFGTRESET,
  output [2:0] BUFGTRSTMASK,
  output CPLLFBCLKLOST,
  output CPLLLOCK,
  output CPLLREFCLKLOST,
  output [15:0] DMONITOROUT,
  output [15:0] DRPDO,
  output DRPRDY,
  output EYESCANDATAERROR,
  output GTHTXN,
  output GTHTXP,
  output GTPOWERGOOD,
  output GTREFCLKMONITOR,
  output GTYTXN,
  output GTYTXP,
  output [15:0] PCIERATEGEN3,
  output PCIERATEIDLE,
  output [1:0] PCIERATEQPLLPD,
  output [1:0] PCIERATEQPLLRESET,
  output PCIESYNCTXSYNCDONE,
  output PCIEUSERGEN3RDY,
  output PCIEUSERPHYSTATUSRST,
  output PCIEUSERRATESTART,
  output [11:0] PCSRSVDOUT,
  output PHYSTATUS,
  output [15:0] PINRSRVDAS,
  output POWERPRESENT,
  output RESETEXCEPTION,
  output [2:0] RXBUFSTATUS,
  output RXBYTEISALIGNED,
  output RXBYTEREALIGN,
  output RXCDRLOCK,
  output RXCDRPHDONE,
  output RXCHANBONDSEQ,
  output RXCHANISALIGNED,
  output RXCHANREALIGN,
  output [4:0] RXCHBONDO,
  output [1:0] RXCLKCORCNT,
  output RXCOMINITDET,
  output RXCOMMADET,
  output RXCOMSASDET,
  output RXCOMWAKEDET,
  output [1:0] RXCTRL0,
  output [1:0] RXCTRL1,
  output [3:0] RXCTRL2,
  output [3:0] RXCTRL3,
  output [127:0] RXDATA,
  output [7:0] RXDATAEXTENDRSVD,
  output [1:0] RXDATAVALID,
  output RXDLYSRESETDONE,
  output RXELECIDLE,
  output [5:0] RXHEADER,
  output [1:0] RXHEADERVALID,
  output RXLFPSTRESETDET,
  output RXLFPSU2LPEXITDET,
  output RXLFPSU3WAKEDET,
  output [7:0] RXMONITOROUT,
  output RXOSINTDONE,
  output RXOSINTSTARTED,
  output RXOSINTSTROBEDONE,
  output RXOSINTSTROBESTARTED,
  output RXOUTCLK,
  output RXOUTCLKFABRIC,
  output RXOUTCLKPCS,
  output RXPHALIGNDONE,
  output RXPHALIGNERR,
  output RXPMARESETDONE,
  output RXPRBSERR,
  output RXPRBSLOCKED,
  output RXPRGDIVRESETDONE,
  output RXQPISENN,
  output RXQPISENP,
  output RXRATEDONE,
  output RXRECCLKOUT,
  output RXRESETDONE,
  output RXSLIDERDY,
  output RXSLIPDONE,
  output RXSLIPOUTCLKRDY,
  output RXSLIPPMARDY,
  output [1:0] RXSTARTOFSEQ,
  output [2:0] RXSTATUS,
  output RXSYNCDONE,
  output RXSYNCOUT,
  output RXVALID,
  output [1:0] TXBUFSTATUS,
  output TXCOMFINISH,
  output TXDCCDONE,
  output TXDLYSRESETDONE,
  output TXOUTCLK,
  output TXOUTCLKFABRIC,
  output TXOUTCLKPCS,
  output TXPHALIGNDONE,
  output TXPHINITDONE,
  output TXPMARESETDONE,
  output TXPRGDIVRESETDONE,
  output TXQPISENN,
  output TXQPISENP,
  output TXRATEDONE,
  output TXRESETDONE,
  output TXSYNCDONE,
  output TXSYNCOUT,
  input CDRSTEPDIR,
  input CDRSTEPSQ,
  input CDRSTEPSX,
  input CFGRESET,
  input CLKRSVD0,
  input CLKRSVD1,
  input CPLLFREQLOCK,
  input CPLLLOCKDETCLK,
  input CPLLLOCKEN,
  input CPLLPD,
  input CPLLREFCLKSEL,
  input CPLLRESET,
  input DMONFIFORESET,
  input DMONITORCLK,
  input [9:0] DRPADDR,
  input DRPCLK,
  input [15:0] DRPDI,
  input DRPEN,
  input DRPRST,
  input DRPWE,
  input EYESCANRESET,
  input EYESCANTRIGGER,
  input FREQOS,
  input GTGREFCLK,
  input GTHRXN,
  input GTHRXP,
  input GTNORTHREFCLK0,
  input GTNORTHREFCLK1,
  input GTREFCLK0,
  input GTREFCLK1,
  input [15:0] GTRSVD,
  input GTRXRESET,
  input GTRXRESETSEL,
  input GTSOUTHREFCLK0,
  input GTSOUTHREFCLK1,
  input GTTXRESET,
  input GTTXRESETSEL,
  input GTYXRXN,
  input GTYXRXP,
  input INCPCTRL,
  input LOOPBACK,
  input [1:0] PCIEEQRXEQADAPTDONE,
  input PCIERSTIDLE,
  input PCIERSTTXSYNCSTART,
  input PCIEUSERRATEDONE,
  input [15:0] PCSRSVDIN,
  input QPLL0CLK,
  input QPLL0FREQLOCK,
  input QPLL0REFCLK,
  input QPLL1CLK,
  input QPLL1FREQLOCK,
  input QPLL1REFCLK,
  input RESETOVRD,
  input RX8B10BEN,
  input RXAFECFOKEN,
  input RXBUFRESET,
  input RXCDRFREQRESET,
  input RXCDRHOLD,
  input RXCDROVRDEN,
  input RXCDRRESET,
  input RXCHBONDEN,
  input [4:0] RXCHBONDI,
  input [2:0] RXCHBONDLEVEL,
  input RXCHBONDMASTER,
  input RXCHBONDSLAVE,
  input RXCKCALRESET,
  input [6:0] RXCKCALSTART,
  input RXCOMMADETEN,
  input RXDFEAGCCTRL,
  input RXDFEAGCHOLD,
  input RXDFEAGCOVRDEN,
  input RXDFECFOKFCNUM,
  input RXDFECFOKFEN,
  input RXDFECFOKFPULSE,
  input RXDFECFOKHOLD,
  input RXDFECFOKOVRD,
  input RXDFEKHHOLD,
  input RXDFEKHOVRDEN,
  input RXDFELFHOLD,
  input RXDFELFOVRDEN,
  input RXDFELPMRESET,
  input RXDFETAP10HOLD,
  input RXDFETAP10OVRDEN,
  input RXDFETAP11HOLD,
  input RXDFETAP11OVRDEN,
  input RXDFETAP12HOLD,
  input RXDFETAP12OVRDEN,
  input RXDFETAP13HOLD,
  input RXDFETAP13OVRDEN,
  input RXDFETAP14HOLD,
  input RXDFETAP14OVRDEN,
  input RXDFETAP15HOLD,
  input RXDFETAP15OVRDEN,
  input RXDFETAP2HOLD,
  input RXDFETAP2OVRDEN,
  input RXDFETAP3HOLD,
  input RXDFETAP3OVRDEN,
  input RXDFETAP4HOLD,
  input RXDFETAP4OVRDEN,
  input RXDFETAP5HOLD,
  input RXDFETAP5OVRDEN,
  input RXDFETAP6HOLD,
  input RXDFETAP6OVRDEN,
  input RXDFETAP7HOLD,
  input RXDFETAP7OVRDEN,
  input RXDFETAP8HOLD,
  input RXDFETAP8OVRDEN,
  input RXDFETAP9HOLD,
  input RXDFETAP9OVRDEN,
  input RXDFEUTHOLD,
  input RXDFEUTOVRDEN,
  input RXDFEVPHOLD,
  input RXDFEVPOVRDEN,
  input RXDFEXYDEN,
  input RXDLYBYPASS,
  input RXDLYEN,
  input RXDLYOVRDEN,
  input RXDLYSRESET,
  input [1:0] RXELECIDLEMODE,
  input [5:0] RXEQTRAINING,
  input RXGEARBOXSLIP,
  input RXLATCLK,
  input RXLPMEN,
  input RXLPMGCHOLD,
  input RXLPMGCOVRDEN,
  input RXLPMHFHOLD,
  input RXLPMHFOVRDEN,
  input RXLPMLFHOLD,
  input RXLPMLFKLOVRDEN,
  input RXLPMOSHOLD,
  input RXLPMOSOVRDEN,
  input RXMCOMMAALIGNEN,
  input [7:0] RXMONITORSEL,
  input RXOOBRESET,
  input RXOSCALRESET,
  input RXOSHOLD,
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
  input [1:0] RXPLLCLKSEL,
  input RXPMARESET,
  input RXPOLARITY,
  input RXPRBSCNTRESET,
  input [3:0] RXPRBSSEL,
  input RXPROGDIVRESET,
  input RXQPIEN,
  input [2:0] RXRATE,
  input RXRATEMODE,
  input RXSLIDE,
  input RXSLIPOUTCLK,
  input RXSLIPPMA,
  input RXSYNCALLIN,
  input RXSYNCIN,
  input RXSYNCMODE,
  input [1:0] RXSYSCLKSEL,
  input [2:0] RXTERMINATION,
  input RXUSERRDY,
  input RXUSRCLK,
  input RXUSRCLK2,
  input SIGVALIDCLK,
  input [19:0] TSTIN,
  input [7:0] TX8B10BBYPASS,
  input TX8B10BEN,
  input [2:0] TXBUFDIFFCTRL,
  input [7:0] TXCTRL0,
  input [7:0] TXCTRL1,
  input [3:0] TXCTRL2,
  input TXDCCFORCESTART,
  input TXDCCRESET,
  input [1:0] TXDEEMPH,
  input TXDETECTRX,
  input [4:0] TXDIFFCTRL,
  input TXDLYBYPASS,
  input TXDLYEN,
  input TXDLYHOLD,
  input TXDLYOVRDEN,
  input TXDLYSRESET,
  input TXDLYUPDOWN,
  input TXELECIDLE,
  input [5:0] TXHEADER,
  input TXINHIBIT,
  input TXLATCLK,
  input TXLFPSTRESET,
  input TXLFPSU2LPEXIT,
  input TXLFPSU3WAKE,
  input [6:0] TXMAINCURSOR,
  input [2:0] TXMARGIN,
  input TXMUXDCDEXHOLD,
  input TXMUXDCDORWREN,
  input TXONESZEROS,
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
  input [1:0] TXPLLCLKSEL,
  input TXPMARESET,
  input TXPOLARITY,
  input [4:0] TXPOSTCURSOR,
  input TXPRBSFORCEERR,
  input [3:0] TXPRBSSEL,
  input [4:0] TXPRECURSOR,
  input TXPROGDIVRESET,
  input TXQPIBIASEN,
  input TXQPIWEAKPUP,
  input [2:0] TXRATE,
  input TXRATEMODE,
  input TXSEQUENCE,
  input TXSWING,
  input TXSYNCALLIN,
  input TXSYNCIN,
  input TXSYNCMODE,
  input [1:0] TXSYSCLKSEL,
  input TXUSERRDY,
  input TXUSRCLK,
  input TXUSRCLK2,
  input CDRSTEPDIR,
  input CDRSTEPSQ,
  input CDRSTEPSX,
  input CPLLFREQLOCK,
  input DRPRST,
  input FREQOS,
  input GTRXRESETSEL,
  input GTTXRESETSEL,
  input GTYXRXN,
  input GTYXRXP,
  input INCPCTRL,
  input [1:0] PCIEEQRXEQADAPTDONE,
  input [15:0] PCSRSVDIN,
  input QPLL0FREQLOCK,
  input QPLL1FREQLOCK,
  input RXAFECFOKEN,
  input RXCKCALRESET,
  input [6:0] RXCKCALSTART,
  input RXDFECFOKFCNUM,
  input RXDFECFOKFEN,
  input RXDFECFOKFPULSE,
  input RXDFECFOKHOLD,
  input RXDFECFOKOVRD,
  input RXDFEKHHOLD,
  input RXDFEKHOVRDEN,
  input [5:0] RXEQTRAINING,
  input [7:0] RXMONITORSEL,
  input [1:0] RXPD,
  input [1:0] RXPLLCLKSEL,
  input [2:0] RXRATE,
  input [2:0] RXTERMINATION,
  input [4:0] TXDATA,
  input [7:0] TXDATAEXTENDRSVD,
  input TXDCCRESET,
  input [1:0] TXDEEMPH,
  input [5:0] TXHEADER,
  input TXLFPSTRESET,
  input TXLFPSU2LPEXIT,
  input TXLFPSU3WAKE,
  input TXMUXDCDEXHOLD,
  input TXMUXDCDORWREN,
  input TXONESZEROS,
  input [2:0] TXMARGIN,
  input [1:0] TXPD,
  input TXPHDLYTSTCLK,
  input TXPHINIT,
  input TXPIPPMEN,
  input TXPIPPMOVRDEN,
  input TXPIPPMPD,
  input TXPIPPMSEL,
  input [4:0] TXPIPPMSTEPSIZE,
  input [4:0] TXPOSTCURSOR,
  input [3:0] TXPRBSSEL,
  input [4:0] TXPRECURSOR,
  input TXQPIBIASEN,
  input TXQPIWEAKPUP,
  input [2:0] TXRATE,
  input TXSEQUENCE,
  input [1:0] TXSYSCLKSEL,
  input TXCOMWAKE,
  input SIGVALIDCLK,
  input TXCOMINIT,
  input TXCOMSAS

);

  reg [15:0] dmonitorout_reg;
  reg [15:0] drpdo_reg;
  reg drprdy_reg;
  reg [11:0] pcsrsvdout_reg;
  reg [1:0] rxclkcorcnt_reg;
  reg [1:0] rxdatavalid_reg;
  reg [1:0] rxstartofseq_reg;
  reg [1:0] txbufstatus_reg;
  reg [2:0] rxbufstatus_reg;
  reg [5:0] rxheader_reg;
  reg [2:0] rxstatus_reg;
  reg [127:0] rxdata_reg;
  reg [1:0] rxctrl0_reg;
  reg [1:0] rxctrl1_reg;
  reg [3:0] rxctrl2_reg;
  reg [3:0] rxctrl3_reg;
  reg [4:0] rxchbondo_reg;
  reg [7:0] rxmonitorout_reg;
  reg eyescandataerror_reg;
  reg gtpowergood_reg;
  reg phystatus_reg;
  reg rxbyteisaligned_reg;
  reg rxbyterealign_reg;
  reg rxcdrlock_reg;
  reg rxcdrphdone_reg;
  reg rxchanbondseq_reg;
  reg rxchanisaligned_reg;
  reg rxchanrealign_reg;
  reg rxcominitdet_reg;
  reg rxcommadet_reg;
  reg rxcomsasdet_reg;
  reg rxcomwakedet_reg;
  reg rxdlysresetdone_reg;
  reg rxelecidle_reg;
  reg [1:0] rxheadervalid_reg;
  reg rxlfpstresetdet_reg;
  reg rxlfpsu2lpexitdet_reg;
  reg rxlfpsu3wakedet_reg;
  reg rxosintdone_reg;
  reg rxosintstarted_reg;
  reg rxosintstrobedone_reg;
  reg rxosintstrobestarted_reg;
  reg rxphaligndone_reg;
  reg rxphalignerr_reg;
  reg rxpmaresetdone_reg;
  reg rxprbserr_reg;
  reg rxprbslocked_reg;
  reg rxprgdivresetdone_reg;
  reg rxratedone_reg;
  reg rxresetdone_reg;
  reg rxsliderdy_reg;
  reg rxslipdone_reg;
  reg rxslipoutclkrdy_reg;
  reg rxslippmardy_reg;
  reg rxsyncdone_reg;
  reg rxsyncout_reg;
  reg rxvalid_reg;
  reg txcomfinish_reg;
  reg txdccdone_reg;
  reg txdlysresetdone_reg;
  reg txphaligndone_reg;
  reg txphinitdone_reg;
  reg txpmaresetdone_reg;
  reg txprgdivresetdone_reg;
  reg txratedone_reg;
  reg txresetdone_reg;
  reg txsyncdone_reg;
  reg txsyncout_reg;
  reg cpllfbclklost_reg;
  reg cplllock_reg;
  reg cpllrefclklost_reg;
  reg [2:0] bufgtce_reg;
  reg [2:0] bufgtcemask_reg;
  reg [8:0] bufgtdiv_reg;
  reg [2:0] bufgtreset_reg;
  reg [2:0] bufgtrstmask_reg;
  reg [15:0] pcierategen3_reg;
  reg pcierateidle_reg;
  reg [1:0] pcierateqpllpd_reg;
  reg [1:0] pcierateqpllreset_reg;
  reg pciesynctxsyncdone_reg;
  reg pcieusergen3rdy_reg;
  reg pcieuserphystatusrst_reg;
  reg pcieuserratestart_reg;
  reg [15:0] pinrsrvdas_reg;
  reg powerpresent_reg;
  reg resetexception_reg;
  reg [7:0] rxdataextendrsvd_reg;
  reg rxqpisenn_reg;
  reg rxqpisenp_reg;
  reg txqpisenn_reg;
  reg txqpisenp_reg;
  reg gtrefclkmonitor_reg;

  wire gthrxn_int;
  wire gthrxp_int;
  wire rxusrclk_int;
  wire rxusrclk2_int;
  wire txusrclk_int;
  wire txusrclk2_int;
  wire drpclk_int;
  wire rxoutclk_int;
  wire txoutclk_int;
  wire rxrecclkout_int;
  wire tx_rst_sync;
  wire rx_rst_sync;
  wire qpll0clk_int;
  wire qpll1clk_int;
  
  wire loopback_en;
  assign loopback_en = (LOOPBACK != 3'b000);
  
  wire clkinsel_int;
  BUF_X1 clkinsel_buf (.A(CLKRSVD0), .Z(clkinsel_int));
  
  BUF_X1 buf_gthrxn (.A(GTHRXN), .Z(gthrxn_int));
  BUF_X1 buf_gthrxp (.A(GTHRXP), .Z(gthrxp_int));
  BUF_X1 buf_rxusrclk (.A(RXUSRCLK), .Z(rxusrclk_int));
  BUF_X1 buf_rxusrclk2 (.A(RXUSRCLK2), .Z(rxusrclk2_int));
  BUF_X1 buf_txusrclk (.A(TXUSRCLK), .Z(txusrclk_int));
  BUF_X1 buf_txusrclk2 (.A(TXUSRCLK2), .Z(txusrclk2_int));
  BUF_X1 buf_drpclk (.A(DRPCLK), .Z(drpclk_int));
  BUF_X1 buf_qpll0clk (.A(QPLL0CLK), .Z(qpll0clk_int));
  BUF_X1 buf_qpll1clk (.A(QPLL1CLK), .Z(qpll1clk_int));
  BUF_X1 buf_txrst (.A(GTTXRESET), .Z(tx_rst_sync));
  BUF_X1 buf_rxrst (.A(GTRXRESET), .Z(rx_rst_sync));

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

  reg [4:0] clk_cnt;
  reg [31:0] rx_prbs_cnt;
  reg [31:0] tx_prbs_cnt;

  always @(posedge rxusrclk2_int) begin
    if (rx_rst_sync) begin
      rxresetdone_reg <= 1'b0;
      rxpmaresetdone_reg <= 1'b0;
      rxdlysresetdone_reg <= 1'b0;
      rxphaligndone_reg <= 1'b0;
      rxcdrlock_reg <= 1'b0;
      rxsyncdone_reg <= 1'b0;
      rxprgdivresetdone_reg <= 1'b0;
      rxratedone_reg <= 1'b0;
    end else begin
      rxresetdone_reg <= rx_reset_done;
      rxpmaresetdone_reg <= rx_reset_done;
      rxdlysresetdone_reg <= rx_reset_done;
      rxphaligndone_reg <= rx_reset_done;
      rxcdrlock_reg <= rx_reset_done;
      rxsyncdone_reg <= rx_reset_done;
      rxprgdivresetdone_reg <= rx_reset_done;
      rxratedone_reg <= rx_reset_done;
    end
  end

  always @(posedge txusrclk2_int) begin
    if (tx_rst_sync) begin
      txresetdone_reg <= 1'b0;
      txpmaresetdone_reg <= 1'b0;
      txdlysresetdone_reg <= 1'b0;
      txphaligndone_reg <= 1'b0;
      txphinitdone_reg <= 1'b0;
      txsyncdone_reg <= 1'b0;
      txprgdivresetdone_reg <= 1'b0;
      txratedone_reg <= 1'b0;
    end else begin
      txresetdone_reg <= tx_reset_done;
      txpmaresetdone_reg <= tx_reset_done;
      txdlysresetdone_reg <= tx_reset_done;
      txphaligndone_reg <= tx_reset_done;
      txphinitdone_reg <= tx_reset_done;
      txsyncdone_reg <= tx_reset_done;
      txprgdivresetdone_reg <= tx_reset_done;
      txratedone_reg <= tx_reset_done;
    end
  end

  always @(posedge drpclk_int) begin
    if (CFGRESET) begin
      drprdy_reg <= 1'b0;
      drpdo_reg <= 16'h0000;
    end else if (DRPEN && !drprdy_reg) begin
      drprdy_reg <= 1'b1;
      drpdo_reg <= {7'h00, DRPADDR};
    end else begin
      drprdy_reg <= 1'b0;
    end
  end

  always @(posedge rxusrclk2_int) begin
    if (loopback_en) begin
      rxdata_reg <= {TXDATA[126:0], 1'b0};
      rxctrl0_reg <= TXCTRL0[1:0];
      rxctrl1_reg <= TXCTRL1[1:0];
      rxctrl2_reg <= TXCTRL2[3:0];
      rxctrl3_reg <= {4'b0000};
    end else begin
      if (RXPRBSSEL == 4'b0000) begin
        rxdata_reg <= 128'h0;
        rxctrl0_reg <= 2'b00;
        rxctrl1_reg <= 2'b00;
        rxctrl2_reg <= 4'b0000;
        rxctrl3_reg <= 4'b0000;
      end else begin
        rxdata_reg <= {rx_prbs_cnt, rx_prbs_cnt, rx_prbs_cnt, rx_prbs_cnt};
        rxctrl0_reg <= 2'b00;
        rxctrl1_reg <= 2'b00;
        rxctrl2_reg <= 4'b0000;
        rxctrl3_reg <= 4'b0000;
        rx_prbs_cnt <= rx_prbs_cnt + 1;
      end
    end
  end

  reg rxclk_sel;
  reg txclk_sel;
  
  always @(*) begin
    rxclk_sel = RXPLLCLKSEL[0];
    txclk_sel = TXPLLCLKSEL[0];
  end

  assign rxoutclk_int = rxclk_sel ? qpll1clk_int : qpll0clk_int;
  assign txoutclk_int = txclk_sel ? qpll1clk_int : qpll0clk_int;
  assign rxrecclkout_int = rxoutclk_int;

  BUF_X1 buf_rxoutclk (.A(rxoutclk_int), .Z(RXOUTCLK));
  BUF_X1 buf_rxoutclkfabric (.A(rxoutclk_int), .Z(RXOUTCLKFABRIC));
  BUF_X1 buf_rxoutclkpcs (.A(rxoutclk_int), .Z(RXOUTCLKPCS));
  BUF_X1 buf_txoutclk (.A(txoutclk_int), .Z(TXOUTCLK));
  BUF_X1 buf_txoutclkfabric (.A(txoutclk_int), .Z(TXOUTCLKFABRIC));
  BUF_X1 buf_txoutclkpcs (.A(txoutclk_int), .Z(TXOUTCLKPCS));
  BUF_X1 buf_rxrecclkout (.A(rxrecclkout_int), .Z(RXRECCLKOUT));

  assign GTHTXN = TXPOLARITY ? gthrxp_int : ~gthrxp_int;
  assign GTHTXP = TXPOLARITY ? ~gthrxp_int : gthrxp_int;
  assign GTYTXN = GTHTXN;
  assign GTYTXP = GTHTXP;

  assign BUFGTCE = bufgtce_reg;
  assign BUFGTCEMASK = bufgtcemask_reg;
  assign BUFGTDIV = bufgtdiv_reg;
  assign BUFGTRESET = bufgtreset_reg;
  assign BUFGTRSTMASK = bufgtrstmask_reg;
  assign CPLLFBCLKLOST = cpllfbclklost_reg;
  assign CPLLLOCK = cplllock_reg;
  assign CPLLREFCLKLOST = cpllrefclklost_reg;
  assign DMONITOROUT = dmonitorout_reg;
  assign DRPDO = drpdo_reg;
  assign DRPRDY = drprdy_reg;
  assign EYESCANDATAERROR = eyescandataerror_reg;
  assign GTPOWERGOOD = gtpowergood_reg;
  assign GTREFCLKMONITOR = gtrefclkmonitor_reg;
  assign PCIERATEGEN3 = pcierategen3_reg;
  assign PCIERATEIDLE = pcierateidle_reg;
  assign PCIERATEQPLLPD = pcierateqpllpd_reg;
  assign PCIERATEQPLLRESET = pcierateqpllreset_reg;
  assign PCIESYNCTXSYNCDONE = pciesynctxsyncdone_reg;
  assign PCIEUSERGEN3RDY = pcieusergen3rdy_reg;
  assign PCIEUSERPHYSTATUSRST = pcieuserphystatusrst_reg;
  assign PCIEUSERRATESTART = pcieuserratestart_reg;
  assign PCSRSVDOUT = pcsrsvdout_reg;
  assign PHYSTATUS = phystatus_reg;
  assign PINRSRVDAS = pinrsrvdas_reg;
  assign POWERPRESENT = powerpresent_reg;
  assign RESETEXCEPTION = resetexception_reg;
  assign RXBUFSTATUS = rxbufstatus_reg;
  assign RXBYTEISALIGNED = rxbyteisaligned_reg;
  assign RXBYTEREALIGN = rxbyterealign_reg;
  assign RXCDRLOCK = rxcdrlock_reg;
  assign RXCDRPHDONE = rxcdrphdone_reg;
  assign RXCHANBONDSEQ = rxchanbondseq_reg;
  assign RXCHANISALIGNED = rxchanisaligned_reg;
  assign RXCHANREALIGN = rxchanrealign_reg;
  assign RXCHBONDO = rxchbondo_reg;
  assign RXCLKCORCNT = rxclkcorcnt_reg;
  assign RXCOMINITDET = rxcominitdet_reg;
  assign RXCOMMADET = rxcommadet_reg;
  assign RXCOMSASDET = rxcomsasdet_reg;
  assign RXCOMWAKEDET = rxcomwakedet_reg;
  assign RXCTRL0 = rxctrl0_reg;
  assign RXCTRL1 = rxctrl1_reg;
  assign RXCTRL2 = rxctrl2_reg;
  assign RXCTRL3 = rxctrl3_reg;
  assign RXDATA = rxdata_reg;
  assign RXDATAEXTENDRSVD = rxdataextendrsvd_reg;
  assign RXDATAVALID = rxdatavalid_reg;
  assign RXDLYSRESETDONE = rxdlysresetdone_reg;
  assign RXELECIDLE = rxelecidle_reg;
  assign RXHEADER = rxheader_reg;
  assign RXHEADERVALID = rxheadervalid_reg;
  assign RXLFPSTRESETDET = rxlfpstresetdet_reg;
  assign RXLFPSU2LPEXITDET = rxlfpsu2lpexitdet_reg;
  assign RXLFPSU3WAKEDET = rxlfpsu3wakedet_reg;
  assign RXMONITOROUT = rxmonitorout_reg;
  assign RXOSINTDONE = rxosintdone_reg;
  assign RXOSINTSTARTED = rxosintstarted_reg;
  assign RXOSINTSTROBEDONE = rxosintstrobedone_reg;
  assign RXOSINTSTROBESTARTED = rxosintstrobestarted_reg;
  assign RXPHALIGNDONE = rxphaligndone_reg;
  assign RXPHALIGNERR = rxphalignerr_reg;
  assign RXPMARESETDONE = rxpmaresetdone_reg;
  assign RXPRBSERR = rxprbserr_reg;
  assign RXPRBSLOCKED = rxprbslocked_reg;
  assign RXPRGDIVRESETDONE = rxprgdivresetdone_reg;
  assign RXQPISENN = rxqpisenn_reg;
  assign RXQPISENP = rxqpisenp_reg;
  assign RXRATEDONE = rxratedone_reg;
  assign RXRESETDONE = rxresetdone_reg;
  assign RXSLIDERDY = rxsliderdy_reg;
  assign RXSLIPDONE = rxslipdone_reg;
  assign RXSLIPOUTCLKRDY = rxslipoutclkrdy_reg;
  assign RXSLIPPMARDY = rxslippmardy_reg;
  assign RXSTARTOFSEQ = rxstartofseq_reg;
  assign RXSTATUS = rxstatus_reg;
  assign RXSYNCDONE = rxsyncdone_reg;
  assign RXSYNCOUT = rxsyncout_reg;
  assign RXVALID = rxvalid_reg;
  assign TXBUFSTATUS = txbufstatus_reg;
  assign TXCOMFINISH = txcomfinish_reg;
  assign TXDCCDONE = txdccdone_reg;
  assign TXDLYSRESETDONE = txdlysresetdone_reg;
  assign TXPHALIGNDONE = txphaligndone_reg;
  assign TXPHINITDONE = txphinitdone_reg;
  assign TXPMARESETDONE = txpmaresetdone_reg;
  assign TXPRGDIVRESETDONE = txprgdivresetdone_reg;
  assign TXQPISENN = txqpisenn_reg;
  assign TXQPISENP = txqpisenp_reg;
  assign TXRATEDONE = txratedone_reg;
  assign TXRESETDONE = txresetdone_reg;
  assign TXSYNCDONE = txsyncdone_reg;
  assign TXSYNCOUT = txsyncout_reg;

  always @(posedge drpclk_int) begin
    if (CFGRESET) begin
      cplllock_reg <= 1'b0;
      cpllfbclklost_reg <= 1'b0;
      cpllrefclklost_reg <= 1'b0;
      gtpowergood_reg <= 1'b0;
    end else begin
      cplllock_reg <= 1'b1;
      cpllfbclklost_reg <= 1'b0;
      cpllrefclklost_reg <= 1'b0;
      gtpowergood_reg <= 1'b1;
    end
  end

  always @(posedge rxusrclk2_int) begin
    rxbufstatus_reg <= 3'b000;
    rxbyteisaligned_reg <= rx_reset_done;
    rxbyterealign_reg <= 1'b0;
    rxcdrphdone_reg <= rx_reset_done;
    rxchanbondseq_reg <= 1'b0;
    rxchanisaligned_reg <= rx_reset_done;
    rxchanrealign_reg <= 1'b0;
    rxchbondo_reg <= 5'b00000;
    rxclkcorcnt_reg <= 2'b00;
    rxcominitdet_reg <= 1'b0;
    rxcommadet_reg <= 1'b0;
    rxcomsasdet_reg <= 1'b0;
    rxcomwakedet_reg <= 1'b0;
    rxdatavalid_reg <= {rx_reset_done, rx_reset_done};
    rxelecidle_reg <= ~rx_reset_done;
    rxheader_reg <= 6'b000000;
    rxheadervalid_reg <= {rx_reset_done, rx_reset_done};
    rxlfpstresetdet_reg <= 1'b0;
    rxlfpsu2lpexitdet_reg <= 1'b0;
    rxlfpsu3wakedet_reg <= 1'b0;
    rxmonitorout_reg <= 8'h00;
    rxosintdone_reg <= rx_reset_done;
    rxosintstarted_reg <= 1'b0;
    rxosintstrobedone_reg <= 1'b0;
    rxosintstrobestarted_reg <= 1'b0;
    rxphalignerr_reg <= 1'b0;
    rxprbserr_reg <= (RXPRBSSEL != 4'b0000) && (rx_prbs_cnt[7:0] == 8'hFF);
    rxprbslocked_reg <= (RXPRBSSEL != 4'b0000) && rx_reset_done;
    rxqpisenn_reg <= 1'b0;
    rxqpisenp_reg <= 1'b0;
    rxsliderdy_reg <= rx_reset_done;
    rxslipdone_reg <= 1'b0;
    rxslipoutclkrdy_reg <= rx_reset_done;
    rxslippmardy_reg <= rx_reset_done;
    rxstartofseq_reg <= 2'b00;
    rxstatus_reg <= 3'b000;
    rxsyncout_reg <= 1'b0;
    rxvalid_reg <= rx_reset_done;
    rxdataextendrsvd_reg <= 8'h00;
  end

  always @(posedge txusrclk2_int) begin
    txbufstatus_reg <= 2'b00;
    txcomfinish_reg <= 1'b0;
    txdccdone_reg <= tx_reset_done;
    txqpisenn_reg <= 1'b0;
    txqpisenp_reg <= 1'b0;
    txsyncout_reg <= 1'b0;
  end

  always @(posedge drpclk_int) begin
    bufgtce_reg <= 3'b000;
    bufgtcemask_reg <= 3'b111;
    bufgtdiv_reg <= 9'b000000100;
    bufgtreset_reg <= 3'b000;
    bufgtrstmask_reg <= 3'b111;
    gtrefclkmonitor_reg <= 1'b1;
    pcierategen3_reg <= 16'h0000;
    pcierateidle_reg <= 1'b1;
    pcierateqpllpd_reg <= 2'b00;
    pcierateqpllreset_reg <= 2'b00;
    pciesynctxsyncdone_reg <= 1'b1;
    pcieusergen3rdy_reg <= 1'b1;
    pcieuserphystatusrst_reg <= 1'b0;
    pcieuserratestart_reg <= 1'b0;
    pcsrsvdout_reg <= 12'h000;
    phystatus_reg <= 1'b0;
    pinrsrvdas_reg <= 16'h0000;
    powerpresent_reg <= 1'b1;
    resetexception_reg <= 1'b0;
    dmonitorout_reg <= 16'h0000;
    eyescandataerror_reg <= 1'b0;
  end

endmodule
