// Kazuya.asm

// This file contains file inclusions, action edits, and assembly for Kazuya.

scope Kazuya {

    insert WHILE_STAND, "moveset/WHILE_STAND.bin"
    insert WAVEDASH, "moveset/WAVEDASH.bin"
    insert GODFIST, "moveset/GODFIST.bin"
    insert SWEEP1, "moveset/SWEEP1.bin"
    insert SWEEP2, "moveset/SWEEP2.bin"

    insert JAB1, "moveset/JAB1.bin"
    insert JAB2, "moveset/JAB2.bin"
    insert JAB3, "moveset/JAB3.bin"

    insert TILTU1, "moveset/TILTU1.bin"
    insert TILTU2, "moveset/TILTU2.bin"
    insert TILTF, "moveset/TILTF.bin"
    insert TILTD, "moveset/TILTD.bin"

    insert CROUCH_JAB, "moveset/CROUCH_JAB.bin"
    insert CROUCH_TILT, "moveset/CROUCH_TILT.bin"

    insert AIRF, "moveset/AIRF.bin"
    insert AIRU, "moveset/AIRU.bin"

    insert SMASHD, "moveset/SMASHD.bin"
    insert SMASHU, "moveset/SMASHU.bin"

    insert NSP, "moveset/NSP.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(KAZUYA,   Action.Entry,        File.KAZUYA_IDLE,           -1,                           -1)
    Character.edit_action_parameters(KAZUYA,   0x006,               File.KAZUYA_IDLE,           -1,                           -1)
    Character.edit_action_parameters(KAZUYA,   Action.Idle,         File.KAZUYA_IDLE,           -1,                           -1)
    Character.edit_action_parameters(KAZUYA,   Action.Jab1,         File.KAZUYA_JAB1,           JAB1,                         0x40000000)
    Character.edit_action_parameters(KAZUYA,   Action.Jab2,         File.KAZUYA_JAB2,           JAB2,                         0x40000000)
    Character.edit_action_parameters(KAZUYA,   0xDC,                File.KAZUYA_JAB3,           JAB3,                         0x40000000)

    Character.edit_action_parameters(KAZUYA,   Action.UTilt,        File.KAZUYA_TILTU1,         TILTU1,                       0x40000000)
    Character.edit_action_parameters(KAZUYA,   Action.FTilt,        File.KAZUYA_TILTF,          TILTF,                        0x40000000)
    Character.edit_action_parameters(KAZUYA,   Action.DTilt,        File.KAZUYA_TILTD,          TILTD,                        0x40000000)

    Character.edit_action_parameters(KAZUYA,   Action.DSmash,       File.KAZUYA_SMASHD,         SMASHD,                       0x40000000)
    Character.edit_action_parameters(KAZUYA,   Action.USmash,       File.KAZUYA_SMASHU,         SMASHU,                       0x00000000)

    Character.edit_action_parameters(KAZUYA,   Action.AttackAirF,   File.KAZUYA_AIRF,           AIRF,                         -1)
    Character.edit_action_parameters(KAZUYA,   Action.AttackAirU,   File.KAZUYA_AIRU,           AIRU,                         -1)

    Character.edit_action_parameters(KAZUYA,   0xE4,                File.KAZUYA_UPPERCUT,       NSP,                          0x40000000)
    Character.edit_action_parameters(KAZUYA,   0xE5,                File.KAZUYA_UPPERCUT,       NSP,                          0x40000000)

    // Modify Actions               // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(KAZUYA,   0xE4,              -1,             KazuyaSpecial.NSP.main,     -1,                             -1,                             -1)
	// Character.edit_action(KAZUYA,   0xE5,              -1,             KazuyaSpecial.NSP.main,     -1,                             -1,                             -1)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                    // Moveset Data             // Flags
    Character.add_new_action_params(KAZUYA,    WHILE_STAND,          -1,        File.KAZUYA_WHILE_STAND,        WHILE_STAND,                0x40000000)
    Character.add_new_action_params(KAZUYA,    WAVEDASH,             -1,        File.KAZUYA_WAVEDASH,           WAVEDASH,                   0x40000000)
    Character.add_new_action_params(KAZUYA,    GODFIST,              -1,        File.KAZUYA_GODFIST,            GODFIST,                    0x40000000)
    Character.add_new_action_params(KAZUYA,    CROUCH_JAB,           -1,        File.KAZUYA_CROUCH_JAB,         CROUCH_JAB,                 0x40000000)
    Character.add_new_action_params(KAZUYA,    SWEEP1,               -1,        File.KAZUYA_SWEEP1,             SWEEP1,                     0x40000000)
    Character.add_new_action_params(KAZUYA,    SWEEP2,               -1,        File.KAZUYA_SWEEP2,             SWEEP2,                     0x40000000)
    Character.add_new_action_params(KAZUYA,    TILTU2,               -1,        File.KAZUYA_TILTU2,             TILTU2,                     0x40000000)
    Character.add_new_action_params(KAZUYA,    CROUCH_TILT,           -1,       File.KAZUYA_CROUCH_TILT,        CROUCH_TILT,                0x40000000)

    // Add Actions                   // Action Name     // Base Action  //Parameters                    // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(KAZUYA,    WHILE_STAND,    -1,             ActionParams.WHILE_STAND,       -1,             0x800D94C4,                     0,                              0x800D8C14,                         0x800DDF44)
    Character.add_new_action(KAZUYA,    WAVEDASH,       -1,             ActionParams.WAVEDASH,          -1,             KazuyaSpecial.WAVEDASH.main,    0,                              0x800D8C14,                         0x800DDF44)
    Character.add_new_action(KAZUYA,    GODFIST,        -1,             ActionParams.GODFIST,           -1,             0x800D94C4,                     0,                              0x800D8C14,                         0x800DDF44)
    Character.add_new_action(KAZUYA,    CROUCH_JAB,     Action.DTilt,   ActionParams.CROUCH_JAB,        -1,             KazuyaSpecial.CROUCH_JAB.main,  0,                              0x800D8C14,                         0x800DDF44)
    Character.add_new_action(KAZUYA,    SWEEP1,         -1,             ActionParams.SWEEP1,            -1,             KazuyaSpecial.SWEEP.main,       0,                              0x800D8C14,                         0x800DDF44)
    Character.add_new_action(KAZUYA,    SWEEP2,         -1,             ActionParams.SWEEP2,            -1,             0x800D94C4,                     0,                              0x800D8C14,                         0x800DDF44)
    Character.add_new_action(KAZUYA,    TILTU2,         -1,             ActionParams.TILTU2,            -1,             0x800D94C4,                     0,                              0x800D8C14,                         0x800DDF44)
    Character.add_new_action(KAZUYA,    CROUCH_TILT,    Action.DTilt,   ActionParams.CROUCH_TILT,       -1,             KazuyaSpecial.CROUCH_JAB.main,  0,                              0x800D8C14,                         0x800DDF44)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(KAZUYA,   0x0,            File.KAZUYA_IDLE,              -1,                         -1)

    Character.table_patch_start(variants, Character.id.KAZUYA, 0x4)
    db      Character.id.NONE   // set as SPECIAL variant for RYU
    db      Character.id.NONE
    db      Character.id.NONE
    db      Character.id.NONE
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.KAZUYA, 0x4)
    float32 1
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.KAZUYA, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

	// Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.KAZUYA, 0x2)
    dh  0x02EA
    OS.patch_end()

    // Disable rapid jab
    Character.table_patch_start(rapid_jab, Character.id.KAZUYA, 0x4)
    dw      Character.rapid_jab.DISABLED        // disable rapid jab
    OS.patch_end()

    // Set default costumes
    // Character.set_default_costumes(Character.id.KAZUYA, 0, 1, 2, 3, 4, 5, 1)
    // Teams.add_team_costume(YELLOW, KAZUYA, 6)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(KAZUYA, BROWN, BLUE, AZURE, PURPLE, GREEN, RED, YELLOW, NA)

    // Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.KAZUYA, 0xC)
    dw Character.kirby_inhale_struct.star_damage.DK
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.KAZUYA, 0xC)
    dh 0x11
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.KAZUYA, 0x4)
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

        string_0x0F3:; String.insert("WhileStand")
        string_0x0F4:; String.insert("Wavedash")
        string_0x0F5:; String.insert("GodFist")
        string_0x0F6:; String.insert("CrouchJab")
        string_0x0F7:; String.insert("SWEEP1")
        string_0x0F8:; String.insert("SWEEP2")
        string_0x0F9:; String.insert("UpTilt2")
        string_0x0FA:; String.insert("CrouchTilt")
        string_0x0FB:; String.insert("FTiltClose")
        string_0x0FC:; String.insert("TatsumakiStrong")
        string_0x0FD:; String.insert("TatsumakiAirGround")
        string_0x0FE:; String.insert("ShoryukenHard")

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
        dw string_0x0FE
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.KAZUYA, 0x4)
    dw  Action.action_string_table
    OS.patch_end()
}
