
require "wavefile"

OUTPUT_FILENAME = "mysound.wav"
SAMPLE_RATE = 44100
SECONDS_TO_GENERATE = 1
TWO_PI = 2 * Math::PI
RANDOM_GENERATOR = Random.new

def main
  # Read the command-line arguments.
  waveform = ARGV[0].to_sym  # Should be "sine", "square", "saw", "triangle", or "noise"
  frequency = ARGV[1].to_f   # 440.0 is the same as middle-A on a piano.
  amplitude = ARGV[2].to_f   # Should be between 0.0 (silence) and 1.0 (full volume).
                             # Amplitudes above 1.0 will result in clipping distortion.

  # Generate sample data at the given frequency and amplitude.
  # The sample rate indicates how many samples we need to generate for
  # 1 second of sound.
  num_samples = SAMPLE_RATE * SECONDS_TO_GENERATE
  samples = generate_sample_data(waveform, num_samples, frequency, amplitude)

  # Wrap the array of samples in a Buffer, so that it can be written to a Wave file
  # by the WaveFile gem. Since we generated samples with values between -1.0 and 1.0,
  # the sample format should be :float
  buffer = WaveFile::Buffer.new(samples, WaveFile::Format.new(:mono, :float, SAMPLE_RATE))

  # Write the Buffer containing our samples to a monophonic Wave file
  WaveFile::Writer.new(OUTPUT_FILENAME, WaveFile::Format.new(:mono, :pcm_16, SAMPLE_RATE)) do |writer|
    writer.write(buffer)
  end
end

# The dark heart of NanoSynth, the part that actually generates the audio data
def generate_sample_data(waveform, num_samples, frequency, amplitude)
  position_in_period = 0.0
  position_in_period_delta = frequency / SAMPLE_RATE

  # Initialize an array of samples set to 0.0. Each sample will be replaced with
  # an actual value below.
  samples = [].fill(0.0, 0, num_samples)

  num_samples.times do |i|
    # Add next sample to sample list. The sample value is determined by
    # plugging position_in_period into the appropriate wave function.
    if waveform == :sine
      samples[i] = Math::sin(position_in_period * TWO_PI) * amplitude
    elsif waveform == :square
      samples[i] = (position_in_period >= 0.5) ? amplitude : -amplitude
    elsif waveform == :saw
      samples[i] = ((position_in_period * 2.0) - 1.0) * amplitude
    elsif waveform == :triangle
      samples[i] = amplitude - (((position_in_period * 2.0) - 1.0) * amplitude * 2.0).abs
    elsif waveform == :noise
      samples[i] = RANDOM_GENERATOR.rand(-amplitude..amplitude)
    end

    position_in_period += position_in_period_delta

    # Constrain the period between 0.0 and 1.0.
    # That is, keep looping and re-looping over the same period.
    if position_in_period >= 1.0
      position_in_period -= 1.0
    end
  end

  samples
end
main
