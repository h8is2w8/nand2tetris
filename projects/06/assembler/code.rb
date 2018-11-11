# Translates Hack assembly language mnemonics into binary codes.
class Code
  DEST_MAP = Hash[%w[M D MD A AM AD AMD].zip(1..7)]

  JUMP_MAP = Hash[%w[JGT JEQ JGE JLT JNE JLE JMP].zip(1..7)]

  COMP_MAP = {
    '0'   => 0b101010, '1'   => 0b111111, '-1'  => 0b111010,
    'D'   => 0b001100, 'A'   => 0b110000, '!D'  => 0b001101,
    '!A'  => 0b110001, '-D'  => 0b001111, '-A'  => 0b110011,
    'D+1' => 0b011111, 'A+1' => 0b110111, 'D-1' => 0b001110,
    'A-1' => 0b110010, 'D+A' => 0b000010, 'D-A' => 0b010011,
    'A-D' => 0b000111, 'D&A' => 0b000000, 'D|A' => 0b010101
  }

  def initialize(dest, comp, jump)
    @dest = dest
    @comp = comp
    @jump = jump
  end

  def m
    @comp&.include?('M') ? 1 : 0
  end

  def comp
    COMP_MAP[@comp&.tr('M', 'A')] || 0
  end

  def dest
    DEST_MAP[@dest] || 0
  end

  def jump
    JUMP_MAP[@jump] || 0
  end
end
