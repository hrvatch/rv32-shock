#!/usr/bin/env python3
import serial
import sys
import os
import time
import argparse

# Parse command line arguments
parser = argparse.ArgumentParser(description='Upload binary to RISC-V bootloader via UART')
parser.add_argument('-f', '--file', required=True, help='Binary file to upload')
parser.add_argument('-d', '--device', required=True, help='Serial device (e.g., /dev/ttyUSB0)')
parser.add_argument('-b', '--baud', type=int, default=115200, help='Baud rate (default: 115200)')
args = parser.parse_args()

binary_file = args.file
serial_port = args.device
baud_rate = args.baud

# Check if file exists
if not os.path.exists(binary_file):
    print(f"Error: File '{binary_file}' not found")
    sys.exit(1)

# Open and read binary file
with open(binary_file, 'rb') as f:
    data = f.read()

file_size = len(data)
print(f"File size: {file_size} bytes")

# Pad to 16KB (16384 bytes) with zeros
if len(data) < 16384:
    padding = 16384 - len(data)
    data += b'\x00' * padding
    print(f"Padded with {padding} zero bytes to 16KB")

# Open serial port
try:
    port = serial.Serial(serial_port, baud_rate, timeout=0.1)
    print(f"Opened {serial_port} at {baud_rate} baud")
except serial.SerialException as e:
    print(f"Error opening serial port: {e}")
    sys.exit(1)

# Clear any stale data
port.reset_input_buffer()

# Send 'R' trigger
print("Sending 'R' trigger...")
port.write(b'R')

print("Uploading program...")
sys.stdout.write("Progress: ")
sys.stdout.flush()

# Send data in 1KB chunks, wait for dot after each chunk
chunk_size = 1024
timeout_seconds = 5

for i in range(0, len(data), chunk_size):
    chunk = data[i:i+chunk_size]
    port.write(chunk)
    port.flush()
    
    # Wait for dot with timeout
    start_time = time.time()
    dot_received = False
    
    while time.time() - start_time < timeout_seconds:
        if port.in_waiting > 0:
            char = port.read(1)
            if char == b'.':
                sys.stdout.write('.')
                sys.stdout.flush()
                dot_received = True
                break
        time.sleep(0.01)
    
    if not dot_received:
        sys.stdout.write(f"\nError: Timeout waiting for progress indicator after {i + len(chunk)} bytes\n")
        sys.stdout.flush()
        port.close()
        sys.exit(1)

sys.stdout.write("\nUpload complete! Program should now be executing...\n")
port.close()
