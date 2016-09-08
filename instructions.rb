# Question: Can a ZP,X instruction overflow into page 1?
# Question: when disassembling an Absolute address, what's the byte order?
#
# Note: (Indirect,X) has zero page wrap-around

# There will be a lot of empty spaces in this array...
$instructions = []

# TODO: None of the ADC instructions is correctly handling flags V and D

# ADC [Immediate]
$instructions[0x69] = Proc.new do
  param = load_byte()
  puts "ADC \#$%02X" % param if Debug
  op_ADC(param)
  2
end

# ADC [Zero Page]
$instructions[0x65] = Proc.new do
  param = load_byte()
  puts "ADC $%02X" % param if Debug
  op_ADC($memory[param])
  3
end

# ADC [Zero Page,X]
$instructions[0x75] = Proc.new do
  param = load_byte()
  puts "ADC $%02X,X" % param if Debug
  addr = byte_add(param, $reg_X)
  op_ADC($memory[addr])
  4
end

# ADC [Absolute]
$instructions[0x6D] = Proc.new do
  addr = get_absolute_addr(load_word())
  puts "ADC $%04X" % addr if Debug
  op_ADC($memory[addr])
  4
end

# ADC [Absolute,X]
$instructions[0x7D] = Proc.new do
  addr = get_absolute_addr(load_word())
  puts "ADC $%04X,X" % addr if Debug
  addr += $reg_X
  op_ADC($memory[addr])
  # TODO: +1 if page crossed
  4
end

# ADC [Absolute,Y]
$instructions[0x79] = Proc.new do
  addr = get_absolute_addr(load_word())
  puts "ADC $%04X,Y" % addr if Debug
  addr += $reg_Y
  op_ADC($memory[addr])
  # TODO: +1 if page crossed
  4
end

# ADC [(Indirect,X)]
$instructions[0x61] = Proc.new do
  addr = load_byte()
  puts "ADC ($%02X,X)" % addr if Debug
  addr = get_indirect_x(byte)
  op_ADC($memory[addr])
  6
end

# ADC [(Indirect),Y]
$instructions[0x71] = Proc.new do
  addr = load_byte()
  puts "ADC ($%02X),Y" % addr if Debug
  addr = get_indirect_y(byte)
  op_ADC($memory[addr])
  # TODO: +1 if page crossed
  5
end

# ASL [Implicit]
$instructions[0x0A] = Proc.new do
  puts "ASL" if Debug
  $reg_A = op_ASL($reg_A)
  2
end

# ASL [Zero Page]
$instructions[0x06] = Proc.new do
  addr = load_byte()
  puts "ASL $%02X" % byte if Debug
  $memory[addr] = op_ASL($memory[addr])
  5
end

# ASL [Zero Page,X]
$instructions[0x16] = Proc.new do
  byte = load_byte()
  puts "ASL $%02X,X" % byte if Debug
  addr = byte_add(byte, $reg_X)
  $memory[addr] = op_ASL($memory[addr])
  6
end

# ASL [Absolute]
$instructions[0x0E] = Proc.new do
  addr = get_absolute_addr(load_word())
  puts "ASL $%04X" % addr if Debug
  $memory[addr] = op_ASL($memory[addr])
  6
end

# ASL [Absolute,X]
$instructions[0x1E] = Proc.new do
  # TODO When it goes to next page it costs one more cycle
  addr = get_absolute_addr(load_word())
  puts "ASL $%04X,X" % addr if Debug
  addr += $reg_X
  $memory[addr] = op_ASL($memory[addr])
  7
end

# ORA (Immediate)
$instructions[0x09] = Proc.new do
  param = load_byte()
  puts "ORA \#$%02x" % param
  op_ORA(param)
  2
end

# BPL
$instructions[0x10] = Proc.new do
  addr = get_relative_addr(load_byte())
  # not sure if this is the correct way to disassemble
  puts "BPL $%02X" % addr
  cycles = 2
  if !$flag_N
    $reg_PC = addr
    cycles += 1
  end
  # TODO: +1 if the target is in a different page
  cycles
end

# CLC
$instructions[0x18] = Proc.new do
  puts "CLC"
  $flag_C = false
  2
end

# JSR
$instructions[0x20] = Proc.new do
  low = load_byte()
  high = load_byte()
  addr = get_absolute_addr(low, high)
  puts "JSR $%04X" % addr
  $memory[$reg_SP] = ($reg_PC-1) & 255
  $memory[$reg_SP-1] = ($reg_PC-1) >> 8
  $reg_SP -= 2
  $reg_PC = addr
  6
end

# BIT [Zero Page]
$instructions[0x24] = Proc.new do
  param = load_byte()
  puts "BIT $%02X" % param
  aux = $memory[param] & $reg_A
  $flag_N = $memory[param] > 127
  # TODO: implement flag_V
  $flag_Z = aux.zero?
  3
end

# AND (Zero Page)
$instructions[0x25] = Proc.new do
  param = load_byte()
  puts "AND $%02X" % param
  op_AND($memory[param])
  3
end

# AND (Immediate)
$instructions[0x29] = Proc.new do
  param = load_byte()
  puts "AND \#$%02X" % param
  op_AND(param)
  2
end

# SEC
$instructions[0x38] = Proc.new do
  puts "SEC"
  $flag_C = true
  2
end

# EOR (Zero Page)
$instructions[0x45] = Proc.new do
  param = load_byte()
  puts "EOR $%02X" % param
  op_EOR($memory[param])
  3
end

# LSR (Zero Page)
$instructions[0x46] = Proc.new do
  addr = load_byte()
  puts "LSR $%02X" % addr
  $memory[addr] = op_LSR($memory[addr])
  5
end

# PHA
$instructions[0x48] = Proc.new do
  puts "PHA"
  $memory[$reg_SP] = $reg_A
  $reg_SP -= 1
  3
end

# EOR (Immediate)
$instructions[0x49] = Proc.new do
  param = load_byte()
  puts "EOR \#$%02X" % param
  op_EOR(param)
  2
end

# LSR [Implicit]
$instructions[0x4A] = Proc.new do
  puts "LSR A"
  $reg_A = op_LSR($reg_A)
  2
end

# CLI
$instructions[0x58] = Proc.new do
  puts "CLI"
  $flag_Int = false
  2
end

# RTS
$instructions[0x60] = Proc.new do
  puts "RTS"
  $reg_SP += 2
  $reg_PC = $memory[$reg_SP] + $memory[$reg_SP-1] * 256 + 1
  6
end

# SEI
$instructions[0x78] = Proc.new do
  puts "SEI"
  $flag_Int = true
  2
end

# STY (Zero Page)
$instructions[0x84] = Proc.new do
  param = load_byte()
  puts "STY $%02X" % param
  $memory[param] = $reg_Y
  3
end

# STA [Zero Page]
$instructions[0x85] = Proc.new do
  param = load_byte()
  puts "STA $%02X" % param
  $memory[param] = $reg_A
  3
end

# STX [Zero Page]
$instructions[0x86] = Proc.new do
  param = load_byte()
  puts "STX $%02X" % param
  $memory[param] = $reg_X
  3
end

# DEY
$instructions[0x88] = Proc.new do
  puts "DEY"
  $reg_Y = op_DEC($reg_Y)
  2
end

# TXA
$instructions[0x8A] = Proc.new do
  puts "TXA"
  $reg_A = $reg_X
  update_NZ_flags($reg_A)
  2
end

# BCC
$instructions[0x90] = Proc.new do
  addr = get_relative_addr(load_byte())
  puts "BCC \$%02X" % addr
  cycles = 2
  if !$flag_C
    $reg_PC = addr
    # TODO +1 if to a new page
    cycles += 1
  end
  cycles
end

# STY (Zero Page,X)
$instructions[0x94] = Proc.new do
  param = load_byte()
  puts "STY \$%02X,X" % param
  $memory[byte_add(param, $reg_X)] = $reg_Y
  4
end

# STA (Zero Page,X)
$instructions[0x95] = Proc.new do
  param = load_byte()
  puts "STA $%02X,X" % param
  $memory[byte_add(param, $reg_X)] = $reg_A
  4
end

# TYA
$instructions[0x98] = Proc.new do
  puts "TYA"
  $reg_A = $reg_Y
  update_NZ_flags($reg_A)
  2
end

# TXS
$instructions[0x9A] = Proc.new do
  puts "TXS"
  $reg_SP = $reg_X
  2
end

# LDY (Immediate)
$instructions[0xA0] = Proc.new do
  param = load_byte()
  puts "LDY \#\$%02X" % param
  $reg_Y = param
  update_NZ_flags($reg_Y)
  2
end

# LDX (Immediate)
$instructions[0xA2] = Proc.new do
  param = load_byte()
  puts "LDX \#\$%02X" % param
  $reg_X = param
  update_NZ_flags($reg_X)
  2
end

# LDY (Zero Page)
$instructions[0xA4] = Proc.new do
  param = load_byte()
  puts "LDY $%02X" % param
  $reg_Y = $memory[param]
  update_NZ_flags($reg_Y)
  3
end

# LDA (Zero Page)
$instructions[0xA5] = Proc.new do
  param = load_byte()
  puts "LDA \$%02X" % param
  op_LDA($memory[param])
  3
end

# LDX [Zero Page]
$instructions[0xA6] = Proc.new do
  param = load_byte()
  puts "LDX $%02X" % param
  $reg_X = $memory[param]
  update_NZ_flags($reg_X)
  3
end

# TAY
$instructions[0xA8] = Proc.new do
  puts "TAY"
  $reg_Y = $reg_A
  update_NZ_flags($reg_Y)
  2
end

# LDA (Immediate)
$instructions[0xA9] = Proc.new do
  param = load_byte()
  puts "LDA \#\$%02X" % param
  op_LDA(param)
  2
end

# TAX
$instructions[0xAA] = Proc.new do
  puts "TAX"
  $reg_X = $reg_A
  update_NZ_flags($reg_X)
  2
end

# LDA (Absolute)
$instructions[0xAD] = Proc.new do
  low = load_byte()
  high = load_byte()
  addr = get_absolute_addr(low, high)
  puts "LDA $%04X" % addr
  op_LDA($memory[addr])
  4
end

# BCS
$instructions[0xB0] = Proc.new do
  addr = get_relative_addr(load_byte())
  puts "BCS $%02X" % addr
  cycles = 2
  if $flag_C
    $reg_PC = addr
    # TODO +1 if to a new page
    cycles += 1
  end
  cycles
end

# LDA (Indirect), Y
$instructions[0xB1] = Proc.new do
  addr = load_byte()
  puts "LDA ($%02X),Y" % addr
  addr = get_indirect_y(addr)
  op_LDA($memory[addr])
  # TODO +1 if page crossed
  5
end

# LDY (Zero Page,X)
$instructions[0xB4] = Proc.new do
  addr = load_byte()
  puts "LDY $%02X,X" % addr
  $reg_Y = $memory[byte_add(addr, $reg_X)]
  update_NZ_flags($reg_Y)
  4
end

# LDA (Zero Page,X)
$instructions[0xB5] = Proc.new do
  addr = load_byte()
  puts "LDA $%02X,X" % addr
  op_LDA($memory[byte_add(addr, $reg_X)])
  4
end

# LDA (Absolute, Y)
$instructions[0xB9] = Proc.new do
  low = load_byte()
  high = load_byte()
  addr = get_absolute_addr(low, high)
  puts "LDA $%04X,Y" % addr
  # Should wrap the add to 16-bit
  op_LDA($memory[addr + $reg_Y])
  # TODO +1 if page crossed
  4
end

# LDA (Absolute,X)
$instructions[0xBD] = Proc.new do
  low = load_byte()
  high = load_byte()
  addr = get_absolute_addr(low, high)
  puts "LDA $%04X,X" % addr
  # Should wrap the add to 16-bit
  op_LDA($memory[addr + $reg_X])
  # TODO +1 if page crossed
  4
end

# LDX (Absolute, Y)
$instructions[0xBE] = Proc.new do
  low = load_byte()
  high = load_byte()
  addr = get_absolute_addr(low, high)
  puts "LDX $%04X,Y" % addr
  # Should wrap the add to 16-bit
  $reg_X = $memory[addr + $reg_Y]
  update_NZ_flags($reg_X)
  # TODO +1 if page crossed
  4
end

# DEX
$instructions[0xCA] = Proc.new do
  puts "DEX"
  $reg_X = op_DEC($reg_X)
  2
end

# INY
$instructions[0xC8] = Proc.new do
  puts "INY"
  $reg_Y = byte_add($reg_Y, 1)
  update_NZ_flags($reg_Y)
  2
end

# CMP (Immediate)
$instructions[0xC9] = Proc.new do
  param = load_byte()
  puts "CMP \#$%02X" % param
  op_CMP($reg_A, param)
  2
end

# BNE
$instructions[0xD0] = Proc.new do
  addr = get_relative_addr(load_byte())
  # not sure if this is the correct way to disassemble
  puts "BNE $%02X" % addr
  cycles = 2
  if !$flag_Z
    $reg_PC = addr
    # TODO +1 if page crossed
    cycles += 1
  end
  cycles
end

# CLD
$instructions[0xD8] = Proc.new do
  puts "CLD"
  $flag_D = false
  2
end

# CPX [Immediate]
$instructions[0xE0] = Proc.new do
  param = load_byte()
  puts "CPX \#$%02X" % param
  op_CMP($reg_X, param)
  2
end

# INC (Zero Page)
$instructions[0xE6] = Proc.new do
  param = load_byte()
  puts "INC $%02X" % param
  $memory[param] = byte_add($memory[param], 1)
  update_NZ_flags($memory[param])
  5
end

# INX
$instructions[0xE8] = Proc.new do
  puts "INX"
  $reg_X = byte_add($reg_X, 1)
  update_NZ_flags($reg_X)
  2
end

# SBC (Immediate)
$instructions[0xE9] = Proc.new do
  param = load_byte()
  puts "SBC \#$%02X" % param
  op_SBC(param)
  2
end

# BEQ
$instructions[0xF0] = Proc.new do
  addr = get_relative_addr(load_byte())
  puts "BEQ $%02X" % addr
  cycles = 2
  if $flag_Z
    $reg_PC = addr
    # TODO +1 if page crossed
    cycles += 1
  end
  cycles
end

# SED
$instructions[0xF8] = Proc.new do
  puts "SED"
  $flag_D = true
  2
end
