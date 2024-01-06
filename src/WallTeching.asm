// WallTeching.asm

scope WallTeching {

    // @ Description
    // Patch which adds wall teching.
    scope patch: {
        OS.patch_start(0xBC644, 0x80141C04)
        j       patch
        addiu   a1, r0, 0x0038          // original line 2
        _return:
        OS.patch_end()

        // Ken stage wall mechanic start
        li      at, Global.match_info
        lw      at, 0x0000(at)                      // t7 = match info
        lbu     at, 0x0001(at)                      // t7 = current stage ID
        lli     t5, Stages.id.BATTLE_HARBOR         // t0 = Stages.id.BATTLE_HARBOR
        bne     t5, at, wall_tech_continue          // if current stage is SMBBF, then skip pirahna and platforms
        nop

        lui     at, 0x42c8                  // ~
        mtc1    at, f6                      // f6 = 100.0
        lwc1    f8, 0x0054(s0)              // f8 = x kb velocity
        abs.s   f8, f8
        nop

        c.le.s  f6, f8                      // xspeed > threshold?
        nop
        bc1fl   wall_tech_continue                   // speed too low
        nop

        lw      a0, 0x0048(sp)

        lw      t5, 0x0044(s0)              // load facing direction
        addiu   at, r0, 0x0001              // at = 1 (facing left)
        bne     t5, at, ko_left        // if facing left, use left
        nop
        b ko_right
        nop

        ko_left:
        jal     0x8013C454 // KO left
        nop
        j ken_stage_end

        ko_right:
        jal     0x8013C30C // KO right
        nop
        j ken_stage_end

        ken_stage_end:
        j       0x80141C28              // return
        nop
        // Ken stage wall mechanic end
        
        wall_tech_continue:
        Toggles.read(entry_wall_teching, at) // at = toggle
        beqz    at, _end
        lw      t6, 0x0160(s0)          // t6 = frames since z pressed
        slti    t6, t6, 0x0014          // t6 = 0 if frames since z pressed > 0x14(20)
        beq     t6, r0, _end            // end if frames sinze z pressed > 20
        nop

        // if we're here, start a wall tech
        mfc1    t5, f6                  // ~
        sw      t5, 0x0B18(s0)          // original logic
        sw      r0, 0x0054(s0)          // ~
        sw      r0, 0x0058(s0)          // ~
        lw      a0, 0x0048(sp)          // a0 = player object
        Action.change(Action.Tech, 0x4000)
        
        // set routines
        // sw      r0, 0x086C(s0)          // update moveset pointer
        // sw      r0, 0x08AC(s0)          // update moveset pointer
        li      at, 0x800D94E8
        sw      at, 0x09D4(s0)          // update main routine
        sw      r0, 0x09E0(s0)          // remove movement routine
        li      at, 0x800DE99C
        sw      at, 0x09E4(s0)          // update collision pointer
        sw      r0, 0x09DC(s0)          // remove interrupt routine
        
        j       0x80141C28              // return
        nop

        _end:
        j       _return                 // return
        addiu   t6, r0, 0x1100          // original line 1
    }

}
