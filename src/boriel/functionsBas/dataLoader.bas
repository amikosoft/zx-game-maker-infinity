' Sub loadDataFromTape()

    #ifndef ENABLED_128k
        load "" CODE ' Load fx
    #endif
    
    load "" CODE ' Load files
    
    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            SetBank(musicBank)
            load "" CODE ' Load vtplayer
            load "" CODE MUSIC_ADDRESS ' Load ingame music

            #ifdef MUSIC_TITLE_ENABLED
                load "" CODE MUSIC_TITLE_ADDRESS ' Load title music
            #endif

            #ifdef MUSIC_2_ENABLED
                load "" CODE MUSIC_2_ADDRESS ' Load music 2
            #endif

            #ifdef MUSIC_3_ENABLED
                load "" CODE MUSIC_3_ADDRESS ' Load music 3
            #endif

            #ifdef MUSIC_ENDING_ENABLED
                load "" CODE MUSIC_ENDING_ADDRESS ' Load ending music
            #endif

            #ifdef MUSIC_GAMEOVER_ENABLED
                load "" CODE MUSIC_GAMEOVER_ADDRESS ' Load game over music
            #endif
        #endif
        
        SetBank(screensBank)
        load "" CODE TITLE_SCREEN_ADDRESS ' Load title Screen
        load "" CODE ENDING_SCREEN_ADDRESS ' Load ending Screen
        load "" CODE HUD_SCREEN_ADDRESS ' Load hud Screen

        #ifdef INTRO_SCREEN_ENABLED
            load "" CODE INTRO_SCREEN_ADDRESS ' Load intro Screen
        #endif
        #ifdef GAMEOVER_SCREEN_ENABLED
            load "" CODE GAMEOVER_SCREEN_ADDRESS ' Load game over Screen
        #endif
        #ifdef GAMEMAP_SCREEN_ENABLED
            load "" CODE GAMEMAP_SCREEN_ADDRESS ' gamemap Screen
        #endif
        #ifdef CREDITS_SCREEN_ENABLED
            load "" CODE CREDITS_SCREEN_ADDRESS ' credits Screen
        #endif
        #ifdef REDEFINE_SCREEN_ENABLED
            load "" CODE REDEFINE_SCREEN_ADDRESS ' redefine Screen
        #endif
        #ifdef INSTRUCTIONS_SCREEN_ENABLED
            load "" CODE INSTRUCTIONS_SCREEN_ADDRESS ' instructions Screen
        #endif

        #ifdef HUD2_SCREEN_ENABLED
        #ifdef SCREEN_HUD2_ENABLED
            load "" CODE HUD2_SCREEN_ADDRESS ' instructions Screen
        #endif
        #endif

        #ifdef FULLSCREEN_TEXTS
            #ifdef ADVENTURETEXTS_SCREEN_ENABLED
                load "" CODE ADVENTURETEXTS_SCREEN_ADDRESS ' adventure texts Screen
            #endif
        #endif

        SetBank(fxBank)
        
        load "" CODE BEEP_FX_ADDRESS
        load "" CODE MAPS_DATA_ADDRESS
        
        #ifdef IN_GAME_TEXT_ENABLED    
            SetBank(textsBank)
            load "" CODE TEXTS_DATA_ADDRESS ' texts
        #endif
        
        SetBank(gameBank)
    #endif
' End Sub