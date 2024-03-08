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

            lb      t2, 0x01C2(a2)                          // t0 = stick_x
            mtc1    t2, f6                                  // f6 = stick_x
            abs.s   f6, f6                                  // f6 = abs(stick_x)
            mfc1    t2, f6                                  // t0 = abs(stick_x)

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
            or      a2, r0, r0                  // a2(starting frame) = 0.0
            lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
            sw      r0, 0x0010(sp)              // argument 4 = 0
            jal     0x800E6F24                  // change action
            nop
            OS.restore_registers()
            
            OS.routine_end(0x20)

            cancel_b:
            OS.save_registers()
            lli     a1, Kazuya.Action.SWEEP1    // a1 = Action.SWEEP1
            or      a2, r0, r0                  // a2(starting frame) = 0.0
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
            lui     t1, 0x3F80      // t1 = 1.0F

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

    scope NSP: {
        // The original function code does [ pos = (random() * deviation) + (deviation_neg) ]
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
            
            jal     0x800D94C4          // original routine
            nop
            
            OS.routine_end(0x20)
        }
    }
}

// NSP
// addiu   a0, a0, 0x001C              // a0 = projectile x/y/z coordinates
// jal     0x800FE068                  // create electric hit gfx
// lli     a1, 00023                   // a1(gfx size) = 23