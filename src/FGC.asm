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
    constant B_PRESSED(0x4000)                // bitmask for b press
    constant A_PRESSED(0x8000)                // bitmask for b press

    // Ryu auto turnaround logic
    scope fcg_tap_hold: {
        OS.patch_start(0x5D160, 0x800E1960)
        j       fcg_tap_hold
        nop
        fcg_tap_hold_end_:
        OS.patch_end()

        // a2 = fighter struct
        // t1, t2, t3, t4 = zero

        OS.save_registers()

        lw      t1, 0x0008(a2)              // t0 = character id
        ori     t2, r0, Character.id.RYU    // t1 = id.RYU
        beq     t1, t2, main_logic
        nop

        b goto_fcg_tap_hold_end_
        nop

        main_logic:
        lw t1,  0x4(a2)                     // t1 = fighter object
        lwc1    f8, 0x0078(t1)              // load current frame into f8

        // Fix a bug where the next action would be triggered after changing from a move to neutral
        // because the action would still be the previous one, but the frame would be less than 0
        // since the previous animation just finished
        lui		at, 0x4000					// at = 0.0
		mtc1    at, f6                      // ~
        c.le.s  f8, f6                      // f8 <= f6 (current frame < 0) ?
        nop
        bc1tl   goto_fcg_tap_hold_end_    // skip if frame < 0
        nop

        lui		at, 0x40C0					// at = 3.0
		mtc1    at, f6                      // ~
        c.le.s  f8, f6                      // f8 <= f6 (current frame < 3) ?
        nop
        bc1tl   button_check                // skip if frame > 3
        nop

        lui		at, 0x0					// at = 6.0 4110 419C 41A0 41A8
		mtc1    at, f6                      // ~
        c.le.s  f6, f8                      // f6 >= f8 (6 > current frame) ?
        nop
        bc1tl   cancel_itself_button_check                // skip if current frame is lower than 6
        nop

        b goto_fcg_tap_hold_end_
        nop

        button_check:
        lhu     t1, 0x01BC(a2)              // load button press buffer
        andi    t2, t1, A_PRESSED           // t2 = 0x80 if (A_PRESSED); else t2 = 0
        bne     t2, r0, goto_fcg_tap_hold_end_ // skip if (!A_PRESSED)
        nop
        // else, check action

        check_action:
        lw      t1, 0x0024(a2) // t0 = current action

        // we'll use t3 to define the action to switch to

        lli    t2, Action.Jab1
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
        or      a2, r0, r0                  // a2 = float: 0.0
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

        cancel_itself_button_check:
        lhu     t1, 0x01BE(a2)              // load button tap buffer
        andi    t2, t1, A_PRESSED           // t2 = 0x80 if (A_PRESSED); else t2 = 0
        beq     t2, r0, goto_fcg_tap_hold_end_ // skip if (!A_PRESSED)
        nop
        // else, check analog

        cancel_itself_analog_check:
        lb      t0, 0x01C3(a2)              // t0 = stick_y

        slti    t1, t0, 40                             // at = 1 if stick_y < 40, else at = 0
        beql    t1, r0, cancel_itself_uptilt_check      // branch if stick_y >= 40...
        nop

        slti    t1, t0, -39                                 // at = 1 if stick_y < -39, else at = 0
        bnel    t1, r0, cancel_itself_dtilt_check          // branch if stick_y >= -40...
        nop

        b goto_fcg_tap_hold_end_
        nop

        cancel_itself_uptilt_check:
        lw      t1, 0x0024(a2) // t0 = current action

        lli    t2, Ryu.Action.UTILT_L
        beq    t1, t2, change_action
        addiu  t3, r0, Action.UTilt

        j goto_fcg_tap_hold_end_
        nop

        cancel_itself_dtilt_check:
        lw      t1, 0x0024(a2) // t0 = current action

        lli    t2, Ryu.Action.DTILT_L
        beq    t1, t2, change_action
        addiu  t3, r0, Action.DTilt

        j goto_fcg_tap_hold_end_
        nop

        cancel_itself_change_action:
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)
        sw      a0, 0x0008(sp)
        sw      a1, 0x000C(sp)              // store variables
        sw      a2, 0x0010(sp)              // store variables
        sw      a3, 0x0014(sp)              // store variables
        addiu   sp, sp,-0x0030              // allocate stack space

        addiu   s0, a2, 0
        sw      r0, 0x0010(sp)              // argument 4 = 0
        addiu   a1, t3, 0
        or      a2, r0, r0                  // a2 = float: 0.0
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
        addiu   sp, sp, 0x0030              // deallocate stack space

        j goto_fcg_tap_hold_end_
        nop

        goto_fcg_tap_hold_end_:
        OS.restore_registers()
        
        lw v0, 0x0174(a2) // original line 1
        slti at, v0, 0x0002 // original line 2

        j fcg_tap_hold_end_
        nop
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
        lw      t0, 0x07EC(a2)              // t0 = current knockback value
        beqz    t0, hitlag_step_attacker   // branch if knockback == 0 (we're the attacker)
        nop

        b goto_hitlag_step_end
        nop

        hitlag_step_attacker:
        lw a0, 0x20(sp) // a0 = player object

        lhu     t0, 0x01BC(a2)              // load button press buffer
        andi    t1, t0, B_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, goto_hitlag_step_end                // skip if (!B_PRESSED)
        nop

        lw      t0, 0x0008(a2)              // t0 = character id
        ori     t1, r0, Character.id.RYU    // t1 = id.RYU
        beq     t0, t1, check_move_cancel_ryu
        nop

        b goto_hitlag_step_end
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

        j goto_hitlag_step_end
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
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        nop
        
        b apply_move_cancel_ground_end
        nop

        apply_move_cancel_airN:
        lw      a0, 0x4(a2)                 // a0 = player object
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, 0xE5
        or      a2, r0, r0                  // a2 = float: 0.0
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
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        nop
        
        b apply_move_cancel_ground_end
        nop

        apply_move_cancel_groundN:
        lw      a0, 0x4(a2)                 // a0 = player object
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, 0xE4
        or      a2, r0, r0                  // a2 = float: 0.0
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

        b goto_hitlag_step_end
        nop

        goto_hitlag_step_end:
        lbu t6, 0x0192(a2) // original line 1
        lw v0, 0x0A08(a2) // original line 2

        j hitlag_step_end_
        nop
    }

    // // The original code sets it to 1.5
    // // Here we make it so it loads the hitbox's hitlag multiplier
    // // And then multiply it by 1.5 instead
    // // So we can have multiple multipliers applied
    // scope hitlag_attacker_electric_multiply: {
    //     OS.patch_start(0x5FCC4, 0x800E44C4)
    //     j       hitlag_attacker_electric_multiply
    //     nop
    //     hitlag_attacker_electric_multiply_end_:
    //     OS.patch_end()

    //     lwc1 f18,0x7a4(s1) // load hitbox hitlag value into f18
    //     lui f18, 0x2
    //     lui at,0x3fc0 // original line 1
    //     mtc1 at, f0 // load 1.5 into f0
    //     mul.s f18, f18, f0  // f18 = f18 * f0 (hitlag *= 1.5)
    //     swc1 f18,0x7a4(s1) // save new hitlag multiplier value

    //     j hitlag_attacker_electric_multiply_end_
    //     nop
    // }

    // // same as above, now for defender
    // scope hitlag_defender_electric_multiply: {
    //     OS.patch_start(0x6002D, 0x800E482C)
    //     j       hitlag_defender_electric_multiply
    //     nop
    //     hitlag_defender_electric_multiply_end_:
    //     OS.patch_end()

    //     lwc1 f18,0x7a4(s5) // load hitbox hitlag value into f18
    //     lui at,0x3fc0 // original line 1
    //     mtc1 at, f0 // load 1.5 into f0
    //     mul.s f18, f18, f0  // f18 = f18 * f0 (hitlag *= 1.5)
    //     swc1 f18,0x7a4(s5) // save new hitlag multiplier value

    //     j hitlag_defender_electric_multiply_end_
    //     nop
    // }

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

        j goto_hitlag_attacker_fgc_multiply_end_
        nop

        _fgc_multiplyier:
        lwc1 f18,0x7a4(s1) // load hitbox hitlag value into f18
        lui at, 0x3fc0 // 1.5
        mtc1 at, f0 // load 1.5 into f0
        mul.s f18, f18, f0  // f18 = f18 * f0 (hitlag *= 1.5)
        swc1 f18,0x7a4(s1) // save new hitlag multiplier value

        goto_hitlag_attacker_fgc_multiply_end_:
        lw t3, 0x0010(s2) // original line 1
        lw v0, 0x07F8(s5) // original line 2
        j hitlag_attacker_fgc_multiply_end_
        nop
    }

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

        j goto_hitlag_defender_fgc_multiply_end_
        nop

        _fgc_multiplyier_defender:
        lwc1 f18,0x7a4(s5) // load hitbox hitlag value into f18
        lui at, 0x3fc0 // 1.5
        mtc1 at, f0 // load 1.5 into f0
        mul.s f18, f18, f0  // f18 = f18 * f0 (hitlag *= 1.5)
        swc1 f18,0x7a4(s5) // save new hitlag multiplier value

        goto_hitlag_defender_fgc_multiply_end_:
        lwc1 f16, 0x00A0(sp) // original line 1
        li at, 2 // original line 2
        nop
        j hitlag_defender_fgc_multiply_end_
        nop

        _redirect_jump:
        j 0x800E483C
        nop

        j hitlag_defender_fgc_multiply_end_
        nop
    }
}