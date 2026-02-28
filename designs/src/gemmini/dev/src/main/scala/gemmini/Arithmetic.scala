// Stripped-down Arithmetic type class for standalone Gemmini Mesh compilation.
// Removes hardfloat dependency; only SInt arithmetic is needed for the mesh.

package gemmini

import chisel3._
import chisel3.util._

abstract class Arithmetic[T <: Data] {
  implicit def cast(t: T): ArithmeticOps[T]
}

abstract class ArithmeticOps[T <: Data](self: T) {
  def *(t: T): T
  def mac(m1: T, m2: T): T // Returns (m1 * m2 + self)
  def +(t: T): T
  def -(t: T): T
  def >>(u: UInt): T // Rounding shift
  def >(t: T): Bool
  def identity: T
  def withWidthOf(t: T): T
  def clippedToWidthOf(t: T): T
  def relu: T
  def zero: T
  def minimum: T

  def divider(denom_t: UInt, options: Int = 0): Option[(DecoupledIO[UInt], DecoupledIO[T])] = None
  def sqrt: Option[(DecoupledIO[UInt], DecoupledIO[T])] = None
  def reciprocal[U <: Data](u: U, options: Int = 0): Option[(DecoupledIO[UInt], DecoupledIO[U])] = None
  def mult_with_reciprocal[U <: Data](reciprocal: U) = self
}

object Arithmetic {
  implicit object SIntArithmetic extends Arithmetic[SInt] {
    override implicit def cast(self: SInt) = new ArithmeticOps(self) {
      override def *(t: SInt) = self * t
      override def mac(m1: SInt, m2: SInt) = m1 * m2 + self
      override def +(t: SInt) = self + t
      override def -(t: SInt) = self - t

      override def >>(u: UInt) = {
        // Rounding shift per RISC-V vector fixed-point spec
        val point_five = Mux(u === 0.U, 0.U, self(u - 1.U))
        val zeros = Mux(u <= 1.U, 0.U, self.asUInt & ((1.U << (u - 1.U)).asUInt - 1.U)) =/= 0.U
        val ones_digit = self(u)
        val r = (point_five & (zeros | ones_digit)).asBool
        (self >> u).asSInt + Mux(r, 1.S, 0.S)
      }

      override def >(t: SInt): Bool = self > t

      override def withWidthOf(t: SInt) = {
        if (self.getWidth >= t.getWidth)
          self(t.getWidth-1, 0).asSInt
        else {
          val sign_bits = t.getWidth - self.getWidth
          val sign = self(self.getWidth-1)
          Cat(Cat(Seq.fill(sign_bits)(sign)), self).asTypeOf(t)
        }
      }

      override def clippedToWidthOf(t: SInt): SInt = {
        val maxsat = ((1 << (t.getWidth-1))-1).S
        val minsat = (-(1 << (t.getWidth-1))).S
        MuxCase(self, Seq((self > maxsat) -> maxsat, (self < minsat) -> minsat))(t.getWidth-1, 0).asSInt
      }

      override def relu: SInt = Mux(self >= 0.S, self, 0.S)
      override def zero: SInt = 0.S
      override def identity: SInt = 1.S
      override def minimum: SInt = (-(1 << (self.getWidth-1))).S
    }
  }
}
