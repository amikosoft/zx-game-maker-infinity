Sub mapDraw()
    Dim index As Uinteger
    Dim y, x As Ubyte
    
    x = 0
    y = 0
    
    For index=0 To SCREEN_LENGTH
        drawTile(Peek(@decompressedMap + index) - 1, x, y)
        
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
                    dim textState as ubyte = textsCoord(texto, 5)
                    
                    if textState Then
                        dim cordX as ubyte = textsCoord(texto, 1) >> 1
                        dim cordY as ubyte = textsCoord(texto, 2) >> 1
                        
                        if textState >= currentAdventureState Then
                            dim textTile as ubyte = textsCoord(texto, 4)
                            
                            if textTile Then SetTileChecked(textTile, attrSet(textTile), cordX, cordY)
                        Else
                            #ifdef SCREEN_ATTRIBUTES
                                SetTileChecked(currentTileBackground, currentScreenBackground, cordX, cordY)
                            #else
                                SetTileChecked(0, BACKGROUND_ATTRIBUTE, cordX, cordY)
                            #endif
                        End if
                    End if
                Next texto
            #endif
        #endif
    #endif
End Sub

Sub mapColor(color As Ubyte)
    Dim index As Uinteger
    Dim y, x As Ubyte
    
    x = 0
    y = 0
    
    For index=0 To SCREEN_LENGTH
        SetTileColor(x, y, color)
        
        x = x + 1
        If x = screenWidth Then
            x = 0
            y = y + 1
        End If
    Next index
End Sub

Sub drawTile(tile As Ubyte, x As Ubyte, y As Ubyte)
    #ifdef SCREEN_ATTRIBUTES
        SetTile(currentTileBackground, currentScreenBackground, x, y)
    #else
        SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
    #endif
    
    If tile < 1 Then Return
    
    If tile < MAX_GENERIC_TILE Then
        If tile = ENEMY_DOOR_TILE Then
            #ifdef SHOULD_KILL_ENEMIES_ENABLED
                If screensWon(currentScreen) Then
                    #ifdef SCREEN_ATTRIBUTES
                        SetTile(currentTileBackground, currentScreenBackground, x, y)
                    #else
                        SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
                    #endif
                Else
                    SetTile(tile, attrSet(tile), x, y)
                End If
            #Else
                #ifdef SCREEN_ATTRIBUTES
                    SetTile(currentTileBackground, currentScreenBackground, x, y)
                #else
                    SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
                #endif
            #endif
            #ifdef KEYS_ENABLED
            Elseif tile = DOOR_TILE
                If screenObjects(currentScreen, SCREEN_OBJECT_DOOR_INDEX) Then
                    SetTile(tile, attrSet(tile), x, y)
                End If
            #endif
            #ifdef USE_BREAKABLE_TILE
            ElseIf tile = BREAKABLE_TILE Then
                If brokenTiles(currentScreen) Then
                    #ifdef SCREEN_ATTRIBUTES
                        SetTile(currentTileBackground, currentScreenBackground, x, y)
                    #else
                        SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
                    #endif
                Else
                    SetTileChecked(tile, attrSet(tile), x, y)
                End If
            #endif
        Else
            SetTile(tile, attrSet(tile), x, y)
        End if
    Else
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
        Elseif tile = LIFE_TILE
            If screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) Then
                SetTileChecked(tile, attrSet(tile), x, y)
            End If
        Elseif tile = AMMO_TILE
            If screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX) Then
                SetTileChecked(tile, attrSet(tile), x, y)
            End If
        End If
    End If
    
    ' #ifdef USE_BREAKABLE_TILE
    '     If tile = BREAKABLE_TILE Then
    '         If brokenTiles(currentScreen) Then
    '             SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
    '         Else
    '             SetTileChecked(tile, attrSet(tile), x, y)
    '         End If
    '         Return
    '     End If
    ' #endif
    
    ' If tile < MAX_GENERIC_TILE Then
    '     SetTile(tile, attrSet(tile), x, y)
    '     Return
    ' End If
    
    ' if force then SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
    
    ' If tile = ITEM_TILE Then
    '     If screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX) Then
    '         SetTileChecked(tile, attrSet(tile), x, y)
    '     End If
    ' Elseif tile = KEY_TILE
    '     #ifdef ARCADE_MODE
    '         currentScreenKeyX = x
    '         currentScreenKeyY = y
    '     #Else
    '         If screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) Then
    '             SetTileChecked(tile, attrSet(tile), x, y)
    '         End If
    '     #endif
    ' Elseif tile = LIFE_TILE
    '     If screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) Then
    '         SetTileChecked(tile, attrSet(tile), x, y)
    '     End If
    ' Elseif tile = AMMO_TILE
    '     If screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX) Then
    '         SetTileChecked(tile, attrSet(tile), x, y)
    '     End If
    ' End If
End Sub

' #ifdef ARCADE_MODE
'     Sub drawKey()
'         SetTile(KEY_TILE, attrSet(KEY_TILE), currentScreenKeyX, currentScreenKeyY)
'     End Sub
' #endif

Sub redrawScreen()
    ClearScreen(7, 0, 0) ' Modified For only cancelops And no clear Screen

    ' #ifdef SCREEN_ATTRIBUTES
    '     FillWithTile(currentTileBackground, 32, 22, currentScreenBackground, 0, 0)
    ' #else
    '     FillWithTile(0, 32, 22, BACKGROUND_ATTRIBUTE, 0, 0)
    ' #endif
    
    mapDraw()

    ' #ifdef HISCORE_ENABLED
    '     Print AT 22, 20; "00000"
    '     Print AT 23, 20; "00000"
    ' #endif
    
    ' printLife()
End Sub

Sub moveToScreen(direction As Ubyte)
    If direction = 6 Then
        'updateProtaData( protaY, 0 + SCREEN_ADJUSTMENT, protaTile, protaDirection)
        protaX = 0 + SCREEN_ADJUSTMENT
        currentScreen = currentScreen + 1
        
        #ifdef LIVES_MODE_ENABLED
            #ifndef CHECKPOINTS_ENABLED
                protaXRespawn = 0 + SCREEN_ADJUSTMENT
                protaYRespawn = protaY
            #endif
        #endif
    Elseif direction = 4 Then
        'updateProtaData( protaY, 60 - SCREEN_ADJUSTMENT, protaTile, protaDirection)
        protaX = 60 - SCREEN_ADJUSTMENT
        currentScreen = currentScreen - 1
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
            'updateProtaData( 0+ SCREEN_ADJUSTMENT, protaX , protaTile, protaDirection)
            protaY = 0+ SCREEN_ADJUSTMENT
            currentScreen = currentScreen + MAP_SCREENS_WIDTH_COUNT
        #endif
    Elseif direction = 8 Then
        protaY = MAX_LINE - SCREEN_ADJUSTMENT
        
        #ifdef SIDE_VIEW
            if not landed Then jumpCurrentKey = 0
        #endif
        currentScreen = currentScreen - MAP_SCREENS_WIDTH_COUNT
    End If
    
    #ifdef LIVES_MODE_ENABLED
        #ifndef CHECKPOINTS_ENABLED
            protaXRespawn = protaX
            protaYRespawn = protaY
        #endif
    #endif
    
    swapScreen(0)
    
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
