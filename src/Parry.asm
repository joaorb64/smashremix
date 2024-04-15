
scope Parry {
    // Is set to 1 if the user's hit was parried
    is_hit_parry:
    db 0x00 //p1
    db 0x00 //p2
    db 0x00 //p3
    db 0x00 //p4

    constant REFLECT_MULTIPLIER(0x3F00) // 0.5

    reflect_hitbox_struct:
    dh 0x0000                         // index to custom reflect routine table. Reflect.custom_reflect_table
    dh Reflect.reflect_type.CUSTOM    // reflect type. Custom value of 4.  ( fox = 0, ??? = 1, bat = 2 )
    dw 0x00000004                     // joint
    dw 0x00000000                     // x offset (local)
    dw 0x42700000                     // y offset (local)
    dw 0x00000000                     // z offset (local)
    dw 0x43AF0000                     // x size = 512 (local)
    dw 0x43AF0000                     // y size = 512 (local)
    dw 0x43AF0000                     // z size = 512 (local)
    dw 0x18000000                     // ? hp value

    // player struct 7D4 = shield_port_id (port id for player that attacked your shield)

    // @ Description
    // Don't change players action to shield stun
    // 800E2D44 + a0
    scope attack_parry: {
        OS.patch_start(0x5E5E4, 0x800E2DE4)
        j       attack_parry
        nop
        _return:
        OS.patch_end()

        // s1 = attacker struct
        // v0 = damage

        lw      t2, 0x6C(sp) // t2 = victim object
        lw      t0, 0x0084(t2) // t0 = victim struct

        //Toggles.read(entry_perfect_shield, at)      // at = Perfect shield toggle
        //beqz    at, _original                       // branch if toggle is disabled
        addiu   at, r0, Action.ShieldOff             // at = shield player action
        // if here, check for a perfect shield
        lw      t1, 0x0024(t0)                      // t0 = current players action
        bne     t1, at, _original                   // branch if not shielding
        nop

        // Update parry flag
        OS.save_registers()
        lbu     t1, 0x000D(s1)              // t1 = attacker port
        li      t2, is_hit_parry            // ~
        addu    t3, t2, t1                  // t3 = px is_hit_parry address
        lbu     t1, 0x0000(t3)              // t2 = is_hit_parry
        addi t1, 0x1                        // is_hit_parry += 1
        sb   t1, 0x0000(t3)                 // update is_hit_parry
        OS.restore_registers()

        // Calculate hitbox hitlag
        OS.save_registers()
        // s32 gmCommon_DamageCalcHitLag(s32 damage, s32 status_id, f32 hitlag_mul)
        or a0, r0, v0
        lw a1, 0x0024(t0)                      // a1 = current players action
        //lw a2, 0x7E0(s5)
        lui a2, 0x3F80 // TODO: should load hitlag multiplier

        jal 0x800EA1C0
        nop
        
        sw v0, 0x0040(s1)
        OS.restore_registers()

        lw t3, 0x0040(s1) // t3 = attacker original hitlag
        addi t4, t3, 0xB // add 11
        sw t4, 0x0040(t0) // save to victim

        jal activate_parry
        nop

        addiu   s0,sp,0x3c

        // // copy the part that generates the hitbox nullify effect
        // OS.copy_segment(0x5E6C8, 0x18) // copy 6 lines at (800E2D44 + 184)

        j 0x800E2EEC // jump to the end of the function
        nop

        _original:
        jal 0x800E2CC0                          // og line1
        addiu a1, sp, 0x0054                    // og line2

        j       _return
        nop
    }

    // 800E2A90 + 74
    scope attack_parry_shield: {
        OS.patch_start(0x5E304, 0x800E2B04)
        j       attack_parry_shield
        nop
        _return:
        OS.patch_end()

        // s0 = victim struct
        // 0x38(sp) = attacker struct
        // t0 = hit damage
        or      v1, r0, t0      // v1 = hit damage
        or      t0, r0, s0      // t0 = victim struct
        lw      t4, 0x38(sp)    // t4 = attacker struct

        //Toggles.read(entry_perfect_shield, at)      // at = Perfect shield toggle
        //beqz    at, _original                       // branch if toggle is disabled
        addiu   at, r0, Action.ShieldOff             // at = shield player action
        // if here, check for a perfect shield
        lw      t2, 0x0024(t0)                      // t2 = current players action
        bne     t2, at, _original                   // branch if not shielding
        nop

        // generates nullify effect
        // OS.copy_segment(0x5E35C, 0x18) // 800E2A90 + cc, 6 lines

        lw      t0, 0xc(s1)          // t0 = attacker_hit->damage
        lw      t4, 0x38(sp)         // t4 = attacker struct

        // Update parry flag
        OS.save_registers()
        lbu     t1, 0x000D(t4)              // t1 = attacker port
        li      t2, is_hit_parry            // ~
        addu    t3, t2, t1                  // t3 = px is_hit_parry address
        lbu     t1, 0x0000(t3)              // t2 = is_hit_parry
        addi t1, 0x1                        // is_hit_parry += 1
        sb   t1, 0x0000(t3)                 // update is_hit_parry
        OS.restore_registers()

        // Calculate hitbox hitlag
        OS.save_registers()
        // s32 gmCommon_DamageCalcHitLag(s32 damage, s32 status_id, f32 hitlag_mul)
        or a0, r0, t0                           // a0 = hit damage
        lw a1, 0x0024(s0)                      // a1 = current players action
        //lw a2, 0x7E0(s5)
        lui a2, 0x3F80 // TODO: should load hitlag multiplier

        jal 0x800EA1C0
        nop
        
        sw v0, 0x0040(t4)
        OS.restore_registers()

        lw t3, 0x0040(t4) // t3 = attacker original hitlag
        addi t4, t3, 0xB // add 11
        sw t4, 0x0040(s0) // save to victim

        or t0, r0, s0 // t0 = victim struct
        lw t2, 0x0004(s0) // t2 = victim object

        jal activate_parry
        nop        

        j 0x800E2B74 // 800E2A90 + E4
        nop

        _original:
        addu    t0, t8, t9
        sw      t0,0x7cc(s0) // og line 1: victim_fp->shield_damage_total += (attacker_hit->damage + attacker_hit->shield_damage);
        lw      v0, 0xc(s1) // og line 2

        j       _return
        nop
    }

    // 800E3418 + 68
    scope projectile_parry: {
        OS.patch_start(0x5EC80, 0x800E3480)
        j       projectile_parry
        nop
        _return:
        OS.patch_end()

        // 0x40(sp) = damage
        // s2 = victim struct

        or      t0, r0, s2 // t0 = victim struct

        //Toggles.read(entry_perfect_shield, at)      // at = Perfect shield toggle
        //beqz    at, _original                       // branch if toggle is disabled
        addiu   at, r0, Action.ShieldOff             // at = shield player action
        // if here, check for a perfect shield
        lw      t1, 0x0024(t0)                      // t0 = current players action
        bne     t1, at, _original                   // branch if not shielding
        nop

        lw t2, 0x0004(t0) // t2 = player object

        jal activate_parry
        nop

        lw t1, 0x40(sp) // t1 = hitbox damage

        sw      t1, 0x240(s0) // projectile->hit_shield_damage = damage
        sw      r0, 0x248(s0) // projectile->shield_collide_vec.x = 0
        sw      r0, 0x24C(s0) // projectile->shield_collide_vec.y = 0
        sw      r0, 0x250(s0) // projectile->shield_collide_vec.z = 0
        lui     t3, 0x4296 // t3 = 75
        sw      t3, 0x244(s0) // projectile->shield_collide_angle = 1

        // Calculate hitbox hitlag
        OS.save_registers()
        // s32 gmCommon_DamageCalcHitLag(s32 damage, s32 status_id, f32 hitlag_mul)
        or a0, r0, t1
        lw a1, 0x0024(t0)                      // a1 = current players action
        //lw a2, 0x7E0(s5)
        lui a2, 0x3F80 // TODO: should load hitlag multiplier

        jal 0x800EA1C0
        nop
        
        sw v0, 0x0040(t0)
        OS.restore_registers()

        j   0x800E35A4 // 800E3418+18c: Pretend the hit didn't happen
        nop

        _original:
        lw      t9,0x48(s1)  // og line1
        sll     t1,t9,0x2  // og line2

        j       _return
        nop
    }

    // ftMain_UpdateShieldStatWeapon: 800E3048 + 5C
    scope projectile_parry_on_shield: {
        OS.patch_start(0x5E8A4, 0x800E30A4)
        j       projectile_parry_on_shield
        nop
        _return:
        OS.patch_end()

        // s1 = victim struct
        // v1 = damage

        or      t0, r0, s1 // t0 = victim struct

        //Toggles.read(entry_perfect_shield, at)      // at = Perfect shield toggle
        //beqz    at, _original                       // branch if toggle is disabled
        addiu   at, r0, Action.ShieldOff             // at = shield player action
        // if here, check for a perfect shield
        lw      t1, 0x0024(t0)                      // t0 = current players action
        bne     t1, at, _original                   // branch if not shielding
        nop

        lw      v1,0x3c(sp) // restore v1
        or      t0, r0, s1 // restore t0 = victim struct

        lw t2, 0x0004(t0) // t2 = player object

        jal activate_parry
        nop

        lw t1,0x3c(sp) // t1 = hitbox damage

        sw      t1, 0x240(s0) // projectile->hit_shield_damage = damage
        sw      r0, 0x248(s0) // projectile->shield_collide_vec.x = 0
        sw      r0, 0x24C(s0) // projectile->shield_collide_vec.y = 0
        sw      r0, 0x250(s0) // projectile->shield_collide_vec.z = 0
        lui     t3, 0x4296 // t3 = 75
        sw      t3, 0x244(s0) // projectile->shield_collide_angle = 1

        // Calculate hitbox hitlag
        OS.save_registers()
        // s32 gmCommon_DamageCalcHitLag(s32 damage, s32 status_id, f32 hitlag_mul)
        or a0, r0, t1
        lw a1, 0x0024(t0)                      // a1 = current players action
        //lw a2, 0x7E0(s5)
        lui a2, 0x3F80 // TODO: should load hitlag multiplier

        jal 0x800EA1C0
        nop

        sw v0, 0x0040(t0)
        OS.restore_registers()

        j 0x800E31A0 // 800E3048+158: go to the end of the original function
        nop

        _original:
        lw      v1,0x3c(sp) // original line 1
        lw      t9,0x240(s0) // original line 2

        j       _return
        nop
    }

    // ftMain_UpdateDamageStatItem: 800E39B0 + 238
    scope item_parry: {
        OS.patch_start(0x5F3E8, 0x800E3BE8)
        j       item_parry
        nop
        _return:
        OS.patch_end()

        // 0x38(sp) = damage
        // a0 = victim struct

        or      t0, r0, a0 // t0 = victim struct

        //Toggles.read(entry_perfect_shield, at)      // at = Perfect shield toggle
        //beqz    at, _original                       // branch if toggle is disabled
        addiu   at, r0, Action.ShieldOff             // at = shield player action
        // if here, check for a perfect shield
        lw      t1, 0x0024(t0)                      // t0 = current players action
        bne     t1, at, _original                   // branch if not shielding
        nop

        lw t2, 0x0004(t0) // t2 = player object

        jal activate_parry
        nop

        lw t1, 0x38(sp) // t1 = hitbox damage

        sw t1, 0x274(s0) // ap->hit_shield_damage = damage;
        lui t3, 0x4296 // t3 = 75
        sw r0,0x264(s0) // ap->hit_victim_damage = 0; < we're not hitting a character, but a shield!
        sw t3, 0x278(s0) //ap->shield_collide_angle = angle;
        sw r0, 0x27c(s0) // ap->shield_collide_vec.x = 0.0F;
        sw r0, 0x278(s0) // ap->shield_collide_vec.y = 0.0F;
        lui t3, 0x3f80 // t3 = 1.0F
        sw t3, 0x280(s0) // ap->shield_collide_vec.z = 0.0F;

        lw t3, 0x384(s0) // load function for when the item hits a shield
        lw a0, 0x0004(s0) // load item object from item struct
        jalr t3 // run function for shield collision
        nop

        lw t1, 0x38(sp) // t1 = hitbox damage
        lw t0, 0x4C(sp) // t0 = victim struct

        // Calculate hitbox hitlag
        OS.save_registers()
        // s32 gmCommon_DamageCalcHitLag(s32 damage, s32 status_id, f32 hitlag_mul)
        or a0, r0, t1
        lw a1, 0x0024(t0)                      // a1 = current players action
        //lw a2, 0x7E0(s5)
        lui a2, 0x3F80 // TODO: should load hitlag multiplier

        jal 0x800EA1C0
        nop
        
        sw v0, 0x0040(t0)
        OS.restore_registers()

        j 0x800E3C98 // jump to the end of function
        nop

        _original:
        lw          t0, 0x0044(sp)      // og 0
        lui         a0, 0x8013          // og 1
        addiu       a0, a0, 0x11C0      // og 2

        j       _return
        nop
    }
    
    // ftMain_UpdateShieldStatItem: 800E36F8 + D8
    scope item_parry_on_shield: {
        OS.patch_start(0x5EFD0, 0x800E37D0)
        j       item_parry_on_shield
        nop
        _return:
        OS.patch_end()

        // s1 = victim struct
        // t6 / 0x7cc(s1) = damage

        or      t0, r0, s1 // t0 = victim struct

        //Toggles.read(entry_perfect_shield, at)      // at = Perfect shield toggle
        //beqz    at, _original                       // branch if toggle is disabled
        addiu   at, r0, Action.ShieldOff             // at = shield player action
        // if here, check for a perfect shield
        lw      t1, 0x0024(t0)                      // t0 = current players action
        bne     t1, at, _original                   // branch if not shielding
        nop

        // original function
        // has to be done before we delete the shield to avoid a null pointer
        // generates nullify effect
        // addu t6, t4, t5         // og 1
        // sw t6, 0x07cc(s1)       // og 3
        // OS.copy_segment(0x5F014, 0x38)
        // original function end

        // or      t0, r0, s1      // t0 = victim struct
        lw      t6, 0x7cc(s1)   // t6 = damage
        lw      t2, 0x0004(t0)  // t2 = player object

        jal activate_parry
        nop

        lw t1, 0x7cc(s1) // t1 = hitbox damage

        // Calculate hitbox hitlag
        OS.save_registers()
        // s32 gmCommon_DamageCalcHitLag(s32 damage, s32 status_id, f32 hitlag_mul)
        or a0, r0, t1
        lw a1, 0x0024(t0)                      // a1 = current players action
        //lw a2, 0x7E0(s5)
        lui a2, 0x3F80 // TODO: should load hitlag multiplier

        jal 0x800EA1C0
        nop

        sw v0, 0x0040(t0)
        OS.restore_registers()

        j 0x800E384C // go to the end of the original function
        nop

        _original:
        addu t6, t4, t5         // og 1
        beqz at, _beqz_to_jump  // og 2 <- had to adapt to a jump
        sw t6, 0x07CC(s1)       // og 3

        j _end
        nop

        _beqz_to_jump:
        j 0x800E3814
        nop

        _end:
        j       _return
        nop
    }

    // 800E61EC + 4a8
    scope apply_attacker_extra_hitlag: {
        OS.patch_start(0x61E94, 0x800E6694)
        j       apply_attacker_extra_hitlag
        nop
        _return:
        OS.patch_end()

        // s0 = player struct
        // v0 = hitlag

        lbu     t1, 0x000D(s0)              // t1 = attacker port
        li      t2, is_hit_parry            // ~
        addu    t3, t2, t1                  // t3 = px is_hit_parry address
        lbu     t1, 0x0000(t3)              // t2 = is_hit_parry

        beq     t1, r0, _end                // our hitbox wasn't parried
        nop

        addi    v0, v0, 0xE                 // add 14
        sb      r0, 0x0000(t3)              // update is_hit_parry = 0

        _end:
        sw      v0,0x40(s0)
        lw      t7,0x84(sp)

        j       _return
        nop
    }

    // t0 = player struct
    // t2 = player object
    scope activate_parry: {
        OS.save_registers()

        OS.save_registers()
        or      a0, r0, t2          // a0 = player object
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, Action.ClangRecoil      // a1 = Action.USPG
        lui     a2, 0x3F80               // a2(starting frame) = 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        // jal     0x800E0830                  // unknown common subroutine
        // or      a0, r0, t2          // a0 = player object
        OS.restore_registers()

        // Overwrite GFX routine
        lw      t1, 0x0A28(t0)
        li      t1, GFXRoutine.PARRY
        sw      t1, 0x0A28(t0)

        lli     t1, 0x0003                  // ~
        sb      t1, 0x05BB(t0)              // set hurtbox state to 0x0003(intangible)

        // play sound effect
        lli     a0, 0x5B5                   // parry sfx
        jal     FGM.play_                   // play sfx
        nop

        // Generate ground bump effect
        OS.save_registers()
        addiu   sp,sp,-0x30
        or      a0, r0, t2
        sw      r0, 0x10(sp)
        li      a1, 0x16 // shockwave GFX
        lw      t2, 0x44(t0)
        sw      r0, 0x1c(sp)
        sw      r0, 0x18(sp)
        or      a2, r0, r0
        or      a3, r0, r0
        jal     0x800EABDC
        sw      t2, 0x14(sp)
        addiu   sp,sp,0x30
        OS.restore_registers()
        
        OS.restore_registers()
        jr      ra
        nop
    }
    
    // @ Description
    // Reflect projectiles if under 3 frames
    scope shield_reflect_projectiles: {
        OS.patch_start(0xE16BC, 0x80166C7C)
        j       shield_reflect_projectiles
        nop
        _return:
        OS.patch_end()
        // v1 = projectile struct
        
        Toggles.read(entry_perfect_shield, t0)      // t0 = Perfect shield toggle
        beqz    t0, _original_logic                 // branch if toggle is disabled
        nop
        
        // initial loop setup variables
        OS.read_word(0x800466FC, t1)                // t1 = player object head
        addiu   t3, v1, 0x0214                      // t3 = pointer to first hit object
        addiu   t4, r0, 0                           // t4 = loop count
        addiu   t5, r0, 4                           // t5 = max loop count

        _loop_start:
        lw      t0, 0x0000(t3)                      // t0 = hit object pointer

        _loop_start_2:
        beq     t0, t1, _check_shield
        nop
        lw      t1, 0x0004(t1)                        // t1 = next player object
        bnez    t1, _loop_start_2
        nop

        // increment loop after looping through each player object
        OS.read_word(0x800466FC, t1)                // t1 = player object head
        addiu   t4, t4, 1                           // loop count +=1
        beq     t4, t5, _original_logic             // exit loop if no player object found
        addiu   t3, t3, 0x0008                      // t3 = next hit object

        b       _loop_start
        nop

        _check_shield:
        lw      t0, 0x0084(t0)                      // ~
        lw      t1, 0x0024(t0)                      // t1 = shielding player action
        addiu   t2, r0, Action.ShieldOn             // t2 = shield on action
        bne     t1, t2, _original_logic             // branch if not in shield on pose
        lw      t1, 0x001C(t0)                      // t1 = shielding player action frame count
        slti    t1, t1, 2                           // t1 = 0 if can't reflect
        beqz    t1, _original_logic
        
        // if here, perfect shield
        sw      r0, 0x0214(v1)                      // reset hit object ptr 1
        sw      r0, 0x021C(v1)                      // reset hit object ptr 2
        sw      r0, 0x0224(v1)                      // reset hit object ptr 3
        sw      r0, 0x022C(v1)                      // reset hit object ptr 4
        li      t1, reflect_hitbox_struct
        sw      t1, 0x0850(t0)                      // overwrite current reflect struct
        lw      t0, 0x0004(t0)                      // t0 = shielding player object
        sw      t0, 0x0008(v1)                      // overwrite player owner
        
        lui     t1, REFLECT_MULTIPLIER
        mtc1    t1, f4
        lw      t1, 0x0108(v1)                      // load current damage multiplier
        mtc1    t1, f6
        mul.s   f6, f4, f6                          // divide damage by 2
        nop
        c.le.s  f6, f4
        nop
        bc1fl   _apply_reflect
        swc1    f4, 0x0108(v1)                      // save new damage multipler as 0.5
        swc1    f6, 0x0108(v1)                      // save new damage multipler

        _apply_reflect:
        j       0x80166CB0
        lw      v0, 0x0290(v1)                      // v0 = reflect routine

        _original_logic:
        bc1fl   _original_branch                    // og line 1 modified
        lw      v0, 0x0284(v1)                      // og line 2 (v0 = shield collision routine)

        j       _return + 0x4
        lwc1    f6, 0xCA74(at)                      // og line 3

        _original_branch:
        j       0x80166CE0 + 0x4                    // og branch location
        lw      a0, 0x0020(sp)                      // og branch line 1

    }

    // @ Description
    // Reflect items if under 3 frames
    scope shield_reflect_items: {
        OS.patch_start(0xEBBFC, 0x801711BC)
        j       shield_reflect_items
        nop
        _return:
        OS.patch_end()
        // v1 = item struct

        Toggles.read(entry_perfect_shield, t0)      // t0 = Perfect shield toggle
        beqz    t0, _original_logic                 // branch if toggle is disabled
        nop

        // if here, check for perfect shield

        // initial loop setup variables
        OS.read_word(0x800466FC, t1)                // t1 = player object head
        addiu   t3, v1, 0x0224                      // t3 = pointer to first hit object
        addiu   t4, r0, 0                           // t4 = loop count
        addiu   t5, r0, 4                           // t5 = max loop count

        _loop_start:
        lw      t0, 0x0000(t3)                      // t0 = hit object pointer

        _loop_start_2:
        beq     t0, t1, _check_shield
        nop
        lw      t1, 0x0004(t1)                      // t1 = next player object
        bnez    t1, _loop_start_2
        nop

        // increment loop after looping through each player object
        OS.read_word(0x800466FC, t1)                // t1 = player object head
        addiu   t4, t4, 1                           // loop count +=1
        beq     t4, t5, _original_logic             // exit loop if no player object found
        addiu   t3, t3, 0x0008                      // t3 = next hit object

        b       _loop_start
        nop

        _check_shield:
        lw      t3, 0x0084(t0)                      // ~
        lw      t1, 0x0024(t3)                      // t1 = shielding player action
        addiu   t2, r0, Action.ShieldOn             // t2 = shield on action
        bne     t1, t2, _original_logic             // branch if not in shield on pose       
        lw      t1, 0x001C(t3)                      // t1 = shielding player action frame count
        slti    t1, t1, 2                           // t1 = 0 if can't reflect
        beqz    t1, _original_logic

        // if here, perfect shield
        sw      r0, 0x0224(v1)                      // reset hit object pointer 1
        sw      r0, 0x022C(v1)                      // reset hit object pointer 2
        sw      r0, 0x0234(v1)                      // reset hit object pointer 3
        sw      r0, 0x023C(v1)                      // reset hit object pointer 4
        li      t1, reflect_hitbox_struct
        sw      t1, 0x0850(t3)                      // overwrite current reflect struct
        
        addiu   t1, r0, Hazards.standard.POKEBALL   // t1 = pokeball id
        lw      t0, 0x000C(v1)                      // t0 = current item id
        beq     t0, t1, _skip_ownership_update      // dont update ownership if its a pokeball

        lw      t0, 0x0004(t3)                      // t0 = shielding player object
        sw      t0, 0x0008(v1)                      // overwrite player owner

        _skip_ownership_update:
        lui     t1, REFLECT_MULTIPLIER
        mtc1    t1, f4
        lw      t1, 0x0118(v1)                      // load current damage multiplier
        mtc1    t1, f6
        mul.s   f6, f4, f6                          // divide damage by 2
        nop
        c.le.s  f6, f4
        nop
        bc1fl   _apply_reflect
        swc1    f4, 0x0118(v1)                      // save new damage multipler as 0.5
        
        swc1    f6, 0x0118(v1)                      // save new damage multipler as current multiplier / 2
        
        _apply_reflect:
        j       0x80171228
        lw      v0, 0x0390(v1)                      // v0 = reflect routine

        _original_logic:
        bc1fl   _original_branch                    // og line 1 modified
        lw      v0, 0x0384(v1)                      // og line 2 (v0 = shield collision routine)

        j       _return + 0x4
        lwc1    f6, 0xCC5C(at)                      // og line 3

        _original_branch:
        j       0x80171228 + 0x4                    // og branch location
        lw      a0, 0x0020(sp)                      // og branch line 1

    }
    
    // a0 = player object
    scope fighter_gfx: {
        OS.save_registers()

        addiu   sp, sp, -0x30

        mtc1    r0, f0               // move 0 to floating point register
        addiu   a1, sp, 0x0018       // place 0x18 address of stack in a1
        swc1    r0, 0x0018(sp)       // save 0 to stack struct
        swc1    r0, 0x001C(sp)       // save 0 to stack struct
        swc1    r0, 0x0020(sp)       // save 0 to stack struct

        sw      a0, 0x0010(sp)
        lw      v0, 0x0084(a0)       // v0 = player struct

        jal     0x800EDF24           // determine origin point of projectiles
        lw      a0, 0x08F4(v0)       // load player shield joint

        addiu   a0, sp, 0x0018       // put stack struct location in a0
        lw      s1, 0x0010(sp)
        jal     0x80101500           // yellow swirl gfx (same as grab)
        lw      s1, 0x0084(s1)       // s1 = player struct (scaling)
        
        addiu   sp, sp, 0x30
        
        OS.restore_registers()
        jr      ra
        nop
    }

}
