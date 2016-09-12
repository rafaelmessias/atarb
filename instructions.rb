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

# Question: Can a ZP,X instruction overflow into page 1?
# Question: when disassembling an Absolute address, what's the byte order?
#
# Note: (Indirect,X) has zero page wrap-around

# TODO Stop calling these Proc's?

class Instruction
  attr_reader :bytes, :cycles, :debug, :code, :params

  def initialize(bytes: 1, cycles: 2, debug:, code: [0x90], params: [])
    @bytes = bytes
    @cycles = cycles
    @debug = debug
    @code = code
    @params = params
  end
end

# There will be a lot of empty spaces in this array...
$instructions = []

# TODO: None of the ADC instructions is correctly handling flags V and D

# ADC [Immediate]
$instructions[0x69] = Proc.new do
  param = fetch()
  puts "ADC \#$%02X" % param if Debug
  op_ADC(param)
  [2]
end

# ADC [Zero Page]
$instructions[0x65] = Proc.new do
  param = fetch()
  puts "ADC $%02X" % param if Debug
  op_ADC($memory[param])
  [3]
end

# ADC [Zero Page,X]
$instructions[0x75] = Proc.new do
  param = fetch()
  puts "ADC $%02X,X" % param if Debug
  addr = byte_add(param, $reg_X)
  op_ADC($memory[addr])
  [4]
end

# ADC [Absolute]
$instructions[0x6D] = Proc.new do
  addr = get_absolute_addr(fetch(), fetch())
  puts "ADC $%04X" % addr if Debug
  op_ADC($memory[addr])
  [4]
end

# ADC [Absolute,X]
$instructions[0x7D] = Proc.new do
  addr = get_absolute_addr(fetch(), fetch())
  puts "ADC $%04X,X" % addr if Debug
  addr += $reg_X
  op_ADC($memory[addr])
  # TODO: +1 if page crossed
  [4]
end

# ADC [Absolute,Y]
$instructions[0x79] = Proc.new do
  addr = get_absolute_addr(fetch(), fetch())
  puts "ADC $%04X,Y" % addr if Debug
  addr += $reg_Y
  op_ADC($memory[addr])
  # TODO: +1 if page crossed
  [4]
end

# ADC [(Indirect,X)]
$instructions[0x61] = Proc.new do
  addr = fetch()
  puts "ADC ($%02X,X)" % addr if Debug
  addr = get_indirect_x(byte)
  op_ADC($memory[addr])
  [6]
end

# ADC [(Indirect),Y]
$instructions[0x71] = Proc.new do
  addr = fetch()
  puts "ADC ($%02X),Y" % addr if Debug
  addr = get_indirect_y(byte)
  op_ADC($memory[addr])
  # TODO: +1 if page crossed
  [5]
end

# ASL [Implicit]
$instructions[0x0A] = Proc.new do
  puts "ASL" if Debug
  $reg_A = op_ASL($reg_A)
  [2]
end

# ASL [Zero Page]
$instructions[0x06] = Proc.new do
  addr = fetch()
  puts "ASL $%02X" % addr if Debug
  $memory[addr] = op_ASL($memory[addr])
  [5]
end

# ASL [Zero Page,X]
$instructions[0x16] = Proc.new do
  byte = fetch()
  puts "ASL $%02X,X" % byte if Debug
  addr = byte_add(byte, $reg_X)
  $memory[addr] = op_ASL($memory[addr])
  [6]
end

# ASL [Absolute]
$instructions[0x0E] = Proc.new do
  addr = get_absolute_addr(fetch(), fetch())
  puts "ASL $%04X" % addr if Debug
  $memory[addr] = op_ASL($memory[addr])
  [6]
end

# ASL [Absolute,X]
$instructions[0x1E] = Proc.new do
  # TODO When it goes to next page it costs one more cycle
  addr = get_absolute_addr(fetch(), fetch())
  puts "ASL $%04X,X" % addr if Debug
  addr += $reg_X
  $memory[addr] = op_ASL($memory[addr])
  [7]
end

# ORA (Immediate)
$instructions[0x09] = Proc.new do
  param = fetch()
  puts "ORA \#$%02X" % param if Debug
  op_ORA(param)
  [2]
end

# ORA [Zero Page]
$instructions[0x05] = Proc.new do
  addr = fetch()
  puts "ORA $%02X" % addr if Debug
  op_ORA($memory[addr])
  [3]
end

# BPL
$instructions[0x10] = Proc.new do
  addr = get_relative_addr(fetch())
  puts "BPL $%04X" % addr if Debug
  cycles = 2
  if !$flag_N
    $reg_PC = addr
    cycles += 1
  end
  # TODO: +1 if the target is in a different page
  [cycles]
end

# CLC
$instructions[0x18] = Proc.new do
  puts "CLC" if Debug
  $flag_C = false
  [2]
end

# JSR
$instructions[0x20] = Proc.new do
  addr = get_absolute_addr(fetch(), fetch())
  puts "JSR $%04X" % addr if Debug
  stack_push(($reg_PC-1) >> 8)
  stack_push(($reg_PC-1) & 255)
  $reg_PC = addr
  [6]
end

# BIT [Zero Page]
$instructions[0x24] = Proc.new do
  param = fetch()
  puts "BIT $%02X" % param if Debug
  aux = $memory[param] & $reg_A
  $flag_N = $memory[param] > 127
  # TODO: implement flag_V
  $flag_Z = aux.zero?
  [3]
end

# AND (Zero Page)
$instructions[0x25] = Proc.new do
  param = fetch()
  puts "AND $%02X" % param if Debug
  op_AND($memory[param])
  [3]
end

# AND (Immediate)
$instructions[0x29] = Proc.new do
  param = fetch()
  puts "AND \#$%02X" % param if Debug
  op_AND(param)
  [2]
end

# SEC
$instructions[0x38] = Proc.new do
  puts "SEC" if Debug
  $flag_C = true
  [2]
end

# EOR (Zero Page)
$instructions[0x45] = Proc.new do
  param = fetch()
  puts "EOR $%02X" % param if Debug
  op_EOR($memory[param])
  [3]
end

# LSR (Zero Page)
$instructions[0x46] = Proc.new do
  addr = fetch()
  puts "LSR $%02X" % addr if Debug
  $memory[addr] = op_LSR($memory[addr])
  [5]
end

# PHA
$instructions[0x48] = Proc.new do
  puts "PHA" if Debug
  stack_push($reg_A)
  [3]
end

# PLA
$instructions[0x68] = Proc.new do
  puts "PLA" if Debug
  $reg_A = stack_pull()
  update_NZ_flags($reg_A)
  [4]
end

# EOR (Immediate)
$instructions[0x49] = Proc.new do
  param = fetch()
  puts "EOR \#$%02X" % param if Debug
  op_EOR(param)
  [2]
end

# LSR [Implicit]
$instructions[0x4A] = Proc.new do
  puts "LSR A" if Debug
  $reg_A = op_LSR($reg_A)
  [2]
end

# CLI
$instructions[0x58] = Proc.new do
  puts "CLI" if Debug
  $flag_Int = false
  [2]
end

# RTS
$instructions[0x60] = Proc.new do
  puts "RTS" if Debug
  $reg_PC = stack_pull() + stack_pull() * 256 + 1
  [6]
end

# SEI
$instructions[0x78] = Instruction.new(
  debug: "SEI",
)

# STY [Zero Page]
$instructions[0x84] = Proc.new do
  addr = fetch()
  puts "STY $%02X" % addr if Debug
  if addr == 2 # WSYNC
    $wSync = true
  else
    $memory[addr] = $reg_Y
  end
  [3]
end

# STA [Zero Page]
$instructions[0x85] = Proc.new do
  addr = fetch()
  puts "STA $%02X" % addr if Debug
  if addr == 2 # WSYNC
    $wSync = true
  else
    $memory[addr] = $reg_A
  end
  [3]
end

# STA [Absolute]
$instructions[0x8D] = Proc.new do
  addr = get_absolute_addr(fetch(), fetch())
  puts "STA $%04X" % addr if Debug
  $memory[addr] = $reg_A
  [4]
end

# STX [Zero Page]
$instructions[0x86] = Proc.new do
  addr = fetch()
  puts "STX $%02X" % addr if Debug
  if addr == 2 # WSYNC
    $wSync = true
  else
    $memory[addr] = $reg_X
  end
  [3]
end

# DEY
$instructions[0x88] = Proc.new do
  puts "DEY" if Debug
  $reg_Y = op_DEC($reg_Y)
  [2]
end

# TXA
$instructions[0x8A] = Proc.new do
  puts "TXA" if Debug
  $reg_A = $reg_X
  update_NZ_flags($reg_A)
  [2]
end

# BCC
$instructions[0x90] = Proc.new do
  addr = get_relative_addr(fetch())
  puts "BCC $%04X" % addr if Debug
  cycles = 2
  if !$flag_C
    $reg_PC = addr
    # TODO +1 if to a new page
    cycles += 1
  end
  [cycles]
end

# STY (Zero Page,X)
$instructions[0x94] = Proc.new do
  param = fetch()
  puts "STY \$%02X,X" % param if Debug
  $memory[byte_add(param, $reg_X)] = $reg_Y
  [4]
end

# STA (Zero Page,X)
$instructions[0x95] = Proc.new do
  param = fetch()
  puts "STA $%02X,X" % param if Debug
  $memory[byte_add(param, $reg_X)] = $reg_A
  [4]
end

# TYA
$instructions[0x98] = Proc.new do
  puts "TYA" if Debug
  $reg_A = $reg_Y
  update_NZ_flags($reg_A)
  [2]
end

# TXS
$instructions[0x9A] = Instruction.new(
  debug: "TXS",
  code: [
    0x88, 0xD9      # mov cl, bl
  ]
)

# LDY [Immediate]
$instructions[0xA0] = Proc.new do
  param = fetch()
  puts "LDY \#$%02X" % param if Debug
  $reg_Y = param
  update_NZ_flags($reg_Y)
  [2]
end

# LDY [Absolute,X]
$instructions[0xBC] = Proc.new do
  addr = get_absolute_addr(fetch(), fetch())
  puts "LDY $%04X,X" % addr if Debug
  $reg_Y = $memory[addr]
  update_NZ_flags($reg_Y)
  # TODO +1 if page crossed
  [4]
end

# LDX (Immediate)
$instructions[0xA2] = Instruction.new(
  bytes: 2, cycles: 2,
  debug: "LDX \#$%02X",
  code: [
    0xB3, 0x00,         # MOV BL, imm   ; BL is X
    0x80, 0xFB, 0x00    # CMP BL, 0     ; for the flags
  ],
  params: [1]
)

# LDY (Zero Page)
$instructions[0xA4] = Proc.new do
  param = fetch()
  puts "LDY $%02X" % param if Debug
  $reg_Y = $memory[param]
  update_NZ_flags($reg_Y)
  [3]
end

# LDA (Zero Page)
$instructions[0xA5] = Proc.new do
  param = fetch()
  puts "LDA \$%02X" % param if Debug
  op_LDA($memory[param])
  [3]
end

# LDX [Zero Page]
$instructions[0xA6] = Proc.new do
  param = fetch()
  puts "LDX $%02X" % param if Debug
  $reg_X = $memory[param]
  update_NZ_flags($reg_X)
  [3]
end

# TAY
$instructions[0xA8] = Proc.new do
  puts "TAY" if Debug
  $reg_Y = $reg_A
  update_NZ_flags($reg_Y)
  [2]
end

# LDA (Immediate)
$instructions[0xA9] = Proc.new do
  param = fetch()
  puts "LDA \#\$%02X" % param if Debug
  op_LDA(param)
  [2]
end

# TAX
$instructions[0xAA] = Proc.new do
  puts "TAX" if Debug
  $reg_X = $reg_A
  update_NZ_flags($reg_X)
  [2]
end

# LDA (Absolute)
$instructions[0xAD] = Proc.new do
  addr = get_absolute_addr(fetch(), fetch())
  puts "LDA $%04X" % addr if Debug
  op_LDA($memory[addr])
  [4]
end

# BCS
$instructions[0xB0] = Proc.new do
  addr = get_relative_addr(fetch())
  puts "BCS $%04X" % addr if Debug
  cycles = 2
  if $flag_C
    $reg_PC = addr
    # TODO +1 if to a new page
    cycles += 1
  end
  [cycles]
end

# LDA (Indirect), Y
$instructions[0xB1] = Proc.new do
  addr = fetch()
  puts "LDA ($%02X),Y" % addr if Debug
  addr = get_indirect_y(addr)
  op_LDA($memory[addr])
  # TODO +1 if page crossed
  [5]
end

# LDY (Zero Page,X)
$instructions[0xB4] = Proc.new do
  addr = fetch()
  puts "LDY $%02X,X" % addr if Debug
  $reg_Y = $memory[byte_add(addr, $reg_X)]
  update_NZ_flags($reg_Y)
  [4]
end

# LDA (Zero Page,X)
$instructions[0xB5] = Proc.new do
  addr = fetch()
  puts "LDA $%02X,X" % addr if Debug
  op_LDA($memory[byte_add(addr, $reg_X)])
  [4]
end

# LDA (Absolute, Y)
$instructions[0xB9] = Proc.new do
  addr = get_absolute_addr(fetch(), fetch())
  puts "LDA $%04X,Y" % addr if Debug
  # Should wrap the add to 16-bit
  op_LDA($memory[addr + $reg_Y])
  # TODO +1 if page crossed
  [4]
end

# LDA (Absolute,X)
$instructions[0xBD] = Proc.new do
  addr = get_absolute_addr(fetch(), fetch())
  puts "LDA $%04X,X" % addr if Debug
  # Should wrap the add to 16-bit
  op_LDA($memory[addr + $reg_X])
  # TODO +1 if page crossed
  [4]
end

# LDX (Absolute, Y)
$instructions[0xBE] = Proc.new do
  addr = get_absolute_addr(fetch(), fetch())
  puts "LDX $%04X,Y" % addr if Debug
  # Should wrap the add to 16-bit
  $reg_X = $memory[addr + $reg_Y]
  update_NZ_flags($reg_X)
  # TODO +1 if page crossed
  [4]
end

# DEX
$instructions[0xCA] = Proc.new do
  puts "DEX" if Debug
  $reg_X = op_DEC($reg_X)
  [2]
end

# DEC [Zero Page]
$instructions[0xC6] = Proc.new do
  addr = fetch()
  puts "DEC $%02X" % addr if Debug
  $memory[addr] = op_DEC($memory[addr])
  [5]
end

# INY
$instructions[0xC8] = Proc.new do
  puts "INY" if Debug
  $reg_Y = byte_add($reg_Y, 1)
  update_NZ_flags($reg_Y)
  [2]
end

# CMP [Immediate]
$instructions[0xC9] = Proc.new do
  param = fetch()
  puts "CMP \#$%02X" % param if Debug
  op_CMP($reg_A, param)
  [2]
end

# CMP [Zero Page]
$instructions[0xC5] = Proc.new do
  addr = fetch()
  puts "CMP $%02X" % addr if Debug
  op_CMP($reg_A, $memory[addr])
  [3]
end

# BNE
$instructions[0xD0] = Proc.new do
  addr = get_relative_addr(fetch())
  puts "BNE $%04X" % addr if Debug
  cycles = 2
  if !$flag_Z
    $reg_PC = addr
    # TODO +1 if page crossed
    cycles += 1
  end
  [cycles]
end

# BMI
$instructions[0x30] = Proc.new do
  addr = get_relative_addr(fetch())
  puts "BMI $%04X" % addr if Debug
  cycles = 2
  if $flag_N
    $reg_PC = addr
    # TODO +1 if page crossed
    cycles += 1
  end
  [cycles]
end

# CLD
$instructions[0xD8] = Instruction.new(
  debug: "CLD",
)

# CPX [Immediate]
$instructions[0xE0] = Proc.new do
  param = fetch()
  puts "CPX \#$%02X" % param if Debug
  op_CMP($reg_X, param)
  [2]
end

# CPX [Zero Page]
$instructions[0xE4] = Proc.new do
  addr = fetch()
  puts "CPX $%02X" % addr if Debug
  op_CMP($reg_X, $memory[addr])
  [3]
end

# CPY [Immediate]
$instructions[0xC0] = Proc.new do
  param = fetch()
  puts "CPY \#$%02X" % param if Debug
  op_CMP($reg_Y, param)
  [2]
end

# INC (Zero Page)
$instructions[0xE6] = Proc.new do
  param = fetch()
  puts "INC $%02X" % param if Debug
  $memory[param] = byte_add($memory[param], 1)
  update_NZ_flags($memory[param])
  [5]
end

# INX
$instructions[0xE8] = Proc.new do
  puts "INX" if Debug
  $reg_X = byte_add($reg_X, 1)
  update_NZ_flags($reg_X)
  [2]
end

# SBC [Immediate]
$instructions[0xE9] = Proc.new do
  param = fetch()
  puts "SBC \#$%02X" % param if Debug
  op_SBC(param)
  [2]
end

# SBC [Zero Page]
$instructions[0xE5] = Proc.new do
  addr = fetch()
  puts "SBC $%02X" % addr if Debug
  op_SBC($memory[addr])
  [3]
end

# BEQ
$instructions[0xF0] = Proc.new do
  addr = get_relative_addr(fetch())
  puts "BEQ $%04X" % addr if Debug
  cycles = 2
  if $flag_Z
    $reg_PC = addr
    # TODO +1 if page crossed
    cycles += 1
  end
  [cycles]
end

# SED
$instructions[0xF8] = Proc.new do
  puts "SED" if Debug
  $flag_D = true
  [2]
end

# NOP
$instructions[0xEA] = Proc.new do
  puts "NOP" if Debug
  [2]
end

# JMP [Absolute]
$instructions[0x4C] = Proc.new do
  addr = get_absolute_addr(fetch(), fetch())
  puts "JMP $%04X" % addr if Debug
  $reg_PC = addr
  [3]
end

# ROL [Zero Page]
$instructions[0x26] = Proc.new do
  addr = fetch()
  puts "ROL $%02X" % addr if Debug
  $memory[addr] = op_ROL($memory[addr])
  [5]
end

# ROL
$instructions[0x2A] = Proc.new do
  puts "ROL" if Debug
  $reg_A = op_ROL($reg_A)
  [2]
end
