#!/usr/bin/env ruby

require_relative 'mpu6507'
require_relative 'instructions'
require_relative 'pia6532'

# Misc. parameters
Debug = true

# Mnemonics
SWCHB = 0x282
INTIM = 0x284
TIMINT = 0x285

# Hardware Setup
$memory[SWCHB] = 0x00111111
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

  opcode = load_byte()
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
    if $reg_SP < 0xFF && !$memory[$reg_SP+1].nil?
      print "| St: %02X | " % $memory[$reg_SP+1]
    end
    puts "-----"
  end

end


