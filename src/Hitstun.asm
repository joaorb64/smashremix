scope Hitstun {  
    // @ Description
    // Toggle for Melee Style Hitstun.
    // Divides Knockback by 2.5, instead of 1.875, thus less hitstun
    scope hitstun_: {
        OS.patch_start(0x659B0, 0x800EA1B0)
        j       hitstun_
        nop
        hitstun_end_:
        OS.patch_end()
        
        lui     at, 0x3FF0                  // original line 1 (1.875 fp)
        mtc1    at, f4                      // original line 2, move to floating point register (f4)

        div.s   f0, f12, f4

        lui     t0, 0x41F0 // if knockback is above 30.0, we'll apply speedup (see Sandbag.asm)
        mtc1    t0, f2

        c.le.s  f0, f2
        nop

        bc1t    no_speedup // otherwise, just use normal values
        nop

        lui     at, 0x4060                  // 3.5
        mtc1    at, f4                      // original line 2, move to floating point register (f4)

        no_speedup:

        Toggles.single_player_guard(Toggles.entry_hitstun, hitstun_end_)
        
        lui     at, 0x4020                  // Melee style, higher divisor, so less hitstun
        mtc1    at, f4                      // original line 2
        
        j      hitstun_end_         // return
        nop
    }
}