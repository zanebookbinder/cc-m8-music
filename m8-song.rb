# Zane's song: Earthrise and Sunset

# play a background drum beat, with varied patterns and panning
define :drum_background do |i|
  sleep(0.6)
  sample :drum_heavy_kick, amp: 0.4, attack: 0, release: 0, pan: -1
  sleep(0.3)
  sample :drum_heavy_kick, amp: 0.4, attack: 0, release: 0, pan: 1
  sleep(0.6)
  
  # Switch up the beat a bit every 2nd and 4th measure
  if i == 0 or i == 2 then
    sample :drum_heavy_kick, amp: 0.4, attack: 0, release: 0, pan: -1
    sleep(0.3)
    sample :drum_heavy_kick, amp: 0.4, attack: 0, release: 0, pan: 1
    sleep(0.6)
  elsif i == 1 then
    sample :drum_heavy_kick, amp: 0.4, attack: 0, release: 0, pan: -1
    sleep(0.3)
    sample :drum_heavy_kick, amp: 0.4, attack: 0, release: 0, pan: 1
    sleep(0.3)
    sample :drum_heavy_kick, amp: 0.4, attack: 0, release: 0, pan: 1
    sleep(0.3)
  else
    sleep(0.6)
    sample :drum_heavy_kick, amp: 0.4, attack: 0, release: 0, pan: -1
    sleep(0.3)
  end
end

# Play a single base note when the 1st and 3rd chords are played
define :bass_note do |chord_to_play|
  use_synth :bass_foundation
  sleep(1.5)
  play invert_chord(chord_to_play, 2), amp: 0.7, attack: 0.2, release: 0.2
end

# Play a soft kalimba (African hand piano) melody
define :melody do |chord_to_play|
  use_synth :kalimba
  sleep(0.05)
  play chord_to_play, amp: 5
  sleep(0.8)
  play chord_to_play, amp: 5
  sleep(0.5)
end

# Play a smooth guero (South American percussion instrument) sound
define :guero do
  sample "/Users/zanebookbinder/Desktop/CC/cc-m8-music/guero.wav",
    start: 0.09,
    finish: 0.32,
    rate: 0.93,
    amp: 0.2
end

# Repeat the given chords three times (inverted differently each time)
define :play_chords_three_times do |chord_list, amp, cycles|
  loop_count = 0
  
  3.times do # 3 loops of all chords
    i = 0
    4.times do # four chords in each sequence
      
      # choose the correct chord from the list
      chord_to_play = chord_list[i]
      if loop_count > 0 then
        chord_to_play = invert_chord(chord_to_play, loop_count)
      end
      
      # play the main chord for the first two cycles
      if cycles < 2 then
        play chord_to_play, attack: 1.1, release: 1.1, amp: amp
      end
      
      # add base note for second cycle
      if cycles == 1 and (i == 0 or i == 2) then
        in_thread do
          bass_note chord_to_play
        end
      end
      
      # add guero for second cycle
      if cycles == 1 then
        in_thread do
          guero
        end
      end
      
      # add kalimba for second and third cycles
      if cycles >= 1 then
        in_thread do
          melody chord_to_play
        end
      end
      
      # always add drums
      drum_background i
      
      i += 1
    end
    
    loop_count += 1
  end
end

##| Notes that grow in amplitude and bird/wave sounds
define :slow_chords do |n_repeats, sound_to_play, starting_amplitudes, decrease_amp|
  main_chord_choices = [chord(:f, :major), chord(:c, :major), chord(:d, :major), chord(:b, :major)]
  pan = -1
  loop_count = 0
  go_right = true
  use_synth :dark_ambience
  main_chord = main_chord_choices.sample
  chord_to_play = chord(:d, :major)
  tempo = 60
  
  n_repeats.times do
    use_bpm tempo
    tempo -= 2
    
    # Choose a different note to play next (avoid repeats)
    new_note = chord_to_play
    while chord_to_play == new_note do
      new_note = [main_chord, invert_chord(main_chord, 1), invert_chord(main_chord, 2)].sample
    end
    
    chord_to_play = new_note
    
    # sample that gets louder over the course of the first minute
    sample sound_to_play,
      start: loop_count * 0.05,
      finish: loop_count * 0.05 + 0.05,
      amp: [0, rrand(0.15 * loop_count - 0.5, 0.15 * loop_count + 0.5)].max()
    
    # Repeat that note at varying amplitudes and pan values for 7.5 seconds
    30.times do
      if pan > 1 then
        pan = 1
      elsif pan < -1 then
        pan = -1
      end
      
      # increase volume when starting song
      random_amp = starting_amplitudes.collect{|n| n + (0.1 * loop_count)}.sample
      
      # decrease volume when ending song
      if decrease_amp then
        random_amp = [starting_amplitudes.collect{|n| n - (0.15 * loop_count)}.sample, 0.1].max()
      end
      
      play chord_to_play,
        pan: pan,
        amp: random_amp,
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


# Main Song Threads
#########################

# Thread for first minute of song
in_thread do
  slow_chords 8,
    "/Users/zanebookbinder/Desktop/CC/cc-m8-music/birds-chirping-sound.wav",
    [0.25, 0.5, 0.75],
    false
end

# Four-chord melodies (base for 2nd part of song)
in_thread do
  sleep(65)
  
  loop_count = 0
  first_chord_set = [chord(:b, :major), chord(:d, :major), chord(:c, :major), chord(:d, :major)]
  second_chord_set = [chord(:c, :major), chord(:d, :major), chord(:a, :major), chord(:b, :major)]

  # decrease the amplitude of the main note over time
  amplitudes = [1, 0.5, 0.3]
  3.times do
    use_synth :organ_tonewheel
    
    play_chords_three_times first_chord_set, amplitudes[loop_count], loop_count
    play_chords_three_times second_chord_set, amplitudes[loop_count], loop_count
    
    loop_count += 1
  end
end

# Thread for last minute of song
in_thread do
  sleep(234)
  slow_chords 8,
    "/Users/zanebookbinder/Desktop/CC/cc-m8-music/waves.wav",
    [1, 1.25, 1.5],
    true
end
