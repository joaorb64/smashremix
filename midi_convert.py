import os
from mido import MidiFile, MidiFile, MidiTrack

convertFiles = [f.split(".mid")[0]
                for f in os.listdir("src/music/") if f.endswith(".mid")]

for f in convertFiles:
    print(f"== CONVERTING {f} ==")

    mid = MidiFile(f"src/music/{f}.mid")
    midi_out = MidiFile()

    for track in mid.tracks:
        track_out = MidiTrack()

        for msg in track:
            if msg.type == 'program_change':
                old_program = msg.program

                if msg.program == 60:
                    msg.program = 66
                elif msg.program > 62:
                    msg.program += 4

                print(old_program, "=>", msg.program)
                track_out.append(msg)
        midi_out.tracks.append(track_out)

    mid.save(f"src/music/{f}.mid")
