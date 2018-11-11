# frozen_string_literal: true

require_relative 'code'

# Encapsulates access to the input code.
class Parser
  A_COMMAND = 0
  C_COMMAND = 1
  L_COMMAND = 2

  def initialize(file)
    @file = file
  end

  def has_more_commands?
    !@file.eof?
  end

  def command_type
    case @tokens&.first
    when '@' then A_COMMAND
    when /^[AMD0]/ then C_COMMAND
    when '(' then L_COMMAND
    end
  end

  def advance
    @tokens = @file.gets.strip.split(' ').first
                   &.split(/([@();=])/)&.reject(&:empty?)
  end

  def symbol
    case command_type
    when A_COMMAND then @tokens.last
    when L_COMMAND then @tokens[1..-2].first
    end
  end

  def dest
    @tokens.first if @tokens.include?('=')
  end

  def comp
    !@tokens.include?('=') ? @tokens.first : @tokens[2]
  end

  def jump
    @tokens.last if @tokens.include?(';')
  end

  def code
    [dest, comp, jump]
  end
end
