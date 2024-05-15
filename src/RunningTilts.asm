// 0x8013EFB0: ftCommon_RunBrake_ProcInterrupt
// 0x8013EFB0+8=8013EFB8

scope RunBrake: {
    scope InterruptableRunBrake: {
        OS.patch_start(0xB99F8, 0x8013EFB8)
        j       InterruptableRunBrake
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_running_tilts, t0)      // t0 = running tilts toggle
        beqz    t0, _original                      // branch if toggle is disabled
        nop

        addiu   sp,sp,-0x20
        sw      ra,0x1c(sp)
        sw      s0,0x18(sp)
        sw      a0,0x14(sp)

        lw      t6, 0x84(a0)             // t6 = player struct
        lw      t7, 0x0044(t6)           // t7 = player direction in the struct
        sw      t7, 0x10(sp)             // save player direction

        // check if we're pressing the opposite direction
        // in this case, temporarily turn the character around
        // used because side tilt/smash checks for player direction
        lb      t3, 0x01C2(t6)           // t3 = stick_x

        bgtz    t3, temp_turnaround_positive
        nop

        bltz    t3, temp_turnaround_negative
        nop

        b       after_temp_turnaround_logic // if stick_x == 0, skip
        nop

        temp_turnaround_positive:
        lli     t2, 1                    // t2 = right
        sw      t2, 0x0044(t6)           // t7 = save player direction
        b after_temp_turnaround_logic
        nop

        temp_turnaround_negative:
        addiu   t2, r0, -0x0001          // t2 = -1
        sw      t2, 0x0044(t6)           // t7 = save player direction
        b after_temp_turnaround_logic
        nop

        after_temp_turnaround_logic:
        jal     0x80151098 // ftCommonSpecialNCheckInterruptCommon
        move    s0,a0
        bnezl   v0,cancel_checks_after_directional
        lw      ra,0x1c(sp)
        jal     0x80151160 // ftCommonSpecialHiCheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)
        jal     0x801511E0 // ftCommonSpecialLwCheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)
        jal     0x80149CE0 // ftCommon_Catch_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after_directional
        lw      ra,0x1c(sp)
        jal     0x80150470 // ftCommon_AttackS4_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after_directional
        lw      ra,0x1c(sp)
        jal     0x8015070C // ftCommon_AttackHi4_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)
        jal     0x80150884 // ftCommon_AttackLw4_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)
        jal     0x8014F8C0 // ftCommon_AttackS3_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after_directional
        lw      ra,0x1c(sp)
        jal     0x8014FB1C // ftCommon_AttackHi3_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)
        jal     0x8014FD70 // ftCommon_AttackLw3_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)
        jal     0x8014EC78 // ftCommon_Attack1_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)
        jal     0x8014E764 // ftCommon_Appeal_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)

        b no_cancel
        nop

        // action was not cancelled,
        // load everything back and go to original function logic
        no_cancel:
        lw      ra, 0x1c(sp)
        lw      s0, 0x18(sp)
        lw      a0, 0x14(sp)

        lw      t6, 0x84(a0)             // t6 = player struct
        lw      t7, 0x10(sp)             // t7 = saved player direction
        sw      t7, 0x0044(t6)           // restore player direction

        addiu   sp, sp,0x20

        b _original
        nop

        cancel_checks_after_directional:
        lw      ra, 0x1c(sp)
        lw      s0, 0x18(sp)
        lw      a0, 0x14(sp)

        addiu   sp, sp,0x20

        // here we're using the direction set by the directional input
        // no need to turn around or anything
        b interrupted_end
        nop
        
        cancel_checks_after:
        lw      ra, 0x1c(sp)
        lw      s0, 0x18(sp)
        lw      a0, 0x14(sp)

        lw      t6, 0x84(a0)             // t6 = player struct
        lw      t7, 0x10(sp)             // t7 = saved player direction
        sw      t7, 0x0044(t6)           // restore player direction

        addiu   sp, sp,0x20

        // this here is needed for us to force direction on grab
        apply_model_direction:
        lw      t7, 0x0044(t6)              // t7 = direction
        mtc1    t7, f6                      // ~
        cvt.s.w f6, f6                      // f6 = direction
        lui     t2, 0x8013                  // ~
        lwc1    f8, 0xFE90(t2)              // t2 = rotation constant
        mul.s   f8, f8, f6                  // f8 = rotation constant * direction
        lw      t7, 0x08E8(t6)              // t7 = character control joint struct
        swc1    f8, 0x0034(t7)              // update character rotation to match direction

        interrupted_end:
        // Oterwise, go to function return directly
        j 0x8013F004 // 8013EFB0+54=8013F004
        nop

        _original:
        lw      t6,0x84(a0)     // Original line 1
        sw      a0,0x20(sp)     // Original line 2

        _end:
        j       _return
        nop
    }

    // 0x8013F1C0: ftCommon_TurnRun_ProcInterrupt
    // 0x8013F1C0+8=8013F1C8
    scope InterruptableTurnrun: {
        OS.patch_start(0xB9C08, 0x8013F1C8)
        j       InterruptableTurnrun
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_running_tilts, t0)      // t0 = running tilts toggle
        beqz    t0, _original                      // branch if toggle is disabled
        nop

        addiu   sp,sp,-0x20
        sw      ra,0x1c(sp)
        sw      s0,0x18(sp)
        sw      a0,0x14(sp)

        lw      t6, 0x84(a0)             // t6 = player struct
        lw      t7, 0x0044(t6)           // t7 = player direction in the struct
        sw      t7, 0x10(sp)             // save player direction

        // check if we're pressing the opposite direction
        // in this case, temporarily turn the character around
        // used because side tilt/smash checks for player direction
        lb      t3, 0x01C2(t6)           // t3 = stick_x

        bgtz    t3, temp_turnaround_positive
        nop

        bltz    t3, temp_turnaround_negative
        nop

        b       after_temp_turnaround_logic // if stick_x == 0, skip
        nop

        temp_turnaround_positive:
        lli     t2, 1                    // t2 = right
        sw      t2, 0x0044(t6)           // t7 = save player direction
        b after_temp_turnaround_logic
        nop

        temp_turnaround_negative:
        addiu   t2, r0, -0x0001          // t2 = -1
        sw      t2, 0x0044(t6)           // t7 = save player direction
        b after_temp_turnaround_logic
        nop

        after_temp_turnaround_logic:
        jal     0x80151098 // ftCommonSpecialNCheckInterruptCommon
        move    s0,a0
        bnezl   v0,cancel_checks_after_directional
        lw      ra,0x1c(sp)
        jal     0x80151160 // ftCommonSpecialHiCheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)
        jal     0x801511E0 // ftCommonSpecialLwCheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)
        jal     0x80149CE0 // ftCommon_Catch_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after_directional
        lw      ra,0x1c(sp)
        jal     0x80150470 // ftCommon_AttackS4_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after_directional
        lw      ra,0x1c(sp)
        jal     0x8015070C // ftCommon_AttackHi4_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)
        jal     0x80150884 // ftCommon_AttackLw4_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)
        jal     0x8014F8C0 // ftCommon_AttackS3_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after_directional
        lw      ra,0x1c(sp)
        jal     0x8014FB1C // ftCommon_AttackHi3_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)
        jal     0x8014FD70 // ftCommon_AttackLw3_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)
        jal     0x8014EC78 // ftCommon_Attack1_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after
        lw      ra,0x1c(sp)
        jal     0x8014E764 // ftCommon_Appeal_CheckInterruptCommon
        move    a0,s0
        bnezl   v0,cancel_checks_after_directional
        lw      ra,0x1c(sp)

        b no_cancel
        nop

        // action was not cancelled,
        // load everything back and go to original function logic
        no_cancel:
        lw      ra, 0x1c(sp)
        lw      s0, 0x18(sp)
        lw      a0, 0x14(sp)

        lw      t6, 0x84(a0)             // t6 = player struct
        lw      t7, 0x10(sp)             // t7 = saved player direction
        sw      t7, 0x0044(t6)           // restore player direction

        addiu   sp, sp,0x20

        b _original
        nop

        cancel_checks_after_directional:
        lw      ra, 0x1c(sp)
        lw      s0, 0x18(sp)
        lw      a0, 0x14(sp)

        addiu   sp, sp,0x20

        // here we're using the direction set by the directional input
        // no need to turn around or anything
        b interrupted_end
        nop
        
        // This is for non-directional moves
        // we always want to use the direction you're sliding towards
        // but the character's struct direction value changes mid-action
        // so we use the (reverse) model direction to set our final direction
        cancel_checks_after:
        lw      ra, 0x1c(sp)
        lw      s0, 0x18(sp)
        lw      a0, 0x14(sp)

        addiu   sp, sp,0x20

        lw      t6, 0x84(a0)             // t6 = player struct
        lw      t7, 0x08E8(t6)           // t7 = character control joint struct
        lw      t7, 0x0034(t7)           // f8 = character model rotation

        lui     t2, 0x8013                  // ~
        lw      t2, 0xFE90(t2)              // t2 = rotation constant (facing right)

        beq     t2, t7, set_direction_left     // if facing right, set direction to left
        nop

        // else, set direction to right
        set_direction_right:
        addiu   t7, r0, 0x0001          // t2 = -1
        sw      t7, 0x0044(t6)          // update direction in player struct
        b apply_model_direction
        nop

        set_direction_left:
        addiu   t7, r0, -0x0001         // t2 = -1
        sw      t7, 0x0044(t6)          // update direction in player struct
        b apply_model_direction
        nop

        apply_model_direction:
        lw      t7, 0x0044(t6)              // t7 = direction
        mtc1    t7, f6                      // ~
        cvt.s.w f6, f6                      // f6 = direction
        lui     t2, 0x8013                  // ~
        lwc1    f8, 0xFE90(t2)              // t2 = rotation constant
        mul.s   f8, f8, f6                  // f8 = rotation constant * direction
        lw      t7, 0x08E8(t6)              // t7 = character control joint struct
        swc1    f8, 0x0034(t7)              // update character rotation to match direction

        interrupted_end:
        j 0x8013F1F8 // 8013F1C0+38=8013F1F8
        nop

        _original:
        lw      t6,0x84(a0)     // Original line 1
        sw      a0,0x20(sp)     // Original line 2

        _end:
        j       _return
        nop
    }

    // @ Description
    // Allows players to turn around and downtilt out of crouch
    scope directional_down_tilt: {
    
        constant DEADZONE(6)
    
        OS.patch_start(0xCA774, 0x8014FD34)
        j       directional_down_tilt
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_running_tilts, t0)      // t0 = running tilts toggle
        beqz    t0, _original                      // branch if toggle is disabled
        nop

        //
        lw      t0, 0x0028(sp)      // t0 = player obj
        lw      t6, 0x0084(t0)      // t6 = player struct
        lw      t4, 0x44(t6)        // t4 = player direction
        lb      t7, 0x01C2(t6)      // t7 = stick x
        andi    t3, t7, 0x0080      // t6 = 0 if pointing right
        beqz    t3, joy_stick_right
        addiu   t5, t7, +DEADZONE   // check deadzone

        // joystick pointing left if here
        bgtzl   t5, _original       // original logic if within deadzone
        nop
        addiu   at, r0, -1          // at = -1 if facing left
        b       _original
        sw      at, 0x44(t6)        // save player direction

        joy_stick_right:
        addiu   t5, t7, -DEADZONE   // check deadzone
        bltzl   t5, _original       // branch if within deadzone
        nop
        addiu   at, r0, 1           // t5 = 1 if facing right
        sw      at, 0x44(t6)        // save player direction

        _original:
        lui     t7, 0x8015          // og line 0
        lw      t8, 0x0024(sp)      // og line 1
        j       _return
        addiu   t7, t7, 0xFCCC      // og line 2
    }
}
