import re
import os
import struct
import math
from collections import defaultdict
import csv
import json
import pandas as pd


def dict_of_dicts_to_csv(data, csv_file):
    df = pd.DataFrame.from_dict(data, orient='index')
    df.to_csv(csv_file)


data_size = {
    "f32": 32,
    "s8": 8,  # Signed  8-bit boolean
    "s16": 16,  # Signed 16-bit boolean
    "s32": 32,  # Signed 32-bit boolean
    "u8": 4,  # Unsigned  8-bit boolean
    "u16": 8,  # Unsigned 16-bit boolean
    "u32": 16,  # Unsigned 32-bit boolean
    "ftHurtboxDesc": 32 + 32 + 16 + 32*3 + 32*3
}

mapping = [
    ("f32", "size_mul"),
    ("f32", "walkslow_anim_speed"),
    ("f32", "walkmiddle_anim_speed"),
    ("f32", "walkfast_anim_speed"),
    ("f32", "throw_walkslow_anim_speed"),
    ("f32", "throw_walkmiddle_anim_speed"),
    ("f32", "throw_walkfast_anim_speed"),  # Cargo Throw
    ("f32", "rebound_anim_length"),
    ("f32", "walk_speed_mul"),
    ("f32", "traction"),
    ("f32", "dash_speed"),
    ("f32", "dash_decelerate"),
    ("f32", "run_speed"),
    ("f32", "kneebend_length"),  # Jump squat frames
    ("f32", "jump_vel_x"),
    ("f32", "jump_height_mul"),
    ("f32", "jump_height_base"),
    ("f32", "aerial_jump_vel_x"),
    ("f32", "aerial_jump_height"),
    ("f32", "aerial_acceleration"),
    ("f32", "aerial_speed_max_x"),
    ("f32", "aerial_friction"),
    ("f32", "gravity"),
    ("f32", "fall_speed_max"),
    ("f32", "fast_fall_speed"),
    ("s32", "jumps_max"),  # Number of jumps
    ("f32", "weight"),
    ("f32", "attack1_followup_frames"),  # Jab combo connection frames
    ("f32", "dash_to_run"),  # Frames before dash transitions to run?
    ("f32", "shield_size"),
    ("f32", "shield_break_vel_y"),
    ("f32", "shadow_size"),
    ("f32", "jostle_width"),  # ???
    ("f32", "jostle_x"),
    ("s32", "is_metallic"),  # So far only seen this used to determine whether the character makes blue sparks or gray metal dust particles when hit; used by Metal Mario and Samus
    ("f32", "cam_offset_y"),
    ("f32", "closeup_cam_zoom"),
    ("f32", "cam_zoom"),
    ("f32", "cam_zoom_default"),
    ("f32", "object_coll_top"),
    ("f32", "object_coll_center"),
    ("f32", "object_coll_bottom"),
    ("f32", "object_coll_width"),
    ("f32", "cliff_catch_x"),  # Ledge grab box
    ("f32", "cliff_catch_y"),  # Ledge grab box
    ("u16", "dead_sfx[0]"),  # KO voices
    ("u16", "dead_sfx[1]"),  # KO voices
    ("u16", "deadup_sfx"),  # Star-KO voice
    ("u16", "damage_sfx"),
    ("u16", "smash_sfx[0]"),  # Random Smash SFX
    ("u16", "smash_sfx[1]"),  # Random Smash SFX
    ("u16", "smash_sfx[2]"),  # Random Smash SFX
    # ( "#" s16 unk_0xC2",;"),
    ("f32", "item_pickup-pickup_offset_light_x"),
    ("f32", "item_pickup-pickup_offset_light_y"),
    ("f32", "item_pickup-pickup_range_light_x"),
    ("f32", "item_pickup-pickup_range_light_y"),
    ("f32", "item_pickup-pickup_offset_heavy_x"),
    ("f32", "item_pickup-pickup_offset_heavy_y"),
    ("f32", "item_pickup-pickup_range_heavy_x"),
    ("f32", "item_pickup-pickup_range_heavy_y"),
    ("s16", "item_throw_vel"),
    ("s16", "item_throw_mul"),
    ("u16", "throw_heavy_sfx"),
    ("u16", "unk_0xEA"),
    ("f32", "halo_size"),  # Respawn platform size?
    ("u8", "shade_color[0]_r"),
    ("u8", "shade_color[0]_g"),
    ("u8", "shade_color[0]_b"),
    ("u8", "shade_color[0]_a"),
    ("u8", "shade_color[1]_r"),
    ("u8", "shade_color[1]_g"),
    ("u8", "shade_color[1]_b"),
    ("u8", "shade_color[1]_a"),
    ("u8", "shade_color[2]_r"),
    ("u8", "shade_color[2]_g"),
    ("u8", "shade_color[2]_b"),
    ("u8", "shade_color[2]_a"),
    ("u8", "shade_color[3]_r"),
    ("u8", "shade_color[3]_g"),
    ("u8", "shade_color[3]_b"),
    ("u8", "shade_color[3]_a"),
    ("u32", "is_have_flags"),
    ("ftHurtboxDesc", "fighter_hurt_desc[0]"),
    ("ftHurtboxDesc", "fighter_hurt_desc[0]"),
    ("ftHurtboxDesc", "fighter_hurt_desc[0]"),
    ("ftHurtboxDesc", "fighter_hurt_desc[0]"),
    ("ftHurtboxDesc", "fighter_hurt_desc[0]"),
    ("ftHurtboxDesc", "fighter_hurt_desc[0]"),
    ("ftHurtboxDesc", "fighter_hurt_desc[0]"),
    ("ftHurtboxDesc", "fighter_hurt_desc[0]"),
    ("ftHurtboxDesc", "fighter_hurt_desc[0]"),
    ("ftHurtboxDesc", "fighter_hurt_desc[0]"),
    ("ftHurtboxDesc", "fighter_hurt_desc[10]"),
    # This is a radius around the fighter within which hitbox detection can occur
    ("f32", "hit_detect_range[0]"),
    # This is a radius around the fighter within which hitbox detection can occur
    ("f32", "hit_detect_range[1]"),
    # This is a radius around the fighter within which hitbox detection can occur
    ("f32", "hit_detect_range[2]"),
    ("s32", "unk_ftca_0x29C"),
    ("ftPartsUnkIndexTable", *"unk_ftca_0x2A0"),
    # The game will cycle through these joints when applying certain particles such as electricity and flames
    ("s32", "gfx_joint_cycle_index[0]"),
    ("s32", "gfx_joint_cycle_index[0]"),
    ("s32", "gfx_joint_cycle_index[0]"),
    ("s32", "gfx_joint_cycle_index[0]"),
    ("s32", "gfx_joint_cycle_index[4]"),
    ("sb32", "cliff_status_ground_air_id[0]"),
    ("sb32", "cliff_status_ground_air_id[0]"),
    ("sb32", "cliff_status_ground_air_id[0]"),
    ("sb32", "cliff_status_ground_air_id[0]"),
    ("sb32", "cliff_status_ground_air_id[4]"),
    ("u8", "filler_0x2CC[0]"),
    ("u8", "filler_0x2CC[1]"),
    ("u8", "filler_0x2CC[2]"),
    ("u8", "filler_0x2CC[3]"),
    ("ftPartIndex", "p_ftpart_lookup"),
    ("DObjDescContainer", "dobj_desc_container"),
    # WARNING: Not actually DObjDesc* but I don't know what this struct is or what its bounds are; bunch of consecutive floats
    ("DObjDesc", "dobj_lookup"),
    ("s32", "unk_join[0]"),
    ("s32", "unk_join[1]"),
    ("s32", "unk_join[2]"),
    ("s32", "unk_join[3]"),
    ("s32", "unk_join[4]"),
    ("s32", "unk_join[5]"),
    ("s32", "unk_join[6]"),
    ("s32", "unk_join[7]"),
    ("s32", "joint_index1"),  # What does this do?
    ("f32", "joint_float1"),
    ("s32", "joint_index2"),
    ("f32", "joint_float2"),
    ("u8", "filler_0x304[0]"),
    ("u8", "filler_0x304[1]"),
    ("u8", "filler_0x304[2]"),
    ("u8", "filler_0x304[3]"),
    ("u8", "filler_0x304[4]"),
    ("u8", "filler_0x304[5]"),
    ("u8", "filler_0x304[6]"),
    ("u8", "filler_0x304[7]"),
    ("u8", "filler_0x304[8]"),
    ("u8", "filler_0x304[9]"),
    ("f32", "unk_0x31C"),
    ("f32", "unk_0x320"),
    # Pointer to some array of vectors, something to do with joints
    ("Vec3f", "unk_0x324"),
    ("ftModelPartContainer", "model_parts"),
    ("UnkFighterDObjData", "unk_0x32C"),
    ("ftTexturePartContainer", "texture_parts"),
    ("s32", "joint_itemhold_heavy"),
    ("ftThrownStatusArray", "thrown_status"),
    ("s32", "joint_itemhold_light"),
    ("ftSprites", "sprites"),
    ("ftSkeleton", "skeleton"),
]


def hex_to_float(hex_string):
    # Convert hexadecimal string to 32-bit integer
    hex_int = int(hex_string, 16)

    # Pack the integer into 4 bytes (little-endian) and unpack it as a single-precision float
    float_value = struct.unpack('<f', struct.pack('<I', hex_int))[0]

    return float_value


def find_last_instance_of_pattern(binary_data, pattern):
    last_position = -1
    for i in range(len(binary_data) - len(pattern) + 1):
        if binary_data[i:i + len(pattern)] == pattern:
            last_position = i
    return last_position


def extract_constants(file_path):
    constants_map = {}
    pattern = r'constant\s+(\w+_MAIN)\((0x[0-9a-fA-F]+)\)'

    with open(file_path, 'r') as file:
        for line in file:
            match = re.search(pattern, line)
            if match:
                name = match.group(1).replace("_MAIN", "")
                value = match.group(2)
                constants_map[name] = f"{value[2:]:0>4}"

    return constants_map


def extract_original_constants(original_path):
    constants_map = {}
    pattern = r'([0-9a-fA-F]+).*-\s(\w+ Main Character)'

    with open(original_path, 'r') as file:
        for line in file:
            match = re.search(pattern, line)
            if match:
                name = match.group(2).replace(" Main Character", "")
                value = match.group(1)

                if value == "0853":
                    break

                constants_map[name] = f"{value}"

    return constants_map


def process_binary_files(constants_map):
    characters = defaultdict(dict)

    pattern = b'\x00\x64\x00\x64'  # Pattern to search for (little-endian)

    for name, value in constants_map.items():
        binary_file_path = os.path.join(
            'build', 'exported', f"{value}.bin")
        if os.path.exists(binary_file_path):
            with open(binary_file_path, 'rb') as binary_file:
                binary_data = binary_file.read()
                last_position = find_last_instance_of_pattern(
                    binary_data, pattern)
                print(
                    f"Last instance of pattern 00640064 in '{binary_file_path}' ({name}): {hex(last_position - 228)}")

                global_pos = last_position - 228
                pos = global_pos

                for i in range(len(mapping)):
                    datasize = int(
                        math.log2(data_size.get(mapping[i][0], 16))-1)

                    values = binary_data[pos:pos+datasize]

                    hex_val_str = ''.join(
                        [f'{hex(v)[2:]:0>2}' for v in values])

                    if mapping[i][1].startswith("is_have_"):
                        print("is have...")

                        pos += int(
                            math.log2(data_size.get(mapping[i][0], 16))-1)

                        # ("u32", "attack11"),
                        # ("u32", "is_have_attack12"),
                        # ("u32", "is_have_attackdash"),
                        # ("u32", "is_have_attacks3"),
                        # ("u32", "is_have_attackhi3"),
                        # ("u32", "is_have_attacklw3"),
                        # ("u32", "is_have_attacks4"),
                        # ("u32", "is_have_attackhi4"),
                        # ("u32", "is_have_attacklw4"),
                        # ("u32", "is_have_attackairn"),
                        # ("u32", "is_have_attackairf"),
                        # ("u32", "is_have_attackairb"),
                        # ("u32", "is_have_attackairhi"),
                        # ("u32", "is_have_attackairlw"),
                        # ("u32", "is_have_specialn"),
                        # ("u32", "is_have_specialairn"),
                        # ("u32", "is_have_specialhi"),
                        # ("u32", "is_have_specialairhi"),
                        # ("u32", "is_have_speciallw"),
                        # ("u32", "is_have_specialairlw"),
                        # ("u32", "is_have_catch"),
                        # ("u32", "is_have_voice"),
                    elif mapping[i][0] == "ftHurtboxDesc":
                        print(f"ftHurtboxDesc ({hex_val_str})")

                        pos += 3 + 3 + 3 + 3*3 + 3*3
                    else:
                        if mapping[i][0] == "s32":
                            try:
                                print(
                                    f"{mapping[i][1]}: ({hex_val_str}) = {float(hex_val_str)}")
                                characters[name][mapping[i]
                                                 [1]] = float(hex_val_str)
                            except:
                                print(
                                    f"{mapping[i][1]}: ({hex_val_str}) = ???")
                                characters[name][mapping[i][1]] = "???"
                        else:
                            try:
                                print(
                                    f"{mapping[i][1]}: ({hex_val_str}) = {hex_to_float(hex_val_str)}")
                                characters[name][mapping[i][1]
                                                 ] = hex_to_float(hex_val_str)
                            except:
                                print(
                                    f"{mapping[i][1]}: ({hex_val_str}) = ???")
                                characters[name][mapping[i][1]
                                                 ] = "???"

                        pos += int(
                            math.log2(data_size.get(mapping[i][0], 16))-1)

    return characters


file_path = 'src/File.asm'
constants_map = extract_constants(file_path)
file_path = 'build/exported/table offsets.txt'
constants_map.update(extract_original_constants(file_path))
print(constants_map)
characters = process_binary_files(constants_map)
print(characters)

# Convert JSON to CSV
dict_of_dicts_to_csv(characters, "char_data.csv")
