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

# Question: what happens if I read from 0x294-0x297?
# Question: what happens if I write 0 to a timer?
# Question: do the TIM*T addresses keep their last-written values?
# TODO TIMINT should be cleared when read

# TODO Ticking every clock can be a problem... if a timer was set, then
#   it will immediately count down X-1 ticks, with X being the size of
#   the write instruction. The correct way is: if there was a timer set,
#   then that should be the only thing to be done for that specific
#   "round" (with "round" being the set of X ticks).

class PIA

  # Important Addresses
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
    @timer -= 1
    # Start by checking if a timer was just set
    @intervals.each_key do |k|
      if $memory[k] > 0
        @timer = 0
        @interval = @intervals[k]
        $memory[INTIM] = $memory[k]
        $memory[TIMINT] = 0
        # TODO Wrong.
        $memory[k] = 0
      end
    end
    # Then keep counting down normally
    if @timer < 0
      $memory[INTIM] -= 1
      if $memory[INTIM] < 0
        $memory[INTIM] = 0xFF
        $memory[TIMINT] = 128
        @interval = 1
        @timer = 0
      else
        @timer += @interval
      end
    end
  end

end
