=begin
  Copyleft (<) 2016, Rafael Martins.

  This file is part of 'ata.rb'.

  'ata.rb' is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version. Please, don't hate me for the way
  I write multiline comments in ruby.

  'ata.rb' is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with 'ata.rb'.  If not, see <http://www.gnu.org/licenses/>.
=end

#!/usr/bin/env ruby

require 'rubygame'

require_relative 'mpu6507'
require_relative 'instructions'
require_relative 'pia6532'
require_relative 'tia'

# Misc. parameters
Debug = false

# Hardware Setup
PIA::start()
TIA::start()

$rom = IO.binread(ARGV[0])

def sync(cycles)
  cycles.times do
    PIA::tick()
    TIA::tick()
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

  cycles = 1

  if !$wSync
    opcode = fetch()
    instruction = $instructions[opcode]
    if !instruction.nil?
      cycles = instruction.call
    else
      puts "%02X ???" % opcode
      exit
    end
  end

  sync(cycles)

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


