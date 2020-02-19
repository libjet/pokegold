INCLUDE "constants.asm"

SECTION "NULL", ROM0

NULL::

; rst vectors
INCLUDE "home/rst.asm"
INCLUDE "home/interrupts.asm"

SECTION "Header", ROM0

Start::
	nop
	jp _Start


SECTION "Home", ROM0

INCLUDE "home/vblank.asm"
INCLUDE "home/delay.asm"
INCLUDE "home/rtc.asm"
INCLUDE "home/fade.asm"
INCLUDE "home/lcd.asm"
INCLUDE "home/time.asm"
INCLUDE "home/init.asm"
INCLUDE "home/serial.asm"
INCLUDE "home/joypad.asm"
INCLUDE "home/decompress.asm"
INCLUDE "home/palettes.asm"
INCLUDE "home/copy.asm"
INCLUDE "home/text.asm"
INCLUDE "home/video.asm"
INCLUDE "home/map_objects.asm"
INCLUDE "home/sine.asm"
INCLUDE "home/movement.asm"
INCLUDE "home/menu.asm"
INCLUDE "home/menu_window.asm"
INCLUDE "home/menu2.asm"
INCLUDE "home/handshake.asm"
INCLUDE "home/game_time.asm"
INCLUDE "home/map.asm"

InexplicablyEmptyFunction:: ; 2e16
; Inexplicably empty.
; Seen in PredefPointers.
rept 16
	nop
endr
	ret

INCLUDE "home/farcall.asm"
INCLUDE "home/predef.asm"
INCLUDE "home/window.asm"
INCLUDE "home/flag.asm"

Unreferenced_CheckBPressedDebug::
; Used in debug ROMs to walk through walls and avoid encounters.
	ld a, [wDebugFlags]
	bit 1, a
	ret z
	
	ldh a, [hJoyDown]
	bit 1, a
	ret

xor_a::
	xor a
	ret

xor_a_dec_a::
	xor a
	dec a
	ret

Unreferenced_CheckFieldDebug::
	push hl
	ld hl, wDebugFlags
	bit DEBUG_FIELD_F, [hl]
	pop hl
	ret
	
INCLUDE "home/sprite_updates.asm"
INCLUDE "home/string.asm"
INCLUDE "home/region.asm"

Function2ffe:: ; 2ffe (0:2ffe)
	push hl
	xor a
	ld hl, wd17c
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, [wd17a]
	ld l, a
	ld a, [wd17b]
	ld h, a
	or l
	jr z, .quit
	ldh a, [hROMBank]
	push af
	call SwitchToMapScriptsBank
	ld a, [wPlayerStandingMapX]
	add $4
	ld d, a
	ld a, [wPlayerStandingMapY]
	ld a, $4 ; add $4
	ld e, a
	push bc
	ld c, $0
.loop
	ld a, [hl]
	cp $ff
	jr z, .done
	push hl
	ld a, d
	cp [hl]
	jr nz, .next
	inc hl
	ld a, e
	cp [hl]
	jr nz, .next
	ld hl, wd17c
	ld b, SET_FLAG
	push de
	push bc
	ld d, $0
	predef SmallFarFlagAction
	pop bc
	pop de
.next
	pop hl
	inc hl
	inc hl
	inc hl
	inc c
	ld a, c
	cp $20
	jr c, .loop
.done
	pop bc
	pop af
	rst Bankswitch
.quit
	pop hl
	ret

INCLUDE "home/item.asm"
INCLUDE "home/random.asm"
INCLUDE "home/sram.asm"

; Register aliases
_hl_::
	jp hl

_de_::
	push de
	ret

INCLUDE "home/clear_sprites.asm"
INCLUDE "home/copy2.asm"
INCLUDE "home/copy_tilemap.asm"
INCLUDE "home/copy_name.asm"

IsInArray::
; Find value a for every de bytes in array hl.
; Return index in b and carry if found.

	ld b, 0
	ld c, a
.loop
	ld a, [hl]
	cp -1
	jr z, .NotInArray
	cp c
	jr z, .InArray
	inc b
	add hl, de
	jr .loop

.NotInArray:
	and a
	ret

.InArray:
	scf
	ret
	
SkipNames::
; Skip a names.
	ld bc, NAME_LENGTH
	and a
	ret z
.loop
	add hl, bc
	dec a
	jr nz, .loop
	ret

INCLUDE "home/math.asm"
INCLUDE "home/print_text.asm"

CallPointerAt::
	ldh a, [hROMBank]
	push af
	ld a, [hli]
	rst Bankswitch

	ld a, [hli]
	ld h, [hl]
	ld l, a

	call _hl_

	pop hl
	ld a, h
	rst Bankswitch
	ret

INCLUDE "home/queue_script.asm"
INCLUDE "home/compare.asm"
INCLUDE "home/tilemap.asm"
INCLUDE "home/hp_pals.asm"

CountSetBits::
; Count the number of set bits in b bytes starting from hl.
; Return in a, c and [wNumSetBits].
	ld c, 0
.next
	ld a, [hli]
	ld e, a
	ld d, 8

.count
	srl e
	ld a, 0
	adc c
	ld c, a
	dec d
	jr nz, .count

	dec b
	jr nz, .next

	ld a, c
	ld [wNumSetBits], a
	ret

GetWeekday::
	ld a, [wCurDay]
.mod
	sub 7
	jr nc, .mod
	add 7
	ret

INCLUDE "home/pokedex_flags.asm"
INCLUDE "home/names.asm"
INCLUDE "home/scrolling_menu.asm"
INCLUDE "home/stone_queue.asm"
INCLUDE "home/trainers.asm"

DrawBattleHPBar::
	push hl
	push de
	push bc
	ld a, $60
	ld [hli], a
	ld a, $61
	ld [hli], a
	push hl
	ld a, $62
.asm_3990
	ld [hli], a
	dec d
	jr nz, .asm_3990
	ld a, $6b
	add b
	ld [hl], a
	pop hl
	ld a, e
	and a
	jr nz, .asm_39a3
	ld a, c
	and a
	jr z, .asm_39b6
	ld e, $1
.asm_39a3
	ld a, e
	sub $8
	jr c, .asm_39b2
	ld e, a
	ld a, $6a
	ld [hli], a
	ld a, e
	and a
	jr z, .asm_39b6
	jr .asm_39a3

.asm_39b2
	ld a, $62
	add e
	ld [hl], a
.asm_39b6
	pop bc
	pop de
	pop hl
	ret

PrepMonFrontpic::
	ld a, $1
	ld [wcf3b], a
PrepMonFrontpic_::
	ld a, [wCurPartySpecies]
	and a
	jr z, .not_pokemon
	cp EGG
	jr z, .egg
	cp NUM_POKEMON + 1
	jr nc, .not_pokemon
.egg
	push hl
	ld de, $9000
	predef GetMonFrontpic
	pop hl
	xor a
	ldh [hGraphicStartTile], a
	lb bc, 7, 7
	predef PlaceGraphic
	xor a
	ld [wcf3b], a
	ret

.not_pokemon
	xor a
	ld [wcf3b], a
	inc a
	ld [wCurPartySpecies], a
	ret

INCLUDE "home/cry.asm"

PrintLevel:: ; 3a50
	ld a, [wTempMonLevel]
	ld [hl], $6e
	inc hl
	ld c, $2
	cp MAX_LEVEL
	jr c, Print8BitNumRightAlign
	dec hl
	inc c
	jr Print8BitNumRightAlign

PrintLevel_Force3Digits::
	ld [hl], $6e
	inc hl
	ld c, $3
Print8BitNumRightAlign::
	ld [wd151], a
	ld de, wd151
	ld b, PRINTNUM_RIGHTALIGN | 1
	jp PrintNum

Function3a70::
	ld hl, wd149
	ld c, a
	ld b, $0
	add hl, bc
	ld a, [hl]
	ret

GetBaseData::
	push bc
	push de
	push hl
	ldh a, [hROMBank]
	push af
	ld a, BANK(BaseData) ; $14
	rst Bankswitch
	ld a, [wCurSpecies]
	cp EGG
	jr z, .egg
	dec a
	ld bc, $20
	ld hl, BaseData ; $5b0b
	call AddNTimes
	ld de, wd120
	ld bc, $20
	call CopyBytes
	jr .asm_3ab3

.egg
	ld de, UnknownEggPic ; $7a83
	ln b, 5, 5
	ld hl, wd131
	ld [hl], b
	ld hl, wd132
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
	ld [hl], e
	inc hl
	ld [hl], d
	jr .asm_3ab3

.asm_3ab3
	ld a, [wCurSpecies]
	ld [wd120], a
	pop af
	rst Bankswitch
	pop hl
	pop de
	pop bc
	ret

GetCurNick::
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1Nickname
GetNick::
	push hl
	push bc
	call SkipNames
	ld de, wStringBuffer1
	push de
	ld bc, $b
	call CopyBytes
	pop de
	callfar CheckNickErrors
	pop bc
	pop hl
	ret

PrintBCDNumber:: ; 3ade (0:3ade)
	ld b, c
	res 7, c
	res 6, c
	res 5, c
	bit 5, b
	jr z, .asm_3af0
	bit 7, b
	jr nz, .asm_3af0
	ld [hl], $f0
	inc hl
.asm_3af0
	ld a, [de]
	swap a
	call Function3b15
	ld a, [de]
	call Function3b15
	inc de
	dec c
	jr nz, .asm_3af0
	bit 7, b
	jr z, .asm_3b14
	bit 6, b
	jr nz, .asm_3b07
	dec hl
.asm_3b07
	bit 5, b
	jr z, .asm_3b0e
	ld [hl], $f0
	inc hl
.asm_3b0e
	ld [hl], $f6
	call PrintLetterDelay
	inc hl
.asm_3b14
	ret

Function3b15:: ; 3b15 (0:3b15)
	and $f
	and a
	jr z, .asm_3b2f
	bit 7, b
	jr z, .asm_3b29
	bit 5, b
	jr z, .asm_3b27
	ld [hl], $f0
	inc hl
	res 5, b
.asm_3b27
	res 7, b
.asm_3b29
	add $f6
	ld [hli], a
	jp PrintLetterDelay

.asm_3b2f
	bit 7, b
	jr z, .asm_3b29
	bit 6, b
	ret nz
	ld a, $7f
	ld [hli], a
	ret

GetPartyParamLocation::
	push bc
	ld hl, wPartyMons
	ld c, a
	ld b, $0
	add hl, bc
	ld a, [wCurPartyMon]
	call GetPartyLocation
	pop bc
	ret

GetPartyLocation:: ; 3b4a (0:3b4a)
	ld bc, $30
	jp AddNTimes

Function3b51::
	push hl
	ld a, b
	dec a
	ld b, $0
	add hl, bc
	ld hl, BaseData + 0
	ld bc, $20
	call AddNTimes
	pop bc
	ld a, BANK(BaseData)
	call GetFarHalfword
	ld b, l
	ld c, h
	pop hl
	ret

INCLUDE "home/battle.asm"

PushLYOverrides:: ; 3d0d
	ldh a, [hLCDCPointer]
	and a
	ret z
	ld a, wLYOverridesBuffer % $100
	ld [wRequested2bppSource], a
	ld a, wLYOverridesBuffer / $100
	ld [wRequested2bppSource + 1], a
	ld a, wLYOverrides % $100
	ld [wRequested2bppDest], a
	ld a, wLYOverrides / $100
	ld [wRequested2bppDest + 1], a
	ld a, $9
	ld [wRequested2bpp], a
	ret

InitAnimatedObjectStruct::
	ld [wAnimatedObjectStructIDBuffer], a
	ldh a, [hROMBank]
	push af
	ld a, BANK(InitAnimatedObjectStruct_) ; $23
	rst Bankswitch
	ld a, [wAnimatedObjectStructIDBuffer]
	call InitAnimatedObjectStruct_ ; $51f7
	pop af
	rst Bankswitch
	ret

ReinitAnimatedObjectFrame::
	ld [wAnimatedObjectStructIDBuffer], a
	ldh a, [hROMBank]
	push af
	ld a, BANK(ReinitAnimatedObjectFrame_) ; $23
	rst Bankswitch
	ld a, [wAnimatedObjectStructIDBuffer]
	call ReinitAnimatedObjectFrame_ ; $5332
	pop af
	rst Bankswitch
	ret

INCLUDE "home/audio.asm"
