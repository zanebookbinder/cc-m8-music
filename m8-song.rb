# Zane's song

##| - 60bpm --> 50bpm
##| - a constant background sound
##| - gentle notes (maybe pan-flute or piano)
##| - flowing sensation across the notes
##| - pan from left to right and back and forth (-1 to 1)
##| - at least 5 minutes

##| What I've implemented so far
##| -panning from left to right (back and forth infinitely)
##| -random notes (cmajor or inverted cmajor) that each:
##|      -play for about 7.5 seconds at random amplitudes
##|      -slow down in tempo throughout the first minute of the song
##|      -get slightly louder over the course of 1 minute

tempo = 60

# TRY EACH OF THESE AND SEE WHAT WORKS
main_chord_choices = [chord(:c, :major), chord(:d, :major), chord(:b, :major)]

# ADD BIRD SOUNDS IN THIRD AND FOURTH LOOPS


in_thread do
  pan = -1
  loop_count = 0
  starting_amplitudes = [0.25, 0.5, 0.75]
  go_right = true
  use_synth :dark_ambience
  main_chord = main_chord_choices.sample
  chord_to_play = chord(:d, :major)
  
  live_loop :repeat_base_note do
    use_bpm tempo
    tempo -= 2
    
    # Choose a different note to play next
    new_note = chord_to_play
    while chord_to_play == new_note do
      new_note = [main_chord, invert_chord(main_chord, 1), invert_chord(main_chord, 2)].sample
    end
    
    chord_to_play = new_note
    
    # INCREASE THE AMPLITUDE OF THIS DURING THE FIRST MINUTE
    sample "/Users/zanebookbinder/Desktop/CC/cc-m8-music/birds-chirping-sound.wav",
      start: loop_count * 0.05,
      finish: loop_count * 0.05 + 0.05,
      amp: [0, rrand(0.15 * loop_count - 0.5, 0.15 * loop_count + 0.5)].max()
    
    # Repeat that note at varying amplitudes and pans for 7.5 seconds
    30.times do
      if pan > 1 then
        pan = 1
      elsif pan < -1 then
        pan = -1
      end
      
      play chord_to_play,
        pan: pan,
        amp: starting_amplitudes.collect{|n| n + (0.1 * loop_count)}.sample,
        attack: 1,
        release: 1
      
      # Handle infinite panning from (-1 to 1 then back to -1)
      if go_right then
        if pan >= 1 then
          go_right = false
          pan -= 0.01
        else
          pan += 0.01
        end
      else
        if pan <= -1 then
          go_right = true
          pan += 0.01
        else
          pan -= 0.01
        end
      end
      
      sleep(0.25)
    end
    loop_count += 1
  end
end