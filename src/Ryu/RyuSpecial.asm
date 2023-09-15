// RyuSpecial.asm

// This file contains subroutines used by Ryu's special moves.

scope RyuUSP {
    // floating point constants for physics and fsm
    constant AIR_Y_SPEED(0x0)            // current setting - float32 92
    constant GROUND_Y_SPEED(0x0)         // current setting - float32 98
    constant X_SPEED(0x4120)                // current setting - float32 10
    constant AIR_ACCELERATION(0x3C88)       // current setting - float32 0.0166
    constant AIR_SPEED(0x41B0)              // current setting - float32 22
    constant LANDING_FSM(0x3EC0)            // current setting - float32 0.375
    // temp variable 3 constants for movement states
    constant BEGIN(0x1)
    constant BEGIN_MOVE(0x2)
    constant MOVE(0x3)

    // @ Description
    // Subroutine which runs when Ryu initiates an aerial up special.
    // Changes action, and sets up initial variable values.
    scope air_initial_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, Ryu.Action.USP_L      // a1 = Action.USPA
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
    // Subroutine which runs when Ryu initiates a grounded up special.
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
        lli     a1, Ryu.Action.USP_L      // a1 = Action.USPG
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
    // Main subroutine for Ryu's up special.
    // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
    // Modified to load Ryu's landing FSM value and disable the interrupt flag.
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
        
        j _main_normal
        nop

        _change_temp2:
        ori     v1, r0, 0x0002              // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x2(BEGIN_MOVE)
        j _main_normal
        nop 

        _change_temp3:
        ori     v1, r0, 0x0003              // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x2(BEGIN_MOVE)
        j _main_normal
        nop

        _main_normal:
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
    // Subroutine which allows a direction change for Ryu's up special.
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
        sw      t1, 0x0180(a1)              // t0 = temp variable 2

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
    // Subroutine which handles movement for Ryu's up special.
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
        jal     0x800D93E4                  // grounded physics subroutine
        nop
        b       _end                        // end subroutine
        // OS.copy_segment(0x548F0, 0x40)      // copy from original air physics subroutine
        // bnez    v0, _check_begin            // modified original branch
        // nop
        // li      t8, 0x800D8FA8              // t8 = subroutine which disallows air control
        // lw      t0, 0x0184(s0)              // t0 = temp variable 3
        // ori     t1, r0, MOVE                // t1 = MOVE
        // bne     t0, t1, _apply_air_physics  // branch if temp variable 3 != MOVE
        // nop
        // li      t8, air_control_             // t8 = air_control_

        _apply_air_physics:
        or      a0, s0, r0                  // a0 = player struct
        jalr    t8                          // air control subroutine
        or      a1, s1, r0                  // a1 = attributes pointer
        or      a0, s0, r0                  // a0 = player struct
        jal     0x800D9074                  // air friction subroutine?
        or      a1, s1, r0                  // a1 = attributes pointer

        _check_begin:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_begin_move   // skip if temp variable 3 != BEGIN
        lw      t0, 0x0024(s0)              // t0 = current action
        lli     t1, Ryu.Action.USP_L      // t1 = Action.USPG
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
        lli     t1, Ryu.Action.USP_L      // t1 = Action.USPG
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
    // Subroutine which handles Ryu's horizontal control for up special.
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
    // Collision wubroutine for Ryu's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Ryu.
    scope collision_: {
        // Copy the first 30 lines of subroutine 0x80156358
        OS.copy_segment(0xD0D98, 0x78)
        // Replace original line which loads the landing fsm
        //lui     a2, 0x3E8F                // original line 1
        lui     a2, LANDING_FSM             // a2 = LANDING_FSM
        // Copy the last 17 lines of subroutine 0x80156358
        OS.copy_segment(0xD0E14, 0x44)
    }
}

scope RyuNSP {
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
    // tmp variable 2 0x0180
    // tmp variable 3 0x0184

    // @ Description 
    // main subroutine for Ryu's Blaster
    scope main: {
        addiu   sp, sp, -0x0040
        sw      ra, 0x0014(sp)
		swc1    f6, 0x003C(sp)
        swc1    f8, 0x0038(sp)
        sw      a0, 0x0034(sp)
		addu	a2, a0, r0
        lw      v0, 0x0084(a0)                      // loads player struct

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

        lhu     t0, 0x01BC(v0)              // load button press buffer
        andi    t1, t0, 0x4000           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, projectile_stage_setting_continue // skip if (!B_PRESSED)
        nop

        la      s0, _blaster_fireball_heavy_struct       // s0 = light hadouken address
        b       projectile_stage_setting_continue
        nop
        
        projectile_stage_setting_continue:
        sw      a1, 0x0034(sp)
        sw      ra, 0x001C(sp)
        lw      t6, 0x0084(a0)
        lw      t0, 0x0024(s0)
        lw      t1, 0x0028(s0)
        li      a1, _blaster_projectile_struct		// load projectile addresses
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
        addiu   sp, sp, -0x0024
        sw      ra, 0x0014(sp)
        sw      a0, 0x0020(sp)
        swc1    f10, 0x0024(sp)
        lw      a0, 0x0084(a0)
        sw      a0, 0x001C(sp)
        
        _continue:
        addiu   t8, r0, r0          // used to use free space area, but for no apparent reason, affects graphics
        //lw      t8, 0x029C(a0)
        li      t0, _blaster_fireball_struct
        addu    v0, r0, t0
        lw      a1, 0x000C(v0)
        lw      a2, 0x0004(v0)
        lw      t1, 0x0020(sp)
        addiu   t2, r0, r0          // used to use free space area, but for no apparent reason, effects graphics
        lw      v1, 0x0074(t1)
        or      v0, r0, r0
        // lwc1    f8, 0x0020(a0)      // load current speed
		// lui		at, 0x3F84          // speed multiplier (accel) loaded in at (1.03125)
		// mtc1	at, f6              // move speed multiplier to floating point register
		// mul.s   f8, f8, f6          // speed multiplied by accel
        
        
        // lw      at, 0x0004(t0)      // load max speed
        // mtc1    at, f6
        // lw      at, 0x029C(a0)      // load multiplier that is typically one, unless reflected
        // mtc1    at, f10
        // mul.s   f6, f6, f10
        // c.le.s  f8, f6
        // nop
        //bc1f    _scaling
        // swc1    f6, 0x0020(a0)      // if speed is greater than max rightward velocity, save max speed
        //neg.s   f6, f6
        //c.le.s  f8, f6
        //nop
        //bc1t    _scaling
        // swc1    f6, 0x0020(a0)      // if speed is less than max leftward velocity, save max speed
		//swc1    f8, 0x0020(a0)      // save new speed amount to projectile hitbox information
        
        _scaling:
        // v1 = projectile joint 1
        // a0 = projectile struct
        // t1 = projectile object

        // lwc1    f6, 0x0020(a0)      // ~
        // abs.s   f6, f6              // f6 = absolute current speed
        // lui     at, 0x41B0          // ~
        // mtc1    at, f8              // f8 = initial speed (currently 22)
        // lui     at, 0x3E80          // ~
        // mtc1    at, f10             // f10 = 0.25
        // add.s   f6, f6, f8          // ~
        // add.s   f6, f6, f8          // ~
        // add.s   f6, f6, f8          // ~
        // mul.s   f6, f6, f10         // f6 = (current speed + 66) * 0.25
        // div.s   f6, f6, f8          // f6 = x size multiplier (adjusted current speed / initial speed)

        lui at, 0x3FC0
        mtc1    at, f6

        // swc1    f6, 0x0040(v1)      // store x size multiplier to projectile joint
        // swc1    f6, 0x0044(v1)      // store y size multiplier to projectile joint
        
        _end_duration:
        lw      ra, 0x0014(sp)
        lwc1    f10, 0x0024(sp)
        addiu   sp, sp, 0x0024
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
        addiu   t7, r0, Character.id.RYU
        bnel    t0, t7, _standard
        lui     t7, 0x3F80          // load normal reflect multiplier if not ryu and thereby top speed of ryu projectile will not increase
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
		dw 0x00000000
        dw Character.RYU_file_6_ptr    // pointer to file
        dw 0x00000000                   // 00000000
        dw 0x12480000                   // rendering routine?
        dw blaster_duration             // duration (default 0x80168540) (samus 0x80168F98)
        dw 0x80175914                   // collision (0x801685F0 - Mario) (0x80169108 - Samus)
        dw 0x80175958    		        // after_effect 0x801691FC, this one is used when grenade connects with player
        dw 0x80175958                   // after_effect 0x801691FC, used when touched by player when object is still, by setting to null, nothing happens
        dw 0x8016DD2C                   // determines behavior when projectile bounces off shield, this uses Master Hand's projectile coding to determine correct angle of graphic (0x8016898C Fox)
        dw 0x80175958                   // after_effect                // rocket_after_effect 0x801691FC
        dw blaster_reflection           // OS.copy_segment(0x1038FC, 0x04)            // this determines reflect behavior (default 0x80168748)
        dw 0x80175958                   // This function is run when the projectile is used on ness while using psi magnet
        OS.copy_segment(0x103904, 0x0C) // empty 

		
		_blaster_fireball_struct:
        dw 5                          // 0x0000 - duration (int)
        float32 18                     // 0x0004 - max speed
        float32 18                      // 0x0008 - min speed
        float32 0                       // 0x000C - gravity
        float32 0                       // 0x0010 - bounce multiplier
        float32 0                       // 0x0014 - rotation angle
        float32 0                       // 0x0018 - initial angle (ground)
        float32 0                       // 0x001C   initial angle (air)
        float32 18                      // 0x0020   initial speed
        dw Character.RYU_file_6_ptr    // 0x0024   projectile data pointer
        dw 0                            // 0x0028   unknown (default 0)
        float32 0                       // 0x002C   palette index (0 = mario, 1 = luigi)
        OS.copy_segment(0x1038A0, 0x30)

        _blaster_fireball_heavy_struct:
        dw 4                          // 0x0000 - duration (int)
        float32 38                     // 0x0004 - max speed
        float32 38                      // 0x0008 - min speed
        float32 0                       // 0x000C - gravity
        float32 0                       // 0x0010 - bounce multiplier
        float32 0                       // 0x0014 - rotation angle
        float32 0                       // 0x0018 - initial angle (ground)
        float32 0                       // 0x001C   initial angle (air)
        float32 38                      // 0x0020   initial speed
        dw Character.RYU_file_6_ptr    // 0x0024   projectile data pointer
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
        
        addiu   a1, r0, 0x00E4              // a1 = equivalent ground action for current air action
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

        lui		at, 0x4000					// at = 1.0
		mtc1    at, f6                      // ~
        c.eq.s  f8, f6                      // f8 == f6 (current frame == 1) ?
        nop
        bc1fl   _check_hop           // skip if frame isn't 1
        nop

        sw      r0, 0x0048(s0)              // x velocity = 0
        // sw      r0, 0x004C(s0)              // y velocity = 0

        _check_hop:
        lwc1    f8, 0x0078(t0)                 // load current animation frame
        lui		at, 0x4130					// at = 10.0
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
}

scope RyuDSP {
    constant X_SPEED(0x4220)                // current setting - float:460.0
    constant X_SPEED_AIR(0x4200)                // current setting - float:460.0
    constant X_SPEED_END_AIR(0x41F0)        // current setting - float:30.0
    constant X_SPEED_END_GROUND(0x4270)     // current setting - float:60.0
    constant Y_SPEED_INITIAL(0x4248)        // current setting - float:50.0
    constant LANDING_FSM(0x3EB3)            // current setting - float:0.35
    constant B_PRESSED(0x40)                // bitmask for b press
    
    // @ Description
    // Subroutine which sets up the movement for the grounded version of phantasm.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x2 = begin movement
    // 0x3 = end movement
    scope ground_subroutine_: {
        // a2 = player struct
        // 0x184 in player struct = temp variable 3
        constant MOVE(0x2)
        constant END_MOVE(0x3)
        
        OS.save_registers()
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        
        _update_buffer:
        lbu     t1, 0x000D(a2)              // t1 = player port
        li      t2, button_press_buffer     // ~
        addu    t3, t2, t1                  // t3 = px button_press_buffer address
        lbu     t1, 0x01BE(a2)              // t1 = button_pressed
        lbu     t2, 0x0000(t3)              // t2 = button_press_buffer
        sb      t1, 0x0000(t3)              // update button_press_buffer with current inputs
        or      t3, t1, t2                  // t3 = button_pressed | button_press_buffer 
        
        _move:
        lwc1    f8, 0x0078(a0)              // load current animation frame
        lui		at, 0x40B0					// at = 6.0
		mtc1    at, f6                      // ~
        c.le.s  f8, f6                      // f8 == f6 (current frame == 1) ?
        nop
        bc1tl   _end           // skip if frame isn't greater than 6
        nop

        // ori     t1, r0, MOVE                // t1 = MOVE
        // bne     t0, t1, _check_end_move     // skip if t0 != MOVE
        // nop
        lui     t1, X_SPEED                 // t1 = X_SPEED
        sw		t1, 0x0060(a2)	            // ground x velocity = X_SPEED
        
        _shorten:
        andi    t1, t3, B_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, _end                // skip if !(B_PRESSED)
        nop
        ori     t1, r0, END_MOVE            // ~
        sw      t1, 0x0184(a2)              // temp variable 3 = END_MOVE
        beq     r0, r0, _end_move           // branch and end movement
        nop
        
        _check_end_move:
        ori     t1, r0, END_MOVE            // t1 = END_MOVE
        bne     t0, t1, _end                // skip if t0 != END_MOVE
        nop
        
        _end_move:
        lui     t1, X_SPEED_END_GROUND      // t1 = X_SPEED_END_GROUND
        lwc1    f2, 0x0044(a2)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        sw		t1, 0x0060(a2)	            // ground x velocity = X_SPEED
        sw      r0, 0x0184(a2)              // temp variable 3 = 0
        lw      t1, 0x0A88(a2)              // t1 = overlay settings
        li      t2, 0x7FFFFFFF              // t2 = bitmask
        and     t1, t1, t2                  // ~
        sw      t1, 0x0A88(a2)              // disable colour overlay bit
        jal     0x800E8518                  // end hitboxes
        nop
        
        _end:
        OS.restore_registers()
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Subroutine which sets up the movement for the aerial version of phantasm.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x1 = initial setup
    // 0x2 = freeze y velocity
    // 0x3 = x movement
    // 0x4 = end movement
    // 0x5 = reduce y velocity (slow fall)
    scope air_subroutine_: {
        // a2 = player struct
        // 0x184 in player struct = temp variable 3
        constant INITIAL_SETUP(0x1)
        constant FREEZE_Y(0x2)
        constant MOVE(0x3)
        constant END_MOVE(0x4)
        constant SLOW_FALL(0x5)
        
        addiu   sp, sp,-0x0010              // allocate stack space
        swc1    f0, 0x0004(sp)              // ~
        swc1    f2, 0x0008(sp)              // store f0, f2
        OS.save_registers()
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        
        _update_buffer:
        lbu     t1, 0x000D(a2)              // t1 = player port
        li      t2, button_press_buffer     // ~
        addu    t3, t2, t1                  // t3 = px button_press_buffer address
        lbu     t1, 0x01BE(a2)              // t1 = button_pressed
        lbu     t2, 0x0000(t3)              // t2 = button_press_buffer
        sb      t1, 0x0000(t3)              // update button_press_buffer with current inputs
        or      t3, t1, t2                  // t3 = button_pressed | button_press_buffer 
        
        // _initial_setup:
        // ori     t1, r0, INITIAL_SETUP       // t1 = INITIAL_SETUP
        // bne     t0, t1, _check_freeze_y     // skip if t0 != INITIAL_SETUP
        // nop
        // lbu     t1, 0x018D(a2)              // t1 = fast fall flag
        // ori     t2, r0, 0x0007              // t2 = bitmask (01111111)
        // and     t1, t1, t2                  // ~
        // sb      t1, 0x018D(a2)              // disable fast fall flag
        // sw      r0, 0x0048(a2)              // x velocity = 0
        // lui     t1, Y_SPEED_INITIAL         // ~
        // sw      t1, 0x004C(a2)              // y velocity = Y_SPEED_INITIAL

        lwc1    f8, 0x0078(a0)              // load current animation frame
        lui		at, 0x4000					// at = 6.0
		mtc1    at, f6                      // ~
        c.eq.s  f8, f6                      // f8 == f6 (current frame == 1) ?
        nop
        bc1fl   _move           // skip if frame isn't greater than 6
        nop

        // check if we reset air speed
        lwc1    f2, 0x004C(a2)              // f2 = y velocity

        lui     t0, 0                       // ~
        mtc1    t0, f0                      // f0 = 0.0
        c.le.s  f2, f0                      // current speed is negative?
        nop
        bc1tl   _set_zero_airspeed           // skip if speed isn't negative
        nop

        lui     t0, X_SPEED_AIR             // ~
        mtc1    t0, f0                      // f0 = 0.0

        c.le.s  f2, f0                      // air x speed < current speed
        nop
        bc1fl   _set_max_airspeed           // skip if speed isn't negative
        nop

        b _move
        nop

        _set_zero_airspeed:
        swc1    f0, 0x004C(a2)              // store updated y velocity

        b _move
        nop

        _set_max_airspeed:
        lui t1, X_SPEED_AIR // speed up = horizontal speed
        sw t1, 0x004C(a2)
        b _move
        nop
        
        _move:
        lwc1    f8, 0x0078(a0)              // load current animation frame
        lui		at, 0x40B0					// at = 6.0
		mtc1    at, f6                      // ~
        c.le.s  f8, f6                      // f8 == f6 (current frame == 1) ?
        nop
        bc1tl   _slow_fall           // skip if frame isn't greater than 6
        nop
        
        // ori     t1, r0, MOVE                // t1 = MOVE
        // bne     t0, t1, _check_end_move     // skip if t0 != MOVE
        // nop
        lui     t1, X_SPEED_AIR                 // ~
        mtc1    t1, f0                      // f0 = X_SPEED
        lwc1    f2, 0x0044(a2)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        mul.s   f0, f0, f2                  // f0 = X_SPEED * DIRECTION
        swc1    f0, 0x0048(a2)              // x velocity = X_SPEED * DIRECTION
        
        // _shorten:
        // andi    t1, t3, B_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        // beq     t1, r0, _freeze_y           // skip if (!B_PRESSED)
        // nop
        // ori     t1, r0, END_MOVE            // ~
        // sw      t1, 0x0184(a2)              // temp variable 3 = END_MOVE
        // beq     r0, r0, _end_move           // branch and end movement
        // nop
        
        // _freeze_y:
        // // when attempting to freeze the character's y velocity by setting it to 0 they will fall at a rate equal to their fall speed acceleration
        // // therefore the character's fall speed acceleration value needs to be written to their y velocity instead of 0
        // lw      t1, 0x09C8(a2)              // t1 = attribute pointer
        // lw      t1, 0x0058(t1)              // t1 = fall speed acceleration
        // sw      t1, 0x004C(a2)              // overwrite y velocity with fall speed acceleration value
        
        _check_end_move:
        ori     t1, r0, END_MOVE            // t1 = END_MOVE
        bne     t0, t1, _slow_fall          // skip if t0 != END_MOVE
        nop
        
        _end_move:
        lui     t1, X_SPEED_END_AIR         // ~
        mtc1    t1, f0                      // f0 = X_SPEED_AIR
        lwc1    f2, 0x0044(a2)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        mul.s   f0, f0, f2                  // f0 = X_SPEED_AIR * DIRECTION
        swc1    f0, 0x0048(a2)              // x velocity = X_SPEED_AIR * DIRECTION
        ori     t1, r0, SLOW_FALL           // ~
        sw      t1, 0x0184(a2)              // temp variable 3 = SLOW_FALL
        lw      t1, 0x0A88(a2)              // t1 = overlay settings
        li      t2, 0x7FFFFFFF              // t2 = bitmask
        and     t1, t1, t2                  // ~
        sw      t1, 0x0A88(a2)              // disable colour overlay bit
        jal     0x800E8518                  // end hitboxes
        nop
        
        _slow_fall:
        // negative y velocity = moving downwards, so adding to the y velocity will slow the fall
        // ori     t1, r0, SLOW_FALL           // t1 = SLOW_FALL
        // bne     t0, t1, _end                 // skip if t0 != SLOW_FALL
        // nop
        lw      t0, 0x0008(a2)              // t0 = current character ID
        lli     t1, Character.id.KIRBY      // t1 = id.KIRBY
        beq     t0, t1, _end                // if Kirby, skip
        lli     t1, Character.id.JKIRBY     // t1 = id.JKIRBY
        beq     t0, t1, _end                // if J Kirby, skip

        lw      t0, 0x09C8(a2)              // t0 = pointer to character attributes
        lwc1    f0, 0x58(t0)               // f0 = gravity
        lwc1    f2, 0x004C(a2)              // f2 = y velocity
        add.s   f0, f2, f0
        swc1    f0, 0x004C(a2)              // store updated y velocity

        lw      t0, 0x4(a2)                      // t0 = character pointer
        lwc1    f8, 0x0078(t0)              // load current animation frame
        lui		at, 0x40D0					// at = 6.0
		mtc1    at, f6                      // ~
        c.le.s  f8, f6                      // f8 == f6 (current frame == 1) ?
        nop
        bc1tl   _end           // skip if frame isn't greater than 6
        nop

        lui     t0, 0x3F80                  // ~
        mtc1    t0, f0                      // f0 = float:2.0
        lwc1    f2, 0x004C(a2)              // f2 = y velocity
        sub.s   f0, f2, f0
        swc1    f0, 0x004C(a2)              // store updated y velocity
        
        _end:
        OS.restore_registers()
        lwc1    f0, 0x0004(sp)              // ~
        lwc1    f2, 0x0008(sp)              // load f0, f2
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop 
    }
    
    // @ Description
    // Holds each player's button presses from the previous frame.
    // Used to add a single frame input buffer to shorten.
    button_press_buffer:
    db 0x00 //p1
    db 0x00 //p2
    db 0x00 //p3
    db 0x00 //p4
    
    // @ Description
    // Subroutine which controls the physics for aerial phantasm. Applies gravity without allowing
    // for control by default, allows control and fast fall when temp variable 3 = 0x5(SLOW_FALL)
    scope air_physics_: {
        // 0x184 in player struct = temp variable 3
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw    	ra, 0x000C(sp)              // store t0, t1, ra
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x0184(t0)              // t1 = temp variable 3
        li      t8, 0x800D91EC              // t8 = physics subroutine which prevents player control 
        ori     t6, r0, air_subroutine_.SLOW_FALL
        bne     t1, t6, _subroutine         // skip if t1 != SLOW_FALL
        nop
        li      t8, 0x800D90E0              // t8 = physics subroutine which allows player control
        
        _subroutine:
        jalr      t8                        // run physics subroutine
        nop
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load t0, t1, ra
        addiu 	sp, sp, 0x0010				// deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Subroutine which handles collision for aerial phantasm.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Falco.
    scope air_collision_: {
        // Copy the first 30 lines of subroutine 0x80156358
        OS.copy_segment(0xD0D98, 0x78)
        // Replace original line which loads the landing fsm
        //lui     a2, 0x3E8F                // original line 1
        lui     a2, LANDING_FSM             // a2 = LANDING_FSM
        // Copy the last 17 lines of subroutine 0x80156358
        OS.copy_segment(0xD0E14, 0x44)
    }
    
    // @ Description
    // Modified version of a short subroutine which resets the temp variables when Fox uses his
    // neutral special. Usually, this subroutine doesn't set the value of temp variable 3.
    scope set_variables_: {
        OS.patch_start(0xD66E0, 0x8015BCA0)
        jal     set_variables_              // ground neutral special
        OS.patch_end()
        OS.patch_start(0xD6724, 0x8015BCE4)
        jal     set_variables_              // air neutral special
        OS.patch_end()
        OS.patch_start(0xD1840, 0x80156E00)
        jal     set_variables_              // kirby ground neutral special
        OS.patch_end()
        OS.patch_start(0xD1884, 0x80156E44)
        jal     set_variables_              // kirby air neutral special
        OS.patch_end()
        
        addiu   sp, sp,-0x0008              // allocate stack space
        sw      t0, 0x0004(sp)              // store t0
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      r0, 0x017C(v0)              // temp variable 1 = 0
        sw      r0, 0x0180(v0)              // temp variable 2 = 0
        ori     t0, r0, 0x0001              // ~
        sw      t0, 0x0184(v0)              // temp variable 3 = 0x1(INITIAL_SETUP)
        lw      t0, 0x0004(sp)              // load t0
        jr      ra
        addiu   sp, sp, 0x0008              // deallocate stack space
    }

    scope main_: {
        // Copy the first 8 lines of subroutine 0x8015C750
        OS.copy_segment(0xD7190, 0x20)
        bc1fl   _end                        // skip if animation end has not been reached
        lw      ra, 0x0024(sp)              // restore ra
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x800DEE54                  // transition to idle
        sw      t6, 0x0014(sp)              // store LANDING_FSM
        lw      ra, 0x0024(sp)              // restore ra

        _end:
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }
}