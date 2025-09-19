#include <zx0.bas>
#include <retrace.bas>
#include <keys.bas>
#include "definitions.bas"
#include "dataLoader.bas"

#include "texts.bas"

#ifdef ENABLED_128k
    #include "128/im2.bas"
    #include "128/vortexTracker.bas"
    #include "128/functions.bas"

    #ifdef MUSIC_ENABLED
        ' VortexTracker_Init()
        IM2Start(@VortexTracker_NextNote)
    #endif
#endif

loadDataFromTape()

' #include "graphicsInitializer.bas"
#include "lib/GuSpritesConfig.bas"
#include "lib/GuSprites.zxbas"

#include "beepFx.bas"
#include "functions.bas"

#include "bullet.bas"
#include "enemies.bas"
#include "draw.bas"
#include "protaMovement.bas"
#include "screensFlow.bas"

'graphicsInitializer.bas
InitGFXLib()
SetTileset(@tileSet)

#ifdef WAIT_PRESS_KEY_AFTER_LOAD
    If firstLoad Then
        firstLoad = 0
        'pauseUntilPressKey()
        while INKEY$<>"":wend
        while INKEY$="":wend
    End If
#endif

waitretrace

#ifdef PASSWORD_ENABLED
    passwordScreen()
#else
    showMenu()
#endif
