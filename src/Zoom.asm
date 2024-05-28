scope Zoom {
    zoom_timer:
    db 0x0000
    OS.align(4)

    zoom_offset:
    dw  0x00000000                                  // x offset
    dw  0x00000000                                  // y offset
    dw  0x00000000                                  // z offset
    dw  0x00000000                                  // unused

    zoom_background:; dw 0x00000000
    zoom_background_object:; dw 0x00000000

    // 80140EE4 + 600
    scope was_just_hit: {
        OS.patch_start(0xBBF24, 0x801414E4)
        j       was_just_hit
        nop
        _return:
        OS.patch_end()

        // If knockback <= 0, skip
        // lwc1    f16, 0x7E0(s0)
        // mtc1    r0, f2
        // c.le.s  f16, f2
        // nop
        // bc1t    _original
        // nop

        // KNOCKBACK CHECK START
        // This code calculates the knockback trajectory
        // For all frames hitstun is active
        check_knockback:
        OS.save_registers()

        addiu   sp, sp,-0x0020
        sw      r0, 0x0(sp) // this is at -0x90(sp) at this point

        //lw    s1, 0x0004(s0) // s1 = player object

        lw      t3, 0x0078(s0) // t3 = player position vector
        lw      t1, 0x0000(t3) // t1 = player x
        lw      t2, 0x0004(t3) // t2 = player y
        
        lw      t3, 0xB18(s0) // t3 = histsun timer

        sw      r0, 0x4(sp)   // using 0x4(sp) as gravity accumulator

        lw      t4, 0x54(s0) // vel_damage_air->x(t4);
        lw      t5, 0x58(s0) // vel_damage_air->y(t5);

        // damage_angle(f0) = atan2f(vel_damage_air->y, vel_damage_air->x);
        lwc1    f12, 0x58(s0)
        jal     0x8001863C // atan2f(f12, f14), result ends in f0
        lwc1    f14, 0x54(s0)

        mov.s   f12, f0     // f12 = damage_angle
        swc1    f0, 0x8(sp) // 0x8(sp) = damage angle

        // save max y value for KOs at the top
        sw      t2, 0xC(sp) // 0xC(sp) = max y value = initial y
        
        kb_loop:
        li      t8, 0x3FD9999A  // t8 = 1.7F
        mtc1    t8, f8          // f8 = 1.7F
        
        lw      t6, 0x58(s0) // vel_damage_new.x(t5) = vel_damage_air->y;
        lw      t7, 0x54(s0) // vel_damage_new.y(t6) = vel_damage_air->x;
        
        // vel_damage_air->x -= (1.7F * cosf(damage_angle));
        lwc1    f12, 0x8(sp) // f12 = 0x8(sp) = damage angle
        jal     0x80035CD0              // f0 = cos(f12)(damage_angle)
        nop

        mtc1    t4, f4      // f4 = vel_damage_air->x
        mtc1    t8, f8      // f8 = 1.7F
        mul.s   f0, f0, f8  // f0 = 1.7F * cosf(damage_angle)
        nop
        sub.s   f4, f4, f0
        mfc1    t4, f4      // save back to vel_damage_air->x

        mtc1    t1, f10         // f10 = t1 = player x
        add.s   f10, f10, f4    // topn_translate->x += vel_damage_air->x;
        mfc1    t1, f10         // save back to player x

        // vel_damage_air->y -= (1.7F * __sinf(damage_angle));
        lwc1    f12, 0x8(sp) // f12 = 0x8(sp) = damage angle
        jal     0x800303F0              // f0 = sin(f12)(damage_angle)
        nop

        mtc1    t5, f4      // f4 = vel_damage_air->y
        mtc1    t8, f8      // f8 = 1.7F
        mul.s   f0, f0, f8  // f0 = 1.7F * sinf(damage_angle)
        nop
        sub.s   f4, f4, f0
        mfc1    t5, f4      // save back to vel_damage_air->y

        mtc1    t2, f10         // f10 = t2 = player y

        add.s   f10, f10, f4    // topn_translate->y += vel_damage_air->y;

        lw      t0, 0x9C8(s0)  // t0 = attribute pointer
        lw      t0, 0x58(t0)   // t0 = gravity

        mtc1    t0, f4         // f4 = t0 = gravity
        lwc1    f6, 0x4(sp)    // f6 = 0x4(sp) = gravity accumulator
        add.s   f4, f4, f6     // add to accumulator

        lw      t0, 0x9C8(s0)  // t0 = attribute pointer
        lw      t0, 0x5C(t0)   // t0 = max fall speed
        mtc1    t0, f6         // f6 = t0 = max fall speed
        
        c.lt.s  f4, f6         // is accumulator(f4) < max fall speed(f6)?
        nop
        bc1tl   after_gravity_clamp
        nop

        mov.s   f4, f6          // clamp fall speed

        after_gravity_clamp:
        swc1    f4, 0x4(sp)    // save back to accumulator

        sub.s   f10, f10, f4   // topn_translate->y += vel_damage_air->y;

        mfc1    t2, f10         // save back to player y

        max_y_check:
        lwc1    f4, 0xC(sp) // f4 = max y position

        c.lt.s  f4, f10     // max y position(f4) < current y position(f10)?
        nop
        bc1fl   max_y_check_end
        nop

        swc1    f10, 0xC(sp) // max y position = current y position
        
        max_y_check_end:

        // loop end logic
        subi    t3, 0x1    // hitstun-based counter -= 1

        bgtz    t3, kb_loop
        nop
        kb_loop_end:

        // here, t1 = final x pos; t2 = final y pos
        li      v1, 0x80131300 // base for blastzone positions
        lw      v1, 0x0(v1)

        // top blastzone
        lh      t0, 0x0074(v1) // top blastzone
        mtc1    t0, f18
        cvt.s.w f18, f18 // f18 = top blastzone (float)

        lwc1    f10, 0xC(sp)  // f10 = max player y position

        c.le.s  f18, f10      // is top blastzone <= player y? f18 <= 10?
        nop
        bc1tl   set_zoom_flag1
        nop

        // side blastzones
        mtc1 t1, f10  // f10 = final player x position

        // left
        lh      t0, 0x007A(v1) // left blastzone
        mtc1    t0, f18
        cvt.s.w f18, f18 // f18 = left blastzone (float)

        c.le.s  f10, f18      // is player x <= left blastzone? f10 <= 18?
        nop
        bc1tl   set_zoom_flag1
        nop

        // right
        lh      t0, 0x0078(v1) // right blastzone
        mtc1    t0, f18
        cvt.s.w f18, f18 // f18 = right blastzone (float)

        c.le.s  f18, f10      // is right blastzone <= player x? f18 <= 10?
        nop
        bc1tl   set_zoom_flag1
        nop

        // bottom blastzone
        lw      t0, 0xEC(s0)    // t0 = clipping id cpu is above (0xFFFF if none)
        addiu   at, r0, 0xFFFF
        bne     at, t0, set_zoom_flag0  // branch ground below
        nop

        lh      t0, 0x0076(v1) // bottom blastzone
        mtc1    t0, f18
        cvt.s.w f18, f18 // f18 = bottom blastzone (float)

        mtc1 t2, f10  // f10 = final player y position

        c.le.s  f10, f18      // is player y <= bottom blastzone? f18 <= 10?
        nop
        bc1tl   set_zoom_flag1
        nop

        // default (no zoom)
        b set_zoom_flag0
        nop

        set_zoom_flag1:
        or      t0, t0, r0
        lli     t0, 0x1
        sw      t0, 0x0(sp)

        b check_knockback_end
        nop

        set_zoom_flag0:
        or      t0, t0, r0
        lli     t0, 0x0
        sw      t0, 0x0(sp)

        b check_knockback_end
        nop

        // KNOCKBACK CHECK END
        check_knockback_end:
        addiu   sp, sp,0x0020
        OS.restore_registers()
        // note: check 0x800E2048 for knockback stuff

        addiu   sp, sp, -0x0090
        lw      t0, 0x0(sp) // load flag value
        addiu   sp, sp, 0x0090

        // if flag is already not zero, skip special move check
        bnez    t0, set_zoom
        nop
        
        attacker_special_move_check:
        OS.save_registers()
        jal     0x800E7ED4 // get v0 = attacker_object
        lw      a0,0x110(sp)

        beqz    v0, attacker_special_move_check_end // if null, skip
        nop

        lw      v1, 0x84(v0)    // load attacker struct
        lw      t0, 0x0008(v1)  // t0 = character id
        lw      t1, 0x0024(v1)  // t1 = current action

        ori     t2, r0, Character.id.CAPTAIN
        beq     t0, t2, attacker_special_move_captain
        nop

        ori     t2, r0, Character.id.GND
        beq     t0, t2, attacker_special_move_gnd
        nop

        ori     t2, r0, Character.id.JIGGLYPUFF
        beq     t0, t2, attacker_special_move_jigglypuff
        nop

        ori     t2, r0, Character.id.DK
        beq     t0, t2, attacker_special_move_dk
        nop

        ori     t2, r0, Character.id.LUIGI
        beq     t0, t2, attacker_special_move_luigi
        nop

        ori     t2, r0, Character.id.NESS
        beq     t0, t2, attacker_special_move_ness
        nop

        ori     t2, r0, Character.id.LUCAS
        beq     t0, t2, attacker_special_move_lucas
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_captain:
        lli    t0, Action.CAPTAIN.FalconPunch
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.CAPTAIN.FalconPunchAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_dk:
        lli    t0, Action.DK.GiantPunchFullyCharged
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.DK.GiantPunchFullyChargedAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_luigi:
        lli    t0, Action.LUIGI.SuperJumpPunch
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_gnd:
        lli    t0, Ganondorf.Action.WarlockPunch
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Ganondorf.Action.WarlockPunchAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.UTilt
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_jigglypuff:
        lli    t0, Action.JIGGLY.Rest
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.JIGGLY.RestAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_ness:
        lli    t0, Action.NESS.PKTA
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.NESS.PKTAAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_lucas:
        lli    t0, Lucas.Action.PKTA
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Lucas.Action.PKTAAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_set_flag:
        lli     t0, 0x2
        addiu   sp, sp, -0x0020
        sw      t0, 0x0(sp) // set flag value
        addiu   sp, sp, 0x0020

        attacker_special_move_check_end:
        OS.restore_registers()

        addiu   sp, sp, -0x0090
        lw      t0, 0x0(sp) // load flag value
        addiu   sp, sp, 0x0090

        // if flag is zero, original behavior
        beqz    t0, _original
        nop
        // IF TRUE, WE HAVE A KO
        // APPLY ZOOM

        set_zoom:
        OS.save_registers()

        // s0 = fighter struct
        lw      a0, 0x4(s0) // a0 = fighter object

        // func_ovl2_8010CF44(fighter_gobj, 0.0F, 0.0F, ftGetStruct(fighter_gobj)->attributes->closeup_cam_zoom, 0.1F, 28.0F);

        addiu   sp,sp,-0x70

        or      a1, r0, r0
        or      a2, r0, r0
        li      a3, 0x44FA0000              // Dist = 2000

        li     t0, 0x3DCCCCCD
        sw      t0, 0x0010(sp)              // argument 4

        li     t0, 0x41E00000
        sw      t0, 0x0014(sp)              // argument 5
        
        jal 0x8010CF44
        nop

        addiu   sp,sp,0x70

        // todo: call
        // gPlayerCommonInterface.is_ifmagnify_display = FALSE;

        lli     t0, 0x0028
        li      t1, zoom_timer     // t1 = zoom_timer address
        sw      t0, 0x0000(t1)     // update zoom timer

        // Hide stage
        hide_stage:
        addiu   sp, sp, -0x0020
        lw      t0, 0x0(sp) // load flag value
        addiu   sp, sp, 0x0020

        lli     t1, 0x1

        bne     t0, t1, hide_stage_end
        nop

        ori     a0, r0, 0x1
        lli     a1, 0x1
        jal     Render.toggle_group_display_
        nop

        ori     a0, r0, 0x2
        lli     a1, 0x1
        jal     Render.toggle_group_display_
        nop
        hide_stage_end:
        //

        // Render background
        // background: 0042 0x03050 0x3FFFC - Intro Fighters Clash Object
        Render.load_file(0x04B, Zoom.zoom_background)

        li      t6, Zoom.zoom_background
        lw      t6, 0x0(t6)

        render:
        create_camera:
        // create camera
        addiu       sp,sp,-0x58
        sw          ra,0x44(sp)
        sw          s1,0x40(sp)
        sw          s0,0x3c(sp)

        li          v0,0x80017EC0
        li          t6,0x3C
        li          t8,0
        li          t9,0x20
        li          t7,1
        li          t0,1
        li          t1,1
        li          t2,1

        sw          t2,0x30(sp)
        sw          t1,0x28(sp)
        sw          t0,0x24(sp)
        sw          t7,0x20(sp)
        sw          t9,0x1c(sp)
        sw          t8,0x18(sp)
        sw          t6,0x14(sp)
        sw          v0,0x10(sp)
        sw          v0,0x4c(sp)
        sw          r0,0x2c(sp)
        sw          r0,0x34(sp)
        li          a0,0x3EF
        or          a1,r0,r0
        li          a2,0x9
        jal         0x8000B93C
        lui         a3,0x8000
        lui         s1,0x8013
        addiu       s1,s1,0x14B0
        lw          t3,0x20(s1)
        lw          t4,0x24(s1)
        lw          t5,0x28(s1)
        lw          t6,0x2C(s1)
        mtc1        t3,f4
        mtc1        t4,f6
        mtc1        t5,f8
        mtc1        t6,f10
        cvt.s.w     f4,f4
        lw          s0,0x74(v0)
        addiu       a0,s0,0x8
        cvt.s.w     f6,f6
        mfc1        a1,f4
        cvt.s.w     f8,f8
        mfc1        a2,f6
        cvt.s.w     f16,f10
        mfc1        a3,f8
        jal         0x80007080
        swc1        f16,0x10(sp)
        lw          t8,0x28(s1)
        lw          t9,0x20(s1)
        lw          t0,0x2c(s1)
        lw          t1,0x24(s1)
        subu        t7,t8,t9
        mtc1        t7,f18
        subu        t2,t0,t1
        mtc1        t2,f6
        cvt.s.w     f4,f18
        mtc1        r0,f0
        lw          t3,0x80(s0)
        lui         at,0x44FA
        mtc1        at,f16
        cvt.s.w     f8,f6
        ori         t4,t3,0x0004
        sw          t4,0x80(s0)
        swc1        f0,0x50(s0)
        swc1        f0,0x4c(s0)
        swc1        f0,0x48(s0)
        div.s       f10,f4,f8
        swc1        f0,0x40(s0)
        swc1        f0,0x3c(s0)
        swc1        f16,0x44(s0)

        swc1        f10,0x24(s0)

        lw      ra,0x44(sp)
        lw      s1,0x40(sp)
        lw      s0,0x3c(sp)
        addiu   sp,sp,0x58
        // create camera end

        create_gfx:
        addiu   sp,sp,-0x28

        addiu   a0,r0,0x03F0
        or      a1,r0,r0
        addiu   a2,r0,0x000D
        jal     Render.CREATE_OBJECT_ // 0x80009968
        lui     a3,0x8000

        li      t6, Zoom.zoom_background_object
        sw      v0, 0x0(t6) // save background object

        // lui     t6,(UPPER + 0x1)
        // lw      t6,LOWER(t6) // original
        li      t6, Zoom.zoom_background
        lw      t6, 0x0(t6)

        lui     t7,0x0000
        addiu   t7,t7,0x35F8
        or      s0,v0,r0
        or      a0,v0,r0
        or      a2,r0,r0
        jal     0x8000F120
        addu    a1,t6,t7
        lui     a1,0x8001
        addiu   t8,r0,-1
        sw      t8,0x10(sp)
        addiu   a1,a1,0x4038 // RAM address of ASM for creating the display list
        or      a0,s0,r0 // object address (v0 from 0x80009968)
        addiu   a2,r0,0x5 // room
        jal     Render.DISPLAY_INIT_ // 0x80009DF4
        lui     a3,0x8000 // order
        
        // lui     at,0x8013
        // lwc1    f0,0x2700(at) // original
        li      at, 0x3FC00000 // scale
        mtc1    at, f0

        lui     at,0x4470
        mtc1    at,f4
        lui     at,0x43B4
        mtc1    at,f6
        
        lw      t1,0x74(s0) // load location vector

        lui     at,0x0
        mtc1    at,f8
        swc1    f8,0x1C(t1) // location x

        lui     at,0x0
        mtc1    at,f8
        swc1    f8,0x20(t1) // location y

        lui     at,0x0
        mtc1    at,f8
        swc1    f8,0x24(t1) // location z

        // lui     t6,(UPPER + 0x1) // original
        li      t6, Zoom.zoom_background
        lw      t6, 0x0(t6)
        srl     t6, t6, 16
        sll     t6, t6, 16

        lui     at,0x8013
        
        lw      t2,0x74(s0)
        lwc1    f10,0x2704(at)


        // addiu   t7,t7,LOWER // original
        lui     t7,0x0000
        addiu   t7,0x2AA8
        // li      t7, Zoom.zoom_background
        // lw      t7, 0x0(t7)
        // andi    t7, t7, 0xFFFF

        swc1    f10,0x34(t2)
        lw      t3,0x74(s0)
        or      a0,s0,r0
        swc1    f0,0x40(t3) // scale x
        lw      t4,0x74(s0)
        swc1    f0,0x44(t4) // scale y
        lw      t5,0x74(s0)
        swc1    f0,0x48(t5) // scale z

        // lw      t6,LOWER(t6) // original
        li      t6, Zoom.zoom_background
        lw      t6, 0x0(t6)

        jal     0x8000F8F4
        addu    a1,t6,t7

        // lui     t8,(UPPER + 0x1)
        // lw      t8,LOWER(t8) // original
        li      t8, Zoom.zoom_background
        lw      t8, 0x0(t8)

        lui     t9,0x0000
        addiu   t9,t9,0x3700
        or      a0,s0,r0
        addiu   a2,r0,0
        jal     0x8000BE28
        addu    a1,t8,t9
        li      a1,0x8000DF34 // render routine
        or      a0,s0,r0 // object
        addiu   a2,r0,1 // room
        jal     Render.REGISTER_OBJECT_ROUTINE_ // 0x80008188
        addiu   a3,r0,1 // group order (0-5)

        jal     0x8000DF34
        or      a0,s0,r0 // object

        addiu   sp,sp,0x28
        // render end

        FGM.play(152)
        FGM.play(187)

        OS.restore_registers()

        _original:
        ori     t6, t7, 0x1   // original lines
        sb      t6, 0x18F(s0)

        j       _return
        nop
    }

    // 8010CAE0 + 10
    scope camera_update: {
        OS.patch_start(0x882F0, 0x8010CAF0)
        j       camera_update
        nop
        _return:
        OS.patch_end()

        li      t0, zoom_timer     // t0 = zoom_timer address
        lw      t1, 0x0000(t0)     // t1 = zoom timer

        addiu   t1, t1, -1

        sw      t1, 0x0000(t0)

        beq     t1, r0, became_zero
        nop

        b       _original
        nop

        became_zero:
        OS.save_registers()
        // Reset camera mode
        // This function calls: cmManager_SetCameraStatus(gCameraStruct.status_default);
        jal 0x8010CF20
        nop

        // Enable stage display
        ori     a0, r0, 0x1
        lli     a1, 0x0
        jal     Render.toggle_group_display_
        nop

        ori     a0, r0, 0x2
        lli     a1, 0x0
        jal     Render.toggle_group_display_
        nop
        //

        li      t6, Zoom.zoom_background_object
        lw      a0, 0x0(t6)
        beqz    a0, after_destroy
        nop

        // destroy ko background
        addiu   sp, sp, -0x0020     // allocate stack space
        sw      ra, 0x0004(sp)      // save registers
        sw      t0, 0x000C(sp)      // ~
        sw      t5, 0x0010(sp)      // ~
        sw      t6, 0x0014(sp)      // ~
        sw      t8, 0x0018(sp)      // ~
        sw      v1, 0x001C(sp)      // ~
        jal     Render.DESTROY_OBJECT_             // destroy the object
        nop
        lw      ra, 0x0004(sp)      // restore registers
        lw      t0, 0x000C(sp)      // ~
        lw      t5, 0x0010(sp)      // ~
        lw      t6, 0x0014(sp)      // ~
        lw      t8, 0x0018(sp)      // ~
        lw      v1, 0x001C(sp)      // ~
        addiu   sp, sp, 0x0020      // deallocate stack space
        //

        sw      r0, 0x0(t6)

        after_destroy:

        OS.restore_registers()
        
        _original:
        sw a0, 0x0018(sp) // original line 1
        lw a0, 0x0074(t6) // original line 2

        j       _return
        nop
    }

    // 0x8000A5E4
    scope objects_update: {
        OS.patch_start(0xB1EC, 0x8000A5EC)
        j       objects_update
        nop
        _return:
        OS.patch_end()

        or      t2, r0, at // save at

        li      t0, zoom_timer     // t0 = zoom_timer address
        lw      t1, 0x0000(t0)     // t1 = zoom timer

        bgt     t1, r0, _cancel_update_check
        nop

        b   _original
        nop

        _cancel_update_check:
        ori         t3, r0, 0x000F  // % 16

        // Using t3 in the "and" working as a "mod" operation (division remainder)
        li      t5, Global.current_screen_frame_count // ~
        lw      t5, 0x0000(t5)           // t5 = global frame count

        and     t7, t5, t3
        beqz    t7, _original
        nop

        addiu sp, sp, 0x28 // deallocate what the original function did earlier

        OS.save_registers()
        lui a0, 0x8013
        lw  a0, 0x1460(a0) // get camera

        jal 0x8010CECC // update camera
        nop

        li      t6, Zoom.zoom_background_object
        lw      a0, 0x0(t6)

        beqz    a0, after_obj
        nop

        ori     t3, r0, 0x0001  // % 1

        // Using t3 in the "and" working as a "mod" operation (division remainder)
        li      t5, Global.current_screen_frame_count // ~
        lw      t5, 0x0000(t5)           // t5 = global frame count

        and     t7, t5, t3
        beqz    t7, after_obj
        nop

        jal     0x8000DF34
        nop

        after_obj:

        OS.restore_registers()

        jr ra
        nop

        _original:
        or      at, r0, t2 // restore at
        sw      r0, 0x6A64(at)
        lui     at, 0x8004

        j       _return
        nop
    }
}