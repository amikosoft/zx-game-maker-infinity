#include <zx0.bas>
#include <retrace.bas>
#include <keys.bas>
#include <memorybank.bas>

#include "definitions.bas"
#include "dataLoader.bas"

' #ifdef GAME_LANGUAGE_ES
'     #include "texts_es.bas"
' #Else
'     #include "texts.bas"
' #endif

#ifdef ENABLED_128k
    #include "128/im2.bas"
    #include "128/vortexTracker.bas"
    ' #include "128/functions.bas"

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

#ifdef CUSTOM_FONT_ENABLED
    #ifdef CUSTOM_FONT_BOLD_ALL
        #include "fnts/Glow.fnt.bas"
    #endif
    
    #ifdef CUSTOM_FONT_BOLD_MAYUS
        #include "fnts/Fuente.fnt.bas"
    #endif
    
    #ifdef CUSTOM_FONT_MEDIEVAL
        #include "fnts/Clasico.fnt.bas"
    #endif
#endif

#include "functions.bas"

' #INCLUDE <scrbuffer.bas>
' #include "screens.bas"

#include "bullet.bas"
#include "enemies.bas"
#include "draw.bas"
#include "protaMovement.bas"
#include "screensFlow.bas"

'graphicsInitializer.bas
InitGFXLib()
SetTileset(@tileSet(0,0))

#ifdef CUSTOM_FONT_ENABLED
    #ifdef CUSTOM_FONT_BOLD_ALL
        POKE UInteger 23606,@Glow(0,0)-256
    #endif
    
    #ifdef CUSTOM_FONT_BOLD_MAYUS
        POKE UInteger 23606,@Fuente(0,0)-256
    #endif
    
    #ifdef CUSTOM_FONT_MEDIEVAL
        POKE UInteger 23606,@Clasico(0,0)-256
    #endif
#endif

#ifdef ULA_PLUS_VALIDATION
    #include "../output/ulacolors.bas"
#endif

#ifdef WAIT_PRESS_KEY_AFTER_LOAD
    If firstLoad Then
        firstLoad = 0
        'pauseUntilPressKey()
        while INKEY$<>"":wend
        while INKEY$="":wend
    End If
#endif

' waitretrace

#ifdef PASSWORD_ENABLED
    passwordScreen()
#else
    showMenu()
#endif
