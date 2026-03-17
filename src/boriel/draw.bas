Sub mapDraw()
    if screenIsDark then
        SetTileset(@darkTileSet(0,0))
    else
        SetTileset(@tileSet(0,0))
    end if

    ' Dim index As Uinteger
    Dim y, x As Ubyte
    
    x = SKIP_WIDTH_SIZE
    y = SKIP_HEIGHT_SIZE
    
    #ifdef FADE_TILES_ENABLED
    maxFadeTile = 0
    #endif
    
    ' dim dmAddress as integer = 

    For index=0 To SCREEN_LENGTH
        dim nextTile as ubyte = Peek(arrayBasePtr(decompressedMap) + index)
        
        #ifdef FADE_TILES_ENABLED
            ' drawTile(nextTile, x, y)
            
            if maxFadeTile < FADE_TILE_TOTAL and (nextTile = FADE_TILE or nextTile = FADE_TILE_END) then
                fadeTileStatus(maxFadeTile, 0) = x
                fadeTileStatus(maxFadeTile, 1) = y
                fadeTileStatus(maxFadeTile, 2) = FADE_TILE_FRAMES
                maxFadeTile = maxFadeTile + 1
            end if
        ' #else
        '     drawTile(nextTile, x, y)
        #endif

        #ifdef TELEPORT_ENABLED
            if nextTile = TELEPORT_TILE then
                if moveScreen = 10 then
                    protaX = x*2
                    protaY = y*2
                    protaXRespawn = protaX
                    protaYRespawn = protaY
                    moveScreen = 0
                end if
                
                #ifdef TELEPORT_DISABLED_TILE
                    if not currentTeleportTo then nextTile = TELEPORT_QUIT_TILE
                #else
                    if not currentTeleportTo then nextTile = 0
                #endif
            end if
        #endif

        drawTile(nextTile, x, y)

        x = x + 1
        If x = (screenWidth+SKIP_WIDTH_SIZE) Then
            x = SKIP_WIDTH_SIZE
            y = y + 1
        End If
    Next index
    
    #ifdef ANIMATED_TILES_ENABLED
        lastFrameTiles = ANIMATE_PERIOD_TILE
        For i=0 To ANIMATED_TILES_TOTAL
            firstTileInScreen = i
            if animatedTilesPerScreen(i, 0) = currentScreen Then Exit for
        next i
    #endif

    #ifdef IN_GAME_TEXT_ENABLED
        #ifdef IS_TEXT_ADVENTURE
            #ifdef ADVENTURE_TEXTS_MANAGE_TILES
                for texto=currentScreenFirstText to AVAILABLE_ADVENTURES
                    if textsCoord(texto, 0) <> currentScreen Then exit for
                    dim textState as ubyte = textsCoord(texto, 5)
                    
                    if textState Then
                        dim cordX as ubyte = textsCoord(texto, 1) >> 1
                        dim cordY as ubyte = textsCoord(texto, 2) >> 1
                        
                        if textState >= currentAdventureState Then
                            #ifdef ADVENTURE_TEXTS_SHOW_TILES
                                dim textTile as ubyte = textsCoord(texto, 4)
                                #ifdef SCREEN_ATTRIBUTES
                                    if textTile Then SetTileChecked(textTile, tileAttrWithBackground(textTile), cordX, cordY)
                                #else
                                    if textTile Then SetTileChecked(textTile, attrSet(textTile), cordX, cordY)
                                #endif
                            #endif
                        #ifdef ADVENTURE_TEXTS_HIDE_TILES
                        Else
                            #ifdef SCREEN_ATTRIBUTES
                                SetTileChecked(currentTileBackground, currentScreenBackground, cordX, cordY)
                            #else
                                SetTileChecked(0, BACKGROUND_ATTRIBUTE, cordX, cordY)
                            #endif
                        #endif
                        End if
                    End if
                Next texto
            #endif
        #endif
    #endif
End Sub

Sub mapColor(color As Ubyte)
    for tmpX = SKIP_WIDTH_SIZE to SKIP_WIDTH_SIZE + screenWidth - 1
        for tmpY = SKIP_HEIGHT_SIZE to SKIP_HEIGHT_SIZE + screenHeight - 1
            SetTileColor(tmpX, tmpY, color)
        next tmpY
    next tmpX
End Sub

' const MAP_X_ADJUSTMENT as ubyte = 14
' const MAP_Y_ADJUSTMENT as ubyte = 10
Sub pathDraw()
    Dim y, x As Ubyte
    
    x = 0
    y = MAP_Y_ADJUSTMENT
    
    For index=0 To SCREENS_COUNT
        #ifdef GAMEMAP_ONLY_VISITED
        if screensStatus(index) <> SCREEN_STATUS_NOT_VISITED then
        #endif
            PAPER screensStatus(index) + 1

            if index = currentScreen then
                PRINT AT y, MAP_X_ADJUSTMENT + (x*2); "X"
            else
                PRINT AT y, MAP_X_ADJUSTMENT + (x*2); " "
            end if
        #ifdef GAMEMAP_ONLY_VISITED
        end if
        #endif

        x = x + 1
        If x >= MAP_SCREENS_WIDTH_COUNT Then
            x = 0
            y = y + 2
        End If
    Next index
End Sub

Sub drawTile(tile As Ubyte, x As Ubyte, y As Ubyte)
    'Revisar draws de vacío innecesarios
    #ifdef SCREEN_ATTRIBUTES
        SetTile(currentTileBackground, currentScreenBackground, x, y)
    #else
        SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
    #endif
    
    If not tile Then Return
    
    If tile < MAX_GENERIC_TILE Then
        If tile = ENEMY_DOOR_TILE Then
            #ifdef SHOULD_KILL_ENEMIES_ENABLED
                If screensStatus(currentScreen) < SCREEN_STATUS_COMPLETED Then
                    SetTile(tile, tileAttrWithBackground(tile), x, y)
                End If
            #endif
            #ifdef KEYS_ENABLED
            Elseif tile = DOOR_TILE
                If screenObjects(currentScreen, SCREEN_OBJECT_DOOR_INDEX) Then
                    SetTile(tile, tileAttrWithBackground(tile), x, y)
                End If
            #endif
            #ifdef USE_BREAKABLE_TILE
            ElseIf tile = BREAKABLE_TILE Then
                If not brokenTiles(currentScreen) Then
                    SetTileChecked(tile, tileAttrWithBackground(tile), x, y)
                End If
            #endif
            #ifdef SCREEN_DARK_ENABLED
            ElseIf tile = SWITCHER_TILE Then
                SetTileChecked(tile, tileAttrWithBackground(tile), x, y)
            #endif
        Else
            SetTile(tile, tileAttrWithBackground(tile), x, y)
        End if
    Else
        If tile = ITEM_TILE Then
            If screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX) Then
                SetTileChecked(tile, tileAttrWithBackground(tile), x, y)
            End If
        Elseif tile = KEY_TILE then
            #ifdef ARCADE_MODE
                currentScreenKeyX = x
                currentScreenKeyY = y
            #Else
                If screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) Then
                    SetTileChecked(tile, tileAttrWithBackground(tile), x, y)
                End If
            #endif
        Elseif tile = LIFE_TILE then
            If screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) Then
                SetTileChecked(tile, tileAttrWithBackground(tile), x, y)
            End If
        Elseif tile = AMMO_TILE then
            If screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX) Then
                SetTileChecked(tile, tileAttrWithBackground(tile), x, y)
            End If
        End If
    End If
    
End Sub

' #ifdef ARCADE_MODE
'     Sub drawKey()
'         SetTile(KEY_TILE, attrSet(KEY_TILE), currentScreenKeyX, currentScreenKeyY)
'     End Sub
' #endif

Sub moveToScreen(direction As Ubyte)
    If direction = 6 Then
        ' EXITING RIGHT
        'updateProtaData( protaY, 0 + SCREEN_ADJUSTMENT, protaTile, protaDirection)
        
        protaX = PLAYER_BOUNDS_LEFT + SCREEN_ADJUSTMENT
        
        currentScreen = currentScreen + 1
        
        #ifdef LIVES_MODE_ENABLED
            #ifndef CHECKPOINTS_ENABLED
                protaXRespawn = 0 + SCREEN_ADJUSTMENT
                protaYRespawn = protaY
            #endif
        #endif
    Elseif direction = 4 Then
        ' EXITING LEFT
        'updateProtaData( protaY, 60 - SCREEN_ADJUSTMENT, protaTile, protaDirection)
        protaX = PLAYER_BOUNDS_RIGHT - SCREEN_ADJUSTMENT

        currentScreen = currentScreen - 1
    Elseif direction = 2 Then
        ' EXITING BOTTOM
        #ifdef LEVELS_MODE
            currentLevel = currentLevel + 1
            if currentLevel > (SCREENS_COUNT/MAP_SCREENS_WIDTH_COUNT) then
                moveScreen = 0
                ending()
            Else
                Print AT 13,8;TEXT_LEVEL_COMPLETE
                Print AT 15,8;GENERIC_ENTER_CONTINUE
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
            protaY = SKIP_HEIGHT_SIZE + SCREEN_ADJUSTMENT
        
            currentScreen = currentScreen + MAP_SCREENS_WIDTH_COUNT
        #endif
    Elseif direction = 8 Then
        ' EXITING TOP
        protaY = MAX_SCREEN_BOTTOM - SCREEN_ADJUSTMENT
        
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
    If protaY < MAX_SCREEN_BOTTOM_PRINT Then
        #ifdef LIVES_MODE_GRAVEYARD
            #ifdef ENERGY_ENABLED
                If not currentEnergy or Not invincible Or invincible bAnd 2 Then
                    Draw2x2Sprite(protaTile, protaX, protaY)
                End If
            #else
                Draw2x2Sprite(protaTile, protaX, protaY)
            #endif
        #else
            If not currentLife or Not invincible Or (invincible bAnd 2) Then
                Draw2x2Sprite(protaTile, protaX, protaY)
            End If
        #endif

        ' Draw1x1Sprite(BULLET_SPRITE_ENEMY_ID, protaX+3, protaY+1)
    End If
    
    #ifdef SHOOTING_ENABLED
        If bulletPositionX <> 0 Then
            Draw1x1Sprite(currentBulletSpriteId, bulletPositionX, bulletPositionY)
        End If
    #endif
    
    ' #ifdef BULLET_ENEMIES movido a enemies
    '     If enemyBulletPositionX <> 0 Then
    '         Draw1x1Sprite(BULLET_SPRITE_ENEMY_ID, enemyBulletPositionX, enemyBulletPositionY)
    '     End If
    ' #endif
    
    RenderFrame()
End Sub
