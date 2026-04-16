// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Fabian Schuiki <fschuiki@iis.ee.ethz.ch>

package snitch_icache_pkg;

  typedef struct packed {
    logic l0_miss;
    logic l0_hit;
    logic l0_prefetch;
    logic l0_double_hit;
    logic l0_stall;
  } icache_l0_events_t;

  typedef struct packed {
    logic l1_miss;
    logic l1_hit;
    logic l1_stall;
    logic l1_handler_stall;
  } icache_l1_events_t;

  typedef struct packed {
    // Parameters passed to the root module.
    int unsigned NR_FETCH_PORTS;
    int unsigned LINE_WIDTH;
    int unsigned LINE_COUNT;
    int unsigned WAY_COUNT;
    int unsigned PENDING_COUNT;
    int unsigned L0_LINE_COUNT;
    int unsigned FETCH_AW;
    int unsigned FETCH_DW;
    int unsigned FILL_AW;
    int unsigned FILL_DW;
    bit          L1_TAG_SCM;
    bit          L1_DATA_SCM;
    bit          EARLY_LATCH;
    bit          BUFFER_LOOKUP;
    bit          GUARANTEE_ORDERING;

    // Derived values.
    int unsigned FETCH_ALIGN;
    int unsigned FILL_ALIGN;
    int unsigned LINE_ALIGN;
    int unsigned COUNT_ALIGN;
    int unsigned WAY_ALIGN;
    int unsigned TAG_WIDTH;
    int unsigned L0_TAG_WIDTH;
    int unsigned L0_EARLY_TAG_WIDTH;
    int unsigned ID_WIDTH;
    int unsigned PENDING_IW;          // refill ID width
  } config_t;

endpackage
