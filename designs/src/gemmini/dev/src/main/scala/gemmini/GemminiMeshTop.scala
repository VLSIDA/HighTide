package gemmini

import chisel3._
import chisel3.util._
import chisel3.stage.ChiselStage

/** Standalone top-level wrapper around the Gemmini systolic Mesh.
  *
  * Instantiates a 16x16 mesh of 2x2 tiles (1024 PEs total), weight-stationary
  * dataflow, 8-bit signed integer input, 20-bit signed accumulator.
  */
class GemminiMeshTop extends Module {
  override def desiredName = "gemmini"

  private val meshRows    = 16
  private val meshColumns = 16
  private val tileRows    = 2
  private val tileColumns = 2
  private val maxSimultaneousMatmuls = 4

  private val inputType  = SInt(8.W)
  private val weightType = SInt(8.W)
  private val outputType = SInt(20.W)
  private val accType    = SInt(20.W)

  val mesh = Module(new Mesh(
    inputType  = inputType,
    weightType = weightType,
    outputType = outputType,
    accType    = accType,
    df         = Dataflow.WS,
    tree_reduction = false,
    tile_latency   = 0,
    max_simultaneous_matmuls = maxSimultaneousMatmuls,
    output_delay = 0,
    tileRows    = tileRows,
    tileColumns = tileColumns,
    meshRows    = meshRows,
    meshColumns = meshColumns
  ))

  val io = IO(new Bundle {
    val in_a       = Input(Vec(meshRows, Vec(tileRows, inputType)))
    val in_b       = Input(Vec(meshColumns, Vec(tileColumns, weightType)))
    val in_d       = Input(Vec(meshColumns, Vec(tileColumns, weightType)))
    val in_control = Input(Vec(meshColumns, Vec(tileColumns, new PEControl(accType))))
    val in_id      = Input(Vec(meshColumns, Vec(tileColumns, UInt(log2Up(maxSimultaneousMatmuls).W))))
    val in_last    = Input(Vec(meshColumns, Vec(tileColumns, Bool())))
    val in_valid   = Input(Vec(meshColumns, Vec(tileColumns, Bool())))

    val out_b       = Output(Vec(meshColumns, Vec(tileColumns, outputType)))
    val out_c       = Output(Vec(meshColumns, Vec(tileColumns, outputType)))
    val out_valid   = Output(Vec(meshColumns, Vec(tileColumns, Bool())))
    val out_control = Output(Vec(meshColumns, Vec(tileColumns, new PEControl(accType))))
    val out_id      = Output(Vec(meshColumns, Vec(tileColumns, UInt(log2Up(maxSimultaneousMatmuls).W))))
    val out_last    = Output(Vec(meshColumns, Vec(tileColumns, Bool())))
  })

  // Connect inputs
  mesh.io.in_a       := io.in_a
  mesh.io.in_b       := io.in_b
  mesh.io.in_d       := io.in_d
  mesh.io.in_control := io.in_control
  mesh.io.in_id      := io.in_id
  mesh.io.in_last    := io.in_last
  mesh.io.in_valid   := io.in_valid

  // Connect outputs
  io.out_b       := mesh.io.out_b
  io.out_c       := mesh.io.out_c
  io.out_valid   := mesh.io.out_valid
  io.out_control := mesh.io.out_control
  io.out_id      := mesh.io.out_id
  io.out_last    := mesh.io.out_last
}

object GemminiMeshEmitter extends App {
  (new ChiselStage).emitVerilog(
    new GemminiMeshTop,
    Array("--target-dir", "generated")
  )
}
