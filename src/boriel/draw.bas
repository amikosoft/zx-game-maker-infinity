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

    #ifdef ITEMS_MULTICOLOR_ENABLED
        multicolorItem(0) = 0
    #endif

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
                        
                        #ifdef ADVENTURE_TEXTS_SHOW_TILES
                            if textState >= currentAdventureState Then
                                ' dim textTile as ubyte = textsCoord(texto, 4)
                                SetTileWithBackground(textsCoord(texto, 4), cordX, cordY)
                                'if textTile Then SetTileWithBackground(textTile, cordX, cordY)
                                ' if textTile Then
                                    ' #ifdef SCREEN_ATTRIBUTES
                                    '     SetTileAnimated(textTile, tileAttrWithBackground(textTile), cordX, cordY)
                                    ' #else
                                    '     #ifdef SCREEN_DARK_ENABLED
                                    '         SetTileAnimated(textTile, tileAttrSet(textTile), cordX, cordY)
                                    '     #Else
                                    '         SetTileAnimated(textTile, attrSet(textTile), cordX, cordY)
                                    '     #endif
                                    ' #endif
                                ' end if
                            End if
                        #else
                            #ifdef ADVENTURE_TEXTS_HIDE_TILES
                                if textState < currentAdventureState Then
                                    ' #ifdef SCREEN_ATTRIBUTES
                                    '     SetTile(currentTileBackground, currentScreenBackground, cordX, cordY)
                                    ' #else
                                    '     SetTile(0, BACKGROUND_ATTRIBUTE, cordX, cordY)
                                    ' #endif
                                    SetTileWithBackground(0, cordX, cordY)
                                End if
                            #endif
                        #endif
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

            #ifdef GAMEMAP_SEPARATED_ROOMS
                if index = currentScreen then
                    PRINT AT y, MAP_X_ADJUSTMENT + (x*2); "X"
                else
                    PRINT AT y, MAP_X_ADJUSTMENT + (x*2); " "
                end if
            #else
                if index = currentScreen then
                    PRINT AT y, MAP_X_ADJUSTMENT + x; "X"
                else
                    PRINT AT y, MAP_X_ADJUSTMENT + x; " "
                end if
            #endif
        #ifdef GAMEMAP_ONLY_VISITED
        end if
        #endif

        x = x + 1
        If x >= MAP_SCREENS_WIDTH_COUNT Then
            x = 0

            #ifdef GAMEMAP_SEPARATED_ROOMS
                y = y + 2
            #else
                y = y + 1
            #endif
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
                    'SetTile(tile, tileAttrWithBackground(tile), x, y)
                    SetTileWithBackground(tile, x, y)
                End If
            #endif
            #ifdef KEYS_ENABLED
            Elseif tile = DOOR_TILE then
                If screenObjects(currentScreen, SCREEN_OBJECT_DOOR_INDEX) Then
                    ' SetTile(tile, tileAttrWithBackground(tile), x, y)
                    SetTileWithBackground(tile, x, y)
                End If
            #endif
            #ifdef USE_BREAKABLE_TILE
            ElseIf tile = BREAKABLE_TILE Then
                If not brokenTiles(currentScreen) Then
                    'SetTileChecked(tile, tileAttrWithBackground(tile), x, y)
                    SetTileWithBackground(tile, x, y)
                End If
            #endif
            #ifdef SCREEN_DARK_ENABLED
            #ifdef SWITCHES_ENABLED
            ElseIf tile = SWITCHER_TILE Then
                'SetTileChecked(tile, tileAttrWithBackground(tile), x, y)
                SetTileWithBackground(tile, x, y)
            #endif
            #endif
            #ifdef FINAL_ITEM_ENABLED
            ElseIf tile = FINAL_ITEM_TILE Then
                #ifdef FINAL_ITEM_ALWAYS_SHOWN
                    SetTileWithBackground(tile, x, y)
                #endif
                #ifdef FINAL_ITEM_HIDE_UNTIL_FINISH
                    If currentItems = GOAL_ITEMS Then
                        SetTileWithBackground(tile, x, y)
                    end if
                #endif
                #ifdef FINAL_ITEM_SHOW_UNTIL_FINISH
                    If currentItems <> GOAL_ITEMS Then
                        SetTileWithBackground(tile, x, y)
                    end if
                #endif
            #endif
        Else
            'SetTile(tile, tileAttrWithBackground(tile), x, y)
            SetTileWithBackground(tile, x, y)
        End if
    Else
        #ifdef SCREEN_DARK_HIDE_ITEMS
            if screenIsDark then Return
        #else
            #ifdef SCREEN_LIGHT_HIDE_ITEMS
                if not screenIsDark then Return
            #endif
        #endif

        If tile = ITEM_TILE Then
            If not screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX) Then return

            #ifdef ITEMS_MULTICOLOR_ENABLED
                multicolorItem(0) = x
                multicolorItem(1) = y
            #endif
        Elseif tile = KEY_TILE then
            #ifdef ARCADE_MODE
                currentScreenKeyX = x
                currentScreenKeyY = y
            #Else
                If not screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) Then return
            #endif
        Elseif tile = LIFE_TILE then
            If not screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) Then return
        Elseif tile = AMMO_TILE then
            If not screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX) Then return
        #ifdef COINS_ENABLED
        ElseIf tile = COIN_TILE then
            If not screenObjects(currentScreen, SCREEN_OBJECT_COIN_INDEX) Then return
        #endif
        End If
        
        #ifdef ARCADE_MODE
            if tile <> KEY_TILE then SetTileWithBackground(tile, x, y)
        #else
            SetTileWithBackground(tile, x, y)
        #endif
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
    #ifdef LIVES_MODE_GRAVEYARD
        #ifdef MAP_COLOR_DEAD_ENABLED
            #ifdef ENERGY_ENABLED
                if currentEnergy then
            #else
                if not invincible then
            #endif
        #endif
    #endif

    dim spriteCol as ubyte = spriteX >> 1
    dim spriteLin as ubyte = spriteY >> 1
    for cc=spriteCol to (spriteCol+1)
        for lc=spriteLin to (spriteLin+1)
            if not GetTile(cc, lc) then SetTileColor(cc, lc, attrWithBackground(color))
        next lc
    next cc

    #ifdef LIVES_MODE_GRAVEYARD
        #ifdef MAP_COLOR_DEAD_ENABLED
            ' #ifdef ENERGY_ENABLED
                end if
            ' #endif
        #endif
    #endif

    Draw2x2Sprite(spriteId, spriteX, spriteY)
end sub