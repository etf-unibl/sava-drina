import smbus

# Create an instance of the I2C bus
bus = smbus.SMBus(1)

# Codec I2C address
codec_address = 0x34

# Register addresses
LEFT_LINE_IN = 0x00
RIGHT_LINE_IN = 0x01
LEFT_HEADPHONE_OUT = 0x02
RIGHT_HEADPHONE_OUT = 0x03
ANALOGUE_AUDIO_PATH_CONTROL = 0x04
DIGITAL_AUDIO_PATH_CONTROL = 0x05
POWER_DOWN_CONTROL = 0x06
DIGITAL_AUDIO_INTERFACE_FORMAT = 0x07
SAMPLING_CONTROL = 0x08
ACTIVE_CONTROL = 0x09

# Configure the codec
# Set the left and right line input volume to 0db
bus.write_byte_data(codec_address, LEFT_LINE_IN, 0x17)
bus.write_byte_data(codec_address, RIGHT_LINE_IN, 0x17)

# Set the left and right headphone volume to 0db
bus.write_byte_data(codec_address, LEFT_HEADPHONE_OUT, 0x79)
bus.write_byte_data(codec_address, RIGHT_HEADPHONE_OUT, 0x79)

# Set the analogue audio path to DAC
bus.write_byte_data(codec_address, ANALOGUE_AUDIO_PATH_CONTROL, 0x05)

# Set the digital audio path to normal mode
bus.write_byte_data(codec_address, DIGITAL_AUDIO_PATH_CONTROL, 0x00)

# Power up the codec
bus.write_byte_data(codec_address, POWER_DOWN_CONTROL, 0x00)

# Set the digital audio interface format to I2S
bus.write_byte_data(codec_address, DIGITAL_AUDIO_INTERFACE_FORMAT, 0x12)

# Set the sampling control to 48kHz
bus.write_byte_data(codec_address, SAMPLING_CONTROL, 0x00)

# Activate the codec
bus.write_byte_data(codec_address, ACTIVE_CONTROL, 0x01)

#Read the register values for debugging
print("LEFT_LINE_IN : ",bus.read_byte_data(codec_address, LEFT_LINE_IN))
print("RIGHT_LINE_IN : ",bus.read_byte_data(codec_address, RIGHT_LINE_IN))
print("LEFT_HEADPHONE_OUT : ",bus.read_byte_data(codec_address, LEFT_HEADPHONE_OUT))
print("RIGHT_HEADPHONE_OUT : ",bus.read_byte_data(codec_address, RIGHT_HEADPHONE_OUT))
print("ANALOGUE_AUDIO_PATH_CONTROL : ",bus.read_byte_data(codec_address, ANALOGUE_AUDIO_PATH_CONTROL))
print("DIGITAL_AUDIO_PATH_CONTROL : ",bus.read_byte_data(codec_address, DIGITAL_AUDIO_PATH_CONTROL))
print("POWER_DOWN_CONTROL : ",bus.read_byte_data(codec_address, POWER_DOWN_CONTROL))
print("DIGITAL_AUDIO_INTERFACE_FORMAT : ",bus.read_byte_data(codec_address, DIGITAL_AUDIO_INTERFACE_FORMAT))
print("SAMPLING_CONTROL : ",bus.read_byte_data(codec_address, SAMPLING_CONTROL))
print("ACTIVE_CONTROL : ",bus.read_byte_data(codec_address, ACTIVE_CONTROL))
