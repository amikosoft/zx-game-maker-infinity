Sub clearScreen()
    'Ink 7: Paper 0: Border 0: BRIGHT 0: FLASH 0: Cls

    Ink INK_VALUE: Paper PAPER_VALUE: Border BORDER_VALUE: BRIGHT 0: FLASH 0: Cls
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
    Ink INK_VALUE: Paper PAPER_VALUE: Border BORDER_VALUE: BRIGHT BRIGHT_VALUE: FLASH 0
    loadScreen(TITLE_SCREEN_ADDRESS)
        
    #ifdef ENABLED_128k
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
    
    #ifndef CONSOLE_MODE
        kempston = 0
    #endif

    Do
        #ifdef CONSOLE_MODE
            If MultiKeys(KEYSPACE) Then
                waitForReleaseKey()
                playGame()
            #ifdef ENABLED_128k
                #ifdef MUSIC_ENABLED
                    #ifdef MUSIC_TOGGLE_ENABLED
                        elseif MultiKeys(KEYQ) Then
                            toggleMusic()
                            waitForReleaseKey()
                    #endif
                #endif
            #endif
            End if
        #else
            If MultiKeys(KEY1) Then
            ' If Not keyArray(LEFT) Then
            '     keyArray(LEFT) = KEYO
            '     keyArray(RIGHT) = KEYP
            '     keyArray(UP) = KEYQ
            '     keyArray(DOWN) = KEYA
            '     keyArray(FIRE) = KEYSPACE
            ' End If

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
        #endif
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
        #ifdef REDEFINE_SCREEN_ENABLED
            loadScreen(REDEFINE_SCREEN_ADDRESS)

            keyArray(LEFT) = LeerTecla()
            Print AT 6,20;REDEFINE_X

            keyArray(RIGHT) = LeerTecla()
            Print AT 8,20;REDEFINE_X

            keyArray(UP) = LeerTecla()
            Print AT 10,20;REDEFINE_X

            keyArray(DOWN) = LeerTecla()
            Print AT 12,20;REDEFINE_X

            keyArray(FIRE) = LeerTecla()
            Print AT 14,20;REDEFINE_X

            #ifdef BUTTON_PAUSE_ENABLED
                keyArray(PAUSE_BUTTON) = LeerTecla()
                Print AT 16,20;REDEFINE_X

                #ifdef BUTTON_QUIT_ENABLED
                    keyArray(QUIT_BUTTON) = LeerTecla()
                    Print AT 18,20;REDEFINE_X
                #endif        
            #endif
        #else
            'clearScreen()
            Ink INK_VALUE: Paper PAPER_VALUE: Border BORDER_VALUE: BRIGHT BRIGHT_VALUE: FLASH 0: Cls
            
            Print AT 7,5;REDEFINE_PRESS_KEY_FOR

            Print AT 9,10;REDEFINE_LEFT
            keyArray(LEFT) = LeerTecla()

            Print AT 10,10;REDEFINE_RIGHT
            keyArray(RIGHT) = LeerTecla()
            
            Print AT 11,10;REDEFINE_UP
            keyArray(UP) = LeerTecla()
            
            Print AT 12,10;REDEFINE_DOWN
            keyArray(DOWN) = LeerTecla()
            
            Print AT 13,10;REDEFINE_FIRE
            keyArray(FIRE) = LeerTecla()

            #ifdef BUTTON_PAUSE_ENABLED
                Print AT 15,10;REDEFINE_PAUSE
                keyArray(PAUSE_BUTTON) = LeerTecla()
                
                #ifdef BUTTON_QUIT_ENABLED
                    Print AT 16,10;REDEFINE_QUIT
                    keyArray(QUIT_BUTTON) = LeerTecla()
                #endif        
            #endif
        
        #endif
        
        Print AT 21,10;GENERIC_ENTER_CONTINUE

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
        
        #ifdef INSTRUCTIONS_SCREEN_ENABLED
            loadScreen(INSTRUCTIONS_SCREEN_ADDRESS)
            pauseUntilPressKey()
        #endif
        
        #ifdef INTRO_SCREEN_ENABLED
            ' SetBank(DATA_BANK)
            ' dzx0Standard(INTRO_SCREEN_ADDRESS, $4000)
            ' SetBank(gameBank)
            loadScreen(INTRO_SCREEN_ADDRESS)
            pauseUntilPressKey()
        #endif
    #endif
    
    #ifdef ARCADE_MODE
        currentScreen = 0
    #Else
        currentScreen = INITIAL_SCREEN
    #endif
    
    #ifndef PLAYER_READY_CONFIRMATION
        #ifdef HUD2_SCREEN_ENABLED
            #ifdef SCREEN_HUD2_ENABLED
                loadHUDScreen()
            #Else
                loadScreen(HUD_SCREEN_ADDRESS)
            #EndIf
        #Else
            loadScreen(HUD_SCREEN_ADDRESS)
        #endif
    #endif
    
    #ifdef ENABLED_128k
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
    
    #include "functionsBas/resetValues.bas"
    swapScreen(1)
    
    ' Let lastFrameProta = framec
    ' Let lastFrameEnemies = framec
    
    ' #ifdef NEW_BEEPER_PLAYER
    '     Let lastFrameBeep = framec
    ' #endif
    
    ' enemiesScreen = enemiesPerScreen(currentScreen)
    Do
        #ifdef MULTICOLOR_ENABLED
            multicolorCurrent = multicolorCurrent + 1
            if multicolorCurrent > 7 then multicolorCurrent = 1

            #ifdef ITEMS_MULTICOLOR_ENABLED
                If multicolorItem(0) Then
                    SetTileColor(multicolorItem(0), multicolorItem(1), attrWithBackground(multicolorCurrent))
                end if
            #endif
        #endif

        #ifdef BUTTON_PAUSE_ENABLED
        if MultiKeys(keyArray(PAUSE_BUTTON)) then
            isPaused = 1

            #ifdef GAMEMAP_SCREEN_ENABLED
                loadScreen(GAMEMAP_SCREEN_ADDRESS)

                #ifdef GAMEMAP_SHOW_ENABLED
                    pathDraw()
                #endif
            #else
                #ifdef GAMEMAP_SHOW_ENABLED
                    mapColor(0)
                    pathDraw()
                #endif
            #endif
        
            waitForReleaseKey()

            while isPaused > 0
                #ifndef GAMEMAP_SCREEN_ENABLED
                    #ifdef MESSAGES_ENABLED
                    if not messageLoopCounter then printMessage(TEXT_PAUSE, 2, 0)
                    #endif
                #endif
            
                if MultiKeys(keyArray(PAUSE_BUTTON)) then
                    #ifdef CONSOLE_MODE
                        isPaused = isPaused + 1
                        if isPaused > 200 then 
                            showMenu()
                        end if
                    #else
                        isPaused = 0
                    #endif
                #ifdef BUTTON_QUIT_ENABLED
                    else if MultiKeys(keyArray(QUIT_BUTTON)) then
                        showMenu()
                    #endif
                #ifdef CONSOLE_MODE
                    else if MultiKeys(KEYSPACE) then
                        isPaused = 0
                    else
                        isPaused = 1
                #EndIf
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
            #ifdef GAMEMAP_SCREEN_ENABLED
                'loadScreen(HUD_SCREEN_ADDRESS)
                #ifdef HUD2_SCREEN_ENABLED
                    #ifdef SCREEN_HUD2_ENABLED
                        loadHUDScreen()
                    #Else
                        loadScreen(HUD_SCREEN_ADDRESS)
                    #EndIf
                #Else
                    loadScreen(HUD_SCREEN_ADDRESS)
                #endif

                ' #ifdef HISCORE_ENABLED
                '     Ink INK_VALUE: Paper PAPER_VALUE: BRIGHT BRIGHT_VALUE: FLASH 0
                '     Print AT 22, 13; TEXT_HI_SCORE_ZERO
                '     Print AT 23, 13; TEXT_HI_SCORE_ZERO
                ' #endif
                ' printHud()

                mapDraw(1)
            #else
                #ifdef GAMEMAP_SHOW_ENABLED
                    Ink INK_VALUE: Paper PAPER_VALUE: BRIGHT BRIGHT_VALUE: FLASH 0
                    mapDraw(0)
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

        protaMovement()
        
        #ifdef MESSAGES_ENABLED
            ' checkMessageForDelete()
            if messageLoopCounter Then
                messageLoopCounter = messageLoopCounter - 1
                If not messageLoopCounter Then
                    PRINT AT 21, 11; TEXT_EMPTY_STRING
                End If
            End if
        #endif

        If moveScreen Then
            moveToScreen(moveScreen)
        else
            ' #ifdef ENERGY_ENABLED
            '     if currentEnergy then moveEnemies()
            ' #else
            '     moveEnemies()
            ' #endif
            moveEnemies()

            #ifdef SHOOTING_ENABLED
                moveBullet()
            #endif
        End If
        
        If currentLife = 0 and not invincible Then
            #include "functionsBas/gameOver.bas"
        end if
        
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
                if not currentEnergy then
                    protaTile = 15
                #endif
                    if Not invincible Then
                        jumpCurrentKey = jumpStopValue

                        #ifdef ENERGY_ENABLED
                        currentEnergy = INITIAL_ENERGY
                        #endif
                        updateProtaData(protaYRespawn, protaXRespawn, 1, protaDirection)

                        #ifndef ARCADE_MODE
                            #ifdef CHECKPOINTS_ENABLED
                                currentScreen = protaScreenRespawn
                            #endif
                        #endif

                        swapScreen(1)
                    else
                        protaTile = 15 
                    End if
                #ifdef ENERGY_ENABLED
                    End if
                #endif
            #endif
            End if
        End If
        
        'drawSprites()
        #include "functionsBas/drawSprites.bas"

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

Sub swapScreen(waitReady as ubyte)
    ' #ifdef HUD2_SCREEN_ENABLED
    '     #ifdef SCREEN_HUD2_ENABLED
    dim mustPrintHud as ubyte = 0
    '     #endif
    ' #endif

    dim offsetTmp as uinteger = screensOffsets(currentScreen)

    SetBank(fxBank)
    dzx0Standard(MAPS_DATA_ADDRESS + offsetTmp, arrayBasePtr(decompressedMap))
    SetBank(gameBank)

    dzx0Standard(ENEMIES_DATA_ADDRESS + enemiesInScreenOffsets(currentScreen), arrayBasePtr(decompressedEnemiesScreen))

    enemiesScreen = enemiesPerScreen(currentScreen)

    if screensStatus(currentScreen) < SCREEN_STATUS_COMPLETED then screensStatus(currentScreen) = SCREEN_STATUS_VISITED

    ' #ifdef ENEMIES_RESPAWN_IN_SCREEN_ENABLED
        firstTimeEnemiesScreen = 1
    ' #endif

    #ifdef SHOOTING_ENABLED
        bulletPositionX = 0

        #ifdef PREVENT_JUMP_ON_FIRE
            shootPressed = 0
        #endif
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

    #ifdef SCREEN_ATTRIBUTES
        #ifdef SCREEN_BACKGROUND_ENABLED
            currentScreenBackground = screenAttributes(currentScreen, SCREEN_BACKGROUND)
        #else
            currentScreenBackground = BACKGROUND_ATTRIBUTE
        #endif

        #ifdef SCREEN_TILE_ENABLED
            currentTileBackground = screenAttributes(currentScreen, SCREEN_TILE)
        #else
            currentTileBackground = 0
        #endif
        
        #ifdef SCREEN_TELEPORTTO_ENABLED
            currentTeleportTo = screenAttributes(currentScreen, SCREEN_TELEPORTTO)
        #endif

        #ifdef SCREEN_DARK_ENABLED
            screenIsDark = screenAttributes(currentScreen, SCREEN_DARK)
        #endif

        #ifdef SCREEN_CENITAL_ENABLED
            screenIsTerrain = screenAttributes(currentScreen, SCREEN_CENITAL)
        #endif

        #ifdef HUD2_SCREEN_ENABLED
            #ifdef SCREEN_HUD2_ENABLED
                screenHud = screenAttributes(currentScreen, SCREEN_HUD2)
            #endif
        #endif

        #ifdef ENABLED_128k
            #ifdef MUSIC_ENABLED
                #ifdef SCREEN_MUSIC_ENABLED
                    dim newScreenMusic as ubyte = screenAttributes(currentScreen, SCREEN_MUSIC)

                    if newScreenMusic <> 0 and newScreenMusic <> musicPlayed Then
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
        #endif
    #endif

    #ifdef PLAYER_READY_CONFIRMATION
        if waitReady Then
            mustPrintHud = 1
            #ifdef HUD2_SCREEN_ENABLED
                #ifdef SCREEN_HUD2_ENABLED
                    loadHUDScreen()
                #Else
                    loadScreen(HUD_SCREEN_ADDRESS)
                #EndIf
            #Else
                loadScreen(HUD_SCREEN_ADDRESS)
            #endif
        #ifdef HUD2_SCREEN_ENABLED
            #ifdef SCREEN_HUD2_ENABLED
            else if currentHud <> screenHud then
                loadHUDScreen()
                mustPrintHud = 1
            #endif
        #endif
        end if
    #else
        #ifdef HUD2_SCREEN_ENABLED
            #ifdef SCREEN_HUD2_ENABLED
            if currentHud <> screenHud then 
                loadHUDScreen()
                mustPrintHud = 1
            end if
            #endif
        #endif
    #endif

    if mustPrintHud then 
        #ifdef HISCORE_ENABLED
            Print AT 22, 13; TEXT_HI_SCORE_ZERO
            Print AT 23, 13; TEXT_HI_SCORE_ZERO
        #endif
        
        printHud()
    end if

    #ifdef SCREEN_BOSSENERGY_ENABLED
        bossTotalEnergy = screenAttributes(currentScreen, SCREEN_BOSSENERGY)
        bossCurEnergy = bossTotalEnergy

        #ifdef HUD_SHOW_BOSS_MESSAGE
            if bossTotalEnergy > 0 then
                if screensStatus(currentScreen) = SCREEN_STATUS_COMPLETED then
                    enemiesScreen = 0
                Else
                    printMessage(TEXT_BOSS, 2, 0)
                end if
            end if
        #else
            if bossTotalEnergy > 0 and screensStatus(currentScreen) = SCREEN_STATUS_COMPLETED then
                enemiesScreen = 0
            end if
        #endif
    #endif
    
    if waitReady then 
        #ifdef PERMANENT_MOVEMENT_ENABLED
            verticalAxisKeyPressed = 0
            horizontalAxisKeyPressed = 1
        #endif

        #ifdef PLAYER_READY_CONFIRMATION
            #ifdef ADVENTURE_TEXTS_CONFIRM_FIRE
                pauseUntilPressFire()
            #else
                pauseUntilPressEnter()
            #endif
        #endif
    end if

    'printHud()

    asm
    call CLEAR_SCREEN
    end asm

    ' #ifdef FULL_SCREEN_CHANGE_ANIMATION
    '     #ifdef SCREEN_ATTRIBUTES
    '         FillWithTile(currentTileBackground, screenWidth, screenHeight, currentScreenBackground, SKIP_WIDTH_SIZE, SKIP_HEIGHT_SIZE)
    '     #else
    '         FillWithTile(0, screenWidth, screenHeight, BACKGROUND_ATTRIBUTE, SKIP_WIDTH_SIZE, SKIP_HEIGHT_SIZE)
    '     #endif
    ' #endif

    mapDraw(0)    
End Sub