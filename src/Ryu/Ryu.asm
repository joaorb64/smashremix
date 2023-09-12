// Ryu.asm

// This file contains file inclusions, action edits, and assembly for Ryu.

scope Ryu {

	scope FACE: {
		constant NORMAL(0xAC000000)
		constant SHOCK(0xAC000006)
	}

    // Insert Moveset files
    insert IDLE,"moveset/IDLE.bin"
    insert RUN,"moveset/RUN.bin"; Moveset.GO_TO(RUN)            // loops
    insert JUMP2, "moveset/JUMP2.bin"
    insert TECHSTAND, "moveset/TECHSTAND.bin"
    insert TECHROLL, "moveset/TECHFROLL.bin"
    insert EDGEATTACKF, "moveset/EDGEATTACKF.bin"
    insert EDGEATTACKS, "moveset/EDGEATTACKS.bin"
    insert TAUNT,"moveset/TAUNT.bin"
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)         // loops
    insert JAB_1,"moveset/JAB_1.bin"
    insert DASH_ATTACK,"moveset/DASH_ATTACK.bin"
    insert FTILT_HI,"moveset/FORWARD_TILT_HIGH.bin"
    insert FTILT_M_HI,"moveset/FORWARD_TILT_MID_HIGH.bin"
    insert FTILT_L,"moveset/FORWARD_TILT.bin"
    insert FTILT_M_LO,"moveset/FORWARD_TILT_MID_LOW.bin"
    insert FTILT_LO,"moveset/FORWARD_TILT_LOW.bin"
    insert UTILT_L,"moveset/UP_TILT.bin"
    insert DTILT_L,"moveset/DOWN_TILT.bin"
    insert FSMASH,"moveset/FORWARD_SMASH.bin"
    insert USMASH,"moveset/UP_SMASH.bin"
    insert DSMASH,"moveset/DOWN_SMASH.bin"
    insert NAIR,"moveset/NEUTRAL_AERIAL.bin"
    insert FAIR,"moveset/FORWARD_AERIAL.bin"
    insert BAIR,"moveset/BACK_AERIAL.bin"
    insert UAIR,"moveset/UP_AERIAL.bin"
    insert DAIR,"moveset/DOWN_AERIAL.bin"
    insert NSP_GROUND,"moveset/NSP_GROUND.bin"
    insert NSP_AIR,"moveset/NSP_AIR.bin"
    insert USP_L,"moveset/SHORYUKEN_L.bin"
    insert DSP_GROUND,"moveset/DOWN_SPECIAL_GROUND.bin"
    insert DSP_FLIP,"moveset/DOWN_SPECIAL_FLIP.bin"
    insert DSP_LAND,"moveset/DOWN_SPECIAL_LANDING.bin"
    insert DSP_AIR,"moveset/DOWN_SPECIAL_AIR.bin"
    insert VICTORY_POSE_1,"moveset/VICTORY_POSE_1.bin"
    insert VICTORY_POSE_2,"moveset/VICTORY_POSE_2.bin"
    insert VICTORY_POSE_3,"moveset/VICTORY_POSE_3.bin"
	insert ONEP,"moveset/ONEP.bin"
	insert ENTRY_1,"moveset/ENTRY_1.bin"
	insert ENTRY_2,"moveset/ENTRY_2.bin"
    insert DOWN_STAND,"moveset/DOWN_STAND.bin"
    insert ROUNDHOUSE,"moveset/ROUNDHOUSE.bin"
    insert DTILT_H,"moveset/DOWN_TILT_H.bin"
    insert UTILT_H,"moveset/UP_TILT_H.bin"
    insert FTILT_H,"moveset/FORWARD_TILT_H.bin"
    insert ENTRY,"moveset/ENTRY.bin"

    TEETER:
    dw FACE.SHOCK; dw 0;

	DOWN_BOUNCE:
	dw FACE.SHOCK
	Moveset.GO_TO(Moveset.shared.DOWN_BOUNCE)

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(RYU,   Action.Idle,            -1,                         IDLE,                       -1)
    Character.edit_action_parameters(RYU,   Action.Run,             -1,                         RUN,                        -1)
    Character.edit_action_parameters(RYU,   Action.Dash,            File.RYU_DASH,              -1,                         -1)
    Character.edit_action_parameters(RYU,   Action.Teeter,          -1,                         TEETER,                     -1)
    Character.edit_action_parameters(RYU,   Action.JumpAerialF,     -1,                         JUMP2,                      -1)
    Character.edit_action_parameters(RYU,   Action.JumpAerialB,     -1,                         JUMP2,                      -1)
    Character.edit_action_parameters(RYU,   Action.DownBounceD,     -1,                         DOWN_BOUNCE,                -1)
    Character.edit_action_parameters(RYU,   Action.DownBounceU,     -1,                         DOWN_BOUNCE,                -1)
    Character.edit_action_parameters(RYU,   Action.DownStandD,      -1,                         DOWN_STAND,                 -1)
    Character.edit_action_parameters(RYU,   Action.DownStandU,      -1,                         DOWN_STAND,                 -1)
    Character.edit_action_parameters(RYU,   Action.TechF,           -1,                         TECHROLL,                   -1)
    Character.edit_action_parameters(RYU,   Action.TechB,           -1,                         TECHROLL,                   -1)
    Character.edit_action_parameters(RYU,   Action.Tech,            -1,                         TECHSTAND,                  -1)
    Character.edit_action_parameters(RYU,   Action.CliffAttackQuick2, -1,                       EDGEATTACKF,                -1)
    Character.edit_action_parameters(RYU,   Action.CliffAttackSlow2, -1,                        EDGEATTACKS,                -1)
    Character.edit_action_parameters(RYU,   Action.Taunt,           File.GND_TAUNT,             TAUNT,                      -1)
    Character.edit_action_parameters(RYU,   Action.ShieldBreak,     -1,                         SHIELD_BREAK,               -1)
    Character.edit_action_parameters(RYU,   Action.Stun,             -1,                        STUN,                       -1)
    Character.edit_action_parameters(RYU,   Action.Jab1,            File.RYU_ROUNDHOUSE,        ROUNDHOUSE,                 0)
    Character.edit_action_parameters(RYU,   Action.DashAttack,      -1,                         DASH_ATTACK,                -1)
    Character.edit_action_parameters(RYU,   Action.FTiltHigh,       -1,                         FTILT_HI,                   -1)
    Character.edit_action_parameters(RYU,   Action.FTiltMidHigh,    -1,                         FTILT_M_HI,                 -1)
    Character.edit_action_parameters(RYU,   Action.FTilt,           File.RYU_FTILT_H,           FTILT_H,                    0x40000000)
    Character.edit_action_parameters(RYU,   Action.FTiltMidLow,     -1,                         FTILT_M_LO,                 -1)
    Character.edit_action_parameters(RYU,   Action.FTiltLow,        -1,                         FTILT_LO,                   -1)
    Character.edit_action_parameters(RYU,   Action.UTilt,           File.RYU_UTILT_H,           UTILT_H,                    0x40000000)
    Character.edit_action_parameters(RYU,   Action.DTilt,           File.RYU_DTILT_H,           DTILT_H,                      0)
    Character.edit_action_parameters(RYU,   Action.FSmashHigh,      0,                          0x80000000,                 0)
    Character.edit_action_parameters(RYU,   Action.FSmash,          0x64E,                      FSMASH,                     0)
    Character.edit_action_parameters(RYU,   Action.FSmashLow,       0,                          0x80000000,                 0)
    Character.edit_action_parameters(RYU,   Action.USmash,          File.GND_USMASH,            USMASH,                     0)
    Character.edit_action_parameters(RYU,   Action.DSmash,          File.RYU_DSMASH,            DSMASH,                     -1)
    Character.edit_action_parameters(RYU,   Action.AttackAirN,      File.RYU_NAIR,              NAIR,                       -1)
    Character.edit_action_parameters(RYU,   Action.AttackAirF,      File.GND_FAIR,              FAIR,                       -1)
    Character.edit_action_parameters(RYU,   Action.AttackAirB,      -1,                         BAIR,                       -1)
    Character.edit_action_parameters(RYU,   Action.AttackAirU,      -1,                         UAIR,                       -1)
    Character.edit_action_parameters(RYU,   Action.AttackAirD,      -1,                         DAIR,                       -1)
    Character.edit_action_parameters(RYU,   Action.LandingAirN,     0x66B,                      0x1720,                     -1)
    Character.edit_action_parameters(RYU,   Action.LandingAirF,     0,                          0x80000000,                 -1)
    Character.edit_action_parameters(RYU,   0xE0,                   File.SHEIK_ENTRY_LEFT,      ENTRY,                     0x40000009)
    Character.edit_action_parameters(RYU,   0xE1,                   File.SHEIK_ENTRY_RIGHT,     ENTRY,                     0x40000009)
	Character.edit_action_parameters(RYU,   0xE2,                   File.GND_ENTRY_2_LEFT,      ENTRY_2,                    0x40000000)
	Character.edit_action_parameters(RYU,   0xE3,                   File.GND_ENTRY_2_RIGHT,      ENTRY_2,                   0x40000000)
	Character.edit_action_parameters(RYU,   0xE4,                   File.RYU_HADOUKEN_GND,          NSP_AIR,                 0x40000000)
    Character.edit_action_parameters(RYU,   0xE5,                   File.RYU_HADOUKEN_GND,          NSP_AIR,                 0x40000000)
    Character.edit_action_parameters(RYU,   0xE6,                   File.RYU_TATSU_GND_L,       DSP_GROUND,                 -1)
    Character.edit_action_parameters(RYU,   0xE7,                   -1,                         DSP_FLIP,                   -1)
    Character.edit_action_parameters(RYU,   0xE8,                   -1,                         DSP_LAND,                   -1)
    Character.edit_action_parameters(RYU,   0xE9,                   File.RYU_TATSU_GND_L,       DSP_GROUND,                 -1) // aerial dsp

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(RYU,  0xE4,              -1,             RyuNSP.main,  				-1,                             RyuNSP.physics_,                RyuNSP.air_collision_)
	Character.edit_action(RYU,  0xE5,              -1,             RyuNSP.main,  				-1,                             RyuNSP.physics_,                RyuNSP.air_collision_)
    Character.edit_action(RYU, 0xE6,               -1,             RyuDSP.main_,                  RyuDSP.ground_subroutine_,      RyuNSP.physics_,              RyuDSP.air_collision_)
    Character.edit_action(RYU, 0xE9,               -1,             RyuDSP.main_,                  RyuDSP.air_subroutine_,         RyuDSP.air_physics_,            RyuDSP.air_collision_)

    Character.edit_action(RYU, 0xE0,                   -1,            0x8013DA94,                    0,                              0x8013DB2C,                    0x800DE348)   // LEFT ENTRY
    Character.edit_action(RYU, 0xE1,                   -1,            0x8013DA94,                    0,                              0x8013DB2C,                    0x800DE348)   // RIGHT ENTRY

    // Add Action Parameters                // Action Name      // Base Action  // Animation                    // Moveset Data             // Flags
    Character.add_new_action_params(RYU,    USP_L,             -1,             File.RYU_SHORYKEN_L,            USP_L,                        0x40000000)
    Character.add_new_action_params(RYU,    JAB_L,              -1,            0x0653,                         JAB_1,                       -1)
    Character.add_new_action_params(RYU,    DTILT_L,           -1,             File.RYU_DTILT_L,               DTILT_L,                      0x00000000)
    Character.add_new_action_params(RYU,    UTILT_L,           -1,             File.RYU_UTILT_L,               UTILT_L,                      0x00000000)
    Character.add_new_action_params(RYU,    FTILT_L,           -1,             File.RYU_FTILT_L,               FTILT_L,                      0x00000000)

    // Add Actions                   // Action Name     // Base Action  //Parameters                    // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(RYU,    USP_L,              -1,             ActionParams.USP_L,            0x11,           RyuUSP.main_,                   RyuUSP.change_direction_,          RyuUSP.physics_,                 RyuUSP.collision_)
    Character.add_new_action(RYU,    JAB_L,             -1,              ActionParams.JAB_L,            0x11,           0x800D94C4,                     0,                                  0x800D8BB4,                     0x80162798)
    Character.add_new_action(RYU,    DTILT_L,            -1,             ActionParams.DTILT_L,          0x11,           0x800D94C4,                     0,                                  0x800D8BB4,                     0x80162798)
    Character.add_new_action(RYU,    UTILT_L,            -1,             ActionParams.UTILT_L,          0x11,           0x800D94C4,                     0,                                  0x800D8BB4,                     0x80162798)
    Character.add_new_action(RYU,    FTILT_L,            -1,             ActionParams.FTILT_L,          0x11,           0x800D94C4,                     0,                                  0x800D8BB4,                     0x80162798)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(RYU,   0x1,               -1,                         VICTORY_POSE_1,             -1)
    Character.edit_menu_action_parameters(RYU,   0x2,               File.GND_SELECT,            VICTORY_POSE_2,             -1)
    Character.edit_menu_action_parameters(RYU,   0x3,               File.GND_VICTORY1,          VICTORY_POSE_3,             -1)
    Character.edit_menu_action_parameters(RYU,   0x4,               File.GND_VICTORY1,          VICTORY_POSE_3,             -1)
    Character.edit_menu_action_parameters(RYU,   0xE,               File.GND_1P_CPU,            ONEP,                       -1)
    Character.edit_menu_action_parameters(RYU,   0xD,               File.GND_POSE_1P,           ONEP,                       -1)

    Character.table_patch_start(variants, Character.id.RYU, 0x4)
    db      Character.id.NONE   // set as SPECIAL variant for RYU
    db      Character.id.NONE
    db      Character.id.NONE
    db      Character.id.NONE
    OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.RYU, 0x4)
    dw      RyuUSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.RYU, 0x4)
    dw      RyuUSP.ground_initial_
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.RYU, 0x4)
    float32 1
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.RYU, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

	// Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.RYU, 0x2)
    dh  0x02EA
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.RYU, 0, 1, 2, 3, 5, 1, 4)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(RYU, BROWN, BLUE, AZURE, PURPLE, GREEN, RED, NA, NA)

    // Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.RYU, 0xC)
    dw Character.kirby_inhale_struct.star_damage.DK
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.RYU, 0xC)
    dh 0x11
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.RYU, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  14,   24,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  12,   31,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  16,   38,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  16,   35,  -1, -1, -1, -1) // todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  8,    15,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FAIR,   -1,  7,    19,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  24,   33,  -1, -1, -1, -1) // todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  10,   16,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  6,    6,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  5,    8,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  7,    17,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  47,   52,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  47,   52,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  7,    17,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  16,   51,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  15,   55,  -1, -1, -1, -1) // todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  19,   33,  -1, -1, -1, -1) // todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  34,   40,  -1, -1, -1, -1) // todo: coords

    // @ Description
    // Ryu's extra actions
    scope Action {
        //constant Jab3(0x0DC)
        //constant JabLoopStart(0x0DD)
        //constant JabLoop(0x0DE)
        //constant JabLoopEnd(0x0DF)
        constant AppearLeft1(0x0E0)
        constant Blaster(0x0E4)
        constant BlasterAir(0x0E5)
        constant AppearRight2(0x0E3)
        constant Hadouken(0x0E4)
        constant HadoukenAir(0x0E5)
        constant WarlockKick(0x0E6)
        constant WarlockKickFromGroundAir(0x0E7)
        constant LandingWarlockKick(0x0E8)
        constant WarlockKickEnd(0x0E9)
        constant CollisionWarlockKick(0x0EA)
        constant WarlockDive(0x0EB)
        constant WarlockDiveCatch(0x0EC)
        constant WarlockDiveEnd1(0x0ED)
        constant WarlockDiveEnd2(0x0EE)

        // strings!
        //string_0x0DC:; String.insert("Jab3")
        //string_0x0DD:; String.insert("JabLoopStart")
        //string_0x0DE:; String.insert("JabLoop")
        //string_0x0DF:; String.insert("JabLoopEnd")
        string_0x0E0:; String.insert("AppearLeft1")
        string_0x0E1:; String.insert("AppearRight1")
        string_0x0E2:; String.insert("AppearLeft1")
        string_0x0E3:; String.insert("AppearRight2")
        string_0x0E4:; String.insert("Hadouken")
        string_0x0E5:; String.insert("HadoukenAir")
        string_0x0E6:; String.insert("WarlockKick")
        string_0x0E7:; String.insert("WarlockKickFromGroundAir")
        string_0x0E8:; String.insert("LandingWarlockKick")
        string_0x0E9:; String.insert("WarlockKickEnd")
        string_0x0EA:; String.insert("CollisionWarlockKick")
        string_0x0EB:; String.insert("WarlockDive")
        string_0x0EC:; String.insert("DarkDiveCatch")
        string_0x0ED:; String.insert("DarkDiveEnd1")
        string_0x0EE:; String.insert("DarkDiveEnd2")

        action_string_table:
        dw 0
        dw 0
        dw 0
        dw 0
        dw string_0x0E0
        dw string_0x0E1
        dw string_0x0E2
        dw string_0x0E3
        dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw string_0x0E7
        dw string_0x0E8
        dw string_0x0E9
        dw string_0x0EA
        dw string_0x0EB
        dw string_0x0EC
        dw string_0x0ED
        dw string_0x0EE
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.RYU, 0x4)
    dw  Action.action_string_table
    OS.patch_end()
}
