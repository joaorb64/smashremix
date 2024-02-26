// Cloud.asm

// This file contains file inclusions, action edits, and assembly for Cloud.

scope Cloud {
    insert JAB1,"moveset/JAB1.bin"
    insert JAB2,"moveset/JAB2.bin"
    insert JAB3,"moveset/JAB3.bin"

    insert GRAB,"moveset/GRAB.bin"

    insert AIRN,"moveset/AIRN.bin"
    insert AIRU,"moveset/AIRU.bin"
    insert AIRD,"moveset/AIRD.bin"
    insert AIRF,"moveset/AIRF.bin"
    insert AIRB,"moveset/AIRB.bin"
    insert TILTF,"moveset/TILTF.bin"
    insert TILTU,"moveset/TILTU.bin"
    insert TILTD,"moveset/TILTD.bin"
    insert DASHATTACK,"moveset/DASHATTACK.bin"
    insert SPECIALHI,"moveset/SPECIALHI.bin"
    insert SPECIALHI2,"moveset/SPECIALHI2.bin"
    insert NSP,"moveset/NSP.bin"
    insert SPECIALHI_LAND,"moveset/SPECIALHI_LAND.bin"
    insert SPECIALLW1,"moveset/DSP_1.bin"
    insert SPECIALLW2,"moveset/DSP_2.bin"
    insert SPECIALLW3,"moveset/DSP_3.bin"
    insert SMASHU,"moveset/SMASHU.bin"
    insert SMASHF,"moveset/SMASHF.bin"
    insert SMASHD,"moveset/SMASHD.bin"

    insert JUMP1,"moveset/JUMP1.bin"

    // Insert AI attack options
    // constant CPU_ATTACKS_ORIGIN(origin())
    // insert CPU_ATTACKS,"AI/attack_options.bin"
    // OS.align(16)

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(CLOUD,   Action.Entry,           File.CLOUD_IDLE,              -1,                         -1)
    Character.edit_action_parameters(CLOUD,   0x006,                  File.CLOUD_IDLE,              -1,                         -1)
    Character.edit_action_parameters(CLOUD,   Action.Idle,            File.CLOUD_IDLE,              -1,                         -1)
    Character.edit_action_parameters(CLOUD,   Action.Dash,            File.CLOUD_DASH,              -1,                         -1)
    Character.edit_action_parameters(CLOUD,   Action.Fall,            File.CLOUD_FALL,              -1,                         -1)
    Character.edit_action_parameters(CLOUD,   Action.FallAerial,      File.CLOUD_FALL_AERIAL,       -1,                         -1)
    Character.edit_action_parameters(CLOUD,   Action.FallSpecial,     File.CLOUD_FALL_SPECIAL,      -1,                         -1)
    Character.edit_action_parameters(CLOUD,   Action.JumpF,           File.CLOUD_JUMPF,          JUMP1,                         0x00000000)
    Character.edit_action_parameters(CLOUD,   Action.JumpAerialF,     File.CLOUD_JUMPAERIALF,       -1,                         0x00000000)
    Character.edit_action_parameters(CLOUD,   Action.JumpB,           File.CLOUD_JUMPB,          JUMP1,                         -1)
    Character.edit_action_parameters(CLOUD,   Action.JumpAerialB,     File.CLOUD_JUMPAERIALB,       -1,                         0x00000000)

    Character.edit_action_parameters(CLOUD,   Action.Grab,            File.CLOUD_GRAB,              GRAB,                       -1)
    Character.edit_action_parameters(CLOUD,   Action.GrabPull,        File.CLOUD_GRABPULL,          -1,                         -1)

    Character.edit_action_parameters(CLOUD,   Action.Jab1,            File.CLOUD_JAB1,              JAB1,                       0x00000000)
    Character.edit_action_parameters(CLOUD,   Action.Jab2,            File.CLOUD_JAB2,              JAB2,                       0x40000000)
    Character.edit_action_parameters(CLOUD,   0xDC,                   File.CLOUD_JAB3,              JAB3,                       0x40000000)

    Character.edit_action_parameters(CLOUD,   Action.AttackAirN,      File.CLOUD_AIRN,            AIRN,                       -1)
    Character.edit_action_parameters(CLOUD,   Action.AttackAirU,      File.CLOUD_AIRU,            AIRU,                       -1)
    Character.edit_action_parameters(CLOUD,   Action.AttackAirD,      File.CLOUD_AIRD,            AIRD,                       -1)
    Character.edit_action_parameters(CLOUD,   Action.AttackAirF,      File.CLOUD_AIRF,            AIRF,                       -1)
    Character.edit_action_parameters(CLOUD,   Action.AttackAirB,      File.CLOUD_AIRB,            AIRB,                       -1)
    Character.edit_action_parameters(CLOUD,   Action.FTilt,           File.CLOUD_TILTF,           TILTF,                      0x40000000)
    Character.edit_action_parameters(CLOUD,   Action.UTilt,           File.CLOUD_TILTU,           TILTU,                      -1)
    Character.edit_action_parameters(CLOUD,   Action.DTilt,           File.CLOUD_TILTD,           TILTD,                      0x40000000)
    Character.edit_action_parameters(CLOUD,   Action.DashAttack,      File.CLOUD_DASH_ATTACK,     DASHATTACK,                 0x40000000)

    Character.edit_action_parameters(CLOUD,   Action.USmash,          File.CLOUD_SMASHU,          SMASHU,                     0x40000000)
    Character.edit_action_parameters(CLOUD,   Action.FSmash,          File.CLOUD_SMASHF,          SMASHF,                     0x40000000)
    Character.edit_action_parameters(CLOUD,   Action.DSmash,          File.CLOUD_SMASHD,          SMASHD,                     0x80000000)

    Character.edit_action_parameters(CLOUD,   0xE2,                   File.CLOUD_SPECIALHI,                         -1,                 0x40000000)
    Character.edit_action_parameters(CLOUD,   0xE4,                   File.CLOUD_SPECIALHI,                         -1,                 0x40000000)
    Character.edit_action_parameters(CLOUD,   0xE4,                   File.CLOUD_SPECIALHI,                         -1,                 0x40000000)
    Character.edit_action_parameters(CLOUD,   0xE5,                   File.CLOUD_SPECIALN,                          NSP,                        -1)
    Character.edit_action_parameters(CLOUD,   0xE8,                   File.CLOUD_SPECIALN,                          NSP,                        -1)

    Character.edit_action_parameters(CLOUD,   0x0EB,                   File.CLOUD_SPECIALLW1,                       SPECIALLW1,                      -1)
    Character.edit_action_parameters(CLOUD,   0x0EC,                   File.CLOUD_SPECIALLW1,                       SPECIALLW1,                      -1)


    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(CLOUD, 0x0,               File.CLOUD_IDLE,              -1,                       -1)
    Character.edit_menu_action_parameters(CLOUD, 0x1,               File.CLOUD_VICTORY,           -1,                       -1)
    Character.edit_menu_action_parameters(CLOUD, 0x2,               File.CLOUD_VICTORY,           -1,                       -1)
    Character.edit_menu_action_parameters(CLOUD, 0x3,               File.CLOUD_VICTORY,           -1,                       -1)
    Character.edit_menu_action_parameters(CLOUD, 0x4,               File.CLOUD_VICTORY,           -1,                       -1)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(CLOUD,  0xE5,              -1,             CloudNSP.main,  				CloudNSP.change_direction_,      CloudNSP.physics_,                -1)
	Character.edit_action(CLOUD,  0xE8,              -1,             CloudNSP.main,  				CloudNSP.change_direction_,      CloudNSP.physics_,                CloudNSP.air_collision_)

    Character.edit_action(CLOUD,  0xEB,              -1,             CloudDSP.main,                  0,                              0x800D8BB4,                       -1)
    Character.edit_action(CLOUD,  0xEC,              -1,             CloudDSP.main,                  0,                              CloudDSP.physics,                CloudDSP.air_collision_)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                    // Moveset Data             // Flags
    Character.add_new_action_params(CLOUD,    USP,             -1,             File.CLOUD_SPECIALHI,            SPECIALHI,                  0x40000000)
    Character.add_new_action_params(CLOUD,    USP2,            -1,             File.CLOUD_SPECIALHI2,           SPECIALHI2,                 0x00000000)
    Character.add_new_action_params(CLOUD,    USP_LAND,        -1,             File.CLOUD_SPECIALHI_LAND,       SPECIALHI_LAND,             0x00000000)

    Character.add_new_action_params(CLOUD,    SPECIALLW2,        -1,           File.CLOUD_SPECIALLW2,       SPECIALLW2,             0x00000000)
    Character.add_new_action_params(CLOUD,    SPECIALLW2_AIR,    -1,           File.CLOUD_SPECIALLW2,       SPECIALLW2,             0x00000000)
    Character.add_new_action_params(CLOUD,    SPECIALLW3,        -1,           File.CLOUD_SPECIALLW3,       SPECIALLW3,             0x00000000)
    Character.add_new_action_params(CLOUD,    SPECIALLW3_AIR,    -1,           File.CLOUD_SPECIALLW3,       SPECIALLW3,             0x00000000)

    // Add Actions                   // Action Name     // Base Action  //Parameters                    // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(CLOUD,    USP,              -1,             ActionParams.USP,                -1,           CloudUSP.main_,                   CloudUSP.change_direction_,     CloudUSP.physics_,                CloudUSP.collision_)
    Character.add_new_action(CLOUD,    USP2,             -1,             ActionParams.USP2,               -1,           0x00000000,                       0,                              CloudUSP.physics2_,               CloudUSP.usp2_collision_)
    Character.add_new_action(CLOUD,    USP_LAND,         -1,             ActionParams.USP_LAND,           -1,           0x800D94C4,                       0,                              0x800D8BB4,                       0x800DDF44)

    Character.add_new_action(CLOUD,    SPECIALLW2,         -1,           ActionParams.SPECIALLW2,           -1,           CloudDSP.main,                  0,                              0x800D8BB4,                       -1)
    Character.add_new_action(CLOUD,    SPECIALLW2_AIR,     -1,           ActionParams.SPECIALLW2_AIR,       -1,           CloudDSP.main,                  0,                              CloudDSP.physics,                CloudDSP.air_collision_)
    Character.add_new_action(CLOUD,    SPECIALLW3,         -1,           ActionParams.SPECIALLW3,           -1,           CloudDSP.main,                  0,                              0x800D8BB4,                       -1)
    Character.add_new_action(CLOUD,    SPECIALLW3_AIR,     -1,           ActionParams.SPECIALLW3_AIR,       -1,           CloudDSP.main,                  0,                              CloudDSP.physics,                CloudDSP.air_collision_)

    // Character.table_patch_start(variants, Character.id.CLOUD, 0x4)
    // db      Character.id.NONE   // set as SPECIAL variant for CLOUD
    // db      Character.id.NONE
    // db      Character.id.NONE
    // db      Character.id.NONE
    // OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.CLOUD, 0, 1, 1, 1, 1, 1, 0)
    Teams.add_team_costume(YELLOW, CLOUD, 0x1)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(CLOUD, GREEN, WHITE, RED, AZURE, PINK, BLACK, YELLOW, NA)

    // // Shield colors for costume matching
    // Character.set_costume_shield_colors(CLOUD, GREEN, WHITE, RED, AZURE, PINK, BLACK, YELLOW, NA)

    // Disable rapid jab
    Character.table_patch_start(rapid_jab, Character.id.CLOUD, 0x4)
    dw      Character.rapid_jab.DISABLED        // disable rapid jab
    OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.CLOUD, 0x4)
    dw      CloudUSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.CLOUD, 0x4)
    dw      CloudUSP.ground_initial_
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.CLOUD, 0x4)
    dw  Action.LINK.action_string_table
    OS.patch_end()
}
