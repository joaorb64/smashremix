import os
import sys

paths = ["src/Ryu/Moveset/", "src/Ken/Moveset/"]

for path in paths:
    for _file in os.listdir(path):
        print(f"> File: {path+_file}")

        if not os.path.isfile(path+_file):
            print("Skip")
            continue

        if os.path.islink(path+_file):
            print("Skip link")
            continue

        with open(path+_file, "rb") as f:
            bts = [b for b in f.read()]
            # print(bts)

        pos = 0

        while pos < len(bts):
            if hex(bts[pos]) in ["0x0c", "0x0d"]:
                pos += 20
                continue

            if hex(bts[pos]) in ["0x98", "0x9a"]:
                pos += 16
                continue

            if hex(bts[pos]) in ["0x44", "0x4c", "0x38"]:
                sound_id = int(f"{(bts[pos+2]):02X}{(bts[pos+3]):02X}", 16)

                if sound_id < 1282:
                    pos += 4
                    continue

                sound_id += 120
                print(
                    f"Play audio {(bts[pos+2]):02X}{(bts[pos+3]):02X} -> {(sound_id):04X}")

                sound_id_str = f"{(sound_id):04X}"

                bts[pos+2] = int(sound_id_str[0:2], 16)
                bts[pos+3] = int(sound_id_str[2:4], 16)

            pos += 4

        with open(path+_file, "wb") as f:
            f.write(bytes(bts))
