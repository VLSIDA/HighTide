`include "repo/hardware/core/defines.svh"
import defines::*;

module NyuziProcessor #(
  parameter int RESET_PC       = 0,
  parameter int NUM_INTERRUPTS = 16
)(
  input  logic clk,
  input  logic reset,

  // Global
  output logic                       m_aclk,
  output logic                       m_aresetn,

  // Write address
  output logic [AXI_ADDR_WIDTH-1:0]  m_awaddr,
  output logic [7:0]                 m_awlen,
  output logic [2:0]                 m_awprot,
  output logic                       m_awvalid,
  input  logic                       s_awready,

  // Write data
  output logic [`AXI_DATA_WIDTH-1:0] m_wdata,
  output logic                       m_wlast,
  output logic                       m_wvalid,
  input  logic                       s_wready,

  // Write response
  input  logic                       s_bvalid,
  output logic                       m_bready,

  // Read address
  output logic [AXI_ADDR_WIDTH-1:0]  m_araddr,
  output logic [7:0]                 m_arlen,
  output logic [2:0]                 m_arprot,
  output logic                       m_arvalid,
  input  logic                       s_arready,

  // Read data
  input  logic [`AXI_DATA_WIDTH-1:0] s_rdata,
  input  logic                       s_rvalid,
  output logic                       m_rready,

  output logic                       io_write_en,
  output logic                       io_read_en,
  output scalar_t                    io_address,
  output scalar_t                    io_write_data,
  input  scalar_t                    io_read_data,

  input  logic jtag_tck,
  input  logic jtag_trst_n,
  input  logic jtag_tdi,
  input  logic jtag_tms,
  output logic jtag_tdo,


  input  logic [NUM_INTERRUPTS-1:0]  interrupt_req
);

  // Interface
  axi4_interface   axi_bus();
  io_bus_interface io_bus();
  jtag_interface   jtag();


  // Global
  assign m_aclk              = axi_bus.m_aclk;
  assign m_aresetn           = axi_bus.m_aresetn;

  // Write address
  assign m_awaddr            = axi_bus.m_awaddr;
  assign m_awlen             = axi_bus.m_awlen;
  assign m_awprot            = axi_bus.m_awprot;
  assign m_awvalid           = axi_bus.m_awvalid;
  assign axi_bus.s_awready   = s_awready;

  // Write data
  assign m_wdata             = axi_bus.m_wdata;
  assign m_wlast             = axi_bus.m_wlast;
  assign m_wvalid            = axi_bus.m_wvalid;
  assign axi_bus.s_wready    = s_wready;

  // Write response
  assign axi_bus.s_bvalid    = s_bvalid;
  assign m_bready            = axi_bus.m_bready;

  // Read address
  assign m_araddr            = axi_bus.m_araddr;
  assign m_arlen             = axi_bus.m_arlen;
  assign m_arprot            = axi_bus.m_arprot;
  assign m_arvalid           = axi_bus.m_arvalid;
  assign axi_bus.s_arready   = s_arready;

  // Read data
  assign axi_bus.s_rdata     = s_rdata;
  assign axi_bus.s_rvalid    = s_rvalid;
  assign m_rready            = axi_bus.m_rready;

  assign io_write_en         = io_bus.write_en;
  assign io_read_en          = io_bus.read_en;
  assign io_address          = io_bus.address;
  assign io_write_data       = io_bus.write_data;
  assign io_bus.read_data    = io_read_data;


  assign jtag.tck            = jtag_tck;
  assign jtag.trst_n         = jtag_trst_n;
  assign jtag.tdi            = jtag_tdi;
  assign jtag.tms            = jtag_tms;
  assign jtag_tdo            = jtag.tdo;

  nyuzi #(
    .RESET_PC(RESET_PC),
    .NUM_INTERRUPTS(NUM_INTERRUPTS)
  ) u_nyuzi (
    .clk          (clk),
    .reset        (reset),
    .axi_bus      (axi_bus.master),
    .io_bus       (io_bus.master),
    .jtag         (jtag.target),
    .interrupt_req(interrupt_req)
  );

endmodule