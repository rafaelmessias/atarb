#!/usr/bin/env ruby

require_relative 'mpu6507'
require_relative 'instructions'
require_relative 'pia6532'

# Misc. parameters
Debug = true

# Mnemonics
SWCHA = 0x280
SWCHB = 0x282
INTIM = 0x284
TIMINT = 0x285

# Hardware Setup
# TODO These are part of the PIA
$memory[SWCHB] = 0b00111111
$memory[SWCHA] = 0b11111111
PIA::start()

$rom = IO.binread(ARGV[0])

def sync(cycles)
  cycles.times do
    PIA::tick()
  end
end

# Load cartridge into right "memory" addresses
addr = $reg_PC
$rom.each_char do |char|
  $memory[addr] = char.ord
  addr += 1
end

while $reg_PC < 0xFFFF do
  print "%04X: " % $reg_PC if Debug

  opcode = fetch()
  instruction = $instructions[opcode]

  if !instruction.nil?
    cycles = instruction.call
    sync(cycles)
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
    if $reg_SP < 0xFF && !$memory[$reg_SP+1].nil? && !$memory[$reg_SP+2].nil?
      print "| St: %04X | " % ($memory[$reg_SP+1] + $memory[$reg_SP+2] * 256)
    end
    puts "-----"
  end

end


