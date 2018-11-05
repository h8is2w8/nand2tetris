# frozen_string_literal: true

require 'pathname'

class Assembler
  LABEL_REGEX  = /\((.+)\)/
  DST_MAP = Hash[%w[M D MD A AM AD AMD].zip(1..7)]
  JMP_MAP = Hash[%w[JGT JEQ JGE JLT JNE JLE JMP].zip(1..7)]
  SYM_MAP = Hash[0.upto(15).map { |i| "R#{i}" }.zip(0..15)]
              .merge!('SCREEN' => 16384, 'KBD' => 24576)
              .merge!(Hash[%w[SP LCL ARG THIS THAT].zip(0..4)])
  CMD_MAP = {
    '0'   => 0b101010, '1'   => 0b111111, '-1'  => 0b111010,
    'D'   => 0b001100, 'A'   => 0b110000, '!D'  => 0b001101,
    '!A'  => 0b110001, '-D'  => 0b001111, '-A'  => 0b110011,
    'D+1' => 0b011111, 'A+1' => 0b110111, 'D-1' => 0b001110,
    'A-1' => 0b110010, 'D+A' => 0b000010, 'D-A' => 0b010011,
    'A-D' => 0b000111, 'D&A' => 0b000000, 'D|A' => 0b010101
  }

  def self.assemble(input)
    case input
    when /\.asm$/ then new(File.read(input).split("\n"))
    when File, Pathname then new(input.read.split("\n"))
    when String then new(input.split("\n"))
    when Array then new(input)
    else fail('Unknown input type')
    end.assemble
  end

  def initialize(input)
    @counter = 15
    @labels = SYM_MAP.dup
    @program = input.select do |line|
      line.gsub!(/\/\/.*/, '')
      line.strip!
      !line.empty?
    end
  end

  def assemble
    detect_labels
    generate_code
  end

  def detect_labels
    address = 0

    @program.each do |line|
      if match = line.match(LABEL_REGEX)
        @labels[match[1]] = address
      else
        address += 1
      end
    end
  end

  def generate_code
    @program.each_with_object([]) do |line, store|
      next if line.match?(LABEL_REGEX)
      store << (line.start_with?('@') ? parse_a_inst(line) : parse_c_inst(line))
    end.join("\n")
  end

  def parse_a_inst(text)
    value = text[1..-1]

    int = @labels[value] || handle_sym(value) || Integer(value)

    "0%015b" % int
  end

  def handle_sym(value)
    return if value.match?(/^\d/)
    @labels[value] ||= @counter += 1
  end

  def parse_c_inst(text)
    chunks = text.gsub(/\/\/.*/, '').strip.split(/=|;/)

    jmp = text.include?(';') ? chunks.pop : '0'
    cmd = text.include?('=') ? chunks.pop : chunks.shift
    dst = text.include?('=') ? chunks.shift : '0'

    c = CMD_MAP.fetch(cmd.tr('M', 'A'), 0)
    d = DST_MAP.fetch(dst, 0)
    j = JMP_MAP.fetch(jmp, 0)
    m = cmd.include?('M') ? 1 : 0

    "111%d%06b%03b%03b" % [m, c, d, j]
  end
end
