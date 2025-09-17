Sub clearScreen()
    Ink 7: Paper 0: Border 0: BRIGHT 0: FLASH 0: Cls
end sub

Sub showMenu()
    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            VortexTracker_Stop()
        #endif
    #endif
    inMenu = 1
    clearScreen()

    #ifdef ENABLED_128k
        ' PaginarMemoria(DATA_BANK)
        ' dzx0Standard(TITLE_SCREEN_ADDRESS, $4000)
        ' PaginarMemoria(0)
        loadScreen128(TITLE_SCREEN_ADDRESS)
        #ifdef MUSIC_ENABLED
            #ifdef MUSIC_TITLE_ENABLED
                VortexTracker_Play(MUSIC_TITLE_ADDRESS)
            #endif
        #endif
    #Else
        dzx0Standard(TITLE_SCREEN_ADDRESS, $4000)
    #endif
    
    #ifdef HISCORE_ENABLED
        Print AT 0, 22; "HI:"
        Print AT 0, 26; hiScore
    #endif
    
    kempston = 0
    Do
        If MultiKeys(KEY1) Then
            If Not keyArray(LEFT) Then
                Let keyArray(LEFT) = KEYO
                Let keyArray(RIGHT) = KEYP
                Let keyArray(UP) = KEYQ
                Let keyArray(DOWN) = KEYA
                Let keyArray(FIRE) = KEYSPACE
            End If

            playGame()
        elseif MultiKeys(KEY2) Then
            kempston = 1
            playGame()
        elseif MultiKeys(KEY3) Then
            Let keyArray(LEFT)=KEY6
            Let keyArray(RIGHT)=KEY7
            Let keyArray(UP)=KEY9
            Let keyArray(DOWN)=KEY8
            Let keyArray(FIRE)=KEY0
            
            playGame()
            #ifdef REDEFINE_KEYS_ENABLED
            elseif MultiKeys(KEY4) Then
                redefineKeys()
            #endif
        End If
    Loop
End Sub



#ifdef REDEFINE_KEYS_ENABLED
    Function LeerTecla() As Uinteger
        Do Loop While GetKeyScanCode()
        Do Loop Until GetKeyScanCode()
        Return GetKeyScanCode()
    End Function
    
    Sub redefineKeys()
        clearScreen()
        
        #ifdef MUSIC_ENABLED
            #ifdef MUSIC_TITLE_ENABLED
                ' VortexTracker_Stop()
            #endif
        #endif
        
        Print AT 5,5;"Press key For:";
        
        Print AT 8,10;"Left"
        keyArray(LEFT) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 8,20; keyOption
        
        Print AT 10,10;"Right"
        keyArray(RIGHT) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 10,20; keyOption
        
        Print AT 12,10;"Up"
        keyArray(UP) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 12,20; keyOption
        
        Print AT 14,10;"Down"
        keyArray(DOWN) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 14,20; keyOption
        
        Print AT 16,10;"Fire"
        keyArray(FIRE) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 16,20; keyOption
        '
        ' keyOption = ""
        
        Print AT 20,2;"Enter To Continue..."
        ' Do
        ' Loop Until MultiKeys(KEYENTER)
        pauseUntilPressEnter()
        
        showMenu()
    End Sub
#endif

#ifdef PASSWORD_ENABLED
    Sub passwordScreen()
        clearScreen()
        Print AT 10, 10; "PASSWORD"
        
        dim pass(passwordLen) as ubyte
        For i=0 To passwordLen - 1
            While GetKeyScanCode()
            Wend
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
    inMenu = 0
    
    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            #ifdef MUSIC_TITLE_ENABLED
                VortexTracker_Stop()
            #endif
        #endif
        
        #ifdef INTRO_SCREEN_ENABLED
            ' PaginarMemoria(DATA_BANK)
            ' dzx0Standard(INTRO_SCREEN_ADDRESS, $4000)
            ' PaginarMemoria(0)
            loadScreen128(INTRO_SCREEN_ADDRESS)
            pauseUntilPressEnter()
        #endif
    #endif
    
    Ink INK_VALUE: Paper PAPER_VALUE: Border BORDER_VALUE
    
    #ifdef ARCADE_MODE
        currentScreen = 0
    #Else
        currentScreen = INITIAL_SCREEN
    #endif
    
    #ifdef ENABLED_128k
        ' PaginarMemoria(DATA_BANK)
        ' dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
        ' PaginarMemoria(0)
        #ifndef PLAYER_READY_CONFIRMATION
            loadScreen128(HUD_SCREEN_ADDRESS)
        #endif

        #ifdef MUSIC_ENABLED
            VortexTracker_Play(MUSIC_ADDRESS)
        #endif
    #Else
        #ifndef PLAYER_READY_CONFIRMATION
            dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
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
    #ifdef ANIMATED_TILES_ENABLED
        lastFrameTiles = 0
    #endif
    
    ' #ifdef NEW_BEEPER_PLAYER
    '     Let lastFrameBeep = framec
    ' #endif
    
    ' enemiesScreen = enemiesPerScreen(currentScreen)

    Do
        waitretrace
        
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
                    Dim tile As Ubyte = animatedTilesPerScreen(i, 1) + animatedFrame
                    'SetTile(tile, attrSet(tile), animatedTilesPerScreen(i, 2), animatedTilesPerScreen(i, 3))
                    SetTileAnimated(tile, attrSet(tile), animatedTilesPerScreen(i, 2), animatedTilesPerScreen(i, 3))
                Next i
            End If
        #endif

        If currentLife Then
            protaMovement()
            checkDamageByTile()
        End if

        moveEnemies()

        #ifdef SHOOTING_ENABLED
            moveBullet()
        #endif
        
        #ifdef BULLET_ENEMIES
            moveEnemyBullet()
        #endif

        #ifdef SHOOTING_ENABLED
            #ifdef BULLET_ENEMIES
                #ifdef BULLET_COLLIDE_BULLET
                    checkBulletsCollision() 
                #endif
            #endif
        #endif

        drawSprites()

        If moveScreen <> 0 Then
            moveToScreen(moveScreen)
            ' enemiesScreen = enemiesPerScreen(currentScreen)
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
    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            #ifdef MUSIC_ENDING_ENABLED
                VortexTracker_Play(MUSIC_ENDING_ADDRESS)
            #else
                VortexTracker_Stop()
            #endif
        #endif

        ' PaginarMemoria(DATA_BANK)
        ' dzx0Standard(ENDING_SCREEN_ADDRESS, $4000)
        ' PaginarMemoria(0)
        loadScreen128(ENDING_SCREEN_ADDRESS)
    #Else
        dzx0Standard(ENDING_SCREEN_ADDRESS, $4000)
    #endif
    ' Do
    ' Loop Until MultiKeys(KEYENTER)
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
            ' PaginarMemoria(DATA_BANK)
            ' dzx0Standard(GAMEOVER_SCREEN_ADDRESS, $4000)
            ' PaginarMemoria(0)
            loadScreen128(GAMEOVER_SCREEN_ADDRESS)
        #Else
            'updateProtaData( protaY, protaX, 15, 0)
            protaTile = 15
            Print AT 7, 12; "GAME OVER"
        #endif
    #Else
        ' updateProtaData( protaY, protaX, 15, 0)
        protaTile = 15
        Print at 7, 12; "GAME OVER"
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
        screensWon(i) = 0
    Next i
    #ifdef USE_BREAKABLE_TILE
        For i = 0 To SCREENS_COUNT
            brokenTiles(i) = 0
        Next i
    #endif
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
    dzx0Standard(MAPS_DATA_ADDRESS + screensOffsets(currentScreen), @decompressedMap)
    dzx0Standard(ENEMIES_DATA_ADDRESS + enemiesInScreenOffsets(currentScreen), @decompressedEnemiesScreen)
    
    enemiesScreen = enemiesPerScreen(currentScreen)
    
    #ifdef ENEMIES_RESPAWN_IN_SCREEN_ENABLED
        firstTimeEnemiesScreen = 1
    #endif

    #ifdef SHOOTING_ENABLED
        bulletPositionX = 0
    #endif

    #ifdef BULLET_ENEMIES
        enemyBulletPositionX = 0
    #endif
    
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
    #endif

    #ifdef PLAYER_READY_CONFIRMATION
        if waitReady Then
            #ifdef ENABLED_128k
                loadScreen128(HUD_SCREEN_ADDRESS)
            #else
                dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
            #endif

            #ifdef HISCORE_ENABLED
                Print AT 22, 20; "00000"
                Print AT 23, 20; "00000"
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
            Print AT 22, 20; "00000"
            Print AT 23, 20; "00000"
        #endif
        
        printLife()
    #endif

    asm
    call CLEAR_SCREEN
    end asm

    #ifdef FULL_SCREEN_CHANGE_ANIMATION
        #ifdef SCREEN_ATTRIBUTES
            FillWithTile(currentTileBackground, 32, 22, currentScreenBackground, 0, 0)
        #else
            FillWithTile(0, 32, 22, BACKGROUND_ATTRIBUTE, 0, 0)
        #endif
    #endif

    mapDraw()
End Sub