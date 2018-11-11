# frozen_string_literal: true

# Keeps a correspondence between symbolic labels and numeric addresses.
class SymbolTable
  DEFAULTS = Hash[0.upto(15).map { |i| "R#{i}" }.zip(0..15)]
              .merge!('SCREEN' => 16384, 'KBD' => 24576)
              .merge!(Hash[%w[SP LCL ARG THIS THAT].zip(0..4)])
              .freeze

  def initialize
    @symbols = DEFAULTS.dup
  end

  def [](key)
    @symbols[key]
  end

  def []=(key, value)
    @symbols[key] = value
  end

  def key?(key)
    @symbols.key?(key)
  end
end
