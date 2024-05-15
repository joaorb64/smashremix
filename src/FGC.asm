// for toggles related to FGC character's features

// FGC.asm
if !{defined __FGC__} {
define __FGC__()
print "included FGC.asm\n"

include "Color.asm"
include "FGM.asm"
include "Global.asm"
include "OS.asm"
include "String.asm"

scope FGC {
    constant FGC_PROJECTILE_ID(0x100A)

    constant B_PRESSED(0x4000)                // bitmask for b press
    constant A_PRESSED(0x8000)                // bitmask for b press

    constant TURNAROUND_X_RANGE_BACK(0x44C8)            // current setting - float: 1600.0

    constant MAX_X_RANGE_FORWARD(0x43C8)            // current setting - float: 400.0
    constant MAX_X_RANGE_BACK(0x4370)            // current setting - float: 240.0
    constant MAX_Y_RANGE_UP(0x447A)            // current setting - float: 1000.0
    constant MAX_Y_RANGE_DOWN(0x4348)            // current setting - float: 200.0

    special_cancel_buffer:
    db 0x00 //p1
    db 0x00 //p2
    db 0x00 //p3
    db 0x00 //p4

    // Ryu auto turnaround logic
    // https://decomp.me/scratch/d0Ors 0x800E1260 @ 0x700
    // @ 488
    scope fcg_tap_hold: {
        OS.patch_start(0x5D160, 0x800E1960)
        j       fcg_tap_hold
        nop
        fcg_tap_hold_end_:
        OS.patch_end()

        jal jab_movement_fix
        nop

        // a2 = fighter struct
        // t1, t2, t3, t4 = zero

        OS.save_registers()

        lw      t1, 0x0008(a2)              // t0 = character id
        ori     t2, r0, Character.id.RYU    // t1 = id.RYU
        beq     t1, t2, ryuken_logic
        nop

        lw      t1, 0x0008(a2)              // t0 = character id
        ori     t2, r0, Character.id.KEN    // t1 = id.RYU
        beq     t1, t2, ryuken_logic
        nop

        lw      t1, 0x0008(a2)              // t0 = character id
        ori     t2, r0, Character.id.KAZUYA    // t1 = id.KAZUYA
        beq     t1, t2, demon_logic
        nop

        b goto_fcg_tap_hold_end_
        nop

        ryuken_logic:
        lw t1,  0x4(a2)                     // t1 = fighter object
        lwc1    f8, 0x0078(t1)              // load current frame into f8

        // Fix a bug where the next action would be triggered after changing from a move to neutral
        // because the action would still be the previous one, but the frame would be less than 0
        // since the previous animation just finished
        lui		at, 0x3f80					// at = 0.0
		mtc1    at, f6                      // ~
        c.le.s  f8, f6                      // f8 <= f6 (current frame < 0) ?
        nop
        bc1tl   goto_fcg_tap_hold_end_    // skip if frame < 0
        nop

        // Load special cancel window buffer
        lbu     t1, 0x000D(a2)              // t1 = player port
        li      t2, special_cancel_buffer   // ~
        addu    t3, t2, t1                  // t3 = px special_cancel_buffer address
        lbu     t1, 0x0000(t3)              // t2 = special_cancel_buffer

        blez t1, thingie // if cancel window <= 0, skip
        nop

        // else, check for cancels
        subi t1, 0x1                    // special_canceL_buffer -= 1
        sb   t1, 0x0000(t3)              // update special_cancel_buffer

        lw t2,  0x4(a2)                     // t2 = fighter object

        lhu     t0, 0x01BC(a2)              // load button press buffer
        lhu     t1, 0x01BE(a2)              // load button hold buffer

        or     t0, t0, t1                  // join both so we cover press or hold

        andi    t1, t0, B_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, hitlag_step_attacker_jab                // skip if (!B_PRESSED)
        nop

        lw      t0, 0x0008(a2)              // t0 = character id
        ori     t1, r0, Character.id.RYU    // t1 = id.RYU
        beq     t0, t1, check_move_cancel_ryu
        nop

        lw      t0, 0x0008(a2)              // t0 = character id
        ori     t1, r0, Character.id.KEN    // t1 = id.RYU
        beq     t0, t1, check_move_cancel_ryu
        nop

        b thingie
        nop

        hitlag_step_attacker_jab:
        lw t2,  0x4(a2)                     // t2 = fighter object

        lhu     t0, 0x01BC(a2)              // load button press buffer
        lhu     t1, 0x01BE(a2)              // load button hold buffer

        or     t0, t0, t1                  // join both so we cover press or hold

        andi    t1, t0, A_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, thingie                // skip if (!A_PRESSED)
        nop

        lw      t0, 0x0008(a2)              // t0 = character id
        ori     t1, r0, Character.id.RYU    // t1 = id.RYU
        beq     t0, t1, check_jab_cancel_ryu
        nop

        lw      t0, 0x0008(a2)              // t0 = character id
        ori     t1, r0, Character.id.KEN    // t1 = id.RYU
        beq     t0, t1, check_jab_cancel_ryu
        nop

        b thingie
        nop
        
        check_jab_cancel_ryu:
        lw      t0, 0x0024(a2) // t0 = current action

        // we're using t2 to set the action to change to

        lli    t1, Ryu.Action.JAB_L
        lli    t2, Ryu.Action.JAB_L2
        beq    t0, t1, apply_jab_cancel
        nop

        lli    t1, Ryu.Action.JAB_L2
        lli    t2, Ryu.Action.JAB_L3
        beq    t0, t1, apply_jab_cancel
        nop

        j thingie
        nop

        apply_jab_cancel:
        // we're using t2 to set the action to change to
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)
        sw      a1, 0x0008(sp)
        sw      a2, 0x000C(sp)              // store variables
        sw      a3, 0x0010(sp)              // store variables
        addiu   sp, sp,-0x0030              // allocate stack space
        
        lw      a0, 0x4(a2)                 // a0 = player object
        sw      r0, 0x0010(sp)              // argument 4 = 0
        or      a1, r0, t2
        lui     a2, 0x3F80                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        nop

        b apply_move_cancel_ground_end
        nop

        check_move_cancel_ryu:
        lw      t0, 0x0024(a2) // t0 = current action

        lli    t1, Action.AttackAirN
        beq t0, t1, apply_move_cancel_air
        nop
        lli    t1, Action.AttackAirF
        beq t0, t1, apply_move_cancel_air
        nop
        lli    t1, Action.AttackAirB
        beq t0, t1, apply_move_cancel_air
        nop
        lli    t1, Action.AttackAirU
        beq t0, t1, apply_move_cancel_air
        nop
        lli    t1, Action.AttackAirD
        beq t0, t1, apply_move_cancel_air
        nop
        lli    t1, Action.DTilt
        beq t0, t1, apply_move_cancel_ground
        nop
        lli    t1, Ryu.Action.DTILT_L
        beq t0, t1, apply_move_cancel_ground
        nop
        lli    t1, Action.UTilt
        beq t0, t1, apply_move_cancel_ground
        nop
        lli    t1, Ryu.Action.UTILT_L
        beq t0, t1, apply_move_cancel_ground
        nop
        lli    t1, Action.DSmash
        beq t0, t1, apply_move_cancel_ground
        nop
        lli    t1, Ryu.Action.JAB_CLOSE
        beq t0, t1, apply_move_cancel_ground
        nop
        lli    t1, Ryu.Action.FTILT_CLOSE
        beq t0, t1, apply_move_cancel_ground
        nop
        lli    t1, Ryu.Action.JAB_L
        beq t0, t1, apply_move_cancel_ground
        nop
        lli    t1, Ryu.Action.JAB_L2
        beq t0, t1, apply_move_cancel_ground
        nop

        j thingie
        nop

        apply_move_cancel_air:
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)
        sw      a1, 0x0008(sp)
        sw      a2, 0x000C(sp)              // store variables
        sw      a3, 0x0010(sp)              // store variables
        addiu   sp, sp,-0x0030              // allocate stack space

        lb      t0, 0x01C3(a2)              // a1 = stick_y

        slti    t1, t0, 40                             // at = 1 if stick_y < 40, else at = 0
        beql    t1, r0, apply_move_cancel_airU      // branch if stick_y >= 40...
        nop

        slti    t1, t0, -39                                 // at = 1 if stick_y < -39, else at = 0
        bnel    t1, r0, apply_move_cancel_airD          // branch if stick_y >= -40...
        nop

        b apply_move_cancel_airN
        nop

        apply_move_cancel_airU:
        jal RyuUSP.air_initial_
        nop
        b apply_move_cancel_ground_end
        nop

        apply_move_cancel_airD:
        lw      a0, 0x4(a2)                 // a0 = player object
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, 0xE9
        lui     a2, 0x3F80
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        nop
        
        b apply_move_cancel_ground_end
        nop

        apply_move_cancel_airN:
        lw      a0, 0x4(a2)                 // a0 = player object
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, 0xE5
        lui     a2, 0x3F80
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        nop

        b apply_move_cancel_ground_end
        nop

        apply_move_cancel_ground:
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)
        sw      a1, 0x0008(sp)
        sw      a2, 0x000C(sp)              // store variables
        sw      a3, 0x0010(sp)              // store variables
        addiu   sp, sp,-0x0030              // allocate stack space

        lb      t0, 0x01C3(a2)              // a1 = stick_y

        slti    t1, t0, 40                             // at = 1 if stick_y < 40, else at = 0
        beql    t1, r0, apply_move_cancel_groundU      // branch if stick_y >= 40...
        nop

        slti    t1, t0, -39                                 // at = 1 if stick_y < -39, else at = 0
        bnel    t1, r0, apply_move_cancel_groundD          // branch if stick_y >= -40...
        nop

        b apply_move_cancel_groundN
        nop

        apply_move_cancel_groundU:
        jal RyuUSP.ground_initial_
        nop
        b apply_move_cancel_ground_end
        nop

        apply_move_cancel_groundD:
        lw      a0, 0x4(a2)                 // a0 = player object
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, 0xE6
        lui     a2, 0x3F80
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        nop
        
        b apply_move_cancel_ground_end
        nop

        apply_move_cancel_groundN:
        lw      a0, 0x4(a2)                 // a0 = player object
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, 0xE4
        lui     a2, 0x3F80
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        nop

        b apply_move_cancel_ground_end
        nop

        apply_move_cancel_ground_end:
        addiu   sp, sp, 0x0030              // allocate stack space
        lw      ra, 0x0004(sp)              // restore ra
        lw      a1, 0x0008(sp)
        lw      a2, 0x000C(sp)              // restore a2
        lw      a3, 0x0010(sp)              // restore a2
        addiu   sp, sp, 0x0030              // deallocate stack space

        lbu     t0, 0x000D(a2)              // t0 = player port
        li      t1, special_cancel_buffer   // ~
        addu    t0, t0, t1                  // t0 = px special_cancel_buffer address
        lli     t1, 0x0
        sb      t1, 0x0000(t0)              // set special_cancel_buffer to zero

        j goto_fcg_tap_hold_end_
        nop

        thingie:
        lw t1,  0x4(a2)                     // t1 = fighter object
        lwc1    f8, 0x0078(t1)              // load current frame into f8

        // If on first animation frame, check if we have to change to the proximity move
        lui at, 0x4000
        mtc1 at, f6
        c.eq.s f8, f6
        nop
        bc1tl fgc_target_check
        nop

        // If we're Ken doing the roundhouse command move,
        // go to its logic block
        lw      t0, 0x0008(a2)              // t0 = character id
        ori     t1, r0, Character.id.KEN    // t1 = id.KEN
        bne     t0, t1, button_check
        nop

        lw     t1, 0x0024(a2) // t0 = current action
        lli    t2, Ken.Action.ROUNDHOUSE
        beq    t1, t2, ken_roundhouse_part2
        nop

        lw     t1, 0x0024(a2) // t0 = current action
        lli    t2, Ken.Action.COMMAND_KICK
        beq    t1, t2, ken_roundhouse_part2
        nop

        lw     t1, 0x0024(a2) // t0 = current action
        lli    t2, Action.Jab1
        beq    t1, t2, ken_jab1_fix
        nop

        b button_check
        nop

        ken_jab1_fix:
        li t0, 0x800D8C14
        sw t0, 0x9E0(a2)
        b button_check
        nop

        ken_roundhouse_part2:
        lhu     t0, 0x01BC(a2)              // load button press buffer
        lhu     t1, 0x01BE(a2)              // load button hold buffer

        or     t0, t0, t1                  // join both so we cover press or hold

        andi    t1, t0, B_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, button_check                // skip if (!B_PRESSED)
        nop

        ken_roundhouse_part2_check_frame:
        lw t1,  0x4(a2)                     // t1 = fighter object
        lwc1    f8, 0x0078(t1)              // load current frame into f8
        
        lui		at, 0x4130					// at = 11.0
		mtc1    at, f6                      // ~
        c.eq.s  f8, f6                      // f8 <= f6 (current frame < 3) ?
        nop
        bc1fl   button_check                // skip if frame != at
        nop

        // if we're here B is held and we're at the right frame
        addiu  t3, r0, Ken.Action.COMMAND_KICK_2

        OS.save_registers()

        addiu   s0, a2, 0
        sw      r0, 0x0010(sp)              // argument 4 = 0
        addiu   a1, t3, 0
        lui     a2, 0x40E0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x4(s0)                 // a0 = player object

        OS.restore_registers()

        j goto_fcg_tap_hold_end_
        nop

        button_check:
        // check current animation frame
        lw t1,  0x4(a2)                     // t1 = fighter object
        lwc1    f8, 0x0078(t1)              // load current frame into f8
        
        lui		at, 0x40C0					// at = 3.0
		mtc1    at, f6                      // ~
        c.le.s  f8, f6                      // f8 <= f6 (current frame < 3) ?
        nop
        bc1fl   goto_fcg_tap_hold_end_      // skip if frame > 3
        nop
        
        lhu     t1, 0x01BC(a2)                  // load button press buffer
        andi    t2, t1, A_PRESSED               // t2 = 0x80 if (A_PRESSED); else t2 = 0
        bne     t2, r0, goto_fcg_tap_hold_end_  // skip if A_PRESSED (wasn't released)
        nop
        // else, check action

        check_action:
        lw      t1, 0x0024(a2) // t0 = current action

        // we'll use t3 to define the action to switch to

        lli    t2, Action.Jab1
        beq    t1, t2, change_action
        addiu  t3, r0, Ryu.Action.JAB_L

        lli    t2, Ryu.Action.JAB_CLOSE
        beq    t1, t2, change_action
        addiu  t3, r0, Ryu.Action.JAB_L

        lli    t2, Action.DTilt
        beq    t1, t2, change_action
        addiu  t3, r0, Ryu.Action.DTILT_L

        lli    t2, Action.UTilt
        beq    t1, t2, change_action
        addiu  t3, r0, Ryu.Action.UTILT_L

        lli    t2, Action.FTilt
        beq    t1, t2, change_action
        addiu  t3, r0, Ryu.Action.FTILT_L

        lli    t2, Action.FTiltHigh
        beq    t1, t2, change_action
        addiu  t3, r0, Ryu.Action.FTILT_L

        lli    t2, Action.FTiltMidHigh
        beq    t1, t2, change_action
        addiu  t3, r0, Ryu.Action.FTILT_L

        lli    t2, Action.FTiltMidLow
        beq    t1, t2, change_action
        addiu  t3, r0, Ryu.Action.FTILT_L

        lli    t2, Action.FTiltLow
        beq    t1, t2, change_action
        addiu  t3, r0, Ryu.Action.FTILT_L

        j goto_fcg_tap_hold_end_
        nop

        change_action:
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)
        sw      a0, 0x0008(sp)
        sw      a1, 0x000C(sp)              // store variables
        sw      a2, 0x0010(sp)              // store variables
        sw      a3, 0x0014(sp)              // store variables
        sw      v0, 0x0018(sp)              // store variables
        addiu   sp, sp,-0x0030              // allocate stack space

        addiu   s0, a2, 0
        sw      r0, 0x0010(sp)              // argument 4 = 0
        addiu   a1, t3, 0
        lui     a2, 0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x4(s0)                 // a0 = player object

        addiu   sp, sp, 0x0030              // allocate stack space
        lw      ra, 0x0004(sp)              // restore ra
        lw      a0, 0x0008(sp)
        lw      a1, 0x000C(sp)              // restore a2
        lw      a2, 0x0010(sp)              // restore a2
        lw      a3, 0x0014(sp)              // restore a2
        lw      v0, 0x0018(sp)              // restore a2
        addiu   sp, sp, 0x0030              // deallocate stack space

        j goto_fcg_tap_hold_end_
        nop

        goto_fcg_tap_hold_end_:
        OS.restore_registers()
        
        lw v0, 0x0174(a2) // original line 1
        slti at, v0, 0x0002 // original line 2
        // lbu     t9,0x191(a2) // original line 1 (488)
        // lw      t3,0x40(a2) // original line 2

        j fcg_tap_hold_end_
        nop

        // @ Description
        // Subroutine which checks for valid targets for Sonic's homing attack.
        // a0 - player object
        scope check_for_targets_: {
            addiu   sp, sp,-0x0050              // allocate stack space
            sw      ra, 0x001C(sp)              // ~
            sw      s0, 0x0020(sp)              // ~
            sw      s1, 0x0024(sp)              // ~
            sw      s2, 0x0028(sp)              // store ra, s0-s2

            or      s0, a0, r0                  // s0 = Sonic player object
            li      s1, 0x800466FC              // s1 = player object head
            lw      s1, 0x0000(s1)              // s1 = first player object
            lw      s2, 0x0084(s0)              // s2 = player struct

            _player_loop:
            beqz    s1, _player_loop_exit       // exit loop when s1 no longer holds an object pointer
            nop
            beql    s1, s0, _player_loop        // loop if player and target object match...
            lw      s1, 0x0004(s1)              // ...and load next object into s1

            _team_check:
            li      t0, Global.match_info       // ~
            lw      t0, 0x0000(t0)              // t0 = match info struct
            lbu     t1, 0x0002(t0)              // t1 = team battle flag
            beqz    t1, _action_check           // branch if team battle flag = FALSE
            lbu     t1, 0x0009(t0)              // t1 = team attack flag
            bnez    t1, _action_check           // branch if team attack flag != FALSE
            nop

            // if the match is a team battle with team attack disabled
            lw      t0, 0x0084(s1)              // t0 = target player struct
            lbu     t0, 0x000C(t0)              // t0 = target team
            lbu     t1, 0x000C(s2)              // t1 = player team
            beq     t0, t1, _player_loop_end    // skip if player and target are on the same team
            nop

            _action_check:
            lw      t0, 0x0084(s1)              // t0 = target player struct
            lw      t0, 0x0024(t0)              // t0 = target player action
            sltiu   at, t0, 0x0007              // at = 1 if action id < 7, else at = 0
            bnez    at, _player_loop_end        // skip if target action id < 7 (target is in a KO action)
            nop

            _target_check:
            or      a0, s2, r0                  // a0 = player struct
            lw      a1, 0x0074(s1)              // a1 = target top joint struct
            jal     check_target_               // check_target_
            or      a2, s1, r0                  // a2 = target object struct
            beqz    v0, _player_loop_end        // branch if no new target
            nop

            // if check_target_ returned a new valid target
            sw      v0, 0x0B18(s2)              // store target object
            sw      v1, 0x0B1C(s2)              // store target X_DIFF

            _player_loop_end:
            b       _player_loop                // loop
            lw      s1, 0x0004(s1)              // s1 = next object

            _player_loop_exit:
            lw      t0, 0x0B18(s2)              // t0 = target object
            bnez    t0, _end                    // end if there is a targeted object
            nop

            li      s1, 0x80046700              // s1 = item object head
            lw      s1, 0x0000(s1)              // s1 = first item object

            _item_loop:
            beqz    s1, _end                    // exit loop when s1 no longer holds an object pointer
            nop

            lw      t0, 0x0084(s1)              // t0 = item special struct
            lw      t0, 0x0248(t0)              // t0 = bit field with hurtbox state
            andi    t0, t0, 0x0001              // t0 = 1 if hurtbox is enabled, else t0 = 0
            beqz    t0, _item_loop_end          // skip if item doesn't have an active hurtbox
            nop
            or      a0, s2, r0                  // a0 = player struct
            lw      a1, 0x0074(s1)              // a1 = target top joint struct
            jal     check_target_               // check_target_
            or      a2, s1, r0                  // a2 = target object struct
            beqz    v0, _item_loop_end          // branch if no new target
            nop

            // if check_target_ returned a new valid target
            sw      v0, 0x0B18(s2)              // store target object
            sw      v1, 0x0B1C(s2)              // store target X_DIFF

            _item_loop_end:
            b       _item_loop                  // loop
            lw      s1, 0x0004(s1)              // s1 = next object

            _end:
            lw      ra, 0x001C(sp)              // ~
            lw      s0, 0x0020(sp)              // ~
            lw      s1, 0x0024(sp)              // ~
            lw      s2, 0x0028(sp)              // load ra, s0-s2
            addiu   sp, sp, 0x0050              // deallocate stack space
            jr      ra                          // return
            nop
        }

        // @ Description
        // Subroutine which checks if a potential target is in range for Sonic's homing attack.
        // a0 - player struct
        // a1 - target top joint struct
        // a2 - target object struct
        // returns
        // v0 - target object (NULL when no valid target)
        // v1 - target X_DIFF
        scope check_target_: {
            lw      t8, 0x0078(a0)              // t8 = player x/y/z coordinates
            addiu   t9, a1, 0x001C              // t9 = target x/y/z coordinates

            // check if the target is within x range
            mtc1    r0, f0                      // f0 = 0
            lwc1    f2, 0x0000(t8)              // f2 = player x coordinate
            lwc1    f4, 0x0000(t9)              // f4 = target x coordinate
            sub.s   f10, f4, f2                 // f10 = X_DIFF (target x - player x)
            lwc1    f8, 0x0044(a0)              // ~
            cvt.s.w f8, f8                      // f8 = DIRECTION
            mul.s   f10, f10, f8                // f10 = X_DIFF * DIRECTION
            lui     at, MAX_X_RANGE_FORWARD     // at = MAX_X_RANGE_FORWARD
            mtc1    at, f8                      // f8 = MAX_X_RANGE_FORWARD
            c.le.s  f10, f8                     // ~
            nop                                 // ~
            bc1fl   _end                        // end if MAX_X_RANGE =< X_DIFF
            or      v0, r0, r0                  // and return 0
            lui     at, TURNAROUND_X_RANGE_BACK     // at = MAX_X_RANGE_BACK
            mtc1    at, f8                      // f8 = MAX_X_RANGE_BACK
            neg.s   f8, f8                      // f8 = -MAX_X_RANGE_BACK
            c.le.s  f8, f10                      // ~
            nop                                 // ~
            bc1fl   _end                        // end if X_DIFF =< MAX_X_RANGE_BACK
            or      v0, r0, r0                  // and return 0

            // check if there is a previous target
            lw      t0, 0x0B18(a0)              // t0 = current target
            beq     t0, r0, _check_y            // branch if there is no current target
            lwc1    f8, 0x0B1C(a0)              // f8 = current target X_DIFF

            // compare X_DIFF to see if the previous target was within closer x proximity
            c.le.s  f10, f8                     // ~
            nop                                 // ~
            bc1fl   _end                        // end if prev X_DIFF =< current X_DIFF
            or      v0, r0, r0                  // return 0

            _check_y:
            // calculate Y_RANGE based on X_DIFF, creating a cone shaped range
            lwc1    f2, 0x0004(t8)              // f2 = player y coordinate
            lwc1    f4, 0x0004(t9)              // f4 = target y coordinate
            sub.s   f12, f4, f2                 // f12 = Y_DIFF (target y - player y)

            lui     at, MAX_Y_RANGE_UP          // at = MAX_Y_RANGE_UP
            mtc1    at, f8                      // f8 = MAX_Y_RANGE_UP
            c.le.s  f12, f8                     // ~
            nop                                 // ~
            bc1fl   _end                        // end if Y_RANGE =< Y_DIFF
            or      v0, r0, r0                  // and return 0

            lui     at, MAX_Y_RANGE_DOWN        // at = MAX_Y_RANGE_DOWN
            mtc1    at, f8                      // f8 = MAX_Y_RANGE_DOWN
            neg.s   f8, f8                      // f8 = -MAX_Y_RANGE_DOWN
            c.le.s  f8, f12                     // ~
            nop                                 // ~
            bc1fl   _end                        // end if Y_RANGE >= Y_DIFF
            or      v0, r0, r0                  // return 0

            // if we're here then the target is the closest within range
            or      v0, a2, r0                  // v0 = target object
            mfc1    v1, f10                     // v1 = X_DIFF

            _end:
            jr      ra                          // return
            nop
        }

        fgc_target_check:
        lw      t0, 0x0024(a2) // t0 = current action

        lli    at, Action.Jab1
        beq    t0, at, fgc_target_check_continue
        nop

        lli    at, Ryu.Action.FTILT_L
        beq    t0, at, fgc_target_check_continue
        nop

        lli    at, Ryu.Action.DTILT_L
        beq    t0, at, fgc_target_check_continue
        nop

        lli    at, Action.DTilt
        beq    t0, at, fgc_target_check_continue
        nop

        lli    at, Action.UTilt
        beq    t0, at, fgc_target_check_continue
        nop

        lli    at, Ryu.Action.UTILT_L
        beq    t0, at, fgc_target_check_continue
        nop

        lli    at, Action.DSmash
        beq    t0, at, fgc_target_check_continue
        nop

        lli    at, Action.USmash
        beq    t0, at, fgc_target_check_continue
        nop

        lw      t2, 0x0008(a2)              // t0 = character id
        ori     t1, r0, Character.id.KEN    // t1 = id.KEN
        bne     t2, t1, button_check        // If character is not Ken, we stop here
        nop

        lli    at, Ken.Action.COMMAND_KICK
        beq    t0, at, fgc_target_check_continue
        nop

        b button_check
        nop

        fgc_target_check_continue:
        or      t5, r0, a0

        lw t6, 0x0B18(a0) //
        lw t7, 0x0B1C(a0) // save player struct variables

        sw      r0, 0x0B18(a2)              // target = NULL
        sw      r0, 0x0B1C(a2)              // X_DIFF = 0

        jal     check_for_targets_          // check_for_targets_
        lw      a0, 0x4(a2)                 // a0 = player object

        lw      t0, 0x0B18(a0)              // t0 = target object

        or a2, r0, a0 // restore a2
        sw t6, 0x0B18(a0) //
        sw t7, 0x0B1C(a0) // restore player struct variables
        or a0, r0, t5

        beq     v0, r0, button_check          // branch if no target was found
        nop

        // skip auto turnaround for ftilt
        lw t1, 0x0024(a2) // t1 = current action

        lli    at, Ryu.Action.FTILT_L
        beq    t1, at, after_turnaround
        nop

        // auto turnaround
        mtc1    v1, f0                      // f0 = xdiff
        mtc1    r0, f2                      // f2 = 0
        c.le.s  f2, f0
        bc1t    after_turnaround

        lw      t7, 0x0044(a2)              // t7 = DIRECTION
        subu    t7, r0, t7                  // ~
        sw      t7, 0x0044(a2)              // reverse and update DIRECTION

        mtc1    t7, f6                      // ~
        cvt.s.w f6, f6                      // f6 = direction
        lui     at, 0x8013                  // ~
        lwc1    f8, 0xFE90(at)              // at = rotation constant
        mul.s   f8, f8, f6                  // f8 = rotation constant * direction
        lw      t7, 0x08E8(a2)              // t6 = character control joint struct
        swc1    f8, 0x0034(t7)              // update character rotation to match direction

        after_turnaround:
        mtc1    v1, f8 // f8 = X_DIFF

        lui     at, MAX_X_RANGE_BACK        // at = MAX_X_RANGE_BACK
        mtc1    at, f6                      // f6 = MAX_X_RANGE_BACK
        neg.s   f8, f8                      // f6 = -MAX_X_RANGE_BACK
        c.le.s  f8, f6                     // ~
        nop                                 // ~
        bc1fl   button_check                // skip if X_DIFF =< MAX_X_RANGE_BACK
        nop

        lw t1, 0x0024(a2) // t0 = current action

        // we'll use t3 to define the action to switch to

        lli    t2, Action.Jab1
        beq    t1, t2, change_action
        addiu  t3, r0, Ryu.Action.JAB_CLOSE

        lli    t2, Ryu.Action.FTILT_L
        beq    t1, t2, change_action
        addiu  t3, r0, Ryu.Action.FTILT_CLOSE

        b button_check
        nop

        jab_movement_fix:
        OS.save_registers()

        lw      t0, 0x0024(a2)              // t0 = current action
        lw      t1, 0x0008(a2)              // t0 = character id

        ori     t2, r0, Character.id.CLOUD    // t1 = id.CLOUD
        beq     t1, t2, jab_movement_fix_cloud
        nop

        j jab_movement_fix_end
        nop

        jab_movement_fix_cloud:
        lli    t1, Action.Jab2
        beq    t0, t1, apply_root_motion
        nop

        lli    t1, 0xDC
        beq    t0, t1, apply_root_motion
        nop

        j jab_movement_fix_end
        nop

        apply_root_motion:
        li t0, 0x800D8C14
        sw t0, 0x9E0(a2)
        j jab_movement_fix_end
        nop

        jab_movement_fix_end:
        OS.restore_registers()
        jr ra

        demon_logic:
        lw      t0, 0x0024(a2)                   // t0 = current action
        lw      t1,  0x4(a2)                     // t1 = fighter object

        auto_turnaround_check:
        lw      t1,  0x4(a2)                     // t1 = fighter object
        lwc1    f8, 0x0078(t1)              // load current frame into f8
        
        // If on first animation frame, check if we have to change to the proximity move
        lui at, 0x4000
        mtc1 at, f6
        c.eq.s f8, f6
        nop
        bc1fl auto_turnaround_check_end
        nop

        lli    t1, Action.Jab1
        beq    t0, t1, apply_auto_turnaround
        nop

        lli    t1, Action.UTilt
        beq    t0, t1, apply_auto_turnaround
        nop

        lli    t1, Kazuya.Action.CROUCH_JAB
        beq    t0, t1, apply_auto_turnaround
        nop

        lli    t1, Kazuya.Action.CROUCH_TILT
        beq    t0, t1, apply_auto_turnaround
        nop

        lli    t1, Kazuya.Action.WHILE_STAND
        beq    t0, t1, apply_auto_turnaround
        nop

        b auto_turnaround_check_end
        nop
        
        apply_auto_turnaround:
        OS.save_registers()
        lw      a0, 0x4(a2) // a0 = fighter object
        jal     auto_turnaround
        nop
        OS.restore_registers()

        auto_turnaround_check_end:

        lli    t1, Action.Jab1
        beq    t0, t1, demon_apply_root_motion
        nop

        lli    t1, Action.Jab2
        beq    t0, t1, demon_apply_root_motion
        nop

        lli    t1, 0xDC // Jab3
        beq    t0, t1, demon_apply_root_motion
        nop

        lli    t1, Action.DSmash
        beq    t0, t1, demon_patch_dsmash
        nop

        lli     t1, Action.UTilt
        beq     t0, t1, demon_patch_utilt
        nop

        lli     t1, Action.Dash
        beq     t0, t1, demon_patch_dash
        nop

        lli     t1, Action.FTiltMidLow
        beq     t0, t1, demon_patch_tsunami
        nop

        lli     t1, Action.FTiltLow
        beq     t0, t1, demon_patch_tsunami
        nop

        lli     t1, Action.FTiltMidHigh
        beq     t0, t1, demon_patch_ftilthigh
        nop

        lli     t1, Action.FTiltHigh
        beq     t0, t1, demon_patch_ftilthigh
        nop
        
        lhu     t1, 0x01BE(a2)              // load button press buffer
        andi    t2, t1, A_PRESSED           // t2 = 0x80 if (A_PRESSED); else t2 = 0
        beq     t2, r0, demon_wavedash_check // skip if (!A_PRESSED)
        nop

        // we're using t2 to set the action to change to
        lli    t1, Action.CrouchEnd
        lli    t2, Kazuya.Action.WHILE_STAND
        beq    t0, t1, apply_jab_cancel
        nop

        lli    t1, Action.CrouchIdle
        beq    t0, t1, demon_resolve_crouch_move
        nop

        b demon_wavedash_check
        nop

        demon_resolve_crouch_move:
        // we're using t2 to set the action to change to
        lb      t2, 0x01C2(a2)                          // t2 = stick_x
        bgez    t2, demon_resolve_crouch_move_continue	// branch if positive value
        nop
        subu    t2, r0, t2					            // t2 = abs(stick.x)
        demon_resolve_crouch_move_continue:
        slti    t1, t2, 40                             // t1 = 1 if abs(stick_x) < 40
        lli     t2, Kazuya.Action.CROUCH_TILT
        beq     t1, r0, apply_jab_cancel
        nop
        
        // else, crouch jab
        lli    t2, Kazuya.Action.CROUCH_JAB
        b      apply_jab_cancel
        nop

        demon_apply_root_motion:
        li t0, 0x800D8C14
        sw t0, 0x9E0(a2)
        
        b goto_fcg_tap_hold_end_
        nop

        demon_patch_dsmash:
        // apply root motion
        li t0, 0x800D8C14
        sw t0, 0x9E0(a2)

        // At the end of Kazuya's down smash, we want him to be laying down
        // aka DownWait state
        lw  t1, 0x4(a2)                 // t1 = fighter object
        lw  at, 0x0078(t1)              // load current frame into f8

        bgtz    at, goto_fcg_tap_hold_end_
        nop

        jal 0x80144294 // ftCommon_DownWait_SetStatus
        nop
        
        b goto_fcg_tap_hold_end_
        nop

        demon_patch_utilt:
        // Change the main function used for utilt
        li t0, KazuyaSpecial.UTILT.main
        sw t0, 0x9D4(a2)

        b goto_fcg_tap_hold_end_
        nop

        demon_patch_dash:
        // Change the main function used for utilt
        li t0, KazuyaSpecial.DASH.main
        sw t0, 0x9D4(a2)

        b goto_fcg_tap_hold_end_
        nop

        demon_patch_tsunami:
        // Change the main function used for utilt
        li t0, KazuyaSpecial.TSUNAMI.main
        sw t0, 0x9D4(a2)

        b goto_fcg_tap_hold_end_
        nop

        demon_patch_ftilthigh:
        // Change the main function used for utilt
        li t0, KazuyaSpecial.RR3KICKS.main
        sw t0, 0x9D4(a2)

        b goto_fcg_tap_hold_end_
        nop

        demon_wavedash_check:
        lw      t0, 0x0024(a2)                   // t0 = current action

        lli    t1, Action.Dash

        bne     t0, t1, goto_fcg_tap_hold_end_
        nop

        lb      t0, 0x01C3(a2)                          // t0 = stick_y
        slti    t1, t0, -39                             // at = 1 if stick_y < -39, else at = 0
        bnel    t1, r0, apply_wavedash                  // branch if stick_y >= -40...
        nop

        b goto_fcg_tap_hold_end_
        nop

        apply_wavedash:
        // we're using t2 to set the action to change to
        lli    t2, Kazuya.Action.WAVEDASH
        b      apply_jab_cancel
        nop

        b goto_fcg_tap_hold_end_
        nop
    }

    // a0 = player object
    scope auto_turnaround: {
        OS.routine_begin(0x20)

        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        // sw      ra, 0x0010(sp)              // ~
        // sw      a1, 0x0014(sp)              // save registers

        lw      t0, 0x0084(a0)              // t0 = player struct

        lw      t6, 0x0B18(t0)              //
        lw      t7, 0x0B1C(t0)              // save player struct variables

        sw      r0, 0x0B18(t0)              // target = NULL
        sw      r0, 0x0B1C(t0)              // X_DIFF = 0

        jal     fcg_tap_hold.check_for_targets_          // check_for_targets_
        nop

        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~ restore a0, a1, a2

        lw      t0, 0x0084(a0)              // t0 = player struct

        sw      t6, 0x0B18(t0)              //
        sw      t7, 0x0B1C(t0)              // restore player struct variables

        beq     v0, r0, _end          // branch if no target was found
        nop

        // apply turnaround
        mtc1    v1, f0                      // f0 = xdiff
        mtc1    r0, f2                      // f2 = 0
        c.le.s  f2, f0
        bc1t    _end

        lw      t7, 0x0044(t0)              // t7 = DIRECTION
        subu    t7, r0, t7                  // ~
        sw      t7, 0x0044(t0)              // reverse and update DIRECTION

        mtc1    t7, f6                      // ~
        cvt.s.w f6, f6                      // f6 = direction
        lui     t2, 0x8013                  // ~
        lwc1    f8, 0xFE90(t2)              // t2 = rotation constant
        mul.s   f8, f8, f6                  // f8 = rotation constant * direction
        lw      t7, 0x08E8(t0)              // t6 = character control joint struct
        swc1    f8, 0x0034(t7)              // update character rotation to match direction

        _end:
        OS.routine_end(0x20)
    }

    // Hitlag just ended
    scope hitlag_step: {
        OS.patch_start(0x5CEC4, 0x800E16C4)
        j       hitlag_step
        nop
        hitlag_step_end_:
        OS.patch_end()

        // when a character is in hitstun, their knockback is stored at player struct offset 0x7EC
        // when not in hitstun, it returns zero
        lw      t6, 0x07EC(a2)              // t0 = current knockback value
        beqz    t6, hitlag_step_attacker   // branch if knockback == 0 (we're the attacker)
        nop

        b goto_hitlag_step_end
        nop

        hitlag_step_attacker:
        lw a0, 0x20(sp) // a0 = player object

        lw      t0, 0x0008(a2)              // t0 = character id
        ori     t1, r0, Character.id.RYU    // t1 = id.RYU
        beq     t0, t1, set_cancel_window
        nop

        lw      t0, 0x0008(a2)              // t0 = character id
        ori     t1, r0, Character.id.KEN    // t1 = id.RYU
        beq     t0, t1, set_cancel_window
        nop

        b goto_hitlag_step_end
        nop

        set_cancel_window:
        lbu     t0, 0x000D(a2)              // t0 = player port
        li      t1, special_cancel_buffer   // ~
        addu    t0, t0, t1                  // t0 = px special_cancel_buffer address
        lli     t1, 0xA
        sb      t1, 0x0000(t0)              // update special_cancel_buffer
    
        goto_hitlag_step_end:
        lbu t6, 0x0192(a2) // original line 1
        lw v0, 0x0A08(a2) // original line 2

        j hitlag_step_end_
        nop
    }

    // 800E3EBC
    scope hitlag_attacker_fgc_multiply: {
        OS.patch_start(0x5FCA0, 0x800E44A0)
        j       hitlag_attacker_fgc_multiply
        nop
        hitlag_attacker_fgc_multiply_end_:
        OS.patch_end()

        lw      t0, 0x0008(s1)              // t0 = character id
        ori     t1, r0, Character.id.RYU    // t1 = id.RYU
        beq     t0, t1, _fgc_multiplyier    // if character id = RYU, jump to _fgc_multiplyier
        nop

        lw      t0, 0x0008(s1)              // t0 = character id
        ori     t1, r0, Character.id.KEN    // t1 = id.KEN
        beq     t0, t1, _fgc_multiplyier    // if character id = KEN, jump to _fgc_multiplyier
        nop

        lw      t0, 0x0008(s1)              // t0 = character id
        ori     t1, r0, Character.id.KAZUYA    // t1 = id.KAZUYA
        beq     t0, t1, _fgc_multiplyier_defender_demon    // if character id = KAZUYA, jump to _fgc_multiplyier_defender_demon
        nop

        j goto_hitlag_attacker_fgc_multiply_end_
        nop

        _fgc_multiplyier:
        lwc1 f18,0x7a4(s1) // load hitbox hitlag value into f18

        // branches for moves with specific hitlag
        // save hitlag to at then jump
        lw t1, 0x0024(s1) // t0 = current action

        lli    t0, Ryu.Action.DTILT_L
        beq    t1, t0, _fgc_multiplyier_continue
        lui    at, 0x4000 // 2.0

        lli   t0, Ryu.Action.JAB_L
        beq   t1, t0, _fgc_multiplyier_continue
        lui   at, 0x4000 // 2.0

        lli   t0, Ryu.Action.JAB_L2
        beq   t1, t0, _fgc_multiplyier_continue
        lui   at, 0x4000 // 2.0

        lli   t0, Ryu.Action.JAB_L3
        beq   t1, t0, _fgc_multiplyier_continue
        lui   at, 0x4000 // 2.0

        lli   t0, Ryu.Action.USP_H
        beq   t1, t0, _fgc_multiplyier_continue
        lui   at, 0x4000 // 2.0

        lli   t0, Ryu.Action.USP_L
        beq   t1, t0, _fgc_multiplyier_continue
        lui   at, 0x4000 // 2.0

        // default is 1.5
        lui   at, 0x3fc0 // 1.5

        b _fgc_multiplyier_continue
        nop

        _fgc_multiplyier_defender_demon:
        lwc1 f18,0x7a4(s5) // load hitbox hitlag value into f18

        // default is 0.4
        lui   at, 0x3ecc // 0.4

        b _fgc_multiplyier_continue
        nop
        
        _fgc_multiplyier_continue:
        mtc1 at, f0 // load at into f0
        mul.s f18, f18, f0  // f18 = f18 * f0 (hitlag multiplier)
        swc1 f18,0x7a4(s1) // save new hitlag multiplier value

        lbu     t0, 0x000D(s1)              // t0 = player port
        li      t1, special_cancel_buffer   // ~
        addu    t0, t0, t1                  // t0 = px special_cancel_buffer address
        lli     t1, 0xA
        sb      t1, 0x0000(t0)              // update special_cancel_buffer

        goto_hitlag_attacker_fgc_multiply_end_:
        lw t3, 0x0010(s2) // original line 1
        lw v0, 0x07F8(s5) // original line 2

        // If we're Kazuya, ignore extra hitlag for electric moves
        lw      t0, 0x0008(s1)                      // t0 = character id
        ori     t1, r0, Character.id.KAZUYA         // t1 = id.KAZUYA
        beq     t0, t1, kazuya_skip_electric_hitlag // if character id = KAZUYA, jump to _fgc_multiplyier_defender_demon
        nop

        j hitlag_attacker_fgc_multiply_end_
        nop

        kazuya_skip_electric_hitlag:
        j 0x800E481C // 800E3EBC + 960
        nop
    }

    // 800E3EBC + 960
    scope hitlag_defender_fgc_multiply: {
        OS.patch_start(0x6001C, 0x800E481C)
        j       hitlag_defender_fgc_multiply
        nop
        hitlag_defender_fgc_multiply_end_:
        OS.patch_end()

        lw      t0, 0x0008(s1)              // t0 = character id
        ori     t1, r0, Character.id.RYU    // t1 = id.RYU
        beq     t0, t1, _fgc_multiplyier_defender    // if character id = RYU, jump to _fgc_multiplyier_defender
        nop

        lw      t0, 0x0008(s1)              // t0 = character id
        ori     t1, r0, Character.id.KEN    // t1 = id.RYU
        beq     t0, t1, _fgc_multiplyier_defender    // if character id = RYU, jump to _fgc_multiplyier_defender
        nop

        lw      t0, 0x0008(s1)              // t0 = character id
        ori     t1, r0, Character.id.KAZUYA    // t1 = id.KAZUYA
        beq     t0, t1, _fgc_multiplyier_defender_demon    // if character id = KAZUYA, jump to _fgc_multiplyier_defender_demon
        nop

        j goto_hitlag_defender_fgc_multiply_end_
        nop

        _fgc_multiplyier_defender:
        lwc1 f18,0x7a4(s5) // load hitbox hitlag value into f18

        // branches for moves with specific hitlag
        // save hitlag to at then jump
        lw t1, 0x0024(s1) // t0 = current action

        lli   t0, Ryu.Action.DTILT_L
        beq   t1, t0, _fgc_multiplyier_defender_continue
        lui   at, 0x4000 // 2.0

        lli   t0, Ryu.Action.JAB_L
        beq   t1, t0, _fgc_multiplyier_defender_continue
        lui   at, 0x4000 // 2.0

        lli   t0, Ryu.Action.JAB_L2
        beq   t1, t0, _fgc_multiplyier_defender_continue
        lui   at, 0x4000 // 2.0

        lli   t0, Ryu.Action.JAB_L3
        beq   t1, t0, _fgc_multiplyier_defender_continue
        lui   at, 0x4000 // 2.0

        lli   t0, Ryu.Action.USP_H
        beq   t1, t0, _fgc_multiplyier_defender_continue
        lui   at, 0x4000 // 2.0

        lli   t0, Ryu.Action.USP_L
        beq   t1, t0, _fgc_multiplyier_defender_continue
        lui   at, 0x4000 // 2.0

        // default is 1.5
        lui   at, 0x3fc0 // 1.5

        b _fgc_multiplyier_defender_continue
        nop

        _fgc_multiplyier_defender_demon:
        lwc1 f18,0x7a4(s5) // load hitbox hitlag value into f18

        // branches for moves with specific hitlag
        // save hitlag to at then jump
        lw t1, 0x0024(s1) // t0 = current action

        lli   t0, Kazuya.Action.GODFIST
        beq   t1, t0, _fgc_multiplyier_defender_continue
        lui   at, 0x4040 // 3.0

        lli   t0, Kazuya.Action.WHILE_STAND
        beq   t1, t0, _fgc_multiplyier_defender_continue
        lui   at, 0x4020 // 2.5

        // default is 0.4
        lui   at, 0x3ecc // 0.4

        b _fgc_multiplyier_defender_continue
        nop
        
        _fgc_multiplyier_defender_continue:
        mtc1 at, f0 // load at into f0
        mul.s f18, f18, f0  // f18 = f18 * f0 (hitlag multiplier)
        swc1 f18,0x7a4(s5) // save new hitlag multiplier value

        goto_hitlag_defender_fgc_multiply_end_:
        lwc1 f16, 0x00A0(sp) // original line 1
        li at, 2             // original line 2
        
        // If we're Kazuya, ignore extra hitlag for electric moves
        lw      t0, 0x0008(s1)                      // t0 = character id
        ori     t1, r0, Character.id.KAZUYA         // t1 = id.KAZUYA
        beq     t0, t1, kazuya_skip_electric_hitlag_mul // if character id = KAZUYA, jump to _fgc_multiplyier_defender_demon
        nop

        j hitlag_defender_fgc_multiply_end_
        nop

        kazuya_skip_electric_hitlag_mul:
        j       0x800E483C // 800E3EBC + 980
        swc1    f16, 0x7E0(s5) // save final hitlag value

        j hitlag_defender_fgc_multiply_end_
        nop
    }


    scope hitlag_defender_fgc_projectile: {
        OS.patch_start(0x5FE00, 0x800E4600)
        j       hitlag_defender_fgc_projectile
        nop
        hitlag_defender_fgc_projectile_end_:
        OS.patch_end()

        lw      t2,0xc(t1) // original line 1 (744)
        sw      t2,0x800(s5) // original line 2 (748)

        // s4 = projectile struct
        lw      t1, 0x000C(s4)              // t6 = item ID
        lli     t2, FGC_PROJECTILE_ID              // at = FGC_PROJECTILE_ID
        bne     t1, t2, goto_hitlag_defender_fgc_projectile_end_     // skip if item ID != FGC_PROJECTILE_ID
        nop

        // s5 = this_fp (struct)
        lwc1 f18,0x7a4(s5) // load hitbox hitlag value into f18
        lui at, 0x3fc0 // 1.5
        mtc1 at, f0 // load 1.5 into f0
        mul.s f18, f18, f0  // f18 = f18 * f0 (hitlag *= 1.5)
        swc1 f18,0x7a4(s5) // save new hitlag multiplier value

        goto_hitlag_defender_fgc_projectile_end_:
        j hitlag_defender_fgc_projectile_end_
        nop
    }
}