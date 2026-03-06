Sub clearScreen()
    Ink 7: Paper 0: Border 0: BRIGHT 0: FLASH 0: Cls
end sub

#ifdef ENABLED_128k
    #ifdef MUSIC_ENABLED
        #ifdef MUSIC_TOGGLE_ENABLED
        Sub toggleMusic()
            isMusicEnabled = not isMusicEnabled
            VortexTracker_Play(MUSIC_TITLE_ADDRESS)
        end sub
        #endif
    #endif
#endif

Sub showMenu()
    ' #ifdef ENABLED_128k
    '     #ifdef MUSIC_ENABLED
    '         VortexTracker_Stop()
    '     #endif
    ' #endif

    ' clearScreen()

    loadScreen(TITLE_SCREEN_ADDRESS)
        
    #ifdef ENABLED_128k
        ' SetBank(DATA_BANK)
        ' dzx0Standard(TITLE_SCREEN_ADDRESS, $4000)
        ' SetBank(0)
        #ifdef MUSIC_ENABLED
            #ifdef MUSIC_TITLE_ENABLED
                VortexTracker_Play(MUSIC_TITLE_ADDRESS)
            #endif
        #endif
    #endif
    
    #ifdef HISCORE_ENABLED
        Print AT 0, 22; TEXT_HI_SCORE
        Print AT 0, 26; hiScore
    #endif
    
    kempston = 0

    #ifdef BUTTON_PAUSE_ENABLED
    If Not keyArray(PAUSE_BUTTON) Then keyArray(PAUSE_BUTTON) = KEYT

        #ifdef BUTTON_QUIT_ENABLED
        If Not keyArray(QUIT_BUTTON) Then keyArray(QUIT_BUTTON) = KEYR
        #endif
    #endif
            
    Do
        If MultiKeys(KEY1) Then
            If Not keyArray(LEFT) Then
                keyArray(LEFT) = KEYO
                keyArray(RIGHT) = KEYP
                keyArray(UP) = KEYQ
                keyArray(DOWN) = KEYA
                keyArray(FIRE) = KEYSPACE
            End If

            playGame()
        elseif MultiKeys(KEY2) Then
            kempston = 1
            playGame()
        elseif MultiKeys(KEY3) Then
            keyArray(LEFT)=KEY6
            keyArray(RIGHT)=KEY7
            keyArray(UP)=KEY9
            keyArray(DOWN)=KEY8
            keyArray(FIRE)=KEY0
            
            playGame()
            #ifdef REDEFINE_KEYS_ENABLED
            elseif MultiKeys(KEY4) Then
                redefineKeys()
            #endif

            #ifdef ENABLED_128k
                #ifdef MUSIC_ENABLED
                    #ifdef MUSIC_TOGGLE_ENABLED
                        elseif MultiKeys(KEYM) Then
                            toggleMusic()
                            waitForReleaseKey()
                    #endif
                #endif
            #endif
        End If
    Loop
End Sub



#ifdef REDEFINE_KEYS_ENABLED
    Function LeerTecla() As Uinteger
        ' Do Loop While GetKeyScanCode()
        ' Do Loop Until GetKeyScanCode()
        pauseUntilPressKey()
        Return GetKeyScanCode()
    End Function
    
    Sub redefineKeys()
        clearScreen()
        
        #ifdef MUSIC_ENABLED
            #ifdef MUSIC_TITLE_ENABLED
                ' VortexTracker_Stop()
            #endif
        #endif
        
        Print AT 7,5;REDEFINE_PRESS_KEY_FOR
        
        Print AT 9,10;REDEFINE_LEFT
        keyArray(LEFT) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 8,20; keyOption
        
        Print AT 10,10;REDEFINE_RIGHT
        keyArray(RIGHT) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 10,20; keyOption
        
        Print AT 11,10;REDEFINE_UP
        keyArray(UP) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 12,20; keyOption
        
        Print AT 12,10;REDEFINE_DOWN
        keyArray(DOWN) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 14,20; keyOption
        
        Print AT 13,10;REDEFINE_FIRE
        keyArray(FIRE) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 16,20; keyOption
        '
        ' keyOption = ""
        
        #ifdef BUTTON_PAUSE_ENABLED
        Print AT 15,10;REDEFINE_PAUSE
        keyArray(PAUSE_BUTTON) = LeerTecla()
        
            #ifdef BUTTON_QUIT_ENABLED
                Print AT 16,10;REDEFINE_QUIT
                keyArray(QUIT_BUTTON) = LeerTecla()
            #endif        
        #endif

        Print AT 19,2;GENERIC_ENTER_CONTINUE
        ' Do
        ' Loop Until MultiKeys(KEYENTER)
        pauseUntilPressEnter()
        
        showMenu()
    End Sub
#endif

#ifdef PASSWORD_ENABLED
    Sub passwordScreen()
        clearScreen()
        Print AT 10, 10; TEXT_PASSWORD
        
        dim pass(passwordLen) as ubyte
        For i=0 To passwordLen - 1
            ' While GetKeyScanCode(): Wend
            waitForReleaseKey()
            pass(i) = GetKey
            Print AT 12, 10 + i; chr(pass(i))
        Next i
        
        For i=0 To passwordLen - 1
            If pass(i) <> password(i) Then
                passwordScreen()
            End If
        Next i

        showMenu()
    End Sub
#endif

Sub playGame()
    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            #ifdef MUSIC_TITLE_ENABLED
                VortexTracker_Stop()
            #endif
        #endif
        
        #ifdef INTRO_SCREEN_ENABLED
            ' SetBank(DATA_BANK)
            ' dzx0Standard(INTRO_SCREEN_ADDRESS, $4000)
            ' SetBank(0)
            loadScreen(INTRO_SCREEN_ADDRESS)
            pauseUntilPressEnter()
        #endif
    #endif
    
    Ink INK_VALUE: Paper PAPER_VALUE: Border BORDER_VALUE
    
    #ifdef ARCADE_MODE
        currentScreen = 0
    #Else
        currentScreen = INITIAL_SCREEN
    #endif
    
    #ifndef PLAYER_READY_CONFIRMATION
        loadScreen(HUD_SCREEN_ADDRESS)
    #endif
    
    #ifdef ENABLED_128k
        ' SetBank(DATA_BANK)
        ' dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
        ' SetBank(0)

        #ifdef MUSIC_ENABLED
            VortexTracker_Play(MUSIC_ADDRESS)
        #endif
    #endif


    #ifndef ARCADE_MODE
        #ifdef LIVES_MODE_ENABLED
            protaXRespawn = INITIAL_MAIN_CHARACTER_X
            protaYRespawn = INITIAL_MAIN_CHARACTER_Y

            #ifdef CHECKPOINTS_ENABLED
                protaScreenRespawn = currentScreen
            #endif
        #endif    

        updateProtaData(INITIAL_MAIN_CHARACTER_Y, INITIAL_MAIN_CHARACTER_X, 1, 1)
    #endif
    
    resetValues()
    swapScreen(1)
    
    ' Let lastFrameProta = framec
    ' Let lastFrameEnemies = framec
    
    ' #ifdef NEW_BEEPER_PLAYER
    '     Let lastFrameBeep = framec
    ' #endif
    
    ' enemiesScreen = enemiesPerScreen(currentScreen)
    Do
        #ifdef BUTTON_PAUSE_ENABLED
        if MultiKeys(keyArray(PAUSE_BUTTON)) then
            isPaused = 1
            
            ' ActivarBuffer()
            ' switch2ShadowScreen()

            #ifdef ENABLED_128    
                #ifdef GAMEMAP_SCREEN_ENABLED
                    loadScreen(GAMEMAP_SCREEN_ADDRESS)

                    pathDraw()
                #else
                    #ifdef GAMEMAP_SHOW_ENABLED
                        mapColor(0)
                        pathDraw()
                    #endif
                #endif
            #else
                #ifdef GAMEMAP_SHOW_ENABLED
                    mapColor(0)
                    pathDraw()
                #endif
            #endif
            
            ' while GetKeyScanCode():wend
            waitForReleaseKey()

            while isPaused
                #ifndef GAMEMAP_SCREEN_ENABLED
                    #ifdef MESSAGES_ENABLED
                    if not messageLoopCounter then printMessage(TEXT_PAUSE, 2, 0)
                    #endif
                #endif

            
                if MultiKeys(keyArray(PAUSE_BUTTON)) then
                    isPaused = 0
                #ifdef BUTTON_QUIT_ENABLED
                else if MultiKeys(keyArray(QUIT_BUTTON)) then
                    showMenu()
                #endif
                end if
            wend

            ' while GetKeyScanCode():wend
            waitForReleaseKey()

            #ifndef GAMEMAP_SCREEN_ENABLED
                #ifdef MESSAGES_ENABLED
                    messageLoopCounter = 1
                #endif
            #endif

            ' DesactivarBuffer()
            ' switch2NormalScreen()
            #ifdef ENABLED_128    
                #ifdef GAMEMAP_SCREEN_ENABLED
                    loadScreen(HUD_SCREEN_ADDRESS)
                    mapDraw()

                    #ifdef HISCORE_ENABLED
                        Print AT 22, 13; TEXT_HI_SCORE_ZERO
                        Print AT 23, 13; TEXT_HI_SCORE_ZERO
                    #endif
                    printLife()
                #else
                    #ifdef GAMEMAP_SHOW_ENABLED
                        mapDraw()
                    #endif
                #endif
            #else
                #ifdef GAMEMAP_SHOW_ENABLED
                    mapDraw()
                #endif
            #endif
        end if
        #endif

        If not enemiesScreen Then 
            waitretrace
        end if

        #ifdef PLATFORM_MOVEABLE
            If not isOnPlatform and enemiesFrame band 1 Then
                protaFrame = getNextFrameRunning()
            End if
        #else
            If enemiesFrame band 1 Then
                protaFrame = getNextFrameRunning()
            End if
        #EndIf

        #ifdef ANIMATED_TILES_ENABLED
            lastFrameTiles = lastFrameTiles + 1
            If lastFrameTiles > ANIMATE_PERIOD_TILE Then
                lastFrameTiles = 0
                animatedFrame = Not animatedFrame

                For i=firstTileInScreen To ANIMATED_TILES_TOTAL
                    if i > ANIMATED_TILES_TOTAL or animatedTilesPerScreen(i, 0) <> currentScreen Then Exit for

                    #ifdef ANIMATED_ALL_HIDDEN    
                        Dim tile As Ubyte = animatedTilesPerScreen(i, 1)

                        tileMustHide = not tile band 1
                        if animatedFrame then
                            tileMustHide = tile band 1
                        end if
                        
                        if tileMustHide then
                            #ifdef SCREEN_ATTRIBUTES
                                SetTileAnimated(currentTileBackground, currentScreenBackground, animatedTilesPerScreen(i, 2), animatedTilesPerScreen(i, 3))
                            #else
                                SetTileAnimated(0, BACKGROUND_ATTRIBUTE, animatedTilesPerScreen(i, 2), animatedTilesPerScreen(i, 3))
                            #endif
                        else
                            SetTileAnimated(tile, tileAttrWithBackground(tile), animatedTilesPerScreen(i, 2), animatedTilesPerScreen(i, 3))
                        end if
                    #else
                        Dim tile As Ubyte = animatedTilesPerScreen(i, 1) + animatedFrame
                        #ifdef ANIMATED_SOLID_HIDDEN
                            tileMustHide = 0
                            if tile < ENEMY_DOOR_TILE then
                                tile = tile - animatedFrame

                                if animatedFrame then
                                    tileMustHide = tile band 1
                                else
                                    tileMustHide = not tile band 1
                                end if
                            end if

                            if tileMustHide then
                                #ifdef SCREEN_ATTRIBUTES
                                    SetTileAnimated(currentTileBackground, currentScreenBackground, animatedTilesPerScreen(i, 2), animatedTilesPerScreen(i, 3))
                                #else
                                    SetTileAnimated(0, BACKGROUND_ATTRIBUTE, animatedTilesPerScreen(i, 2), animatedTilesPerScreen(i, 3))
                                #endif
                            else
                                SetTileAnimated(tile, tileAttrWithBackground(tile), animatedTilesPerScreen(i, 2), animatedTilesPerScreen(i, 3))
                            end if
                        #else
                            SetTileAnimated(tile, tileAttrWithBackground(tile), animatedTilesPerScreen(i, 2), animatedTilesPerScreen(i, 3))
                        #endif
                    #endif
                Next i
            End If
        #endif

        If currentLife Then
            protaMovement()
            checkDamageByTile()
        End if

        ' moveEnemies()

        ' #ifdef SHOOTING_ENABLED
        '     moveBullet()
        ' #endif
        If moveScreen Then
            moveToScreen(moveScreen)
            ' enemiesScreen = enemiesPerScreen(currentScreen)
        else
            moveEnemies()

            #ifdef SHOOTING_ENABLED
                moveBullet()
            #endif

            drawSprites()
        End If
        
        If currentLife = 0 and not invincible Then gameOver()
        
        If invincible Then
            invincible = invincible - 1
            
            #ifdef BORDER_DAMAGE_COLOR
            if invincible < (INVINCIBLE_FRAMES - 5) Then Border BORDER_VALUE
            #endif

            if not currentLife Then 
                protaTile = 15
            #ifdef LIVES_MODE_GRAVEYARD
            Else
                #ifdef ENERGY_ENABLED
                if not currentEnergy and not invincible Then
                #Else
                if Not invincible Then
                #endif
                    jumpCurrentKey = jumpStopValue

                    #ifdef ENERGY_ENABLED
                    currentEnergy = INITIAL_ENERGY
                    #endif
                    updateProtaData(protaYRespawn, protaXRespawn, 1, protaDirection)
                    ' printLife()

                    #ifndef ARCADE_MODE
                        #ifdef CHECKPOINTS_ENABLED
                            currentScreen = protaScreenRespawn
                        #endif
                    #endif

                    swapScreen(1)   
                End if
            #endif
            End if
        End If
        
        #ifdef NEW_BEEPER_PLAYER
            BeepFX_NextNote()
        #endif
    Loop
End Sub

Sub ending()
    loadScreen(ENDING_SCREEN_ADDRESS)

    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            #ifdef MUSIC_ENDING_ENABLED
                VortexTracker_Play(MUSIC_ENDING_ADDRESS)
            #else
                VortexTracker_Stop()
            #endif
        #endif
    #endif

    pauseUntilPressEnter()
    showMenu()
End Sub

Sub gameOver()
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
            ' SetBank(DATA_BANK)
            ' dzx0Standard(GAMEOVER_SCREEN_ADDRESS, $4000)
            ' SetBank(0)
            loadScreen(GAMEOVER_SCREEN_ADDRESS)
        #Else
            'updateProtaData( protaY, protaX, 15, 0)
            protaTile = 15
            Print AT 7, 12; TEXT_GAME_OVER
        #endif
    #Else
        ' updateProtaData( protaY, protaX, 15, 0)
        protaTile = 15
        Print at 7, 12; TEXT_GAME_OVER
    #endif
    
    ' Do
    ' Loop Until MultiKeys(KEYENTER)
    pauseUntilPressEnter()
    showMenu()
End Sub

Sub resetValues()
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
        If ITEMS_COUNTDOWN Then
            currentItems = itemsToFind
        Else
            currentItems = 0
        End If
    #endif
    
    ' #ifdef LIVES_MODE_ENABLED
    '     protaXRespawn = INITIAL_MAIN_CHARACTER_X
    '     protaYRespawn = INITIAL_MAIN_CHARACTER_Y
    ' #endif
    
    ' removeScreenObjectFromBuffer()
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
End Sub

Sub swapScreen(waitReady as ubyte)
    dzx0Standard(MAPS_DATA_ADDRESS + screensOffsets(currentScreen), dmAddress)
    dzx0Standard(ENEMIES_DATA_ADDRESS + enemiesInScreenOffsets(currentScreen), arrayBasePtr(decompressedEnemiesScreen))
    
    enemiesScreen = enemiesPerScreen(currentScreen)

    if screensStatus(currentScreen) < SCREEN_STATUS_COMPLETED then screensStatus(currentScreen) = SCREEN_STATUS_VISITED
    
    ' #ifdef ENEMIES_RESPAWN_IN_SCREEN_ENABLED
        firstTimeEnemiesScreen = 1
    ' #endif

    #ifdef SHOOTING_ENABLED
        bulletPositionX = 0
    #endif

    ' #ifdef BULLET_ENEMIES
    '     enemyBulletPositionX = 0
    ' #endif
    
    #ifdef ARCADE_MODE
        countItemsOnTheScreen()
        updateProtaData( mainCharactersArray(currentScreen, 1), mainCharactersArray(currentScreen, 0), 1, 1)
        
        #ifdef LIVES_MODE_ENABLED
            protaXRespawn = mainCharactersArray(currentScreen, 0)
            protaYRespawn = mainCharactersArray(currentScreen, 1)
        #endif
    #endif

     #ifdef IN_GAME_TEXT_ENABLED
        'esto es para agilizar la busqueda de textos
        for texto=0 to AVAILABLE_ADVENTURES
            if textsCoord(texto, 0) = currentScreen Then 
                currentScreenFirstText = texto
                Exit for
            end if
        next texto
    #endif

    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            dim newScreenMusic as ubyte = screenMusic(currentScreen)
            if newScreenMusic <> 0  and newScreenMusic <> musicPlayed Then
                musicPlayed = newScreenMusic
                
                #ifdef NO_MUSIC_SELECTED
                    if newScreenMusic = 10 Then VortexTracker_Stop()
                #endif
                
                #ifdef MUSIC_1_SELECTED
                    if newScreenMusic = 1 Then VortexTracker_Play(MUSIC_ADDRESS)
                #endif
                #ifdef MUSIC_2_SELECTED
                    #ifdef MUSIC_2_ENABLED
                        if newScreenMusic = 2 Then VortexTracker_Play(MUSIC_2_ADDRESS)
                    #endif
                #endif
                #ifdef MUSIC_3_SELECTED
                    #ifdef MUSIC_3_ENABLED
                        if newScreenMusic = 3 Then VortexTracker_Play(MUSIC_3_ADDRESS)
                    #endif
                #endif
                #ifdef MUSIC_4_SELECTED
                    #ifdef MUSIC_TITLE_ENABLED
                        if newScreenMusic = 4 Then VortexTracker_Play(MUSIC_TITLE_ADDRESS)
                    #endif
                #endif
                #ifdef MUSIC_5_SELECTED
                    #ifdef MUSIC_ENDING_ENABLED
                        if newScreenMusic = 5 Then VortexTracker_Play(MUSIC_ENDING_ADDRESS)
                    #endif
                #endif
                #ifdef MUSIC_6_SELECTED
                    #ifdef MUSIC_GAMEOVER_ENABLED
                        if newScreenMusic = 6 Then VortexTracker_Play(MUSIC_GAMEOVER_ADDRESS)
                    #endif
                #endif
            End if
        #endif
    #endif
    
    #ifdef SCREEN_ATTRIBUTES
        currentScreenBackground = screenAttributes(currentScreen, 0)
        currentTileBackground = screenAttributes(currentScreen, 1)
        #ifdef TELEPORT_ENABLED
            currentTeleportTo = screenAttributes(currentScreen, 2)
        #endif
    #endif

    #ifdef PLAYER_READY_CONFIRMATION
        if waitReady Then
            loadScreen(HUD_SCREEN_ADDRESS)
            
            #ifdef HISCORE_ENABLED
                Print AT 22, 13; TEXT_HI_SCORE_ZERO
                Print AT 23, 13; TEXT_HI_SCORE_ZERO
            #endif
            
            printLife()

            #ifdef ADVENTURE_TEXTS_CONFIRM_FIRE
                pauseUntilPressFire()
            #else
                pauseUntilPressEnter()
            #endif
        end if 
    #else
        #ifdef HISCORE_ENABLED
            Print AT 22, 13; TEXT_HI_SCORE_ZERO
            Print AT 23, 13; TEXT_HI_SCORE_ZERO
        #endif
        
        printLife()
    #endif

    asm
    call CLEAR_SCREEN
    end asm

    #ifdef FULL_SCREEN_CHANGE_ANIMATION
        #ifdef SCREEN_ATTRIBUTES
            FillWithTile(currentTileBackground, screenWidth, screenHeight, currentScreenBackground, SKIP_WIDTH_SIZE, SKIP_HEIGHT_SIZE)
        #else
            FillWithTile(0, screenWidth, screenHeight, BACKGROUND_ATTRIBUTE, SKIP_WIDTH_SIZE, SKIP_HEIGHT_SIZE)
        #endif
    #endif

    mapDraw()    
End Sub