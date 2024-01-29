// CloudSpecial.asm

// This file contains subroutines used by Cloud's special moves.

scope CloudUSP {
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
        lli     a1, Cloud.Action.USP      // a1 = Action.USPA
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
        lli     a1, Cloud.Action.USP      // a1 = Action.USPG
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

        lhu     t0, 0x01BC(a2)              // load button press buffer
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
        // OS.copy_segment(0x548F0, 0x40)      // copy from original air physics subroutine
        // bnez    v0, _check_begin            // modified original branch
        // nop
        // li      t8, 0x800D8FA8              // t8 = subroutine which disallows air control
        // lw      t0, 0x0184(s0)              // t0 = temp variable 3
        // ori     t1, r0, MOVE                // t1 = MOVE
        // bne     t0, t1, _apply_air_physics  // branch if temp variable 3 != MOVE
        // nop

        // Check if reached min frame where air control is possible
        lw     at, 0x4(s0)              // at = player object
        lwc1   f8, 0x0078(at)              // f8 = current animation frame
        lw     t7, 0x0024(s0)              // t7 = current action
        lli    t2, Cloud.Action.USP
        bne    t7, t2, _end        // if not performing USP(1), skip
        nop

        lui		at, 0x41C8					// at = 2.0
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

scope CloudNSP {
    // floating point constants for physics and fsm
    constant AIR_Y_SPEED(0x4220)            // current setting - float32 60
    constant GROUND_Y_SPEED(0x42C4)         // current setting - float32 98
    constant X_SPEED(0x0)                // current setting - float32 10
    constant AIR_ACCELERATION(0x3C88)       // current setting - float32 0.0166
    constant AIR_SPEED(0x41B0)              // current setting - float32 22
    constant LANDING_FSM(0x4000)            // current setting - float32 0.375
    // temp variable 3 constants for movement states
    constant BEGIN(0x1)
    constant BEGIN_MOVE(0x2)
    constant MOVE(0x3)


    // tmp variable 1 0x017C
    // tmp variable 2 0x0B30 -- use this to check if we're going for shakunetsu
    // tmp variable 3 0x0184

    // @ Description 
    // main subroutine for Cloud's Blaster
    scope main: {
        addiu   sp, sp, -0x0040
        sw      ra, 0x0014(sp)
		swc1    f6, 0x003C(sp)
        swc1    f8, 0x0038(sp)
        sw      a0, 0x0034(sp)
		addu	a2, a0, r0
        lw      v0, 0x0084(a0)                      // loads player struct

        fire_effect:
        // FIRE EFFECT
        // OS.save_registers()

        // or a0, r0, a2 // argument = player object
        // lw v1, 0x0084(a0) // v1 = player struct

        // jal 0x80101F84
        // nop

        // OS.restore_registers()
        // END FIRE EFFECT

        // Check if we're on fist frame so we can set x speed to 0
        lui t1, 0x4000 // t1=1.0
        mtc1    t1, f6 // f6=1.0
        lwc1    f8, 0x0078(a2) // f8=current frame, if a2 is player object
        c.eq.s  f8, f6 // compare less equal f8 f6
        bc1fl   main_continue // if frame is not 1.0, continue
        nop

        // frame = 1.0
        sw      r0, 0x0048(v0)  // set zero x speed
        
        main_continue:
        or      a3, a0, r0
        lw      t6, 0x017C(v0)                      // tmp variable 1
        beql    t6, r0, _idle_transition_check      // this checks moveset variables to see if projectile should be spawned
        lw      ra, 0x0014(sp)
        mtc1    r0, f0
        sw      r0, 0x017C(v0)                      // clears out variable so he only fires one shot
        addiu   a1, sp, 0x0020
        swc1    f0, 0x0020(sp)                      // x origin point
        swc1    f0, 0x0024(sp)                      // y origin point
        swc1    f0, 0x0028(sp)                      // z origin point

        // lui    t0, 0x42C8
        // mtc1   f0, f0

        lw      a0, 0x0928(v0)
        sw      a3, 0x0030(sp)
        jal     0x800EDF24                          // generic function used to determine projectile origin point
        sw      v0, 0x002C(sp)
        lw      v0, 0x002C(sp)
        lw      a3, 0x0030(sp)
        sw      r0, 0x001C(sp)
        or      a0, a3, r0
        addiu   a1, sp, 0x0020
        jal     projectile_stage_setting            // this sets the basic features of a projectile
        lw      a2, 0x001C(sp)
		lw      a2, 0x0034(sp)
        lw      ra, 0x0014(sp)
		
		// checks frame counter to see if reached end of the move
        _idle_transition_check:
        mtc1    r0, f6
        lwc1    f8, 0x0078(a2)
        c.le.s  f8, f6
        nop
        bc1fl   _end
        lw      ra, 0x0014(sp)
        lw      a2, 0x0034(sp)
        jal     0x800DEE54
        or      a0, a2, r0
         _end:
		lw      a0, 0x0034(sp)
        lwc1    f6, 0x003C(sp)
        lwc1    f8, 0x0038(sp)
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0040
        jr      ra
        nop

		projectile_stage_setting:
        addiu   sp, sp, -0x0050
        sw      a2, 0x0038(sp)
        lw      t7, 0x0038(sp)
		sw      s0, 0x0018(sp)

        // Check if B is pressed to switch between light and strong hadouken
        // v0 = player struct
        la      s0, _blaster_fireball_struct       // s0 = light hadouken address

        li t2, _blaster_projectile_struct // Load projectile struct address into t2 for later use
        
        projectile_stage_setting_continue:
        sw      a1, 0x0034(sp)
        sw      ra, 0x001C(sp)
        or      a1, t2, r0		// use projectile address saved in t2
        lw      t6, 0x0084(a0)
        lw      t0, 0x0024(s0)
        lw      t1, 0x0028(s0)
        lw      a2, 0x0034(sp)
        lui     a3, 0x8000
        sw      t6, 0x002C(sp)
        //sw      t0, 0x0008(a1)        // would revise default pointer, which has another pointer, which is to the hitbox data
        jal     0x801655C8                // This is a generic routine that does much of the work for defining all projectiles
        sw      t1, 0x000C(a1)

        bnez    v0, _projectile_branch
        sw      v0, 0x0028(sp)
        beq     r0, r0, _end_stage_setting
        or      v0, r0, r0
        
        _projectile_branch:
        lw      v1, 0x0084(v0)
        lui     t2, 0x3f80              // load 1(fp) into f2
        addiu   at, r0, 0x0001
        mtc1    r0, f4
        sw      t2, 0x029C(v1)           // save 1(fp) to projectile struct free space
        lw      t3, 0x0000(s0)
        sw      t3, 0x0268(v1)

        lw v0, 0x002C(sp) // load player struct to v0

        _projectile_branch_hadouken:
        // ==============
        // EDIT HITBOX
        // ==============

        // Hitbox size
        lui     at, 0x4334              // at = 180.0 (fp)
        sw      at, 0x0128(v1)          // save

        // Hitbox damage
        lli     at, 0x000A              // 10
        sw      at, 0x0104(v1)          // save

        // Hit type
        sw      r0, 0x010C(v1)          // save

        // Hit angle
        lli     at, 0x37                // 55 deg
        sw      at, 0x012C(v1)

        // // Hitbox base knockback
        lli     at, 0x0026              // at = 38
        sw      at, 0x0138(v1)          // save

        // Hitbox knockback growth
        lli     at, 0x003C              // at = 60
        sw      at, 0x0130(v1)          // save

        // Hit FGM
        lli     at, 0x57C               // at = RYU_HIT_M
        sh      at, 0x0146(v1)          // save
        
        // ==============
        // END EDIT HITBOX
        // ==============
        
        b _projectile_branch_continue
        nop
   
        _projectile_branch_continue:
        OS.copy_segment(0xE3268, 0x2C)   
        lw      t6, 0x002C(sp)
		lwc1    f6, 0x0020(s0)           // load speed (integer)
        lw      v1, 0x0024(sp)
        lw      t7, 0x0044(t6)
        mul.s   f8, f0, f6
        lwc1    f12, 0x0020(sp)
        mtc1    t7, f10
        nop
        cvt.s.w f16, f10
        mul.s   f18, f8, f16
        jal     0x800303F0
        swc1    f18, 0x0020(v1)
        lwc1    f4, 0x0020(s0)
        lw      v1, 0x0024(sp)
        lw      a0, 0x0028(sp)
        mul.s   f6, f0, f4
        swc1    f6, 0x0024(v1)
        lw      t8, 0x0074(a0)
        lwc1    f10, 0x002C(s0)
        lw      t9, 0x0080(t8)

        lui     at, 0x4000 // at = 2.0
        mtc1    at, f6
        swc1    f6, 0x0040(t8)      // store scale x size multiplier to projectile joint
        swc1    f6, 0x0044(t8)      // store scale y size multiplier to projectile joint
        swc1    f6, 0x0048(t8)      // store scale z size multiplier to projectile joint

        lui     t0, 0xc348
        mtc1    t0, f0
        swc1    f0, 0x6c(v1)         // Adjust coll_data.object_coll.bottom

        lw      at, 0x014C(t4)      // Load player grounded state
        sw      at, 0xfc(v1)        // Save grounded matching grounded state for projectile

        lw      t1, 0xEC(t4)  // t1 = player (t4) ground_line_id
        sw      t1, 0xA0(v1)  // save to projectile

        bne     at, r0, projectile_not_grounded
        nop
        // ip->phys_info.ground_vel = ip->phys_info.vel.x * ip->lr

        lw      t6, 0x18(v1)  // t2 = ip.phys_info
        lwc1    f4, 0x20(v1)
        mtc1    t6, f6
        nop
        cvt.s.w f18, f6
        mul.s   f6, f4, f18
        nop
        swc1    f6, 0x1C(v1)  // save to projectile

        projectile_not_grounded:

        // or      a0, at, r0
        lw      v0, 0x0028(sp)
        
        // This ensures the projectile faces the correct direction
        jal     0x80167FA0
        swc1    f10, 0x0088(t9)

        lw      v0, 0x0028(sp)

        _end_stage_setting:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        addiu   sp, sp, 0x0050
        jr  	ra
        nop

		// this subroutine seems to have a variety of functions, but definetly deals with the duration of move and result at the end of duration
        blaster_duration:
        addiu   sp, sp, -0x0038
        sw      ra, 0x0014(sp)
        sw      a0, 0x0020(sp)
        swc1    f10, 0x0024(sp)

        jal     0x8016BC50
        nop

        sw      v0, 0x28(sp)
        sw      v1, 0x2C(sp)

        // lw      a0, 0x0020(sp) // load Item_Struct
        // lw      t8, 0xfc(a0) // grounded state
        bnezl   t8, blaster_duration_end // skip if not grounded
        nop

        // spawn a dash gfx every 8 frames
        andi    t7, t7, 0x0007              // ~
        bnez    t7, blaster_duration_end    // branch if timer value does not end in 0b000 (branch won't be taken once every 8 frames)

        lw      a0, 0x0020(sp)              // ~

        lw      t0, 0x0084(a0)              // t0 = item special struct
        lw      a1, 0x0018(t0)              // ~ a1 = direction

        lw      a0, 0x0074(a0)              // ~
        addiu   a0, a0, 0x001C              // a0 = object x/y/z coordinates
        lui     a2, 0x3F80                  // a2 = scale? float32 1
        jal     0x800FF7D8                  // create footstep gfx
        nop

        lw      a0, 0x0020(sp)

        lw      v0, 0x28(sp)
        lw      v1, 0x2C(sp)

        blaster_duration_end:
        lw      ra, 0x0014(sp)
        //lw      a0, 0x0020(sp)
        lwc1    f10, 0x0024(sp)
        addiu   sp, sp, 0x0038
        jr      ra
        nop

        _hitbox_end:
        OS.copy_segment(0xE396C, 0x38)
        // swc1 f4, 0x0148(v0)
        OS.copy_segment(0xE39A8, 0x30)
        
        // this subroutine determines the behavior of the projectile upon reflection
        blaster_reflection:
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        sw      a0, 0x0018(sp)
        lw      a0, 0x0084(a0)      // loads active projectile struct
        lw      t0, 0x0008(v0)
        addiu   t7, r0, Character.id.CLOUD
        bnel    t0, t7, _standard
        lui     t7, 0x3F80          // load normal reflect multiplier if not cloud and thereby top speed of cloud projectile will not increase
        li      t7, 0x3FC90FDB      // load reflect multiplier
        _standard:
        mtc1    t7, f4              // move reflect multiplier to floating point
        sw      t7, 0x029C(a0)      // save multiplier to free space to increase max speed
        lw      t7, 0x0008(a0)
        li      t0, _blaster_fireball_struct // load fireball struct to pull parameters
        lw      t0, 0x0000(t0)      // loads max duration from fireball struct
        sw      t0, 0x0268(a0)      // save max duration to active projectile struct current remaining duration
        lw      a1, 0x0084(t7)      // loads reflective character's struct

        // Before determining new direction, multiply speed.
        lw      t6, 0x0044(a1)      // loads player direction 1 or -1 in fp
        lwc1    f0, 0x0020(a0)      // loads projectile velocity
        mul.s   f0, f0, f4          // multiply current speed by reflection speed multiplier
        nop
        swc1    f0, 0x0020(a0)      // save new speed
        nop
        jal     0x801680EC          // go to the default subroutine that determines direction
        nop

        // old routine for reference, was based on 0x801680EC
        // lw      t6, 0x0044(a1)      // loads direction 1 or -1 in fp
        // lwc1    f0, 0x0020(a0)      // loads velocity
        // mul.s   f0, f0, f4          // multiply current speed by reflection speed multiplier (not original logic)
        // mtc1    r0, f10             // move 0 to f10
        // mtc1    t6, f4              // place direction in f4
        // nop
        // cvt.s.w f6, f4              // cvt to sw floating point
        // mul.s   f8, f0, f6          // change direction of projectile to the opposite direction via multiplication
        // //  lw      t6, 0x0004(t0)      // load max speed
        // //  mtc1    t6, f6              // move max speed to f6
        // c.lt.s  f8, f10             // current velocity compared to 0 (less than or equal to)
        // nop
        // bc1f    _branch              // jump if velocity is greater than 0
        // nop
        // neg.s   f16, f0
        // swc1    f16, 0x0020(a0)     // save velocity
        
        _branch:
        lw      a0, 0x0018(sp)
        lw      v0, 0x0084(a0)      // load active projectile struct
        mtc1    r0, f6              // move 0 to f6
        lwc1    f4, 0x0020(v0)      // load current velocity of projectile
        c.le.s  f6, f4              // compare 0 to current velocity to see if now traveling leftward
        nop
        bc1f    _left               // jump if 0 is greater than velocity, this means the projectile is traveling leftward
        nop
        li        at, 0x3FC90FDB
        mtc1      at, f8    
        lw      t6, 0x0074(a0)
        j       _end_reflect
        swc1    f8, 0x0034(t6)
        _left:
        li        at, 0xBFC90FDB
        mtc1      at, f10
        lw      t7, 0x0074(a0)
        swc1    f10, 0x0034(t7)
        _end_reflect:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        or      v0, r0, r0
        jr      ra
        nop
        
		_blaster_projectile_struct:
        dw 0x00000000                   // this has some sort of bit flag to tell it to use secondary type display list?
		dw FGC.FGC_PROJECTILE_ID+1
        dw Character.CLOUD_file_6_ptr    // pointer to file
        dw 0x00000000                   // 00000000
        dw 0x1C000000                   // rendering routine?
        dw blaster_duration             // duration (default 0x80168540) (samus 0x80168F98)
        dw 0x8016BCC8                   // collision (0x801685F0 - Mario) (0x80169108 - Samus)
        dw 0x80175958    		        // after_effect 0x801691FC, this one is used when grenade connects with player
        dw 0x80175958                   // after_effect 0x801691FC, used when touched by player when object is still, by setting to null, nothing happens
        dw 0x8016DD2C                   // determines behavior when projectile bounces off shield, this uses Master Hand's projectile coding to determine correct angle of graphic (0x8016898C Fox)
        dw 0x80175958                   // after_effect                // rocket_after_effect 0x801691FC
        dw blaster_reflection           // OS.copy_segment(0x1038FC, 0x04)            // this determines reflect behavior (default 0x80168748)
        dw 0x80175958                   // This function is run when the projectile is used on ness while using psi magnet
        OS.copy_segment(0x103904, 0x0C) // empty
		
		_blaster_fireball_struct:
        dw 60                          // 0x0000 - duration (int)
        float32 48                     // 0x0004 - max speed
        float32 48                      // 0x0008 - min speed
        float32 0                       // 0x000C - gravity
        float32 0                       // 0x0010 - bounce multiplier
        float32 0                       // 0x0014 - rotation angle
        float32 0                       // 0x0018 - initial angle (ground)
        float32 0                       // 0x001C   initial angle (air)
        float32 48                      // 0x0020   initial speed
        dw Character.CLOUD_file_6_ptr    // 0x0024   projectile data pointer
        dw 0                            // 0x0028   unknown (default 0)
        float32 0                       // 0x002C   palette index (0 = mario, 1 = luigi)
        OS.copy_segment(0x1038A0, 0x30)
    }
		
   // @ Description
   // Subroutine which handles air collision for neutral special actions
    scope air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_to_ground_          // a1(transition subroutine) = air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop 
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Subroutine which handles ground to air transition for neutral special actions
    scope air_to_ground_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        
        lw      a2, 0x0008(v0)              // load character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, _change_action      // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WOLF_NSP_Ground
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, _change_action      // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WOLF_NSP_Ground
        
        addiu   a1, r0, 0xE5              // a1 = equivalent ground action for current air action
        _change_action:
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


    // @ Description
    // Subroutine which handles movement for Marina's up special.
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
        jal     0x800D8BB4                  // grounded physics subroutine
        nop
        b       _end                        // end subroutine
        nop

        _aerial:
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

        sw      r0, 0x0048(s0)              // x velocity = 0
        // sw      r0, 0x004C(s0)              // y velocity = 0

        _check_hop:
        lwc1    f8, 0x0078(t0)                 // load current animation frame
        lui		at, 0x4140					// at = 12.0
		mtc1    at, f6                      // ~
        c.eq.s  f8, f6                      // f8 == f6 (current frame == 10) ?
        nop
        bc1fl   _end           // skip if frame isn't 10
        nop

        lui     t1, AIR_Y_SPEED             // t1 = AIR_Y_SPEED
        sw      t1, 0x004C(s0)              // store y velocity

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
}

scope CloudDSP {
    scope main: {
        addiu   sp, sp, -0x0040
        sw      ra, 0x0014(sp)
		swc1    f6, 0x003C(sp)
        swc1    f8, 0x0038(sp)
        sw      a0, 0x0034(sp)

        lwc1    f8, 0x0078(a0)              // load current frame

        // check if we are in a state that can change to a next DSP stage
        // save next stage to t2
        lw     t7, 0x0024(a2)              // t7 = current action

        // grounded dsp1
        lli    t2, 0xEB
        beq    t7, t2, state_change_continue
        lli    t2, Cloud.Action.SPECIALLW2

        // aerial dsp1
        lli    t2, 0xEC
        beq    t7, t2, state_change_continue
        lli    t2, Cloud.Action.SPECIALLW2_AIR

        // grounded dsp2
        lli    t2, Cloud.Action.SPECIALLW2
        beq    t7, t2, state_change_continue
        lli    t2, Cloud.Action.SPECIALLW3

        // aerial dsp2
        lli    t2, Cloud.Action.SPECIALLW2_AIR
        beq    t7, t2, state_change_continue
        lli    t2, Cloud.Action.SPECIALLW3_AIR

        b    _main_normal   // skip state change logic
        nop

        state_change_continue:
        lui		at, 0x4140					// at = 12.0
		mtc1    at, f6                      // ~
        c.eq.s  f8, f6                      // f8 >= f6 (current frame >= 2) ?
        nop
        bc1fl   _main_normal                // skip if haven't reached frame 2
        nop

        lhu     t0, 0x01BC(a2)              // load button press buffer
        andi    t1, t0, 0x4000              // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, _main_normal        // skip if (!B_PRESSED)
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

        or      a1, r0, t2                  // a1 = Action.USPG
        or      a2, r0, r0                  // a2(starting frame) = current animation frame
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

        j       _end
        nop
        
        j _main_normal
        nop

        _main_normal:
        // checks frame counter to see if reached end of the move
        lw      a2, 0x0034(sp)
        mtc1    r0, f6
        lwc1    f8, 0x0078(a2)
        c.le.s  f8, f6
        nop
        bc1fl   _end
        lw      ra, 0x0014(sp)
        lw      a2, 0x0034(sp)
        jal     0x800DEE54
        or      a0, a2, r0

         _end:
		lw      a0, 0x0034(sp)
        lwc1    f6, 0x003C(sp)
        lwc1    f8, 0x0038(sp)
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0040

        jr      ra
        nop
    }

    // @ Description
    // Subroutine which handles air collision for neutral special actions
    scope air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_to_ground_          // a1(transition subroutine) = air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop 
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Subroutine which handles ground to air transition for neutral special actions
    scope air_to_ground_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        
        lw      a2, 0x0008(v0)              // load character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, _change_action      // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WOLF_NSP_Ground
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, _change_action      // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WOLF_NSP_Ground
        
        // Resolve transition action id
        lw     t7, 0x0024(v0)              // t7 = current action

        // aerial dsp1
        lli    t2, 0xEC
        beq    t7, t2, _change_action
        lli    a1, 0xEB // a1 = equivalent ground action for current air action

        // aerial dsp2
        lli    t2, Cloud.Action.SPECIALLW2_AIR
        beq    t7, t2, _change_action
        lli    a1, Cloud.Action.SPECIALLW2 // a1 = equivalent ground action for current air action

        // aerial dsp2
        lli    t2, Cloud.Action.SPECIALLW3_AIR
        beq    t7, t2, _change_action
        lli    a1, Cloud.Action.SPECIALLW3 // a1 = equivalent ground action for current air action

        _change_action:
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

    // @ Description
    // Subroutine which handles physics for Wario's down special.
    // Prevents player control when temp variable 2 = 0
    // Prevents negative Y velocity when temp variable 3 = 1 (BEGIN)
    scope physics: {
        // 0x180 in player struct = temp variable 2

        addiu   sp, sp,-0x001C              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw    	ra, 0x000C(sp)              // ~
        sw      a0, 0x0010(sp)              // store t0, t1, ra, a0
        
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x0180(t0)              // t1 = temp variable 2
        li      t8, 0x800D91EC              // t8 = physics subroutine which disallows player control

        lw      t3, 0x4(t0)                 // t3 = player object
        lw      t4, 0x0078(t3)              // load current frame to t4

        lui      t2, 0x3F80                 // t2 = 1

        bne      t2, t4, _subroutine        // if current frame is not 1, skip
        nop

        // if on first frame
        lwc1    f0, 0x0048(t0)              // current x velocity
        lui     t4, 0x3E80                  // ~
        mtc1    t4, f2                      // f2 = 0.25
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.25
        swc1    f0, 0x0048(t0)              // x velocity = (x velocity * 0.25)

        sw      r0, 0x004C(t0)              // y velocity = 0

        // if performing DSP1, skip to subroutine
        lw      t5, 0x0024(t0)               // t5 = current action
        lli     t6, 0xEB                     // a1 = DSP1 (ground)
        beq     t5, t6, _subroutine
        lli     t6, 0xEC                     // a1 = DSP1 (air)
        beq     t5, t6, _subroutine

        // else, perform a small hop on frame 1
        lui     t6, 0x4120                  // 10.0
        sw      t6, 0x004C(t0)              // y velocity = 0

        _subroutine:
        // load default anti-gravity value
        lui     t4, 0x4020                  // t4 = 2.5

        lw      t5, 0x0024(t0)               // t5 = current action
        lli     t6, Cloud.Action.SPECIALLW3_AIR // a1 = DSP3 (air)
        bne     t5, t6, _subroutine_continue
        nop

        lui     t4, 0x4040                  // t4 = 3.0

        _subroutine_continue:
        mtc1    t4, f2                      // f2 = anti-gravity value
        nop

        lwc1    f0, 0x004C(t0)              // f0 = current y velocity
        add.s   f0, f0, f2                  // f0 = f0 - f2 (y speed -= f2)
        nop

        swc1    f0, 0x004C(t0)              // save y velocity

        jalr      t8                        // run physics subroutine
        nop

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // load t0, t1, ra, a0
        jr      ra                          // return
        addiu 	sp, sp, 0x001C				// deallocate stack space
    }
}