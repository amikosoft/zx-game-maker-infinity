sub CleanWithTile(TileIndex as uByte, Attribute as uByte)

    ' Dim tmpX as uByte
    ' Dim tmpY as uByte

    for tmpX = SKIP_WIDTH_SIZE to SKIP_WIDTH_SIZE + screenWidth - 1
        for tmpY = SKIP_HEIGHT_SIZE to SKIP_HEIGHT_SIZE + screenHeight - 1
            SetTile(TileIndex, Attribute, tmpX, tmpY)
        next tmpY
    next tmpX

end sub

Sub mapDraw(withHud as ubyte)
    'Ink INK_VALUE: Paper PAPER_VALUE: BRIGHT BRIGHT_VALUE: FLASH 0
    if withHud Then
        #ifdef HISCORE_ENABLED
            Print AT 22, 13; TEXT_HI_SCORE_ZERO
            Print AT 23, 13; TEXT_HI_SCORE_ZERO
        #endif

        printHud()
    end if

    if screenIsDark then
        SetTileset(@darkTileSet(0,0))
    else
        SetTileset(@tileSet(0,0))
    end if

    #ifdef FULL_SCREEN_CHANGE_ANIMATION
        #ifdef SCREEN_ATTRIBUTES
            #ifdef PLAYER_COLOR_ENABLED
                'FillWithTile(currentTileBackground, screenWidth, screenHeight, attrWithBackground(PLAYER_COLOR), SKIP_WIDTH_SIZE, SKIP_HEIGHT_SIZE)
                CleanWithTile(currentTileBackground, attrWithBackground(PLAYER_COLOR))
            #else
                'FillWithTile(currentTileBackground, screenWidth, screenHeight, currentScreenBackground, SKIP_WIDTH_SIZE, SKIP_HEIGHT_SIZE)
                CleanWithTile(currentTileBackground, currentScreenBackground)
            #endif
        #else
            #ifdef PLAYER_COLOR_ENABLED
                'FillWithTile(0, screenWidth, screenHeight, attrWithBackground(PLAYER_COLOR), SKIP_WIDTH_SIZE, SKIP_HEIGHT_SIZE)
                CleanWithTile(0, attrWithBackground(PLAYER_COLOR))
            #else
                'FillWithTile(0, screenWidth, screenHeight, BACKGROUND_ATTRIBUTE, SKIP_WIDTH_SIZE, SKIP_HEIGHT_SIZE)
                CleanWithTile(0, BACKGROUND_ATTRIBUTE)
            #endif
        #endif
    #endif

    Dim index As Uinteger = 0
    
    #ifdef FADE_TILES_ENABLED
    maxFadeTile = 0
    #endif

    for y = SKIP_HEIGHT_SIZE to SKIP_HEIGHT_SIZE + screenHeight - 1
        for x = SKIP_WIDTH_SIZE to SKIP_WIDTH_SIZE + screenWidth - 1
            dim nextTile as ubyte = Peek(arrayBasePtr(decompressedMap) + index)
            
            #ifdef FADE_TILES_ENABLED
                if maxFadeTile < FADE_TILE_TOTAL and (nextTile = FADE_TILE or nextTile = FADE_TILE_END) then
                    fadeTileStatus(maxFadeTile, 0) = x
                    fadeTileStatus(maxFadeTile, 1) = y
                    fadeTileStatus(maxFadeTile, 2) = FADE_TILE_FRAMES
                    maxFadeTile = maxFadeTile + 1
                end if
            #endif

            #ifdef TELEPORT_ENABLED
                if nextTile = TELEPORT_TILE then
                    if moveScreen = 10 then
                        protaX = x*2
                        protaY = y*2

                        #ifdef LIVES_MODE_ENABLED
                            #ifndef CHECKPOINTS_ENABLED
                                protaXRespawn = protaX
                                protaYRespawn = protaY
                                protaScreenRespawn = currentScreen
                            #endif
                        #endif
                       
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

            index = index + 1
        next x
    next y
    
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
    #ifndef FULL_SCREEN_CHANGE_ANIMATION
        #ifdef SCREEN_ATTRIBUTES
            #ifdef PLAYER_COLOR_ENABLED
                SetTile(currentTileBackground, attrWithBackground(PLAYER_COLOR), x, y)
            #else
                SetTile(currentTileBackground, currentScreenBackground, x, y)
            #endif
        #else
            #ifdef PLAYER_COLOR_ENABLED
                SetTile(0, attrWithBackground(PLAYER_COLOR), x, y)
            #else
                SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
            #endif
        #endif
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

Sub moveToScreen(direction As Ubyte)
    If direction = 6 Then
        ' EXITING RIGHT
        
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

Sub drawSpriteWithColor(spriteId as ubyte, spriteX as ubyte, spriteY as ubyte, color as ubyte)
    dim spriteCol as ubyte = spriteX >> 1
    dim spriteLin as ubyte = spriteY >> 1
    for cc=spriteCol to (spriteCol+1)
        for lc=spriteLin to (spriteLin+1)
            if not GetTile(cc, lc) then SetTileColor(cc, lc, attrWithBackground(color))
        next lc
    next cc

    Draw2x2Sprite(spriteId, spriteX, spriteY)
end sub