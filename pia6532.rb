
# Question: what happens if I read from 0x294-0x297?
# Question: what happens if I write 0 to a timer?
#
# TODO TIMINT should be cleared when read
# TODO the first decrement is 1 cycle after a timer is set

class PIA

  # Mnemonics
  SWCHB = 0x282
  SWCHA = 0x280
  INTIM = 0x284
  TIMINT = 0x285
  TIM1T = 0x294
  TIM8T = 0x295
  TIM64T = 0x296
  T1024T = 0x297

  @timer = 0
  @interval = 1024
  @intervals = {
    TIM1T => 1,
    TIM8T => 8,
    TIM64T => 64,
    T1024T => 1024
  }


  def self.start
    $memory[INTIM] = rand(256)
    $memory[TIMINT] = 0
    $memory[SWCHA] = 0b11111111
    $memory[SWCHB] = 0b00111111
    @intervals.each_key do |k|
      $memory[k] = 0
    end
  end

  def self.tick
    # Start by checking if a timer was just set
    @intervals.each_key do |k|
      if $memory[k] > 0
        # TODO setting the timer to 1 is a temporary hack; fix
        @timer = 1
        @interval = @intervals[k]
        $memory[INTIM] = $memory[k]
        $memory[TIMINT] = 0
      end
      # These must always be cleared at every tick (right?)
      $memory[k] = 0
    end
    # Then proceed with counting down
    if $memory[TIMINT] == 0
      if $memory[INTIM] >= 0
        @timer -= 1
        if @timer <= 0
          $memory[INTIM] -= 1
          @timer += @interval
        end
      else
        # this is obviously not right, but it'll do for now
        $memory[INTIM] = 0xFF
        $memory[TIMINT] = 128
        @interval = 1
      end
    end
  end

end
