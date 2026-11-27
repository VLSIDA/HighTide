# Example cocotb test for the tools/sim harness self-test.
# Drives the DUT clock and checks the counter advances on enable, so the
# cocotb-runner + verilator path can be validated end to end.
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer


@cocotb.test()
async def counts_when_enabled(dut):
    """count should advance by one per clock edge while enable is asserted."""
    dut._log.info("starting counts_when_enabled")
    cocotb.start_soon(Clock(dut.clk, 2, units="ns").start())
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    dut.enable.value = 1
    for _ in range(4):
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
    assert dut.count.value == 4, f"expected 4, got {dut.count.value}"


@cocotb.test()
async def halted_when_disabled(dut):
    """count should hold while enable is deasserted."""
    cocotb.start_soon(Clock(dut.clk, 2, units="ns").start())
    dut.enable.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
    # last synchronous increment with enable=0 must not have advanced it
    before = dut.count.value
    await Timer(1, units="ns")
    assert dut.count.value == before, f"count moved while disabled {before} -> {dut.count.value}"
