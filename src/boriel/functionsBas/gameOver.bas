#ifdef ENABLED_128k
    #ifdef MUSIC_ENABLED
        #ifdef MUSIC_GAMEOVER_ENABLED
            VortexTracker_Play(MUSIC_GAMEOVER_ADDRESS)
        #else
            VortexTracker_Stop()
        #endif
    #endif
#endif

#ifdef NEW_BEEPER_PLAYER
    BeepFX_Reset()
#endif

#ifdef ENABLED_128k
    #ifdef GAMEOVER_SCREEN_ENABLED
        loadScreen(GAMEOVER_SCREEN_ADDRESS)
    #Else
        protaTile = 15
        Print AT 7, 12; TEXT_GAME_OVER
    #endif
#Else
    protaTile = 15
    Print at 7, 12; TEXT_GAME_OVER
#endif

' Do
' Loop Until MultiKeys(KEYENTER)
pauseUntilPressEnter()
showMenu()