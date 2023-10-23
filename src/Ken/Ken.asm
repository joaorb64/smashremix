// Ken.asm

// This file contains file inclusions, action edits, and assembly for Ken.

scope Ken {

	scope FACE: {
		constant NORMAL(0xAC000000)
		constant SHOCK(0xAC000006)
	}

    // Insert Moveset files
    insert IDLE,"moveset/IDLE.bin"
    insert RUN,"moveset/RUN.bin"; Moveset.GO_TO(RUN)            // loops
    insert JUMP2, "moveset/JUMP2.bin"
    insert JUMPB, "moveset/JUMPB.bin"
    insert TECHSTAND, "moveset/TECHSTAND.bin"
    insert TECHROLL, "moveset/TECHFROLL.bin"
    insert EDGEATTACKF, "moveset/EDGEATTACKF.bin"
    insert EDGEATTACKS, "moveset/EDGEATTACKS.bin"
    insert TAUNT,"moveset/TAUNT.bin"
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)         // loops
    insert JAB_1,"moveset/JAB_1.bin"
    insert JAB_2,"moveset/JAB_2.bin"
    insert JAB_3,"moveset/JAB_3.bin"
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
    insert USP_H,"moveset/SHORYUKEN_H.bin"
    insert DSP_L,"moveset/DOWN_SPECIAL_L.bin"
    insert DSP_M,"moveset/DOWN_SPECIAL_M.bin"
    insert DSP_H,"moveset/DOWN_SPECIAL_H.bin"
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
    insert JAB_CLOSE,"moveset/JAB_CLOSE.bin"
    insert JAB_FAR,"moveset/JAB_FAR.bin"
    insert COMMAND_KICK,"moveset/COMMAND_KICK.bin"
    insert COMMAND_KICK_2,"moveset/COMMAND_KICK_2.bin"
    insert FTILT_CLOSE,"moveset/FORWARD_TILT_CLOSE.bin"
    insert ENTRY,"moveset/ENTRY.bin"

    insert THROWF_DATA, "moveset/THROWF_DATA.bin"
    THROWF:; Moveset.THROW_DATA(THROWF_DATA); insert "moveset/THROWF.bin"
    insert THROWB_DATA, "moveset/THROWB_DATA.bin"
    THROWB:; Moveset.THROW_DATA(THROWB_DATA); insert "moveset/THROWB.bin"

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
    Character.edit_action_parameters(KEN,   Action.Entry,           File.RYU_IDLE,              IDLE,                         -1)
    Character.edit_action_parameters(KEN,   0x006,                  File.RYU_IDLE,              IDLE,                         -1)
    Character.edit_action_parameters(KEN,   Action.Idle,            File.RYU_IDLE,              IDLE,                       -1)
    Character.edit_action_parameters(KEN,   Action.Run,             -1,                         RUN,                        -1)
    Character.edit_action_parameters(KEN,   Action.Dash,            File.RYU_DASH,              -1,                         -1)
    Character.edit_action_parameters(KEN,   Action.Walk3,           File.RYU_WALK3,              -1,                         -1)
    Character.edit_action_parameters(KEN,   Action.Teeter,          -1,                         IDLE,                       -1)
    Character.edit_action_parameters(KEN,   Action.TeeterStart,     -1,                         IDLE,                       -1)
    Character.edit_action_parameters(KEN,   Action.Fall,            File.RYU_FALL,              -1,                         0x00000000)
    Character.edit_action_parameters(KEN,   Action.FallAerial,      File.RYU_AIRFALL,           -1,                         0x00000000)
    Character.edit_action_parameters(KEN,   Action.FallSpecial,      File.RYU_FALLSPECIAL,           -1,                         -1)
    Character.edit_action_parameters(KEN,   Action.JumpF,           File.RYU_JUMPF,             -1,                         0x00000000)
    Character.edit_action_parameters(KEN,   Action.JumpB,           File.RYU_JUMPB,             JUMPB,                      0x80000000)
    Character.edit_action_parameters(KEN,   Action.ThrowF,          File.RYU_THROWF,            THROWF,                     0x10000000)
    Character.edit_action_parameters(KEN,   Action.ThrowB,          File.KEN_THROWB,            THROWB,                     0x50000000)
    Character.edit_action_parameters(KEN,   Action.JumpAerialF,     File.RYU_AIRJUMPF,          JUMP2,                      -1)
    Character.edit_action_parameters(KEN,   Action.JumpAerialB,     File.RYU_AIRJUMPB,          JUMP2,                      -1)
    Character.edit_action_parameters(KEN,   Action.DownBounceD,     -1,                         DOWN_BOUNCE,                -1)
    Character.edit_action_parameters(KEN,   Action.DownBounceU,     -1,                         DOWN_BOUNCE,                -1)
    Character.edit_action_parameters(KEN,   Action.DownStandD,      -1,                         DOWN_STAND,                 -1)
    Character.edit_action_parameters(KEN,   Action.DownStandU,      -1,                         DOWN_STAND,                 -1)
    Character.edit_action_parameters(KEN,   Action.TechF,           -1,                         TECHROLL,                   -1)
    Character.edit_action_parameters(KEN,   Action.TechB,           -1,                         TECHROLL,                   -1)
    Character.edit_action_parameters(KEN,   Action.Tech,            -1,                         TECHSTAND,                  -1)
    Character.edit_action_parameters(KEN,   Action.CliffAttackQuick2, -1,                       EDGEATTACKF,                -1)
    Character.edit_action_parameters(KEN,   Action.CliffAttackSlow2, -1,                        EDGEATTACKS,                -1)
    Character.edit_action_parameters(KEN,   Action.Taunt,           File.GND_TAUNT,             TAUNT,                      -1)
    Character.edit_action_parameters(KEN,   Action.ShieldBreak,     -1,                         SHIELD_BREAK,               -1)
    Character.edit_action_parameters(KEN,   Action.Stun,             -1,                        STUN,                       -1)
    Character.edit_action_parameters(KEN,   Action.Jab1,            File.KEN_FAR_JAB,           JAB_FAR,                 0x40000000)
    Character.edit_action_parameters(KEN,   Action.DashAttack,      File.RYU_DASH_ATTACK,       DASH_ATTACK,                0x40000000)
    Character.edit_action_parameters(KEN,   Action.FTiltHigh,       File.KEN_HARD_FTILT,        FTILT_H,                   0x00000000)
    Character.edit_action_parameters(KEN,   Action.FTiltMidHigh,    File.KEN_HARD_FTILT,        FTILT_H,                 0x00000000)
    Character.edit_action_parameters(KEN,   Action.FTilt,           File.KEN_HARD_FTILT,        FTILT_H,                    0x00000000)
    Character.edit_action_parameters(KEN,   Action.FTiltMidLow,     File.KEN_HARD_FTILT,        FTILT_H,                 0x00000000)
    Character.edit_action_parameters(KEN,   Action.FTiltLow,        File.KEN_HARD_FTILT,        FTILT_H,                   0x00000000)
    Character.edit_action_parameters(KEN,   Action.UTilt,           File.RYU_UTILT_H,           UTILT_H,                    0x40000000)
    Character.edit_action_parameters(KEN,   Action.DTilt,           File.RYU_DTILT_H,           DTILT_H,                      0)
    Character.edit_action_parameters(KEN,   Action.FSmashHigh,      File.KEN_FSMASH,            FSMASH,                 0x40000000)
    Character.edit_action_parameters(KEN,   Action.FSmash,          File.KEN_FSMASH,            FSMASH,                     0x40000000)
    Character.edit_action_parameters(KEN,   Action.FSmashLow,       File.KEN_FSMASH,            FSMASH,                 0x40000000)
    Character.edit_action_parameters(KEN,   Action.USmash,          File.RYU_USMASH,            USMASH,                     0)
    Character.edit_action_parameters(KEN,   Action.DSmash,          File.RYU_DSMASH,            DSMASH,                     -1)
    Character.edit_action_parameters(KEN,   Action.AttackAirN,      File.KEN_AIRN,              NAIR,                       -1)
    Character.edit_action_parameters(KEN,   Action.AttackAirF,      File.RYU_AIRF,              FAIR,                       -1)
    Character.edit_action_parameters(KEN,   Action.AttackAirB,      File.RYU_AIRB,              BAIR,                       -1)
    Character.edit_action_parameters(KEN,   Action.AttackAirU,      File.KEN_AIRU,              UAIR,                       -1)
    Character.edit_action_parameters(KEN,   Action.AttackAirD,      File.RYU_AIRD,              DAIR,                       -1)
    Character.edit_action_parameters(KEN,   Action.LandingAirN,     0x66B,                      0x1720,                     -1)
    Character.edit_action_parameters(KEN,   Action.LandingAirF,     0,                          0x80000000,                 -1)
    Character.edit_action_parameters(KEN,   0xE0,                   File.RYU_ENTRYR,            ENTRY,                     0x40000009)
    Character.edit_action_parameters(KEN,   0xE1,                   File.RYU_ENTRYR,            ENTRY,                     0x40000009)
	Character.edit_action_parameters(KEN,   0xE4,                   File.RYU_HADOUKEN_GND,      NSP_AIR,                 0x40000000)
    Character.edit_action_parameters(KEN,   0xE5,                   File.RYU_HADOUKEN_GND,      NSP_AIR,                 0x40000000)
    Character.edit_action_parameters(KEN,   0xE6,                   File.KEN_TATSU_L,       DSP_L,                 -1)
    Character.edit_action_parameters(KEN,   0xE7,                   -1,                         DSP_FLIP,                   -1)
    Character.edit_action_parameters(KEN,   0xE8,                   -1,                         DSP_LAND,                   -1)
    Character.edit_action_parameters(KEN,   0xE9,                   File.KEN_TATSU_M,       DSP_M,                 -1) // aerial dsp
    Character.edit_action_parameters(KEN,   Action.Crouch,          File.RYU_CROUCH_START,        -1,                         -1)
    Character.edit_action_parameters(KEN,   Action.CrouchIdle,      File.RYU_CROUCH_IDLE,         -1,                         -1)
    Character.edit_action_parameters(KEN,   Action.CrouchEnd,       File.RYU_CROUCH_END,          -1,                         -1)
    
    Character.edit_action_parameters(KEN,   Action.RunBrake,        File.RYU_DASH,      -1,                         -1)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(KEN,  0xE4,              -1,             RyuNSP.main,  				RyuNSP.change_direction_,                             RyuNSP.physics_,                RyuNSP.air_collision_)
	Character.edit_action(KEN,  0xE5,              -1,             RyuNSP.main,  				RyuNSP.change_direction_,                             RyuNSP.physics_,                RyuNSP.air_collision_)
    Character.edit_action(KEN, 0xE6,               -1,             RyuDSP.main_,                  RyuDSP.ground_subroutine_,      RyuNSP.physics_,              RyuDSP.air_collision_)
    Character.edit_action(KEN, 0xE9,               -1,             RyuDSP.main_,                  RyuDSP.air_subroutine_,         RyuDSP.air_physics_,            RyuDSP.air_collision_)

    Character.edit_action(KEN, 0xE0,                   -1,            0x8013DA94,                    0,                              0x8013DB2C,                    0x800DE348)   // LEFT ENTRY
    Character.edit_action(KEN, 0xE1,                   -1,            0x8013DA94,                    0,                              0x8013DB2C,                    0x800DE348)   // RIGHT ENTRY

    // Add Action Parameters                // Action Name      // Base Action  // Animation                    // Moveset Data             // Flags
    Character.add_new_action_params(KEN,    USP_L,             -1,             File.RYU_SHORYUKEN_L,            USP_L,                        0x40000000)
    Character.add_new_action_params(KEN,    JAB_L,             -1,             File.RYU_JAB_1,                 JAB_1,                       -1)
    Character.add_new_action_params(KEN,    JAB_L2,             -1,            File.RYU_JAB_2,                 JAB_2,                       -1)
    Character.add_new_action_params(KEN,    JAB_L3,             -1,            File.RYU_JAB_3,                 JAB_3,                       -1)
    Character.add_new_action_params(KEN,    DTILT_L,           -1,             File.RYU_DTILT_L,               DTILT_L,                      0x00000000)
    Character.add_new_action_params(KEN,    UTILT_L,           -1,             File.RYU_UTILT_L,               UTILT_L,                      0x00000000)
    Character.add_new_action_params(KEN,    FTILT_L,           -1,             File.RYU_FTILT_L,               FTILT_L,                      0x00000000)
    Character.add_new_action_params(KEN,    JAB_CLOSE,         -1,             File.RYU_UTILT_H,               JAB_CLOSE,                    0x40000000)
    Character.add_new_action_params(KEN,    FTILT_CLOSE,       -1,             File.RYU_FTILT_CLOSE,           FTILT_CLOSE,                  0x40000000)
    Character.add_new_action_params(KEN,    DSP_H,             0xE6,           File.KEN_TATSU_H,           DSP_H,                        -1)
    Character.add_new_action_params(KEN,    USP_H,             -1,             File.RYU_SHORYUKEN_H,            USP_H,                        0x40000000)
    Character.add_new_action_params(KEN,    ROUNDHOUSE,             -1,        File.RYU_ROUNDHOUSE,            ROUNDHOUSE,                   0)
    Character.add_new_action_params(KEN,    COMMAND_KICK_2,             -1,    File.KEN_COMMAND_KICK_FINISHER,  COMMAND_KICK_2,                   0x40000000)
    Character.add_new_action_params(KEN,    COMMAND_KICK,             -1,      File.KEN_COMMAND_KICK,         COMMAND_KICK,                   0x40000000)

    // Add Actions                   // Action Name     // Base Action  //Parameters                    // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(KEN,    USP_L,              -1,             ActionParams.USP_L,            0x11,           RyuUSP.main_,                   RyuUSP.change_direction_,          RyuUSP.physics_,                 RyuUSP.collision_)
    Character.add_new_action(KEN,    JAB_L,              -1,             ActionParams.JAB_L,            0x11,           0x800D94C4,                     0,                                  0x800D8BB4,                     0x800DDF44)
    Character.add_new_action(KEN,    JAB_L2,              -1,            ActionParams.JAB_L2,           0x11,           0x800D94C4,                     0,                                  0x800D8BB4,                     0x800DDF44)
    Character.add_new_action(KEN,    JAB_L3,              -1,            ActionParams.JAB_L3,           0x11,           0x800D94C4,                     0,                                  0x800D8BB4,                     0x800DDF44)
    Character.add_new_action(KEN,    DTILT_L,            -1,             ActionParams.DTILT_L,          0x11,           0x800D94C4,                     0,                                  0x800D8BB4,                     0x800DDF44)
    Character.add_new_action(KEN,    UTILT_L,            -1,             ActionParams.UTILT_L,          0x11,           0x800D94C4,                     0,                                  0x800D8BB4,                     0x800DDF44)
    Character.add_new_action(KEN,    FTILT_L,            -1,             ActionParams.FTILT_L,          0x11,           0x800D94C4,                     0,                                  0x800D8BB4,                     0x800DDF44)
    Character.add_new_action(KEN,    JAB_CLOSE,            -1,           ActionParams.JAB_CLOSE,        0x11,           0x800D94C4,                     0,                                  0x800D8BB4,                     0x800DDF44)
    Character.add_new_action(KEN,    FTILT_CLOSE,            -1,         ActionParams.FTILT_CLOSE,      0x11,           0x800D94C4,                     0,                                  0x800D8BB4,                     0x800DDF44)

    Character.add_new_action(KEN,    DSP_H,              -1,             ActionParams.DSP_H,            0x11,           RyuDSP.main_,                   RyuDSP.ground_subroutine_,          RyuNSP.physics_,            RyuDSP.air_collision_)
    Character.add_new_action(KEN,    USP_H,              -1,             ActionParams.USP_H,            0x11,           RyuUSP.main_,                   RyuUSP.change_direction_,           RyuUSP.physics_,                RyuUSP.collision_)
    
    Character.add_new_action(KEN,    ROUNDHOUSE,            -1,         ActionParams.ROUNDHOUSE,        0x11,           0x800D94C4,                     0,                                  0x800D8BB4,                     0x800DDF44)
    Character.add_new_action(KEN,    COMMAND_KICK_2,            -1,     ActionParams.COMMAND_KICK_2,    0x11,       0x800D94C4,                     0,                                  0x800D8C14,                     0x800DDF44)
    Character.add_new_action(KEN,    COMMAND_KICK,            -1,     ActionParams.COMMAND_KICK,    0x11,            0x800D94C4,                     0,                                  0x800D8C14,                     0x800DDF44)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(KEN,   0x1,               -1,                         VICTORY_POSE_1,             -1)
    Character.edit_menu_action_parameters(KEN,   0x2,               File.GND_SELECT,            VICTORY_POSE_2,             -1)
    Character.edit_menu_action_parameters(KEN,   0x3,               File.GND_VICTORY1,          VICTORY_POSE_3,             -1)
    Character.edit_menu_action_parameters(KEN,   0x4,               File.GND_VICTORY1,          VICTORY_POSE_3,             -1)
    Character.edit_menu_action_parameters(KEN,   0xE,               File.GND_1P_CPU,            ONEP,                       -1)
    Character.edit_menu_action_parameters(KEN,   0xD,               File.GND_POSE_1P,           ONEP,                       -1)

    Character.table_patch_start(variants, Character.id.KEN, 0x4)
    db      Character.id.NONE   // set as SPECIAL variant for RYU
    db      Character.id.NONE
    db      Character.id.NONE
    db      Character.id.NONE
    OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.KEN, 0x4)
    dw      RyuUSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.KEN, 0x4)
    dw      RyuUSP.ground_initial_
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.KEN, 0x4)
    float32 1
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.KEN, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

	// Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.KEN, 0x2)
    dh  0x02EA
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.KEN, 0, 1, 2, 3, 5, 1, 4)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(KEN, BROWN, BLUE, AZURE, PURPLE, GREEN, RED, NA, NA)

    // Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.KEN, 0xC)
    dw Character.kirby_inhale_struct.star_damage.DK
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.KEN, 0xC)
    dh 0x11
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.KEN, 0x4)
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
    // Ken's extra actions
    scope Action {
        //constant Jab3(0x0DC)
        //constant JabLoopStart(0x0DD)
        //constant JabLoop(0x0DE)
        //constant JabLoopEnd(0x0DF)
        // constant AppearLeft1(0x0E0)
        constant Blaster(0x0E4)
        constant BlasterAir(0x0E5)
        // constant AppearRight2(0x0E3)
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
        // string_0x0E0:; String.insert("AppearLeft1")
        // string_0x0E1:; String.insert("AppearRight1")
        // string_0x0E2:; String.insert("AppearLeft1")
        // string_0x0E3:; String.insert("AppearRight2")
        string_0x0E4:; String.insert("Hadouken")
        string_0x0E5:; String.insert("HadoukenAir")
        string_0x0E6:; String.insert("WarlockKick")
        string_0x0E7:; String.insert("WarlockKickFromGroundAir")
        string_0x0E8:; String.insert("Hadouken")
        string_0x0E9:; String.insert("HadoukenAir")
        string_0x0EA:; String.insert("TatsumakiLight")
        string_0x0EB:; String.insert("---")
        string_0x0EC:; String.insert("DarkDiveCatch")
        string_0x0ED:; String.insert("TatsumakiAir")
        string_0x0EE:; String.insert("DarkDiveEnd2")

        string_0x0F3:; String.insert("ShoryukenLight")
        string_0x0F4:; String.insert("Jab1")
        string_0x0F5:; String.insert("Jab2")
        string_0x0F6:; String.insert("Jab3")
        string_0x0F7:; String.insert("DTiltLight")
        string_0x0F8:; String.insert("UTiltLight")
        string_0x0F9:; String.insert("FTiltLight")
        string_0x0FA:; String.insert("JabClose")
        string_0x0FB:; String.insert("FTiltClose")
        string_0x0FC:; String.insert("TatsumakiStrong")
        string_0x0FD:; String.insert("ShoryukenHard")

        action_string_table:
        dw 0
        dw 0
        dw 0
        dw 0
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

        dw 0
        dw 0
        dw 0
        dw 0
        dw string_0x0F3
        dw string_0x0F4
        dw string_0x0F5
        dw string_0x0F6
        dw string_0x0F7
        dw string_0x0F8
        dw string_0x0F9
        dw string_0x0FA
        dw string_0x0FB
        dw string_0x0FC
        dw string_0x0FD
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.KEN, 0x4)
    dw  Action.action_string_table
    OS.patch_end()
}
