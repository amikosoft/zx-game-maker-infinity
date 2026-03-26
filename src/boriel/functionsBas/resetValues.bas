#ifdef SHOOTING_ENABLED
    bulletPositionX = 0
#endif
#ifdef SIDE_VIEW
    jumpCurrentKey = jumpStopValue
#endif

invincible = 0

currentLife = INITIAL_LIFE

#ifdef ENERGY_ENABLED
    currentEnergy = INITIAL_ENERGY
#endif

#ifdef KEYS_ENABLED
    currentKeys = 0
#EndIf

#ifdef LEVELS_MODE
    currentLevel = 0
#endif

#ifdef ARCADE_MODE
    currentItems = 0
#Else
    #ifdef ITEMS_COUNTDOWN_ENABLED
        currentItems = itemsToFind
    #Else
        currentItems = 0
    #EndIf
#endif

screenObjects = screenObjectsInitial

For i = 0 To SCREENS_COUNT
    screensStatus(i) = SCREEN_STATUS_NOT_VISITED
    
    #ifdef USE_BREAKABLE_TILE
        brokenTiles(i) = 0
    #endif
Next i
#ifdef HISCORE_ENABLED
    score = 0
#endif

#ifdef AMMO_ENABLED
    currentAmmo = INITIAL_AMMO
#endif

#ifdef IN_GAME_TEXT_ENABLED
    #ifndef ARCADE_MODE
        #ifdef IS_TEXT_ADVENTURE
            currentAdventureState = 1
        #endif
    #endif
#endif

#ifdef MUSIC_ENABLED
    musicPlayed = 0
#endif