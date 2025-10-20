import sys
import numpy as np
from PIL import Image


def calculate_checksum(data_bytes):
    """Calculate Intel HEX checksum"""
    checksum = sum(data_bytes) & 0xFF
    return (0x100 - checksum) & 0xFF


def image_to_intel_hex(image_path, output_path):
    # Open the image and convert to grayscale
    img = Image.open(image_path).convert("L")
    width, height = img.size

    # Get pixel data
    pixels = list(img.getdata())

    # Write pixel data in Intel HEX format
    with open(output_path, "w") as f:
        address = 0x0000
        bytes_per_line = 16  # Standard Intel HEX line length

        for i in range(0, len(pixels), bytes_per_line):
            # Get the chunk of pixels for this line
            chunk = pixels[i : i + bytes_per_line]
            byte_count = len(chunk)

            # Create the data bytes array for checksum calculation
            data_bytes = [
                byte_count,
                (address >> 8) & 0xFF,  # High byte of address
                address & 0xFF,  # Low byte of address
                0x00,  # Data record type
            ] + [pixel & 0xFF for pixel in chunk]

            # Calculate checksum
            checksum = calculate_checksum(data_bytes)

            # Write the Intel HEX line
            line = f":{byte_count:02X}{address:04X}00"
            for pixel in chunk:
                line += f"{pixel & 0xFF:02X}"
            line += f"{checksum:02X}\n"

            f.write(line)
            address += byte_count

        # Write end of file record
        f.write(":00000001FF\n")

    print(f"Intel HEX file saved to {output_path}")


def main():
    if len(sys.argv) != 3:
        print("Usage: python convert_to_intel_hex.py <input_image> <output_hex_file>")
        sys.exit(1)
    image_to_intel_hex(sys.argv[1], sys.argv[2])


if __name__ == "__main__":
    main()
