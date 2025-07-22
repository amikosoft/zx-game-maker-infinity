Sub mapDraw(force As Ubyte)
    Dim index As Uinteger
    Dim y, x As Ubyte
    
    x = 0
    y = 0
    
    For index=0 To SCREEN_LENGTH
        drawTile(Peek(@decompressedMap + index) - 1, x, y, force)
        
        x = x + 1
        If x = screenWidth Then
            x = 0
            y = y + 1
        End If
    Next index
    
    #ifdef IN_GAME_TEXT_ENABLED
        #ifdef IS_TEXT_ADVENTURE
            #ifdef ADVENTURE_TEXTS_HIDE_TILES
                for texto=currentScreenFirstText to AVAILABLE_ADVENTURES
                    if textsCoord(texto, 0) <> currentScreen Then exit for
                    dim cordX as ubyte = textsCoord(texto, 1) >> 1
                    dim cordY as ubyte = textsCoord(texto, 2) >> 1
                    
                    if GetTile(cordX, cordY) Then
                        dim textState as ubyte = textsCoord(texto, 5)
                        if textState and textState <> currentAdventureState Then
                            SetTileChecked(0, BACKGROUND_ATTRIBUTE, cordX, cordY)
                        End if
                    End if
                Next texto
            #endif
        #endif
    #endif
End Sub

Sub drawTile(tile As Ubyte, x As Ubyte, y As Ubyte,force As Ubyte)
    if force then SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
    If tile < 1 Then Return
    
    #ifdef SHOULD_KILL_ENEMIES_ENABLED
        If tile = ENEMY_DOOR_TILE Then
            If screensWon(currentScreen) Then
                SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
            Else
                SetTile(tile, attrSet(tile), x, y)
            End If
            Return
        End If
    #Else
        If tile = ENEMY_DOOR_TILE Then
            SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
            Return
        End If
    #endif
    
    #ifdef USE_BREAKABLE_TILE
        If tile = 62 Then
            If brokenTiles(currentScreen) Then
                SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
            Else
                SetTileChecked(tile, attrSet(tile), x, y)
            End If
            Return
        End If
    #endif
    
    If tile < MAX_GENERIC_TILE Then
        SetTile(tile, attrSet(tile), x, y)
        Return
    End If
    
    ' if force then SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
    
    If tile = ITEM_TILE Then
        If screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX) Then
            SetTileChecked(tile, attrSet(tile), x, y)
        End If
    Elseif tile = KEY_TILE
        #ifdef ARCADE_MODE
            currentScreenKeyX = x
            currentScreenKeyY = y
        #Else
            If screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) Then
                SetTileChecked(tile, attrSet(tile), x, y)
            End If
        #endif
        #ifdef KEYS_ENABLED
        Elseif tile = DOOR_TILE
            If screenObjects(currentScreen, SCREEN_OBJECT_DOOR_INDEX) Then
                SetTile(tile, attrSet(tile), x, y)
            End If
        #endif
    Elseif tile = LIFE_TILE
        If screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) Then
            SetTileChecked(tile, attrSet(tile), x, y)
        End If
    Elseif tile = AMMO_TILE
        If screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX) Then
            SetTileChecked(tile, attrSet(tile), x, y)
        End If
    End If
End Sub

#ifdef ARCADE_MODE
    Sub drawKey()
        SetTile(KEY_TILE, attrSet(KEY_TILE), currentScreenKeyX, currentScreenKeyY)
    End Sub
#endif

Sub redrawScreen()
    ' memset(22527,0,768)
    ' CancelOps()
    ClearScreen(7, 0, 0) ' Modified For only cancelops And no clear Screen
    ' dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
    FillWithTile(0, 32, 22, BACKGROUND_ATTRIBUTE, 0, 0)
    ' clearBox(0,0,120,112)
    mapDraw(0)
    printLife()
    ' enemiesDraw(currentScreen)
End Sub

#ifdef KEYS_ENABLED
    Function checkTileIsDoor(col As Ubyte, lin As Ubyte) As Ubyte
        If GetTile(col, lin) = DOOR_TILE Then
            If currentKeys <> 0 Then
                currentKeys = currentKeys - 1
                
                #ifdef LEVELS_MODE
                    moveScreen = 2
                #Else
                    screenObjects(currentScreen, SCREEN_OBJECT_DOOR_INDEX) = 0
                    removeTilesFromScreen(DOOR_TILE)
                #endif
                
                printLife()
                BeepFX_Play(4)
                #ifdef MESSAGES_ENABLED
                Else
                    printMessage("Need keys", 2, 0)
                #endif
            End If
            Return 1
        End If
        
        Return 0
    End Function
    
    Function CheckDoor(x As Ubyte, y As Ubyte) As Ubyte
        Dim col as uByte = x >> 1
        Dim lin as uByte = y >> 1
        
        Dim maxCol as uByte = 1
        Dim maxLin as uByte = 1
        
        if (x bAnd 1) <> 0 Then maxCol = 2
        if (y bAnd 1) <> 0 Then maxLin = 2
        
        for c=0 to maxCol
            for l=0 to maxLin
                if checkTileIsDoor(col+c, lin+l) then return 1
            next l
        next c
        
        return 0
        ' Dim xIsEven As Ubyte = (x bAnd 1) = 0
        ' Dim yIsEven As Ubyte = (y bAnd 1) = 0
        ' Dim col As Ubyte = x >> 1
        ' Dim lin As Ubyte = y >> 1
        
        ' If xIsEven Then
        '     if yIsEven Then
        '         Return checkTileIsDoor(col, lin) Or checkTileIsDoor(col + 1, lin) _
        '         Or checkTileIsDoor(col, lin + 1) Or checkTileIsDoor(col + 1, lin + 1)
        '     Else
        '         Return checkTileIsDoor(col, lin) Or checkTileIsDoor(col + 1, lin) _
        '         Or checkTileIsDoor(col, lin + 1) Or checkTileIsDoor(col + 1, lin + 1) _
        '         Or checkTileIsDoor(col, lin + 2) Or checkTileIsDoor(col + 1, lin + 2)
        '     End if
        ' Else
        '     if yIsEven Then
        '         Return checkTileIsDoor(col, lin) Or checkTileIsDoor(col + 1, lin) Or checkTileIsDoor(col + 2, lin) _
        '         Or checkTileIsDoor(col, lin + 1) Or checkTileIsDoor(col + 1, lin + 1) Or checkTileIsDoor(col + 2, lin + 1)
        '     Else
        '         Return checkTileIsDoor(col, lin) Or checkTileIsDoor(col + 1, lin) Or checkTileIsDoor(col + 2, lin) _
        '         Or checkTileIsDoor(col, lisn + 1) Or checkTileIsDoor(col + 1, lin + 1) Or checkTileIsDoor(col + 2, lin + 1) _
        '         Or checkTileIsDoor(col, lin + 2) Or checkTileIsDoor(col + 1, lin + 2) Or checkTileIsDoor(col + 2, lin + 2)
        '     End If
        ' End If
    End Function
#endif

Sub moveToScreen(direction As Ubyte)
    ' removeAllObjects()
    If direction = 6 Then
        'saveSprite( protaY, 0 + SCREEN_ADJUSTMENT, protaTile, protaDirection)
        protaX = 0 + SCREEN_ADJUSTMENT
        currentScreen = currentScreen + 1
        
        #ifdef LIVES_MODE_ENABLED
            #ifndef CHECKPOINTS_ENABLED
                protaXRespawn = 0 + SCREEN_ADJUSTMENT
                protaYRespawn = protaY
            #endif
        #endif
    Elseif direction = 4 Then
        'saveSprite( protaY, 60 - SCREEN_ADJUSTMENT, protaTile, protaDirection)
        protaX = 60 - SCREEN_ADJUSTMENT
        currentScreen = currentScreen - 1
        
        ' #ifdef LIVES_MODE_ENABLED
        '     protaXRespawn = protaX
        '     protaYRespawn = protaY
        ' #endif
    Elseif direction = 2 Then
        #ifdef LEVELS_MODE
            currentLevel = currentLevel + 1
            if currentLevel > (SCREENS_COUNT/MAP_SCREENS_WIDTH_COUNT) then
                moveScreen = 0
                ending()
            Else
                Print AT 13,8;"LEVEL COMPLETE!!!"
                Print AT 15,8;"PRESS ENTER..."
                'Do
                'Loop Until MultiKeys(KEYENTER)
                pauseUntilPressEnter()
                
                jumpCurrentKey = jumpStopValue
                
                currentScreen = (currentLevel * MAP_SCREENS_WIDTH_COUNT )
                protaX = INITIAL_MAIN_CHARACTER_X
                protaY = INITIAL_MAIN_CHARACTER_Y

                #ifdef CHECKPOINTS_ENABLED
                    protaScreenRespawn = currentScreen
                    protaXRespawn = INITIAL_MAIN_CHARACTER_X
                    protaYRespawn = INITIAL_MAIN_CHARACTER_Y
                #endif
            End if
        #else
            'saveSprite( 0+ SCREEN_ADJUSTMENT, protaX , protaTile, protaDirection)
            protaY = 0+ SCREEN_ADJUSTMENT
            currentScreen = currentScreen + MAP_SCREENS_WIDTH_COUNT
            
            ' #ifdef LIVES_MODE_ENABLED
            '     protaXRespawn = protaX
            '     protaYRespawn = protaY
            ' #endif
        #endif
    Elseif direction = 8 Then
        'saveSprite( MAX_LINE - SCREEN_ADJUSTMENT, protaX, protaTile, protaDirection)
        protaY = MAX_LINE - SCREEN_ADJUSTMENT
        
        #ifdef SIDE_VIEW
            if not landed Then jumpCurrentKey = 0
        #endif
        currentScreen = currentScreen - MAP_SCREENS_WIDTH_COUNT
        
        ' #ifdef LIVES_MODE_ENABLED
        '     protaXRespawn = protaX
        '     protaYRespawn = protaY
        ' #endif
    End If
    
    #ifdef LIVES_MODE_ENABLED
        #ifndef CHECKPOINTS_ENABLED
            protaXRespawn = protaX
            protaYRespawn = protaY
        #endif
    #endif

    swapScreen()

    moveScreen = 0
End Sub

Sub drawSprites()
    If (protaY < 41) Then
        #ifdef LIVES_MODE_GRAVEYARD
            #ifdef ENERGY_ENABLED
            If not currentEnergy or Not invincible Or invincible bAnd 2 Then
                Draw2x2Sprite(protaTile, protaX, protaY)
            End If
            #else
                Draw2x2Sprite(protaTile, protaX, protaY)
            #endif
        #else
            If not currentLife or Not invincible Or invincible bAnd 2 Then
                Draw2x2Sprite(protaTile, protaX, protaY)
            End If
        #endif
    End If
    
    #ifdef SHOOTING_ENABLED
        If bulletPositionX <> 0 Then
            Draw1x1Sprite(currentBulletSpriteId, bulletPositionX, bulletPositionY)
        End If
    #endif
    
    #ifdef BULLET_ENEMIES
        If enemyBulletPositionX <> 0 Then
            Draw1x1Sprite(BULLET_SPRITE_ENEMY_ID, enemyBulletPositionX, enemyBulletPositionY)
        End If
    #endif
    
    RenderFrame()
End Sub
