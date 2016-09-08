# Memory
$memory = {}

# 16-bit Program Counter
$reg_PC = 0xF000

# 8-bit Processor registers
$reg_X = 0
$reg_Y = 0
$reg_A = 0
$reg_SP = 0

# Processor flags
$flag_Int = false
$flag_D = false
$flag_N = false
$flag_Z = false
$flag_C = false

# Load next byte from cartridge
def fetch()
  byte = $memory[$reg_PC]
  $reg_PC += 1
  byte
end

def stack_push(byte)
  $memory[$reg_SP] = byte
  $reg_SP -=1
end

def stack_pull()
  $reg_SP += 1
  $memory[$reg_SP]
end

def byte_add(b1, b2)
  (b1 + b2) % 256
end

def get_absolute_addr(low, high)
  high * 256 + low
end

def get_relative_addr(byte)
  if byte > 0x7F
    byte = -(0xFF - byte + 1)
  end
  $reg_PC + byte
end

def get_indirect_x(byte)
  addr = byte + $reg_X
  $memory[addr] + $memory[addr + 1] * 256
end

def get_indirect_y(byte)
  addr = $memory[byte] + $memory[byte + 1] * 256
  addr + $reg_Y
end

def update_NZ_flags(value)
  $flag_N = value > 127
  $flag_Z = value == 0
end

def op_ASL(byte)
  $flag_C = !(byte & 128).zero?
  byte = (byte << 1) % 256
  update_NZ_flags(byte)
  byte
end

def op_AND(byte)
  $reg_A &= byte
  update_NZ_flags($reg_A)
end

def op_ADC(byte)
  # TODO: correctly handle flags D and V
  if $reg_D
    puts "Called ADC with reg_D set; can't handle this yet. Sorry."
    exit(-1)
  end
  aux = $reg_A + byte + ($flag_C ? 1 : 0)
  $flag_C = aux > 256
  $reg_A = aux % 256
  update_NZ_flags($reg_A)
end

def op_SBC(byte)
  # TODO: correctly use D and V flags
  aux = $reg_A - byte - ($flag_C ? 0 : 1)
  # TODO: is this really how you set the C flag?
  $flag_C = !(aux < 0)
  $reg_A = aux % 256
  update_NZ_flags($reg_A)
end

def op_CMP(reg, byte)
  # TODO: there must be a better way to do this
  if reg < byte
    $flag_N = true
    $flag_Z = false
    $flag_C = false
  elsif reg == byte
    $flag_N = false
    $flag_Z = true
    $flag_C = true
  else # reg > byte
    $flag_N = false
    $flag_Z = false
    $flag_C = true
  end
end

def op_EOR(byte)
  $reg_A ^= byte
  update_NZ_flags($reg_A)
end

def op_DEC(value)
  value = byte_add(value, -1)
  update_NZ_flags(value)
  value
end

def op_LDA(byte)
  $reg_A = byte
  update_NZ_flags($reg_A)
end

def op_ORA(byte)
  $reg_A |= byte
  update_NZ_flags($reg_A)
end

def op_LSR(byte)
  $flag_C = !(byte % 2).zero?
  byte >>= 1
  update_NZ_flags(byte)
  byte
end

def op_ROL(byte)
  aux_C = !(byte & 128).zero?
  byte = (byte << 1) + ($flag_C ? 1 : 0)
  $flag_C = aux_C
  byte
end
