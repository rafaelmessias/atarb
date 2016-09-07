class PIA

  @timer_on = false
  @timer = 0
  @interval = 1024

  def self.start
    $memory[INTIM] = rand(256)
    @timer_on = true
  end

  def self.clock
    if @timer_on
      if $memory[INTIM] >= 0
        @timer -= 1
        if @timer <= 0
          $memory[INTIM] -= 1
          @timer += @interval
        end
      else
        # this is obviously not right, but it'll do for now
        $memory[INTIM] = 0xFF
        @timer_on = false
      end
    end
  end

end
