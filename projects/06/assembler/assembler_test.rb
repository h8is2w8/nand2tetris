require 'test/unit'

require_relative 'assembler'

class AssemblerTest < Test::Unit::TestCase
  def test_a_instruction_parsing
    assert_equal '0000000001100100', Assembler.assemble('@100')
    assert_equal '0000000000000001', Assembler.assemble('@1')
    assert_equal '0000000000001111', Assembler.assemble('@R15')
    assert_equal '0110000000000000', Assembler.assemble('@KBD')
    assert_equal '0100000000000000', Assembler.assemble('@SCREEN')
    assert_equal '0000000000000011', Assembler.assemble('@THIS')
  end

  def test_c_instruction_parsing
    assert_equal '1110000010010000', Assembler.assemble('D=D+A')
    assert_equal '1111110010100000', Assembler.assemble('A=M-1')
    assert_equal '1110001100001000', Assembler.assemble('M=D')
    assert_equal '1110011111011000', Assembler.assemble('MD=D+1')
    assert_equal '1110001100000001', Assembler.assemble('D;JGT')
    assert_equal '1110101010000111', Assembler.assemble('0;JMP')
  end

  def test_assemble_program_without_symbols
    assert_equal %w[
      0000000000000010
      1110110000010000
      0000000000000011
      1110000010010000
      0000000000000000
      1110001100001000
    ].join("\n"), Assembler.assemble(%q{
      // Computes R0 = 2 + 3  (R0 refers to RAM[0])

      @2
      D=A
      @3
      D=D+A //sum
      @0
      M=D
    })
  end

  def test_assemble_program_with_symbols
    assert_equal %w[
      0000000000000010
      1110101010001000
      0000000000010000
      1110111111001000
      0000000000010000
      1111110000010000
      0000000000000001
      1111010011010000
      0000000000010010
      1110001100000001
      0000000000000000
      1111110000010000
      0000000000000010
      1111000010001000
      0000000000010000
      1111110111001000
      0000000000000100
      1110101010000111
      0000000000010010
      1110101010000111
    ].join("\n"), Assembler.assemble(%q{
      // Multiplies R0 and R1 and stores the result in R2.
      // (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

        @R2
        M=0

        @i
        M=1

      (LOOP)
        // if (i == R1) goto END
        @i
        D=M
        @R1
        D=D-M
        @END
        D;JGT

        // R2 = R2 + R0
        @R0
        D=M
        @R2
        M=D+M
        @i
        M=M+1
        @LOOP
        0;JMP

      (END)
        @END
        0;JMP
    })
  end
end
