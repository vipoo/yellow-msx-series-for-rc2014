\newpage
\ifoot*{SofaROM (c) NYYRIKKI}

### SofaROM

```
            *********************************************
            *              SofaROM v3.2                 *
            *     coded by Louthrax in February 2021    *
            *          A.I. code by NYYRIKKI            *
            *********************************************
```

#### Introduction

SofaROM  is an  MSX tool  designed to  launch MSX  ROM images.  It
supports several "ROM devices" and most ROMs and MegaROMs  formats.
ROMs can also be launched without any external device using "Memory
mapper" or "turboR mapper".

Depending on the options passed, ROMs are patched on the fly to use
JoyMega, FM Towns, JoySNES pads, Game Master  1 or  2,  PSG to SCC,
external SCC (for  ROM devices  having no integrated SCC chip) or
other features.

SofaROM will pick  the best suitable  ROM device depending  on the
ROM type and settings chosen. You can specify a "preferred  device"
with the  /Dx option,  but if  this one  is not  found or suitable,
another device might be selected instead.



#### License

You are allowed to freely  use and distribute SofaROM for  any non-
commercial usage.

This software is provided  'as-is', without any express  or implied
warranty.  In no  event will  the author  be held  liable for  any
damages arising from the use of this software.


#### Requirements

MSX computer  with MSX-DOS   2,  and  some extra   mapped-memory on
the main slot if you want to use Game Masters or "Memory mapper" to
launch ROMs.


Supported ROM devices are:

 * Memory mapper
   - Game Master 1 support only for small ROMs (<=32KB).
   - No Game Master 2 support.
   - ROMs  will be  patched at  load time  by SofaROM  for all  ROM
     types.
   - Disk accesses during ROM execution.
   - Fastest speed on turboR R800 mode.
   - /T option required for SCC sounds.

 * turboR mapper
   - ROMs  will be  patched at  load time  by SofaROM  for all  ROM
     types.
   - No disk accesses during ROM execution but ROM size limited  to
     1MB.
   - Fastest speed on turboR R800 mode.
   - /T option required for SCC sounds.

 * SD Snatcher
   - Same  as Snatcher  cartridge  but pages  are  offseted by  8.
   - ROMs  will be  patched at  load time  by SofaROM  for all  ROM
     types.

 * Snatcher
   - Konami SCC+ cartridge.
   - ROMs will be patched at load time by SofaROM for non-SCC ROMs.

 * MegaRAM
   - ROMs will be patched at load time by SofaROM for ASCII ROMs.
   - /T option required for SCC sounds.

 * ESE SCC
   - ROMs will be patched at load time by SofaROM for non-SCC ROMs.

 * ESE RAM
   - ROMs will  be patched at  load time by  SofaROM for non-ASCII8
     ROMs.

 * MegaFlashROM SCC
   - ROMs will be patched at load time by SofaROM for non-SCC ROMs.

 * MegaFlashROM SCC+ SD
   - Native support  for all ROMs  except Linear0 and  LinearC (see
     below).

 * Carnivore 2 - Flash
   - Native support for all ROMs.

   You have  to reserve  an entry  for SofaROM  in the  Carnivore 2
   flash memory in order to use it (the Carnivore 2 can be  flashed
   in RAM mode  without doing   that, but  the size  is  limited to
   720KB). Here's the procedure for it:

      1. Extract one of the  file in CARNIROM.ZIP depending on  the
      space you want to reserve for SofaROM in flash memory. Go  to
      the  SofaROM  directory,  and  type:

         SUZ  E CARNIROM.ZIP SOFAROM1.ROM

      SOFAROM1.ROM will reserve  1MB in flash  memory, SOFAROM2.ROM
      will reserve 2MB, etc...

      2. Flash  the extracted  ROM file  in the  Carnivore 2  flash
      memory using  C2MAN.COM  or  C2MAN_40.COM (the   same way you
      flash a normal ROM).

      3. Reset you MSX.

 * OCM
   - Native support for all ROMs.

 * GR8NET
   - Native support for all ROMs.

 * Multi-MSXRAM
   - Native support for all ROMs.
   - /T option required for SCC sounds.

 * MegaFlashROM SCC+
   - Native support for all ROMs.

 * Carnivore 2 - RAM
   - Native support for all ROMs.



#### Supported ROM types

Supported ROM types are:

 * ASCII16
   ASCII MegaROMs  with 16KB  pages and  standard switch  addresses
   (6000 and 7000).

 * ASCII16F8
   ASCII  MegaROMs with  16KB pages  and "TAITO"  switch addresses
   (67F8 and 77F8).

 * ASCII8
   ASCII  MegaROMs with  8KB pages  and standard  switch addresses
   (6000, 6800, 7000 and 7800).

 * ASCII8F8
   ASCII  MegaROMs  with  8KB pages  and  "TAITO"  switch addresses
   (67F8, 6FF8, 77F8 and 7FF88).

 * Konami SCC
   Konami  SCC  MegaROMs  (switch addresses  5000,  7000,  9000 and
   B000).

 * Konami
   Konami MegaROMs (switch addresses 4000, 6000, 8000 and A000).

 * ASCII16W
   ASCII  MegaROMs  with  16KB pages  and  "wide"  switch addresses
   (6000-67FF and 7000-77FF).

 * ASCII8W
   ASCII MegaROMs with 8KB pages and "wide" switch addresses (6000-
   67FF 6800-6FFF 7000-77FF and 7800-7FFF).

 * Linear
   Linear ROM image  starting at 4000  or 8000 and  not overlapping
   C000-FFFF.

 * Linear0
   Linear ROM image starting at 0000 and not overlapping C000-FFFF.

 * LinearC
   Any linear ROM image overlapping C000-FFFF.

 * BASIC
   BASIC ROM image (starting at 8000).



#### Non-volatile ROM devices

SofaROM  keeps track  of the  last flashed  ROMs for  each type  of
device in a "SROM.FLH" file. If a device is considered non-volatile,
SofaROM  reflashes  it  only when  needed  (different  ROM file  or
different options).

Non-volatile devices are:
 * ESE SCC
 * ESE RAM
 * MegaFlashROM SCC
 * MegaFlashROM SCC+
 * MegaFlashROM SCC+ SD

You  can  force  reflashing  by using  the  /E  option  or manually
deleting the "SROM.FLH" file.



#### Soft reset

If you  have enabled  Joy2Key support,  you can   reset the game by
pressing a combination of buttons:
 * (Start)+(A)+(Down) for JoyMega and JoySNES
 * (Start)+(Run) for FM-Towns



#### Artificial intelligence

When patching ROMs, SofaROM uses A.I. code (created by NYYRIKKI) to
detect if  the area  to patch   is really  code, or  data (patching
must be avoided in this case).

You have  a limited  control on  this process  with the  /A option.
Basically,  try  to  decrease  the  A.I.  level  if  you experiment
crashes in  the game,  and increase  it if  you see data corruption
after that (in graphics or musics).



#### Interruption mode

The /I option is only  used by "Memory mapper" and  "turboR mapper"
devices. Those two devices are more prone to problems because  they
require calls to time-consuming routines to swap ROM pages.

Try to  play  with  this option   to increase speed  or fix crashes
when  using "Memory mapper" or  "turboR mapper" devices.

* Auto-safe
  Safest but slowest mode.

* Auto-fast
  A bit faster compared to "Auto-safe" at the cost of safety.

* None
  Fastest mode, might cause crashes in some games.

* DI-EI
  Fast mode, use this if "None" does not work.

* DI
  Fast mode, use this if "None" and "DI-EI" does not work.



#### SROM.INI

You can define several settings in this file:

 * Path to the SROM.FLH file.
 * Path to the Game Master's ROMs.
 * The Joy2Key joystick to key bindings.
 * The PSG2SCC waveforms.

Have a look at the comments in the file for more details.



#### Usage


SofaROM 3.0 by Louthrax
 A.I. code by NYYRIKKI

Usage: SROM [options] <rom_image>

[options] can be one or more of:
```
  /Ax: A.I. level (0-2)
       Default is 2

  /B:  Patch game to disable keyboard

  /Cxyz: Patch ROM to filter PSG channels
    x: PSG channel 1
    y: PSG channel 2
    z: PSG channel 3
      0: No patch (default)
      1: Noise only
      2: Music only
      3: Off

  /Dx: Select preferred device
    0: Memory mapper
    1: turboR mapper
    2: SD Snatcher
    3: Snatcher
    4: MegaRAM
    5: ESE SCC
    6: ESE RAM
    7: MegaFlashROM SCC
    8: MegaFlashROM SCC+
    9: MegaFlashROM SCC+ SD
    10: Carnivore 2 - Flash
    11: OCM
    12: GR8NET
    13: Multi-MSXRAM
    14: Carnivore 2 - RAM

  /E:  Enforce flashing (reset SROM.FLH)

  /F:  Flash mode
       - MFRSCC+ (SD) and Carnivore 2 only -
    0: Flash at 1x speed (default for MFRSCC+)
    1: Flash at 2x speed
    2: Flash at 4x speed (default for MFRSCC+SD and Carnivore 2)

  /Gx: Set Game Master mode
    0: Off (default)
    1: Game Master 1
    2: Game Master 2

  /Ix: Change interruption mode
       - Memory mapper and turboR mapper devices only -
    0: Auto-safe (default)
    1: Auto-fast
    2: None
    3: DI-EI
    4: DI

  /Jx: Patch ROM for Joy2Key
    0: No patch (default)
    x: Index in JOY2KEY section of SROM.INI

  /K: Contiguous MFRSCC+SD (no hole patching)

  /Lx: Patch ROM to use different language
    0: No patch (default)
    1: Japanese
    2: International
    3: Korean

  /Mx: Patch ROM to use different MSX version
    0: No patch (default)
    1: MSX 1
    2: MSX 2
    3: MSX 2+
    4: turboR

  /N:  No subslots

  /Ox: Page switch optimization (0-255)
       - Memory mapper device only -
       Default is 9

  /Px: Patch ROM to use different PSG port
    0: No patch (default)
    1: MFRSCC+(SD) port
    2: Muted

  /Q: Quiet mode

  /Rx: Set MegaROM mapper type
    0: Automatic (default)
    1: ASCII16
    2: ASCII16F8
    3: ASCII8
    4: ASCII8F8
    5: Konami SCC
    6: Konami
    7: ASCII16W
    8: ASCII8W
    9: Linear
    10: Linear0
    11: LinearC
    12: BASIC

  /Sxy: Set SCC slot
    x: Main slot (0-3)
    y: Subslot (0-3)

  /T: Patch ROM to use external SCC

  /U: Enable fast interruptions. Keyboard will
    not be available in this mode

  /Wxyz: Patch ROM to use SCC instead of PSG
    x: PSG channel 1
    y: PSG channel 2
    z: PSG channel 3
      0: No patch (default)
      x: Index in WAVEFORMS section of SROM.INI

  /X: Disable disk driver

  /Y: Preserve AB header

  /Zx: Set CPU mode
       - turboR or OCM only -
    turboR:
    0: No change (default)
    1: Z80 (ROM)
    2: R800 ROM
    3: R800 DRAM
    OCM:
    0: No change (default)
    1: 3.58MHz
    2: 4.10MHz
    3: 4.48Mhz
    4: 4.90MHz
    5: 5.39MHz
    6: 6.10MHz
    7: 6.96MHz
    8: 8.06MHz

<rom_image> is a ROM image file
```


#### Thanks

Thanks are flying to (no special order):

 * Bifi for ROMLOAD.
   Official site: http://www.tni.nl/products/romload.html

 * Adriano Camargo Rodrigues da Cunha for ExecROM.
   Official site: http://sourceforge.net/projects/execrom/

 * Trunks  & Victor  for LOADROM  and for  the help  on the  GR8Net
   driver.

 * Fabf  for providing  me a  test cartridge  for both  MegaRAM and
   Multi-MSXRAM!

 * Jipe for his advices on ASCII 16 ROMs.

 * Hamlet for providing me a HBM-512 memory expansion cartridge.

 * Trunks  & Victor  for LOADROM  and for  the help  on the  GR8Net
   driver.

 * Jipe for his advices on ASCII 16 ROMs.

 * Tiny Yarou for the PSG to SCC idea and SG2MSX tool.

 * Manuel  Pazos   for   the  MegaFlashROM   cartridges  and    his
   technical help on it.

 * Samy83 for providing a Carnivore 2 cartridge.

 * Sebbeug for his assistance on Carnivore 2.

 * Meits for lending me his OCM.

 * Kdl for his assistance on OCM support.

\newpage
\ifoot*{}
