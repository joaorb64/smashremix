scope KazuyaSpecial {
    scope CROUCH_JAB: {
        constant A_PRESSED(0x8000)  // bitmask for a press

        // tmp variable 3 0x0184 -- used to check if A was ever pressed down during the move
        scope main: {
            OS.routine_begin(0x20)

            lw      v0, 0x0084(a0)  // v0 = player struct

            lw      t0, 0x0078(a0)  // t0 = current animation frame
            lui     t1, 0x4000      // t1 = 1.0F

            // if frame != 1, skip
            bne     t0, t1, main_continue
            nop
            
            sw      r0, 0x0184(v0)              // reset tmp variable 3 = 0

            main_continue:
            lw      v0, 0x0084(a0)              // loads player struct into v0
            lhu     t1, 0x01BE(v0)              // load button press buffer
            andi    t2, t1, A_PRESSED           // t2 = 0x80 if (A_PRESSED); else t2 = 0
            beq     t2, r0, normal            // if A is not pressed, skip
            nop

            check_neutral:
            lb      t2, 0x01C2(a2)                          // t2 = stick_x
            bgez    t2, check_neutral_continue			    // branch if positive value
            nop
            subu    t2, r0, t2					            // t2 = abs(stick.x)
            check_neutral_continue:

            slti    t1, t2, 40                             // t1 = 1 if abs(stick_x) < 40
            beq     t1, r0, normal                         // stick must be neutral in X
            nop

            lb      t0, 0x01C3(v0)              // t0 = stick_y
            slti    t1, t0, -39                 // at = 1 if stick_y < -39, else at = 0
            bnel    t1, r0, register_press      // branch if stick_y >= -40
            nop

            b       normal
            nop

            register_press:
            lli     t0, 0x1
            sw      t0, 0x0184(v0)

            b       normal
            nop

            normal:
            lw      t0, 0x0078(a0)  // t0 = current animation frame
            mtc1    t0, f6
            lui     t1, 0x4160      // t1 = 14.0F
            mtc1    t1, f8

            c.le.s  f6, f8
            nop
            bc1tl   main_normal
            nop

            lw      t0, 0x0184(v0)          // was A or B ever pressed during the move?
            beq     t0, r0, main_normal     // If not, main_normal
            nop

            lw      t0, 0x0024(a2)      // t0 = current action
            lli     t1, Kazuya.Action.CROUCH_JAB    // Are we performing crouch jab?
            bne     t0, t1, main_normal
            nop

            // all conditions are met
            b cancel_itself
            nop

            cancel_itself:
            OS.save_registers()
            lli     a1, Kazuya.Action.CROUCH_JAB    // a1 = Action.SWEEP1
            or      a2, r0, r0                      // a2(starting frame) = 0.0
            lui     a3, 0x3F80                      // a3(frame speed multiplier) = 1.0
            sw      r0, 0x0010(sp)                  // argument 4 = 0
            jal     0x800E6F24                      // change action
            nop
            OS.restore_registers()
            OS.routine_end(0x20)

            main_normal:
            li      a1, 0x8014329C      // Argument 1 = ftCommon_SquatWait_SetStatus (set crouched state)
            jal     0x800D9480          // ftStatus_IfAnimEnd_ProcStatus: Subroutine that waits for animation end to call argument 1
            nop

            OS.routine_end(0x20)
        }
    }

    scope WAVEDASH: {
        constant A_PRESSED(0x8000)  // bitmask for a press
        constant B_PRESSED(0x4000)  // bitmask for b press

        scope main: {
            OS.routine_begin(0x20)

            sw      a0, 0x0010(sp)
            
            lw      v0, 0x0084(a0)              // loads player struct into v0
            lhu     t1, 0x01BE(v0)              // load button press buffer
            andi    t2, t1, A_PRESSED           // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne     t2, r0, cancel_a            // if A is pressed
            nop

            andi    t2, t1, B_PRESSED           // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne     t2, r0, cancel_b            // if A is pressed
            nop

            b   normal
            nop

            cancel_a:
            OS.save_registers()
            lli     a1, Kazuya.Action.GODFIST   // a1 = Action.GODFIST
            lui     a2, 0x3F80                  // a2(starting frame) = 1.0
            lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
            sw      r0, 0x0010(sp)              // argument 4 = 0
            jal     0x800E6F24                  // change action
            nop
            OS.restore_registers()
            
            OS.routine_end(0x20)

            cancel_b:
            OS.save_registers()
            lli     a1, Kazuya.Action.SWEEP1    // a1 = Action.SWEEP1
            lui     a2, 0x3F80                  // a2(starting frame) = 1.0
            lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
            sw      r0, 0x0010(sp)              // argument 4 = 0
            jal     0x800E6F24                  // change action
            nop
            OS.restore_registers()
            
            OS.routine_end(0x20)

            normal:
            // if not holding down
            // jal     0x800D94C4          // original routine

            // if holding down
            lw      a0, 0x0010(sp)      // Argument 0 = fighter_gobj
            li      a1, 0x8014329C      // Argument 1 = ftCommon_SquatWait_SetStatus (set crouched state)
            jal     0x800D9480          // ftStatus_IfAnimEnd_ProcStatus: Subroutine that waits for animation end to call argument 1
            nop

            OS.routine_end(0x20)
        }
    }

    scope SWEEP: {
        constant A_PRESSED(0x8000)  // bitmask for a press
        constant B_PRESSED(0x4000)  // bitmask for b press

        // tmp variable 3 0x0184 -- used to check if A or B was ever pressed down during the move

        scope main: {
            OS.routine_begin(0x20)

            lw      v0, 0x0084(a0)  // v0 = player struct

            lw      t0, 0x0078(a0)  // t0 = current animation frame
            lui     t1, 0x4000      // t1 = 1.0F

            // if frame != 1, skip
            bne     t0, t1, main_continue
            nop
            
            sw      r0, 0x0184(v0)              // reset tmp variable 3 = 0

            main_continue:
            sw      a0, 0x0010(sp)
            
            lw      v0, 0x0084(a0)              // loads player struct into v0
            lhu     t1, 0x01BE(v0)              // load button press buffer
            andi    t2, t1, A_PRESSED           // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne     t2, r0, register_press            // if A is pressed
            nop

            andi    t2, t1, B_PRESSED           // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne     t2, r0, register_press            // if A is pressed
            nop

            b   normal
            nop

            register_press:
            lli     t0, 0x1
            sw      t0, 0x0184(v0)

            b       normal
            nop

            normal:
            lw      t0, 0x0078(a0)  // t0 = current animation frame
            mtc1    t0, f6
            lui     t1, 0x4150      // t1 = 13.0F
            mtc1    t1, f8

            c.eq.s  f6, f8
            nop
            bc1fl   main_normal
            nop

            lw      t0, 0x0184(v0)          // was A or B ever pressed during the move?
            beq     t0, r0, main_normal     // If not, main_normal
            nop

            // all conditions are met
            b cancel_spin_2
            nop

            cancel_spin_2:
            OS.save_registers()
            lli     a1, Kazuya.Action.SWEEP2    // a1 = Action.SWEEP1
            or      a2, r0, r0                  // a2(starting frame) = 0.0
            lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
            lli     t6, 0x0003                  // ~
            sw      t6, 0x0010(sp)              // argument 4 = 0x0003 keep hitboxes
            jal     0x800E6F24                  // change action
            nop
            OS.restore_registers()
            OS.routine_end(0x20)

            main_normal:
            jal     0x800D94C4          // original routine
            nop
            OS.routine_end(0x20)
        }
    }

    scope RR3KICKS: {
        constant A_PRESSED(0x8000)  // bitmask for a press
        constant B_PRESSED(0x4000)  // bitmask for b press

        // tmp variable 3 0x0184 -- used to check if A or B was ever pressed down during the move

        scope main: {
            OS.routine_begin(0x20)

            lw      v0, 0x0084(a0)  // v0 = player struct

            lw      t0, 0x0078(a0)  // t0 = current animation frame
            lui     t1, 0x4000      // t1 = 1.0F

            // if frame != 1, skip
            bne     t0, t1, main_continue
            nop
            
            sw      r0, 0x0184(v0)              // reset tmp variable 3 = 0

            main_continue:
            sw      a0, 0x0010(sp)
            
            lw      v0, 0x0084(a0)              // loads player struct into v0
            lhu     t1, 0x01BE(v0)              // load button press buffer
            andi    t2, t1, A_PRESSED           // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne     t2, r0, register_press            // if A is pressed
            nop

            andi    t2, t1, B_PRESSED           // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne     t2, r0, register_press            // if A is pressed
            nop

            b   normal
            nop

            register_press:
            lli     t0, 0x1
            sw      t0, 0x0184(v0)

            b       normal
            nop

            normal:
            lw     t3, 0x0024(v0)              // t3 = current action

            // Here, we load into t1 the frame in which each step of the move should check for a transition
            lli    t2, Action.FTiltMidHigh
            beq    t1, t2, normal_continue
            lui    t1, 0x41A8      // t1 = 21.0F

            lli    t2, Action.FTiltHigh
            beq    t1, t2, normal_continue
            lui    t1, 0x41A8      // t1 = 21.0F

            lli    t2, Action.FTiltMidHigh
            beq    t1, t2, normal_continue
            lui    t1, 0x4170      // t1 = 15.0F

            lli    t2, Action.FTiltMidHigh
            beq    t1, t2, normal_continue
            lui    t1, 0x41A8      // t1 = 21.0F

            normal_continue:
            lw      t0, 0x0078(a0)  // t0 = current animation frame
            mtc1    t0, f6
            mtc1    t1, f8

            c.eq.s  f6, f8
            nop
            bc1fl   main_normal
            nop

            lw      t0, 0x0184(v0)          // was A or B ever pressed during the move?
            beq     t0, r0, main_normal     // If not, main_normal
            nop

            // all conditions are met
            b cancel_next
            nop

            cancel_next:
            lw     t1, 0x0024(v0)              // t1 = current action

            // we'll use t2 to store the next action as we jump

            lli    t2, Action.FTiltMidHigh
            beq    t1, t2, cancel_next_change_action
            lli    t2, Kazuya.Action.RR3KICKS2

            lli    t2, Action.FTiltHigh
            beq    t1, t2, cancel_next_change_action
            lli    t2, Kazuya.Action.RR3KICKS2

            lli    t2, Kazuya.Action.RR3KICKS2
            beq    t1, t2, cancel_next_change_action
            lli    t2, Kazuya.Action.RR3KICKS3

            lli    t2, Kazuya.Action.RR3KICKS3
            beq    t1, t2, cancel_next_change_action
            lli    t2, Kazuya.Action.RR3KICKS4

            cancel_next_change_action:
            OS.save_registers()
            or      a1, r0, t2                  // a1 = t2 = next action
            or      a2, r0, r0                  // a2(starting frame) = 0.0
            lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
            sw      r0, 0x0010(sp)              // argument 4 = 0
            jal     0x800E6F24                  // change action
            nop
            OS.restore_registers()
            OS.routine_end(0x20)

            main_normal:
            jal     0x800D94C4          // original routine
            nop
            OS.routine_end(0x20)
        }
    }

    scope UTILT: {
        constant A_PRESSED(0x8000)  // bitmask for a press

        // tmp variable 3 0x0184 -- used to check if A was ever pressed down during the move

        scope main: {
            OS.routine_begin(0x20)

            lw      v0, 0x0084(a0)  // v0 = player struct

            lw      t0, 0x0078(a0)  // t0 = current animation frame
            lui     t1, 0x4000      // t1 = 1.0F

            // if frame != 1, skip
            bne     t0, t1, main_continue
            nop
            
            sw      r0, 0x0184(v0)              // reset tmp variable 3 = 0

            main_continue:
            sw      a0, 0x0010(sp)
            
            lw      v0, 0x0084(a0)              // loads player struct into v0
            lhu     t1, 0x01BE(v0)              // load button press buffer
            andi    t2, t1, A_PRESSED           // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne     t2, r0, register_press            // if A is pressed
            nop

            b   normal
            nop

            register_press:
            lli     t0, 0x1
            sw      t0, 0x0184(v0)

            b       normal
            nop

            normal:
            lw      t0, 0x0078(a0)  // t0 = current animation frame
            mtc1    t0, f6
            lui     t1, 0x41A0      // t1 = 20.0F
            mtc1    t1, f8

            c.eq.s  f6, f8
            nop
            bc1fl   main_normal
            nop

            lw      t0, 0x0184(v0)          // was A or B ever pressed during the move?
            beq     t0, r0, main_normal     // If not, main_normal
            nop

            // all conditions are met
            b cancel_utilt_2
            nop

            cancel_utilt_2:
            OS.save_registers()
            lli     a1, Kazuya.Action.TILTU2    // a1 = Action.SWEEP1
            or      a2, r0, r0                  // a2(starting frame) = 0.0
            lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
            lli     t6, 0x0003                  // ~
            sw      t6, 0x0010(sp)              // argument 4 = 0x0003 keep hitboxes
            jal     0x800E6F24                  // change action
            nop
            OS.restore_registers()
            OS.routine_end(0x20)

            main_normal:
            jal     0x800D94C4          // original routine
            nop
            OS.routine_end(0x20)
        }
    }

    scope DASH: {
        // tmp variable 3 0x0184 -- used to keep track of the wavedash input
        // in the first frame, we set it to 0
        // check for neutral stick to set it to 1
        // then check for a diagonal (down-forward) input to trigger an action change

        scope main: {
            OS.routine_begin(0x20)

            lw      v0, 0x0084(a0)  // v0 = player struct

            lw      t0, 0x0078(a0)  // t0 = current animation frame
            lui     t1, 0x4000      // t1 = 1.0F

            // if frame != 1, skip
            bne     t0, t1, main_continue
            nop
            
            sw      r0, 0x0184(v0)              // reset tmp variable 3 = 0

            main_continue:
            sw      a0, 0x0010(sp)
            
            lw      t0, 0x0184(v0)

            lli    t1, 0x0
            beq    t0, t1, check_neutral
            nop

            lli    t1, 0x1
            beq    t0, t1, check_diagonal
            nop

            b   main_normal
            nop

            check_neutral:
            lb      t2, 0x01C2(a2)                          // t2 = stick_x
            bgez    t2, check_neutral_continue			    // branch if positive value
            nop
            subu    t2, r0, t2					            // t2 = abs(stick.x)
            check_neutral_continue:
            slti    t1, t2, 70                             // t1 = 1 if abs(stick_x) < 70
            beq     t1, r0, main_normal                         // stick must be neutral in X
            nop

            // lb      t2, 0x01C3(a2)                          // t0 = stick_y
            // mtc1    t2, f6                                  // f6 = stick_y
            // abs.s   f6, f6                                  // f6 = abs(stick_y)
            // mfc1    t2, f6                                  // t0 = abs(stick_y)

            // slti    t1, t2, 70                             // t1 = 1 if abs(stick_y) < 70
            // beq     t1, r0, main_normal                         // stick must be neutral in Y
            // nop

            lli     t0, 0x1                             // ~
            sw      t0, 0x0184(v0)                      // X and Y are neutral, set tmp var to 1

            b main_normal
            nop

            check_diagonal:

            // Check Y
            lb      t0, 0x01C3(v0)              // t0 = stick_y
            slti    t1, t0, -39                 // at = 1 if stick_y < -39, else at = 0
            beql    t1, r0, main_normal              // branch if stick_y >= -40
            nop

            // Check X
            lb      t0, 0x01C2(a2)                          // t0 = stick_x
            lli     t1, 40                                  // t1 = stick range
            lw      t2, 0x0044(v0)                          // t2 = facing direction (1 = right, -1 = left)

            slti    t3, t2, 0
            beq     t3, r0, facing_right
            nop

            facing_left:
            slti    t1, t0, -10                 // t1 = 1 if stick_x < -39, else at = 0
            beql    t1, r0, main_normal              // branch if stick_x >= -40
            nop

            b check_diagonal_success // check ok
            nop

            facing_right:
            slti    t1, t0, 10                 // t1 = 1 if stick_y < -39, else at = 0
            bnel    t1, r0, main_normal              // branch if stick_x >= -40
            nop

            b check_diagonal_success // check ok
            nop

            check_diagonal_success:
            // all conditions are met
            b cancel_wavedash
            nop

            cancel_wavedash:
            OS.save_registers()
            lli     a1, Kazuya.Action.WAVEDASH    // a1 = Action.SWEEP1
            or      a2, r0, r0                  // a2(starting frame) = 0.0
            lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
            lli     t6, 0x0003                  // ~
            sw      t6, 0x0010(sp)              // argument 4 = 0x0003 keep hitboxes
            jal     0x800E6F24                  // change action
            nop
            OS.restore_registers()
            OS.routine_end(0x20)

            main_normal:
            jal     0x800D94C4          // original routine
            nop
            OS.routine_end(0x20)
        }
    }

    scope TSUNAMI: {
        constant A_PRESSED(0x8000)  // bitmask for a press

        // tmp variable 3 0x0184 -- used to check if A was ever pressed down during the move

        scope main: {
            OS.routine_begin(0x20)

            lw      v0, 0x0084(a0)  // v0 = player struct

            lw      t0, 0x0078(a0)  // t0 = current animation frame
            lui     t1, 0x4000      // t1 = 1.0F

            // if frame != 1, skip
            bne     t0, t1, main_continue
            nop
            
            sw      r0, 0x0184(v0)              // reset tmp variable 3 = 0

            main_continue:
            sw      a0, 0x0010(sp)
            
            lw      v0, 0x0084(a0)              // loads player struct into v0
            lhu     t1, 0x01BE(v0)              // load button press buffer
            andi    t2, t1, A_PRESSED           // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne     t2, r0, register_press            // if A is pressed
            nop

            b   normal
            nop

            register_press:
            lli     t0, 0x1
            sw      t0, 0x0184(v0)

            b       normal
            nop

            normal:
            lw      t0, 0x0078(a0)  // t0 = current animation frame
            mtc1    t0, f6
            lui     t1, 0x4180      // t1 = 16.0F
            mtc1    t1, f8

            c.eq.s  f6, f8
            nop
            bc1fl   main_normal
            nop

            lw      t0, 0x0184(v0)          // was A or B ever pressed during the move?
            beq     t0, r0, main_normal     // If not, main_normal
            nop

            // all conditions are met
            b cancel_tsunami_2
            nop

            cancel_tsunami_2:
            OS.save_registers()
            lli     a1, Kazuya.Action.TSUNAMI2  // a1 = Action.SWEEP1
            or      a2, r0, r0                  // a2(starting frame) = 0.0
            lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
            lli     t6, 0x0003                  // ~
            sw      t6, 0x0010(sp)              // argument 4 = 0x0003 keep hitboxes
            jal     0x800E6F24                  // change action
            nop
            OS.restore_registers()
            OS.routine_end(0x20)

            main_normal:
            jal     0x800D94C4          // original routine
            nop
            OS.routine_end(0x20)
        }
    }

    scope NSP: {
        // The original electric effect function code does:
        // [ pos = (random() * deviation) + (deviation_neg) ]
        constant POS_DEVIATION(0x4120) // 10.0F (original is 300.0F)
        constant POS_DEVIATION_NEG(0xC0A0) // -5.0 (negative deviation/2)

        constant SCALE_MULTI(0x3FC0) // Scale multiplier = 1.5F

        scope main: {
            OS.routine_begin(0x20)

            lw      t0, 0x0078(a0)  // t0 = current animation frame
            mtc1    t0, f0

            lui     t0, 0x41F0 // t0 = 30.0f
            mtc1    t0, f2

            c.lt.s  f0, f2       // Compare f0 < f2?
            bc1f normal           // Branch if current frame > 30
            nop

            mtc1    r0, f2      // f2 = 0
            c.lt.s  f2, f0       // Compare f2 < f0?
            bc1f normal           // Branch if current frame < 0
            nop

            // Here we check if current frame % (N) == 0
            // So we generate an effect every N frames

            lui     t0, 0x4040      // t0 = 6.0f
            mtc1    t0, f2

            div.s       f1, f0, f2      // Divide f0 by f2
            nop
            floor.w.s   f2, f1          // f2 = floor(f1)
            cvt.s.w     f2, f2
            c.eq.s      f2, f1          // Check if the original float is equal to its floor
            nop
            bc1f normal    // Branch if false
            nop

            OS.save_registers()

            addiu   sp, sp, -0x30

            // Get hand position vector using a vanilla function
            lw      v0, 0x0084(a0)              // loads player struct into v0
            mtc1    r0, f0
            addiu   a1, sp, 0x0020
            swc1    f0, 0x0020(sp)              // x origin point
            swc1    f0, 0x0024(sp)              // y origin point
            swc1    f0, 0x0028(sp)              // z origin point
            lw      a0, 0x0910(v0)              // argument 0: object = Captain Falcon left hand joint
            sw      a3, 0x0030(sp)

            jal     0x800EDF24           // determine origin point of object in argument 0
            sw      v0, 0x002C(sp)

            lw      v0, 0x002C(sp)
            lw      a3, 0x0030(sp)
            sw      r0, 0x001C(sp)
            or      a0, a3, r0
            addiu   a0, sp, 0x0020

            // Reimplement subroutine 0x800FEEB0 (efParticle_ShockSmall_MakeEffect)
            OS.copy_segment(0x7A6B0, 0x44)

            lui     at, POS_DEVIATION     // X deviation
            mtc1    at, f4
            lui     at, POS_DEVIATION_NEG // X deviation neg
            mtc1    at, f8

            OS.copy_segment(0x7A6B0+0x54, 0x6C-0x54)

            lui     at, POS_DEVIATION     // Y deviation
            mtc1    at, f4
            lui     at, POS_DEVIATION_NEG // Y deviation neg
            mtc1    at, f8

            OS.copy_segment(0x7A6B0+0x7C, 0x108-0x7C)

            lui     t0, SCALE_MULTI // scale multiplier
            mtc1    t0, f6
            mul.s   f2, f2, f6
            nop
            swc1    f2,0x40(s1)
            swc1    f2,0x44(s1)

            OS.copy_segment(0x7A6B0+0x108, 0x124-0x108)

            addiu   sp,sp,0x38 // final function line
            
            addiu   sp, sp, 0x30

            OS.restore_registers()

            normal:
            lw      t0, 0x014C(v0)              // t0 = kinetic state
            bnez    t0, aerial                 // branch if kinetic state !grounded
            nop

            grounded:
            jal     0x800D94C4          // original routine
            nop
            b end
            nop

            aerial:
            jal 0x800D94E8
            nop
            
            end:
            OS.routine_end(0x20)
        }

        scope light_to_hard: {
            OS.routine_begin(0x20)

            lwc1    f8, 0x0078(a0)              // load current animation frame
            lui		at, 0x4100					// at = 8.0
            mtc1    at, f6                      // ~
            c.eq.s  f8, f6                      // f8 == f6 (current frame == 8) ?
            nop
            bc1fl   _end           // skip if frame isn't greater than 6
            nop

            lhu     t0, 0x01BC(a2)              // load button press buffer
            andi    t1, t0, 0x4000              // t1 = 0x40 if (B_PRESSED); else t1 = 0
            beq     t1, r0, _end               // skip if (!B_PRESSED)
            nop

            addiu   sp, sp,-0x0038              // allocate stack space
            sw      ra, 0x0004(sp)
            sw      a0, 0x0008(sp)
            sw      a1, 0x000C(sp)              // store variables
            sw      a2, 0x0010(sp)              // store variables
            sw      a3, 0x0014(sp)              // store variables
            sw      v0, 0x0018(sp)              // store variables
            addiu   sp, sp,-0x0030              // allocate stack space

            lw      v0, 0x0034(a2)              // v0 = player struct

            lli     a1, Kazuya.Action.SPECIALN2 // a1 = Action
            lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
            lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
            sw      r0, 0x0010(sp)              // argument 4 = 0
            jal     0x800E6F24                  // change action
            nop

            addiu   sp, sp, 0x0030              // allocate stack space
            lw      ra, 0x0004(sp)              // restore ra
            lw      a0, 0x0008(sp)
            lw      a1, 0x000C(sp)              // restore a2
            lw      a2, 0x0010(sp)              // restore a2
            lw      a3, 0x0014(sp)              // restore a2
            lw      v0, 0x0018(sp)              // restore a2
            addiu   sp, sp, 0x0038              // deallocate stack space

            _end:
            OS.routine_end(0x20)
        }
    }

    scope DSP: {
        scope air_collision: {
            OS.routine_begin(0x20)
            sw      ra, 0x0014(sp)              // store ra
            li      a1, air_to_ground          // a1(transition subroutine) = air_to_ground
            jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
            nop 
            lw      ra, 0x0014(sp)              // load ra
            OS.routine_end(0x20)
        }

        scope air_to_ground: {
            addiu   sp, sp,-0x0038              // allocate stack space
            sw      ra, 0x001C(sp)              // store ra
            sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
            lw      a0, 0x0084(a0)              // a0 = player struct
            jal     0x800DEE98                  // set grounded state
            sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
            lw      v0, 0x0034(sp)              // v0 = player struct
            lw      a0, 0x0038(sp)              // a0 = player object
            
            addiu   a1, r0, 0xE6              // a1 = equivalent ground action for current air action
            
            lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
            lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
            lli     t6, 0x0001                  // ~
            jal     0x800E6F24                  // change action
            sw      t6, 0x0010(sp)              // argument 4 = 1 (continue hitbox)
            lw      ra, 0x001C(sp)              // load ra
            addiu   sp, sp, 0x0038              // deallocate stack space
            jr      ra                          // return
            nop
        }
    }

    scope USP: {
        constant MOVE_SPEED_Y(0x42C8)   // float 100
        constant MOVE_SPEED_X(0x3F00)   // float 0.5

        scope main: {
            OS.routine_begin(0x20)

            lw      v0, 0x0084(a0)  // v0 = player struct

            lw      t0, 0x0078(a0)  // t0 = current animation frame
            lui     t1, 0x3F80      // t1 = 1.0F

            // if frame != 1, skip
            bne     t0, t1, main_continue
            nop
            
            lui     at, MOVE_SPEED_Y            // load y velocity
            sw      at, 0x004C(v0)              // save updated y velocity

            lb      t0, 0x01C2(v0)              // t0 = stick_x
            mtc1    t0, f14                     // ~
            cvt.s.w f14, f14                    // f14 = stick x
            lui     t0, MOVE_SPEED_X            // load move speed into t0
            mtc1    t0, f12                     // move move speed to fp register
            mul.s   f10, f14, f12               // multiply move speed by stick_x input
            swc1    f10, 0x0048(v0)             // store updated x velocity

            main_continue:
            jal     0x800D90E0          // original routine
            nop

            OS.routine_end(0x20)
        }

        scope collision: {
            OS.routine_begin(0x20)

            sw             ra, 0x001c (sp)      // save return address to stack
            lw             a1, 0x0084 (a0)      // load player struct
            sw             a0, 0x0028 (sp)      // save player object to stack

            jal            0x800de87c           // check to see if player has collided with clipping
            sw             a1, 0x0024(sp)      // save player struct

            beqz           v0, _end             // if no collision, skip to end
            lw             a1, 0x0024(sp)      // load player struct

            lhu            v0, 0x00d2(a1)      // load collision clipping flag
            andi           t6, v0, Surface.GROUND // check if colliding with a floor

            beqz           t6, _cliff_check     // branch not colliding with a wall
            andi           t7, v0, 0x3000       // check if colliding with cliff

            _ground:
            jal            0x800dee98
            or             a0, a1, r0           // place player struct in a0

            lw             a0, 0x0028 (sp)      // load player object
            addiu          a1, r0, Kazuya.Action.USP_LAND // load action ID
            addiu          a2, r0, 0x0000
            lui            a3, 0x3f80           // 1.0 placed in a3

            lli            t6, 0x0001                  // ~
            sw             t6, 0x0010(sp)              // argument 4 = 1 (continue hitbox)

            jal            0x800e6f24           // change action routine
            nop

            b              _end_2
            lw             ra, 0x001c (sp)      // load return address

            _cliff_check:
            beqzl          t7, _end   // branch if not a cliff
            andi           t6, v0, Surface.CEILING // check if colliding with a ceiling
            jal            0x80144c24           // cliff catch routine
            lw             a0, 0x0028 (sp)      // load player object

            _end:
            lw             ra, 0x001c (sp)      // load return address
            _end_2:
            OS.routine_end(0x20)
        }
    }

    scope NSP_AIR: {
        constant AIR_Y_SPEED(0x4248)            // current setting - float32 50
        constant AIR_ACCELERATION(0x3C65)       // current setting - float32 0.014
        constant AIR_SPEED(0x41A0)              // current setting - float32 20
        // @ Description
        // Subroutine which handles movement for Marina's up special.
        // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
        // This command's purpose appears to be setting a temporary variable in the player struct.
        // The most common use of this variable is to determine when a throw should be applied.
        // Variable values used by this subroutine:
        // 0x2 = begin movement
        // 0x3 = movement
        // 0x4 = ending
        scope physics: {
            // s0 = player struct
            // s1 = attributes pointer
            // 0x184 in player struct = temp variable 3
            addiu   sp, sp,-0x0038              // allocate stack space
            sw      ra, 0x001C(sp)              // ~
            sw      s0, 0x0014(sp)              // ~
            sw      s1, 0x0018(sp)              // store ra, s0, s1

            lw      s0, 0x0084(a0)              // s0 = player struct
            lw      t0, 0x014C(s0)              // t0 = kinetic state

            OS.copy_segment(0x548F0, 0x40)      // copy from original air physics subroutine
            li      t8, air_control_             // t8 = air_control_

            _apply_air_physics:
            or      a0, s0, r0                  // a0 = player struct
            jalr    t8                          // air control subroutine
            or      a1, s1, r0                  // a1 = attributes pointer
            or      a0, s0, r0                  // a0 = player struct
            jal     0x800D9074                  // air friction subroutine?
            or      a1, s1, r0                  // a1 = attributes pointer

            _check_begin:
            lw      t0,  0x4(s0) // t1 = player object
            lwc1    f8, 0x0078(t0)                 // load current animation frame

            lui		at, 0x4040					// at = 1.0
            mtc1    at, f6                      // ~
            c.eq.s  f8, f6                      // f8 == f6 (current frame == 1) ?
            nop
            bc1fl   _check_hop           // skip if frame isn't 1
            nop

            // sw      r0, 0x0048(s0)              // x velocity = 0
            // sw      r0, 0x004C(s0)              // y velocity = 0

            _check_hop:
            lwc1    f8, 0x0078(t0)                 // load current animation frame
            lui		at, 0x41C0					// at = 24.0
            mtc1    at, f6                      // ~
            c.eq.s  f8, f6                      // f8 == f6 (current frame == 10) ?
            nop
            bc1fl   _end           // skip if frame isn't 10
            nop

            lui     t1, AIR_Y_SPEED             // t1 = AIR_Y_SPEED
            sw      t1, 0x004C(s0)              // store y velocity

            lui     t1, AIR_SPEED             // t1 = AIR_Y_SPEED
            lw      t2, 0x0044(s0)            // t2 = facing direction (1 = right, -1 = left)

            slti    t3, t2, 0
            beq     t3, r0, set_x_speed
            nop

            facing_left:
            mtc1    t1, f6
            neg.s   f6, f6
            mfc1    t1, f6

            set_x_speed:
            sw      t1, 0x0048(s0)            // store x velocity

            _end:
            lw      ra, 0x001C(sp)              // ~
            lw      s0, 0x0014(sp)              // ~
            lw      s1, 0x0018(sp)              // loar ra, s0, s1
            addiu   sp, sp, 0x0038              // deallocate stack space
            jr      ra                          // return
            nop
        }

        // @ Description
        // Subroutine which handles Marina's horizontal control for up special.
        scope air_control_: {
            addiu   sp, sp,-0x0028              // allocate stack space
            sw      a1, 0x001C(sp)              // ~
            sw      ra, 0x0014(sp)              // ~
            sw      t0, 0x0020(sp)              // ~
            sw      t1, 0x0024(sp)              // store a1, ra, t0, t1
            addiu   a1, r0, 0x0008              // a1 = 0x8 (original line)
            lw      t6, 0x001C(sp)              // t6 = attribute pointer
            // load an immediate value into a2 instead of the air acceleration from the attributes
            lui     a2, AIR_ACCELERATION        // a2 = AIR_ACCELERATION
            lui     a3, AIR_SPEED               // a3 = AIR_SPEED
            jal     0x800D8FC8                  // air drift subroutine?
            nop
            lw      ra, 0x0014(sp)              // ~
            lw      t0, 0x0020(sp)              // ~
            lw      t1, 0x0024(sp)              // load ra, t0, t1
            addiu   sp, sp, 0x0028              // deallocate stack space
            jr      ra                          // return
            nop
        }

        // @ Description
        // Subroutine which allows a direction change
        // Uses the moveset data command 580000XX (orignally identified as "set flag" by toomai)
        // This command's purpose appears to be setting a temporary variable in the player struct.
        // Variable values used by this subroutine:
        // 0x2 = change direction
        scope change_direction_: {
            // begin by checking for turn inputs
            lw      a1, 0x0084(a0)              // a1 = player struct

            lui		at, 0x4000					// at = 1.0
            mtc1    at, f6                      // ~
            lwc1    f8, 0x0078(a0)              // ~
            c.eq.s  f8, f6                      // ~
            nop
            bc1fl   _end               // skip if haven't reached frame 3
            nop

            lb      t6, 0x01C2(a1)              // t6 = stick_x
            lw      t7, 0x0044(a1)              // t7 = DIRECTION
            multu   t6, t7                      // ~
            mflo    t6                          // t6 = stick_x * DIRECTION
            slti    at, t6, -39                 // at = 1 if stick_x < -39, else at = 0
            beqz    at, _end                    // branch if stick_x >= -39
            nop

            // if we're here, stick_x is opposite the facing direction, so turn the character around
            subu    t7, r0, t7                  // ~
            sw      t7, 0x0044(a1)              // reverse and update DIRECTION

            mtc1    t7, f6                      // ~
            cvt.s.w f6, f6                      // f6 = direction
            lui     at, 0x8013                  // ~
            lwc1    f8, 0xFE90(at)              // at = rotation constant
            mul.s   f8, f8, f6                  // f8 = rotation constant * direction
            lw      t7, 0x08E8(a1)              // t6 = character control joint struct
            swc1    f8, 0x0034(t7)              // update character rotation to match direction

            _end:
            jr      ra                          // return
            nop
        }

        scope collision: {
            OS.routine_begin(0x20)
            sw      ra, 0x0014(sp)              // store ra
            li      a1, air_to_ground          // a1(transition subroutine) = air_to_ground
            jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
            nop 
            lw      ra, 0x0014(sp)              // load ra
            OS.routine_end(0x20)
        }

        scope air_to_ground: {
            addiu   sp, sp,-0x0038              // allocate stack space
            sw      ra, 0x001C(sp)              // store ra
            sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
            lw      a0, 0x0084(a0)              // a0 = player struct
            jal     0x800DEE98                  // set grounded state
            sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
            lw      v0, 0x0034(sp)              // v0 = player struct
            lw      a0, 0x0038(sp)              // a0 = player object
            
            addiu   a1, r0, 0xE4              // a1 = equivalent ground action for current air action
            
            lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
            lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
            lli     t6, 0x0001                  // ~
            jal     0x800E6F24                  // change action
            sw      t6, 0x0010(sp)              // argument 4 = 1 (continue hitbox)
            lw      ra, 0x001C(sp)              // load ra
            addiu   sp, sp, 0x0038              // deallocate stack space
            jr      ra                          // return
            nop
        }
    }
}

scope KazuyaUSP {
    // floating point constants for physics and fsm
    constant AIR_Y_SPEED(0x0)            // current setting - float32 92
    constant GROUND_Y_SPEED(0x0)         // current setting - float32 98
    constant X_SPEED(0x4120)                // current setting - float32 10
    constant AIR_ACCELERATION(0x3E4C)       // current setting - float32 0.2
    constant AIR_SPEED(0x41B0)              // current setting - float32 22
    constant LANDING_FSM(0x3EC0)            // current setting - float32 0.375
    // temp variable 3 constants for movement states
    constant BEGIN(0x1)
    constant BEGIN_MOVE(0x2)
    constant MOVE(0x3)

    // @ Description
    // Subroutine which runs when Cloud initiates an aerial up special.
    // Changes action, and sets up initial variable values.
    scope air_initial_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, Kazuya.Action.USP      // a1 = Action.USPA
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        ori     v1, r0, 0x0002              // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        // reset fall speed
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        // freeze y position
        lw      v1, 0x09C8(a0)              // v1 = attribute pointer
        lw      v1, 0x0058(v1)              // v1 = gravity
        sw      v1, 0x004C(a0)              // y velocity = gravity
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which runs when Cloud initiates a grounded up special.
    // Changes action, and sets up initial variable values.
    scope ground_initial_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3

        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t7, 0x014C(a0)              // t7 = kinetic state
        bnez    t7, _change_action          // skip if kinetic state !grounded
        nop
        jal     0x800DEEC8                  // set aerial state
        nop
        lw      a0, 0x0020(sp)

        _change_action:
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, Kazuya.Action.USP      // a1 = Action.USPG
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        ori     v1, r0, 0x0002              // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which controls the physics of the movement stage of Dedede's Up Special.
    scope physics2_: {
        // a0 = player object
        addiu          sp, sp, -0x10        // allocate stack
        sw             ra, 0x0008 (sp)      // save return address

        jal            apply_vertical_movement2_
        nop

        _end:
        lw             ra, 0x0008 (sp)      // save return address
        jr             ra
        addiu          sp, sp, 0x10
    }

    constant BEGIN_SPEED(0x3F00)    // float 0.5
    constant MOVE_SPEED_X(0x3F30)   // float 0.6875
    constant MOVE_SPEED_Y(0x4310)   // float 144
    constant GRAVITY(0x4040)        // float 3
    constant GRAVITY_PEAK(0x4000)   // float -2.0
    constant GRAVITY_FALLING(0x4320) // float 20.0
    constant MAX_FALLING(0x4320)    // float 120
    constant B_PRESSED(0x40)                // bitmask for b press

    // @ Description
    // Subroutine which controls vertical movement during Dedede's Up Special.
    scope apply_vertical_movement2_: {
        // a0 = player object
        addiu          sp, sp, -0x20        // allocate stack
        sw             ra, 0x001c (sp)      // save return address
        sw             s0, 0x0018 (sp)
        lw             s0, 0x0084 (a0)      // load player struct
        sw             a0, 0x0020 (sp)      // save player object
        or             a0, s0, r0           // place player struct in a0
        lw             v0, 0x09c8 (s0)      // load attribute pointer
        addiu          t5, r0, 0x0001

        lw      at, 0x0020(sp)              // at = player object
        lw      t0, 0x0078(at)              // load current frame to t0

        lui		at, 0x0					    // at = last animation frame
		beq     t0, at, _apply_speed
        lui     at, MAX_FALLING         // apply fast fall speed

        b _apply_speed
        lui     at, GRAVITY_PEAK         // apply fast fall speed

        _apply_speed:
        mtc1           at, f6
        lwc1           f4, 0x0058 (v0)      // load player gravity
        mul.s          f0, f4, f6           // multiply player gravity by aerial boost multiplier
        nop
        mfc1           a1, f0               // move gravity to a1
        jal            0x800d8d68           // determine vertical lift amount, a1=gravity, a2=max falling speed
        lui            a2, MAX_FALLING      // load max falling speed

        _move:
        or             a0, s0, r0           // player struct moved to a0
        jal            0x800d8fa8
        lw             a1, 0x09c8 (s0)      // loads attribute pointer
        lw             ra, 0x001c (sp)      // load return address

        _end:
        lw             s0, 0x0018 (sp)
        jr             ra
        addiu          sp, sp, 0x20
    }

    // @ Description
    // Subroutine which controls the collision of the movement stage of Dedede's Up Special.
    scope usp2_collision_: {
        addiu          sp, sp, -0x28        // allocate stack space
        sw             ra, 0x001c (sp)      // save return address to stack
        lw             a1, 0x0084 (a0)      // load player struct
        sw             a0, 0x0028 (sp)      // save player object to stack

        jal            0x800de87c           // check to see if player has collided with clipping
        sw             a1, 0x0024 (sp)      // save player struct

        beqz           v0, _end             // if no collision, skip to end
        lw             a1, 0x0024 (sp)      // load player struct

        lhu            v0, 0x00d2 (a1)      // load collision clipping flag
        andi           t6, v0, Surface.GROUND // check if colliding with a floor

        beqz           t6, _cliff_check     // branch not colliding with a wall
        andi           t7, v0, 0x3000       // check if colliding with cliff

		_ground:
        jal            0x800dee98
        or             a0, a1, r0           // place player struct in a0

        lw             a0, 0x0028 (sp)      // load player object
        addiu          a1, r0, Cloud.Action.USP_LAND // load action ID
        addiu          a2, r0, 0x0000
        lui            a3, 0x3f80           // 1.0 placed in a3

        jal            0x800e6f24           // change action routine
        sw             r0, 0x0010 (sp)

        b              _end_2
        lw             ra, 0x001c (sp)      // load return address

        _cliff_check:
        beqzl          t7, _end   // branch if not a cliff
        andi           t6, v0, Surface.CEILING // check if colliding with a ceiling
        jal            0x80144c24           // cliff catch routine
        lw             a0, 0x0028 (sp)      // load player object

        _end:
        lw             ra, 0x001c (sp)      // load return address
		_end_2:
        jr             ra                   // return
        addiu          sp, sp, 0x28         // deallocate stack space
    }

    // @ Description
    // Main subroutine for Cloud's up special.
    // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
    // Modified to load Cloud's landing FSM value and disable the interrupt flag.
    scope main_: {
        lwc1    f8, 0x0078(a0)              // load current frame

        lui		at, 0x4040					// at = 3.0
		mtc1    at, f6                      // ~
        c.eq.s  f8, f6                      // f8 >= f6 (current frame >= 3) ?
        nop
        bc1tl   _change_temp2                // skip if haven't reached frame 3
        nop

        lui		at, 0x4000					// at = 2.0
		mtc1    at, f6                      // ~
        c.eq.s  f8, f6                      // f8 >= f6 (current frame >= 2) ?
        nop
        bc1tl   _change_temp2                // skip if haven't reached frame 2
        nop

        _change_temp2:
        ori     v1, r0, 0x0002              // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x2(BEGIN_MOVE)

        _change_temp3:
        ori     v1, r0, 0x0003              // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x2(BEGIN_MOVE)

        _check_input_for_part_2:
        lw     t7, 0x0024(a2)              // t7 = current action
        lli    t2, Cloud.Action.USP
        bne    t7, t2, _main_normal        // if not performing USP(1), skip
        nop

        lui		at, 0x41F0					// at = 2.0
		mtc1    at, f6                      // ~
        c.lt.s  f8, f6                      // f8 >= f6 (current frame >= 2) ?
        nop
        bc1fl   _main_normal                // skip if haven't reached frame 2
        nop

        lui		at, 0x41A0					// at = 2.0
		mtc1    at, f6                      // ~
        c.lt.s  f6, f8                      // f8 >= f6 (current frame >= 2) ?
        nop
        bc1fl   _main_normal                // skip if haven't reached frame 2
        nop

        lhu     t0, 0x01BE(a2)              // load button press buffer
        andi    t1, t0, 0x4000              // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, _main_normal        // skip if (!B_PRESSED)
        nop

        // Change into upB2
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x0004(sp)
        sw      a0, 0x0008(sp)
        sw      a1, 0x000C(sp)              // store variables
        sw      a2, 0x0010(sp)              // store variables
        sw      a3, 0x0014(sp)              // store variables
        sw      v0, 0x0018(sp)              // store variables
        addiu   sp, sp,-0x0030              // allocate stack space

        lw      v0, 0x0034(a2)              // v0 = player struct

        lli     a1, Cloud.Action.USP2        // a1 = Action.USP2
        lui     a2, 0x3F80               // a2(starting frame) = 0.0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E6F24                  // change action
        nop

        addiu   sp, sp, 0x0030              // allocate stack space
        lw      ra, 0x0004(sp)              // restore ra
        lw      a0, 0x0008(sp)
        lw      a1, 0x000C(sp)              // restore a2
        lw      a2, 0x0010(sp)              // restore a2
        lw      a3, 0x0014(sp)              // restore a2
        lw      v0, 0x0018(sp)              // restore a2
        addiu   sp, sp, 0x0038              // deallocate stack space
        or      a1, a0, r0                 // restore a0 = player object

        jr      ra
        nop

        j _main_normal
        nop

        _main_normal:

        // On frame 15, set tmp variable 1 to 1
        // This is needed for the collision function
        // so we transition to special landing on grounded transition
        lui		at, 0x4170					// at = 15
		mtc1    at, f6                      // ~
        c.eq.s  f8, f6                      // f8 >= f6 (current frame >= 3) ?
        nop
        bc1fl   _change_temp1_continue      // skip if haven't reached frame 3
        nop

        lli     t0, 0x1
        sw      t0, 0x0180(a2)

        _change_temp1_continue:

        // Copy the first 8 lines of subroutine 0x8015C750
        OS.copy_segment(0xD7190, 0x20)
        bc1fl   _end                        // skip if animation end has not been reached
        lw      ra, 0x0024(sp)              // restore ra
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM
        lw      ra, 0x0024(sp)              // restore ra

        _end:
        addiu   sp, sp, 0x0028              // deallocate stack space

        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which allows a direction change for Cloud's up special.
    // Uses the moveset data command 580000XX (orignally identified as "set flag" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // Variable values used by this subroutine:
    // 0x2 = change direction
    scope change_direction_: {
        // 0x180 in player struct = temp variable 2
        lw      a1, 0x0084(a0)              // a1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // store t0, t1, ra

        ori     t1, r0, 0x0000              // t1 = 0x0
        //sw      t1, 0x0180(a1)              // t0 = temp variable 2

        lui		at, 0x4040					// at = 3.0
		mtc1    at, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.eq.s  f8, f6                      // ~
        nop
        bc1tl   _set_temp_var               // skip if haven't reached frame 3
        nop

        _main:
        lw      t0, 0x0180(a1)              // t0 = temp variable 2
        ori     t1, r0, 0x0002              // t1 = 0x2
        bne     t1, t0, _end                // skip if temp variable 2 != 2
        nop

        jal     0x80160370                  // turn subroutine (copied from captain falcon)
        nop

        lw      a1, 0x0010(sp)              // load a1
        ori     t1, r0, 0x0001              // t1 = 0x1
        sw      t1, 0x0180(a1)              // temp variable 2 = 1

        j _end
        nop

        _set_temp_var:
        ori      t1, r0, 0x0002                  // t1 = 0x2
        sw      t1, 0x0180(a1)              // t0 = temp variable 2

        j _main
        nop

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load t0, t1, ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles movement for Cloud's up special.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x2 = begin movement
    // 0x3 = movement
    // 0x4 = ending
    scope physics_: {
        // s0 = player struct
        // s1 = attributes pointer
        // 0x184 in player struct = temp variable 3
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        sw      s1, 0x0018(sp)              // store ra, s0, s1

        lw      s0, 0x0084(a0)              // s0 = player struct
        lw      t0, 0x014C(s0)              // t0 = kinetic state
        bnez    t0, _aerial                 // branch if kinetic state !grounded
        nop

        _grounded:
        jal     0x800DEEC8                  // set aerial state
        nop
        
        jal     0x800D93E4                  // grounded physics subroutine
        nop
        b       _end                        // end subroutine
        nop

        _aerial:
        // Check if reached min frame where air control is possible
        lw     at, 0x4(s0)              // at = player object
        lwc1   f8, 0x0078(at)              // f8 = current animation frame
        lw     t7, 0x0024(s0)              // t7 = current action
        lli    t2, Cloud.Action.USP
        bne    t7, t2, _end        // if not performing USP(1), skip
        nop

        lui		at, 0x41F0					// at = 2.0
		mtc1    at, f6                      // ~
        c.lt.s  f6, f8                      // f8 >= f6 (current frame >= 2) ?
        nop
        bc1fl   _root_motion                // skip if haven't reached frame 2
        nop

        b _apply_air_physics
        nop

        _root_motion:
        jal     0x800D93E4                  // grounded physics subroutine
        nop

        b _end
        nop

        _apply_air_physics:
        lw      s0, 0x0014(sp)              // restore s0 for this one
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x0180(t0)              // t1 = temp variable 2
        li      t8, 0x800D90E0              // t8 = physics subroutine which allows player control

        jalr    t8
        nop

        or      a1, s1, r0                  // a1 = attributes pointer
        or      a0, s0, r0                  // a0 = player struct

        // jal     0x800D9074                  // air friction subroutine?
        // or      a1, s1, r0                  // a1 = attributes pointer

        b       _end                        // end subroutine
        nop

        _check_begin:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_begin_move   // skip if temp variable 3 != BEGIN
        lw      t0, 0x0024(s0)              // t0 = current action
        lli     t1, Cloud.Action.USP      // t1 = Action.USPG
        beq     t0, t1, _check_begin_move   // skip if current action = USP_GROUND
        nop
        // freeze x movement
        sw      r0, 0x0048(s0)              // x velocity = 0
        // freeze y position
        sw      r0, 0x004C(s0)              // y velocity = 0

        _check_begin_move:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN_MOVE          // t1 = BEGIN_MOVE
        bne     t0, t1, _end                // skip if temp variable 3 != BEGIN_MOVE
        nop
        // initialize x/y velocity
        lw      t0, 0x0024(s0)              // t0 = current action
        lli     t1, Cloud.Action.USP      // t1 = Action.USPG
        beq     t0, t1, _apply_velocity     // branch if current action = USP_GROUND
        lui     t1, GROUND_Y_SPEED          // t1 = GROUND_Y_SPEED
        // if current action != USP_GROUND
        lui     t1, AIR_Y_SPEED             // t1 = AIR_Y_SPEED

        _apply_velocity:
        lui     t0, X_SPEED                 // ~
        mtc1    t0, f2                      // f2 = X_SPEED
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        mul.s   f2, f0, f2                  // f2 = x velocity * direction
        ori     t0, r0, MOVE                // t0 = MOVE
        sw      t0, 0x0184(s0)              // temp variable 3 = MOVE
        // take mid-air jumps away at this point
        lw      t0, 0x09C8(s0)              // t0 = attribute pointer
        lw      t0, 0x0064(t0)              // t0 = max jumps
        sb      t0, 0x0148(s0)              // jumps used = max jumps

        // og
        //swc1    f2, 0x0048(s0)              // store x velocity
        //sw      t1, 0x004C(s0)              // store y velocity

        // try 1
        // lw      v1, 0x09C8(a0)              // v1 = attribute pointer
        // lw      v1, 0x0058(v1)              // v1 = gravity
        // sw      v1, 0x004C(s0)              // y velocity = gravity

        // try 2
        // freeze x movement
        sw      r0, 0x0048(s0)              // x velocity = 0
        // freeze y position
        sw      r0, 0x004C(s0)              // y velocity = 0

        _end:
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        lw      s1, 0x0018(sp)              // loar ra, s0, s1
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles Cloud's horizontal control for up special.
    scope air_control_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      a1, 0x001C(sp)              // ~
        sw      ra, 0x0014(sp)              // ~
        sw      t0, 0x0020(sp)              // ~
        sw      t1, 0x0024(sp)              // store a1, ra, t0, t1
        addiu   a1, r0, 0x0008              // a1 = 0x8 (original line)
        lw      t6, 0x001C(sp)              // t6 = attribute pointer
        // load an immediate value into a2 instead of the air acceleration from the attributes
        lui     a2, AIR_ACCELERATION        // a2 = AIR_ACCELERATION
        lui     a3, AIR_SPEED               // a3 = AIR_SPEED
        jal     0x800D8FC8                  // air drift subroutine?
        nop
        lw      ra, 0x0014(sp)              // ~
        lw      t0, 0x0020(sp)              // ~
        lw      t1, 0x0024(sp)              // load ra, t0, t1
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision wubroutine for Cloud's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Cloud.
    scope collision_: {
        OS.save_registers()
        jal RyuDSP.check_ledge_grab_        // cliff catch routine
        nop
        OS.restore_registers()
        
        // Copy the first 30 lines of subroutine 0x80156358
        OS.copy_segment(0xD0D98, 0x78)
        // Replace original line which loads the landing fsm
        //lui     a2, 0x3E8F                // original line 1
        lui     a2, LANDING_FSM             // a2 = LANDING_FSM
        // Copy the last 17 lines of subroutine 0x80156358
        OS.copy_segment(0xD0E14, 0x44)
    }
}