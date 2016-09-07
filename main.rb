#!/usr/bin/env ruby

require_relative 'mpu6502'
require_relative 'instructions'

# Misc. parameters
Debug = true

# Mnemonics
SWCHB = 0x282
INTIM = 0x284

# Hardware Setup
$memory[SWCHB] = 0x00111111
#$memory[INTIM] = rand(256)
$intim_clock = 0

$rom = IO.binread(ARGV[0])

# Load cartridge into right "memory" addresses
addr = $reg_PC
$rom.each_char do |char|
  $memory[addr] = char.ord
  addr += 1
end

while $reg_PC < 0xFFFF do
  print "%04X: " % $reg_PC if Debug

  opcode = load_byte()
  instruction = $instructions[opcode]

  if !instruction.nil?
    instruction.call
  else
    puts "%02X ???" % opcode
    exit
  end

  if Debug
    print "----- "
    print "A: %02X, " % $reg_A
    print "X: %02X, " % $reg_X
    print "Y: %02X, " % $reg_Y
    print "SP: %02X, " % $reg_SP
    print $flag_N ? "N " : "n "
    print $flag_Z ? "Z " : "z "
    print $flag_C ? "C " : "c "
    print $flag_D ? "D " : "d "
    #print "| St: %02X | " % $memory[$reg_SP+1] if $reg_SP < 0xFF
    puts "-----"
  end

end


