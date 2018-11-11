# frozen_string_literal: true

require 'pathname'
require_relative 'code'
require_relative 'parser'
require_relative 'symbol_table'

class Assembler
  def self.assemble(file)
    new(file).assemble
  end

  def initialize(file)
    @file = Pathname(file)
    @counter = 15
    @symbols = SymbolTable.new

    fail('Bad input') if @file.extname != '.asm'
  end

  def assemble
    detect_symbols
    @file.sub_ext('.hack').open('w') do |out|
      generate_code(out)
    end
  end

  private

  def detect_symbols
    @file.open('r') do |f|
      parser = Parser.new(f)
      addresss = 0
      while parser.has_more_commands?
        parser.advance
        case parser.command_type
        when Parser::A_COMMAND, Parser::C_COMMAND
          addresss += 1
        when Parser::L_COMMAND
          @symbols[parser.symbol] = addresss
        end
      end
    end
  end

  def generate_code(out)
    @file.open('r') do |f|
      parser = Parser.new(f)

      while parser.has_more_commands?
        parser.advance

        code =
          case parser.command_type
          when Parser::A_COMMAND
            gen_a_inst(handle_sym(parser.symbol))
          when Parser::C_COMMAND
            gen_c_inst(Code.new(*parser.code))
          end

        out.puts code if code
      end
    end
  end

  def handle_sym(value)
    return value if value.match?(/^\d/)
    @symbols[value] ||= @counter += 1
  end

  def gen_a_inst(value)
    "0%015b" % value
  end

  def gen_c_inst(code)
    "111%1d%06b%03b%03b" % [code.m, code.comp, code.dest, code.jump]
  end
end

if $PROGRAM_NAME == __FILE__

  if ARGV.size != 1
    puts "Usage: ./assembler.rb file.asm"
  else
    Assembler.assemble(ARGV[0])
  end
end
