# Zane's song

tempo = 60

define :play_chords_three_times do |chord_list, amp|
  loop_count = 0
  
  3.times do
    i = 0
    4.times do
      chord_to_play = chord_list[i]
      if loop_count > 0 then
        chord_to_play = invert_chord(chord_to_play, loop_count)
      end
      
      play chord_to_play, attack: 1.1, release: 1.1, amp: amp
      
      sleep(0.6)
      sample :drum_heavy_kick, amp: 0.4, attack: 0, release: 0, pan: -1
      sleep(0.3)
      sample :drum_heavy_kick, amp: 0.4, attack: 0, release: 0, pan: 1
      sleep(0.6)
      sample :drum_heavy_kick, amp: 0.4, attack: 0, release: 0, pan: -1
      sleep(0.3)
      
      # Switch up the beat a bit every 4th note
      if i < 3 then
        sample :drum_heavy_kick, amp: 0.4, attack: 0, release: 0, pan: 1
        sleep(0.6)
      else
        sample :drum_heavy_kick, amp: 0.4, attack: 0, release: 0, pan: 1
        sleep(0.3)
        sample :drum_heavy_kick, amp: 0.4, attack: 0, release: 0, pan: 1
        sleep(0.3)
      end
      
      i += 1
    end
    
    loop_count += 1
  end
end

# Four-chord melodies (base for 2nd part of song)
in_thread do
  ##| sleep(65)
  
  loop_count = 0
  amplitudes = [1, 0.5] + Array.new(50, 0.3)
  live_loop :enlivening_chords do
    use_synth :organ_tonewheel
    
    chord_order = [chord(:b, :major), chord(:d, :major), chord(:c, :major), chord(:d, :major)]
    play_chords_three_times chord_order, amplitudes[loop_count]
    
    more_chords = [chord(:c, :major), chord(:d, :major), chord(:a, :major), chord(:b, :major)]
    play_chords_three_times more_chords, amplitudes[loop_count]
    
    loop_count += 1
  end
end


##| Bird songs and notes that grow in amplitude
in_thread do
  
  sleep(10000)
  
  main_chord_choices = [chord(:f, :major), chord(:c, :major), chord(:d, :major), chord(:b, :major)]
  pan = -1
  loop_count = 0
  starting_amplitudes = [0.25, 0.5, 0.75]
  go_right = true
  use_synth :dark_ambience
  main_chord = main_chord_choices.sample
  chord_to_play = chord(:d, :major)
  
  8.times do
    use_bpm tempo
    tempo -= 2
    
    # Choose a different note to play next
    new_note = chord_to_play
    while chord_to_play == new_note do
      new_note = [main_chord, invert_chord(main_chord, 1), invert_chord(main_chord, 2)].sample
    end
    
    chord_to_play = new_note
    
    # sample of birds chirping that gets louder over the course of the first minute
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

