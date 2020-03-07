require "wavefile"
include WaveFile    # To avoid prefixing classes with "WaveFile::"

FILES_TO_APPEND = ["c-sine.wav", "f-sine.wav", "g-sine.wav"]
OUTPUT_FORMAT = Format.new(:stereo, :pcm_16, 44100)

Writer.new("cfg.wav", OUTPUT_FORMAT) do |writer|
  FILES_TO_APPEND.each do |file_name|
    Reader.new(file_name).each_buffer do |buffer|
      writer.write(buffer)
    end
  end
end
