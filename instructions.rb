# There will be a lot of empty spaces in this array...
$instructions = []

$instructions[0x0A] = Proc.new do # ASL
    puts "ASL"
    $reg_A <<= 1
    update_NZ_flags($reg_A)
end

$instructions[0x09] = Proc.new do # ORA (Immediate)
  param = load_byte()
  puts "ORA \#$%02x" % param
  op_ORA(param)
end

$instructions[0x10] = Proc.new do # BPL
  param = load_byte()
  # not sure if this is the correct way to disassemble
  puts "BPL $%02X" % param
  if !$flag_N
    $reg_PC = get_relative_addr(param)
  end
end

$instructions[0x18] = Proc.new do # CLC
  puts "CLC"
  $flag_C = false
end

$instructions[0x20] = Proc.new do # JSR
  low = load_byte()
  high = load_byte()
  puts "JSR $%02X%02X" % [low, high]
  # TODO: This is wrong; PC is 16-bit
  $memory[$reg_SP] = $reg_PC - 1
  $reg_SP -= 1
  $reg_PC = get_absolute_addr(low, high)
end

$instructions[0x24] = Proc.new do # BIT [Zero Page]
  param = load_byte()
  puts "BIT $%02X" % param
  aux = $memory[param] & $reg_A
  $flag_N = $memory[param] > 127
  # TODO: implement flag_V
  $flag_Z = aux.zero?
end

$instructions[0x25] = Proc.new do # AND (Zero Page)
  param = load_byte()
  puts "AND $%02X" % param
  op_AND($memory[param])
end

$instructions[0x29] = Proc.new do # AND (Immediate)
  param = load_byte()
  puts "AND \#$%02X" % param
  op_AND(param)
end

$instructions[0x38] = Proc.new do # SEC
  puts "SEC"
  $flag_C = true
end

$instructions[0x45] = Proc.new do # EOR (Zero Page)
  param = load_byte()
  puts "EOR $%02X" % param
  op_EOR($memory[param])
end

$instructions[0x46] = Proc.new do # LSR (Zero Page)
  addr = load_byte()
  puts "LSR $%02X" % addr
  $memory[addr] = op_LSR($memory[addr])
end

$instructions[0x48] = Proc.new do # PHA
  puts "PHA"
  $memory[$reg_SP] = $reg_A
  $reg_SP -= 1
end

$instructions[0x49] = Proc.new do # EOR (Immediate)
  param = load_byte()
  puts "EOR \#$%02X" % param
  op_EOR(param)
end

$instructions[0x4A] = Proc.new do # LSR
  puts "LSR A"
  $reg_A = op_LSR($reg_A)
end

$instructions[0x58] = Proc.new do # CLI
  puts "CLI"
  $flag_Int = false
end

$instructions[0x60] = Proc.new do # RTS
  puts "RTS"
  # TODO: This is wrong; PC is 16-bit
  $reg_SP += 1
  $reg_PC = $memory[$reg_SP] + 1
end

$instructions[0x65] = Proc.new do # ADC (Zero Page)
  param = load_byte()
  puts "ADC $%02X" % param
  op_ADC($memory[param])
end

$instructions[0x69] = Proc.new do # ADC (Immediate)
  param = load_byte()
  puts "ADC \#$%02X" % param
  op_ADC(param)
end

$instructions[0x78] = Proc.new do # SEI
  puts "SEI"
  $flag_Int = true
end

$instructions[0x84] = Proc.new do # STY (Zero Page)
  param = load_byte()
  puts "STY $%02X" % param
  $memory[param] = $reg_Y
end

$instructions[0x85] = Proc.new do # STA
  param = load_byte()
  puts "STA $%02X" % param
  $memory[param] = $reg_A
end

$instructions[0x86] = Proc.new do # STX (Zero Page)
  param = load_byte()
  puts "STX $%02X" % param
  $memory[param] = $reg_X
end

$instructions[0x88] = Proc.new do # DEY
  puts "DEY"
  $reg_Y = op_DEC($reg_Y)
end

$instructions[0x8A] = Proc.new do # TXA
  puts "TXA"
  $reg_A = $reg_X
  update_NZ_flags($reg_A)
end

$instructions[0x90] = Proc.new do # BCC
  param = load_byte()
  puts "BCC \$%02X" % param
  if !$flag_C
    $reg_PC = get_relative_addr(param)
  end
end

$instructions[0x94] = Proc.new do # STY (Zero Page,X)
  param = load_byte()
  puts "STY \$%02X,X" % param
  $memory[byte_add(param, $reg_X)] = $reg_Y
end

$instructions[0x95] = Proc.new do # STA (Zero Page,X)
  param = load_byte()
  puts "STA $%02X,X" % param
  $memory[byte_add(param, $reg_X)] = $reg_A
end

$instructions[0x98] = Proc.new do # TYA
  puts "TYA"
  $reg_A = $reg_Y
  update_NZ_flags($reg_A)
end

$instructions[0x9A] = Proc.new do # TXS
  puts "TXS"
  $reg_SP = $reg_X
end

$instructions[0xA0] = Proc.new do # LDY (Immediate)
  param = load_byte()
  puts "LDY \#\$%02X" % param
  $reg_Y = param
  update_NZ_flags($reg_Y)
end

$instructions[0xA2] = Proc.new do # LDX (Immediate)
  param = load_byte()
  puts "LDX \#\$%02X" % param
  $reg_X = param
  update_NZ_flags($reg_X)
end

$instructions[0xA4] = Proc.new do # LDY (Zero Page)
  param = load_byte()
  puts "LDY $%02X" % param
  $reg_Y = $memory[param]
  update_NZ_flags($reg_Y)
end

$instructions[0xA5] = Proc.new do # LDA (Zero Page)
  param = load_byte()
  puts "LDA \$%02X" % param
  op_LDA($memory[param])
end

$instructions[0xA6] = Proc.new do # LDX [Zero Page]
  param = load_byte()
  puts "LDX $%02X" % param
  $reg_X = $memory[param]
  update_NZ_flags($reg_X)
end

$instructions[0xA8] = Proc.new do # TAY
  puts "TAY"
  $reg_Y = $reg_A
  update_NZ_flags($reg_Y)
end

$instructions[0xA9] = Proc.new do # LDA (Immediate)
  param = load_byte()
  puts "LDA \#\$%02X" % param
  op_LDA(param)
end

$instructions[0xAA] = Proc.new do # TAX
  puts "TAX"
  $reg_X = $reg_A
  update_NZ_flags($reg_X)
end

$instructions[0xAD] = Proc.new do # LDA (Absolute)
  low = load_byte()
  high = load_byte()
  addr = get_absolute_addr(low, high)
  puts "LDA $%04X" % addr
  op_LDA($memory[addr])
end

$instructions[0xB0] = Proc.new do # BCS
  param = load_byte()
  addr = get_relative_addr(param)
  puts "BCS $%02X" % addr
  if $flag_C
    $reg_PC = addr
  end
end

$instructions[0xB1] = Proc.new do # LDA (Indirect), Y
  addr = load_byte()
  puts "LDA ($%02X),Y" % addr
  addr = $memory[addr] + $memory[addr+1] * 256
  op_LDA($memory[addr + $reg_Y])
end

$instructions[0xB4] = Proc.new do # LDY (Zero Page,X)
  addr = load_byte()
  puts "LDY $%02X,X" % addr
  $reg_Y = $memory[byte_add(addr, $reg_X)]
  update_NZ_flags($reg_Y)
end

$instructions[0xB5] = Proc.new do # LDA (Zero Page,X)
  addr = load_byte()
  puts "LDA $%02X,X" % addr
  op_LDA($memory[byte_add(addr, $reg_X)])
end

$instructions[0xB9] = Proc.new do # LDA (Absolute, Y)
  low = load_byte()
  high = load_byte()
  addr = get_absolute_addr(low, high)
  puts "LDA $%04X,Y" % addr
  # Should wrap the add to 16-bit
  op_LDA($memory[addr + $reg_Y])
end

$instructions[0xBD] = Proc.new do # LDA (Absolute,X)
  low = load_byte()
  high = load_byte()
  addr = get_absolute_addr(low, high)
  puts "LDA $%04X,X" % addr
  # Should wrap the add to 16-bit
  op_LDA($memory[addr + $reg_X])
end

$instructions[0xBE] = Proc.new do # LDX (Absolute, Y)
  low = load_byte()
  high = load_byte()
  addr = get_absolute_addr(low, high)
  puts "LDX $%04X,Y" % addr
  # Should wrap the add to 16-bit
  $reg_X = $memory[addr + $reg_Y]
  update_NZ_flags($reg_X)
end

$instructions[0xCA] = Proc.new do # DEX
  puts "DEX"
  $reg_X = op_DEC($reg_X)
end

$instructions[0xC8] = Proc.new do # INY
  puts "INY"
  $reg_Y = byte_add($reg_Y, 1)
  update_NZ_flags($reg_Y)
end

$instructions[0xC9] = Proc.new do # CMP (Immediate)
  param = load_byte()
  puts "CMP \#$%02X" % param
  op_CMP($reg_A, param)
end

$instructions[0xD0] = Proc.new do # BNE
  param = load_byte()
  # not sure if this is the correct way to disassemble
  puts "BNE $%02X" % param
  if !$flag_Z
    $reg_PC = get_relative_addr(param)
  end
end

$instructions[0xD8] = Proc.new do # CLD
  puts "CLD"
  $flag_D = false
end

$instructions[0xE0] = Proc.new do # CPX [Immediate]
  param = load_byte()
  puts "CPX \#$%02X" % param
  op_CMP($reg_X, param)
end

$instructions[0xE6] = Proc.new do # INC (Zero Page)
  param = load_byte()
  puts "INC $%02X" % param
  $memory[param] = byte_add($memory[param], 1)
  update_NZ_flags($memory[param])
end

$instructions[0xE8] = Proc.new do # INX
  puts "INX"
  $reg_X = byte_add($reg_X, 1)
  update_NZ_flags($reg_X)
end

$instructions[0xE9] = Proc.new do # SBC (Immediate)
  param = load_byte()
  puts "SBC \#$%02X" % param
  op_SBC(param)
end

$instructions[0xF0] = Proc.new do # BEQ
  param = load_byte()
  puts "BEQ $%02X" % param
  if $flag_Z
    $reg_PC = get_relative_addr(param)
  end
end

$instructions[0xF8] = Proc.new do # SED
  puts "SED"
  $flag_D = true
end
