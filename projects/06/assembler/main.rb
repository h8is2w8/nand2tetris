# frozen_string_literal: true

require 'pathname'
require_relative 'assembler'

file = Pathname(ARGV[0])

fail 'Wrong input' if file.extname != '.asm'

File.write file.sub_ext('.hack'), Assembler.assemble(file)
