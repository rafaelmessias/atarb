class TIA

  # Important addresses
  VSYNC = 0
  VBLANK = 1
  COLUBK = 9

  @color_clock = 0
  @beam_x = 160
  @beam_y = 192
  @vsync = false
  @vblank = false

  def self.start
    Rubygame.init
    # pixels are 3:2 (and we're drawing them x2)
    @screen = Rubygame::Screen.new [480,384]
    @screen.fill [0, 0, 0]
    @screen.update
  end

  def self.tick()
    #puts "beam_x = %d / beam_y = %d" % [@beam_x, @beam_y]
    # VSYNC checking/setting
    if !@vsync && ($memory[VSYNC] & 2) == 2
      @vsync = true
      @beam_x = -68
      @beam_y = -40
    elsif @vsync && ($memory[VSYNC] == 0)
      @vsync = false
    end
    # VBLANK checking/setting
    if !@vblank && ($memory[VBLANK] & 2) == 2
      @vblank = true
    elsif @vblank && ($memory[VBLANK] == 0)
      @vblank = false
    end
    # draw stuff (3 color clocks per tick)
    3.times do
      if @beam_x >= 0 && @beam_y >= 0
        color = [0, 0, 0]
        if !$memory[COLUBK].nil?
          lum = ($memory[COLUBK] & 15) * (256 / 15)
          color = [lum, lum, lum]
        end
        ((@beam_x * 3)..(@beam_x * 3 + 2)).each do |x|
          point = [x, @beam_y * 2]
          @screen.draw_box point, point, color
          point = [x, @beam_y * 2 + 1]
          @screen.draw_box point, point, color
        end
      end
      @beam_x += 1
      if @beam_x > 159
        @beam_x -= 228
        @beam_y += 1
        $wSync = false
      end
    end
    @screen.update
  end

end
