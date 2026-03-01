package sha3

import Chisel._
import chisel3.stage.ChiselStage

/** Standalone top-level wrapper around the SHA3 Keccak datapath.
  *
  * Instantiates DpathModule with configurable stages (S=1 default, W=64)
  * and exposes its IO directly. No Rocket Chip / RoCC dependencies.
  */
class Sha3Top extends Module {
  override def desiredName = "sha3"

  private val W = 64      // Keccak word width
  private val S = 1       // Pipeline stages

  val dpath = Module(new DpathModule(W, S))

  // SHA3-256 constants (from DpathModule)
  private val round_size_words = dpath.round_size_words
  private val hash_size_words  = dpath.hash_size_words

  val io = IO(new Bundle {
    val absorb     = Input(Bool())
    val init       = Input(Bool())
    val write      = Input(Bool())
    val round      = Input(UInt(5.W))
    val stage      = Input(UInt(log2Up(S).W))
    val aindex     = Input(UInt(log2Up(round_size_words).W))
    val message_in = Input(UInt(W.W))
    val hash_out   = Output(Vec(hash_size_words, UInt(W.W)))
  })

  dpath.io.absorb     := io.absorb
  dpath.io.init       := io.init
  dpath.io.write      := io.write
  dpath.io.round      := io.round
  dpath.io.stage      := io.stage
  dpath.io.aindex     := io.aindex
  dpath.io.message_in := io.message_in

  for (i <- 0 until hash_size_words) {
    io.hash_out(i) := dpath.io.hash_out(i)
  }
}

object Sha3Emitter extends App {
  (new ChiselStage).emitVerilog(
    new Sha3Top,
    Array("--target-dir", "generated")
  )
}
