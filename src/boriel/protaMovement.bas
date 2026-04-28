' Function canMoveLeft() As Ubyte
'     Return Not CheckCollision(protaX - 1, protaY)
' End Function

' Function canMoveRight() As Ubyte
'     Return Not CheckCollision(protaX + 1, protaY)
' End Function

Function canMoveUp() As Ubyte
    #ifdef ARCADE_MODE
        If protaY <= PLAYER_BOUNDS_TOP Then
            protaY = PLAYER_BOUNDS_BOTTOM
            Return 1
        End If
    #endif
    ' #ifdef KEYS_ENABLED
    '     If CheckDoor(protaX, protaY - 1) Then
    '         Return 0
    '     End If
    ' #endif
    Return Not CheckCollision(protaX, protaY - 1)
End Function

#ifdef SIDE_VIEW
    Function checkIsLadder(y as Ubyte, anim as Ubyte) as ubyte
        for i=0 to 2
            #ifdef LADDERS_ANIMATION_ENABLED
                dim tile as ubyte = CheckStaticPlatform(protaX+i, y)
                #ifdef SCREEN_TERRAIN_ENABLED
                    if screenIsTerrain then tile = 255
                #endif
                if tile Then
                    if tile > STEPS_TILE_END Then
                        ' if anim then protaDirection = 2
                        #ifdef SCREEN_TERRAIN_ENABLED
                            if anim = 2 and screenIsTerrain Then
                                if not horizontalAxisKeyPressed then
                                    protaDirection = 2
                                    If protaTile = PROTA_TILE_DOWN Then
                                        protaTile = 8
                                    Else
                                        protaTile = PROTA_TILE_DOWN
                                    End If
                                end if
                                return 1
                            end if
                        #endif
                        
                        if anim then
                            if not horizontalAxisKeyPressed then
                                protaDirection = 2
                                If protaTile = PROTA_TILE_UP Then
                                    protaTile = 6
                                Else
                                    protaTile = PROTA_TILE_UP
                                End If
                            end if
                        End If
                    end if
                    return 2
                End if
            #else
                #ifdef SCREEN_TERRAIN_ENABLED
                    if screenIsTerrain or CheckStaticPlatform(protaX+i, y) Then return 2
                #Else
                    if CheckStaticPlatform(protaX+i, y) Then return 2
                #endif
            #endif
        next i
        
        return 0
    end function
#endif

Function canMoveDown() As Ubyte
    #ifdef ARCADE_MODE
        If protaY > MAX_SCREEN_BOTTOM Then
            protaY = PLAYER_BOUNDS_TOP
            Return 1
        End If
    #endif
    
    #ifdef SIDE_VIEW
        If CheckCollision(protaX, protaY + 1) Then Return 0
        
        If checkPlatformByXY() Then Return 0
        
        if checkIsLadder(protaY + 4, 0) then return 0
    #else
        If CheckCollision(protaX, protaY + 1) Then Return 0
    #endif
    Return 1
End Function

Function getNextFrameRunning() As Ubyte
    #ifdef SIDE_VIEW
        If protaDirection = 1 Then
            If protaFrame = 0 Then
                Return 1
            Else
                Return 0
            End If
        Elseif protaDirection = 0 Then
            If protaFrame = 2 Then
                Return 3
            Else
                Return 2
            End If
        End If
    #Else
        If protaDirection = 1 Then
            If protaFrame = 0 Then
                Return 1
            Else
                Return 0
            End If
        Elseif protaDirection = 0 Then
            If protaFrame = 2 Then
                Return 3
            Else
                Return 2
            End If
        Elseif protaDirection = 8 Then
            If protaFrame = 4 Then
                Return 5
            Else
                Return 4
            End If
        Else ' down
            If protaFrame = 6 Then
                Return 7
            Else
                Return 6
            End If
        End If
    #endif
End Function

' Function pressingUp() As Ubyte
'     Return ((kempston = 0 And MultiKeys(keyArray(UP)) <> 0) Or (kempston = 1 And In(31) bAND %1000 <> 0))
' End Function

' Function pressingDown() As Ubyte
'     Return ((kempston = 0 And MultiKeys(keyArray(DOWN)) <> 0) Or (kempston = 1 And In(31) bAND %100 <> 0))
' End Function

Sub shoot()
    If bulletPositionX Then Return
    
    #ifdef AMMO_ENABLED
        If not currentAmmo Then Return
        currentAmmo = currentAmmo - 1
        printHud()
    #endif
    
    bulletDirection = -1
    bulletDirectionVertical = 0
    bulletPositionY = protaY + 1

    if not horizontalAxisKeyPressed or verticalAxisKeyPressed then
        bulletPositionX = protaX + 1

        if protaDirection = 8 or verticalAxisKeyPressed = 1 Then
            #ifdef OVERHEAD_VIEW
            #ifdef IDLE_ENABLED
                protaTile = PROTA_TILE_UP
            #endif
            #endif
            bulletDirectionVertical = BULLET_DIRECTION_UP

            #ifndef BULLET_ANIMATION
                currentBulletSpriteId = BULLET_SPRITE_UP_ID
            #endif

            bulletPositionY = protaY

            #ifndef BULLET_DISTANCE_FULL
                bulletEndPositionY = protaY - BULLET_DISTANCE
                If bulletEndPositionY < PLAYER_BOUNDS_TOP Then
                    bulletEndPositionY = PLAYER_BOUNDS_TOP
                End If
            #Else
                bulletEndPositionY = PLAYER_BOUNDS_TOP
            #EndIf
        elseif protaDirection = 2 or verticalAxisKeyPressed = -1 then
            #ifdef OVERHEAD_VIEW
            #ifdef IDLE_ENABLED
                protaTile = PROTA_TILE_DOWN
            #endif
            #endif

            bulletDirectionVertical = BULLET_DIRECTION_DOWN

            #ifndef BULLET_ANIMATION
                currentBulletSpriteId = BULLET_SPRITE_DOWN_ID
            #endif
            
            bulletPositionY = protaY + 2

            #ifndef BULLET_DISTANCE_FULL
                bulletEndPositionY = protaY + BULLET_DISTANCE
                If bulletEndPositionY > PLAYER_BOUNDS_BOTTOM Then
                    bulletEndPositionY = PLAYER_BOUNDS_BOTTOM
                End If
            #Else
                bulletEndPositionY = PLAYER_BOUNDS_BOTTOM
            #EndIf
        end if

    end if
    
    if not verticalAxisKeyPressed or horizontalAxisKeyPressed then
        If protaDirection = 1 or horizontalAxisKeyPressed = 1 Then
            #ifdef IDLE_ENABLED
                protaTile = PROTA_TILE_RIGHT

                #ifndef OVERHEAD_VIEW
                    protaDirection = 1
                #endif
            #endif
            
            bulletDirection = BULLET_DIRECTION_RIGHT
            
            #ifndef BULLET_ANIMATION
                currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
            #endif
            bulletPositionX = protaX + 2
            
            #ifndef BULLET_DISTANCE_FULL
                bulletEndPositionX = protaX + BULLET_DISTANCE
                If bulletEndPositionX > PLAYER_BOUNDS_RIGHT Then
                    bulletEndPositionX = PLAYER_BOUNDS_RIGHT
                End If
            #Else
                bulletEndPositionX = PLAYER_BOUNDS_RIGHT
            #EndIf
        Elseif protaDirection = 0 or horizontalAxisKeyPressed = -1 then
            #ifdef IDLE_ENABLED
                protaTile = PROTA_TILE_LEFT
                #ifndef OVERHEAD_VIEW
                    protaDirection = 0
                #endif
            #endif
            
            bulletDirection = BULLET_DIRECTION_LEFT

            #ifndef BULLET_ANIMATION
                currentBulletSpriteId = BULLET_SPRITE_LEFT_ID
            #endif
            bulletPositionX = protaX
            
            #ifndef BULLET_DISTANCE_FULL
                bulletEndPositionX = protaX - BULLET_DISTANCE
                If bulletEndPositionX < (PLAYER_BOUNDS_LEFT+2) Then
                    bulletEndPositionX = PLAYER_BOUNDS_LEFT+2
                End If
            #Else
                bulletEndPositionX = PLAYER_BOUNDS_LEFT+2
            #EndIf
        End If
    end if

    BeepFX_Play(2)
End Sub

Sub leftKey(animate as ubyte)
    horizontalAxisKeyPressed = -1

    if animate then
        if protaDirection <> 0 Then
            protaFrame = PROTA_FRAME_LEFT
        End If

        protaTile = protaFrame + 1 
        protaDirection = 0
    end if
    
    If protaX <= PLAYER_BOUNDS_LEFT Then
        #ifdef ARCADE_MODE
            protaX = MAX_SCREEN_RIGHT
            Return
        #Else
            moveScreen = 4
        #endif
    Else
        #ifdef GLUE_SLOW_DOWN
            if isOnGlue and (enemiesFrame band 1) then return
        #endif

        #ifdef SIDE_VIEW
            if isInStep(protaX) then
                protaY = protaY - 1
            end if
        #endif
        
        if Not CheckCollision(protaX - 1, protaY) then 
            protaX = protaX - 1
        end if
    End If
End Sub

Sub rightKey(animate as ubyte)
    horizontalAxisKeyPressed = 1

    ' If animate and protaDirection <> 1 Then
    '     protaFrame = PROTA_FRAME_RIGHT
    ' End If

    if animate then
        if protaDirection <> 1 Then
            protaFrame = PROTA_FRAME_RIGHT
        End If

        protaTile = protaFrame + 1 
        protaDirection = 1
    end if

    If protaX >= PLAYER_BOUNDS_RIGHT Then
        #ifdef ARCADE_MODE
            protaX = MAX_SCREEN_LEFT
            Return
        #Else
            moveScreen = 6
        #endif
    Else
        #ifdef GLUE_SLOW_DOWN
            if isOnGlue and (enemiesFrame band 1) then return
        #endif    
            
        #ifdef SIDE_VIEW
            if isInStep(protaX+3) then protaY = protaY - 1
        #endif
        
        if Not CheckCollision(protaX + 1, protaY) then 
            protaX = protaX + 1
        end if
    End If
End Sub

Sub upKey()
    verticalAxisKeyPressed = 1

    #ifdef SIDE_VIEW
        #ifdef LADDERS_ANIMATION_ENABLED
            If checkIsLadder(protaY + 3, 1) Then
                if not horizontalAxisKeyPressed then protaDirection = 8
                checkProtaTop()
                
                if Not CheckCollision(protaX, protaY - 1) Then
                    protaY = protaY - 1
                End If
            Else
                #ifdef PREVENT_JUMP_ON_FIRE
                    if shootPressed then return
                #endif

                jump()
            End If
        #Else
            #ifdef SCREEN_TERRAIN_ENABLED
                If screenIsTerrain then
                    checkProtaTop()
                    
                    if Not CheckCollision(protaX, protaY - 1) Then
                        protaY = protaY - 1
                    End If
                else
                    #ifdef PREVENT_JUMP_ON_FIRE
                        if shootPressed then return
                    #endif
                    jump()
                end if
            #else
                #ifdef PREVENT_JUMP_ON_FIRE
                    if shootPressed then return
                #endif
                jump()
            #endif
        #endif
    #Else
        If protaDirection <> 8 Then
            protaFrame = 4
        End If
        If canMoveUp() Then
            protaY = protaY - 1

            protaTile = protaFrame + 1
            protaDirection = 8
            
            checkProtaTop()
        End If
    #endif
End Sub

Sub downKey()
    verticalAxisKeyPressed = -1

    #ifdef OVERHEAD_VIEW
        If protaDirection <> 2 Then
            protaFrame = 6
        End If
        If canMoveDown() Then
            If protaY >= MAX_SCREEN_BOTTOM Then
                #ifndef LEVELS_MODE
                    #ifndef ARCADE_MODE
                        moveScreen = 2
                    #endif
                #endif
            Else
                protaY = protaY + 1
                protaTile = protaFrame + 1
                protaDirection = 2
            End If
        End If
    #Else
        #ifdef JUMP_CANCEL
            jumpCurrentKey = jumpStopValue
        #endif
        
        ' if protaY bAnd 1 Then protaY = protaY + 1
        
        If not CheckCollision(protaX, protaY + 1) Then
            #ifdef LADDERS_ANIMATION_ENABLED
                ' If checkIsLadder(protaY + 4, 2) Then
                '     protaY = protaY + 1
                ' End If
                protaY = protaY + checkIsLadder(protaY + 4, 2)
            #Else
                protaY = protaY + checkIsLadder(protaY + 4, 0)
            #endif
        end if
    #endif
End Sub

#ifdef IN_GAME_TEXT_ENABLED
    Sub muestraDialogo(texto as ubyte, tile as ubyte)
        #ifdef FULLSCREEN_TEXTS
            #ifdef ADVENTURETEXTS_SCREEN_ENABLED
            '     FillWithTile(currentTileBackground, screenWidth, screenHeight, currentScreenBackground, SKIP_WIDTH_SIZE, SKIP_HEIGHT_SIZE)
                loadScreen(ADVENTURETEXTS_SCREEN_ADDRESS)
            #else
                'FillWithTile(0, screenWidth, screenHeight, BACKGROUND_ATTRIBUTE, SKIP_WIDTH_SIZE, SKIP_HEIGHT_SIZE)
                CleanWithTile(0, BACKGROUND_ATTRIBUTE)
            #endif
            
            SetTile(tile, attrSet(tile), 16, 4)
        #else
            #ifdef MAP_COLOR_TEXT_ENABLED
                mapColor(MAP_COLOR_TEXT_COLOR)
                SetTile(tile, attrSet(tile), 16, 4)
            #EndIf
        #EndIf

        for fila=0 to ((TEXTS_SIZE / 15 ) - 1)
            dim textId as ubyte = textsCoord(texto, 3)
            SetBank(textsBank)
            for letra=0 to 14
                #ifndef FULLSCREEN_TEXTS
                    if fila = 0 Then Print AT 5, 9 + letra; " "
                #endif

                #ifdef ADVENTURE_TEXTS_SOUND
                    dim nextChar as ubyte = textToDisplay(textId, (fila*15)+letra)
                    
                    if nextChar <> 32 then 
                        ' PAUSE 2: 
                        BEEP .05, 8

                        Print AT 6+fila, 9 + letra; Chr$(nextChar)
                    end if
                #Else
                    Print AT 6+fila, 9 + letra; Chr$(textToDisplay(textId, (fila*15)+letra))
                #endif
            Next letra
            SetBank(gameBank)
            #ifndef FULLSCREEN_TEXTS
                #ifndef MAP_COLOR_TEXT_ENABLED
                    SetTile(tile, attrSet(tile), 16, 5)
                #endif
            #endif
        Next fila

        #ifdef ADVENTURE_TEXTS_CONFIRM_FIRE
            pauseUntilPressFire()
        #else
            pauseUntilPressEnter()
        #endif
    
        #ifdef FULLSCREEN_TEXTS
            #ifdef ADVENTURETEXTS_SCREEN_ENABLED
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
                '     Print AT 22, 13; TEXT_HI_SCORE_ZERO
                '     Print AT 23, 13; TEXT_HI_SCORE_ZERO
                ' #endif

                ' printHud()
            #endif
        #endif
        mapDraw(1)
    end sub
    
    Function validaTexto(validateTile as ubyte) as ubyte
        dim textFound as ubyte = 0
        
        #ifdef IS_TEXT_ADVENTURE
            dim adventureStateTmp as ubyte = currentAdventureState
        #EndIf
        
        for texto=currentScreenFirstText to AVAILABLE_ADVENTURES
            if textsCoord(texto, 0) <> currentScreen Then exit for
            dim cordX as ubyte = textsCoord(texto, 1)
            dim cordY as ubyte = textsCoord(texto, 2)
            
            If (protaX-1) <= cordX And (protaX+4) >= cordX Then
                If (protaY-1) <= cordY And (protaY+4) >= cordY Then
                    dim tileText as ubyte = GetTile(cordX>>1, cordY>>1)
                    
                    if tileText Then
                        textFound = 1
                        
                        #ifdef IS_TEXT_ADVENTURE
                            #ifndef ARCADE_MODE
                                #ifndef LEVELS_MODE
                                    dim textState as ubyte = textsCoord(texto, 5)
                                    
                                    if not textState or textState = adventureStateTmp Then
                                        if textState and textState = adventureStateTmp Then
                                            if currentAdventureState = adventureStateTmp and textsCoord(texto, 4) Then
                                                currentAdventureState = currentAdventureState + 1
                                            End if
                                        elseif validateTile and validateTile <> tileText Then
                                            textFound = 0
                                        end if
                                        
                                        if textFound Then muestraDialogo(textsCoord(texto, 3), tileText)
                                    else
                                        textFound = 0
                                    end if
                                #EndIf
                            #EndIf
                        #Else
                            muestraDialogo(textsCoord(texto, 3), tileText)
                        #EndIf
                    end if
                End If
            End if
        Next texto
        
        #ifdef IS_TEXT_ADVENTURE
            #ifndef ARCADE_MODE
                #ifndef LEVELS_MODE
                    If currentAdventureState > MAX_ADVENTURE_STATE Then
                        ending()
                    end if
                #EndIf
            #EndIf
        #EndIf
        
        return textFound
    End Function
#endif

Sub fireKey()
    isActionPerformed = 0
    
    #ifdef FIRED_ITEMS_ENABLED
    checkObjectContact(0)
    #endif
    
    #ifdef IN_GAME_TEXT_ENABLED
        if not isActionPerformed then isActionPerformed = validaTexto(0)
    #endif
    
    #ifdef SHOOTING_ENABLED
        if not isActionPerformed then shoot()
    #endif
End Sub

Sub keyboardListen()
    verticalAxisKeyPressed = 0
    horizontalAxisKeyPressed = 0
    
    #ifdef PREVENT_JUMP_ON_FIRE
        if shootPressed then shootPressed = shootPressed - 1
    #endif
    
    If kempston Then
        Dim n As Ubyte = In(31)
        If n bAND %10 Then leftKey(1)
        If n bAND %1 Then rightKey(1)
        
        #ifdef PREVENT_JUMP_ON_FIRE
            If n bAND %10000 Then shootPressed = 5
            If n bAND %1000 Then upKey()
            If n bAND %100 Then downKey()
        #else
            If n bAND %1000 Then upKey()
            If n bAND %100 Then downKey()
            If n bAND %10000 Then fireKey()
        #endif
    Else
        If MultiKeys(keyArray(LEFT)) Then leftKey(1)
        If MultiKeys(keyArray(RIGHT)) Then rightKey(1)
        
        #ifdef PREVENT_JUMP_ON_FIRE
            If MultiKeys(keyArray(FIRE)) Then shootPressed = 5
            If MultiKeys(keyArray(UP)) Then upKey()
            If MultiKeys(keyArray(DOWN)) Then downKey()
        #else
            If MultiKeys(keyArray(UP)) Then upKey()
            If MultiKeys(keyArray(DOWN)) Then downKey()
            If MultiKeys(keyArray(FIRE)) Then fireKey()
        #endif
    End If

    #ifdef PREVENT_JUMP_ON_FIRE
        if shootPressed = 5 then fireKey()
    #endif

    #ifdef IDLE_ENABLED
        If not horizontalAxisKeyPressed and not verticalAxisKeyPressed Then
            If protaLoopCounter < IDLE_TIME Then protaLoopCounter = protaLoopCounter + 1
        Else
            protaLoopCounter = 0
        End If
    #endif
End Sub

Function checkTileObject(tile As Ubyte, withoutFire as ubyte) As Ubyte
    #ifdef GLUE_TILE_ENABLED
        if tile = GLUE_TERRAIN_TILE then isOnGlue = 1
    #endif

    if withoutFire then
        If tile = ITEM_TILE Then
            #ifdef SHOULD_PICKUP_ITEMS
                screensStatus(currentScreen) = SCREEN_STATUS_COMPLETED
                removeTilesFromScreen(ENEMY_DOOR_TILE)
            #endif
            currentItems = currentItems + ITEMS_INCREMENT
            #ifdef HISCORE_ENABLED
                score = score + 100
                If score > hiScore Then
                    hiScore = score
                End If
            #endif
            printHud()
            #ifdef MESSAGES_ENABLED
                printMessage(TEXT_NEW_ITEM, 4, 0)
            #endif
            #ifdef ARCADE_MODE
                If currentItems = itemsToFind Then
                    'SetTile(KEY_TILE, tileAttrWithBackground(KEY_TILE), currentScreenKeyX, currentScreenKeyY)
                    SetTileWithBackground(KEY_TILE, currentScreenKeyX, currentScreenKeyY)
                End If
            #Else
                #ifndef LEVELS_MODE
                    If currentItems = GOAL_ITEMS Then
                        ending()
                    End If
                #endif
            #endif
            screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX) = 0
            BeepFX_Play(5)
            Return tile
            #ifndef ARCADE_MODE
                #ifdef CHECKPOINTS_ENABLED
                ElseIf tile = FLAG_TILE Then
                    #ifdef MESSAGES_ENABLED
                        if protaScreenRespawn <> currentScreen Then printMessage(TEXT_CHECK_POINT, 4, 0)
                    #endif
                    
                    protaXRespawn = protaX
                    protaYRespawn = protaY - 1
                    protaScreenRespawn = currentScreen
                #endif
            #endif
            #ifdef KEYS_ENABLED
            Elseif tile = KEY_TILE Then
                #ifdef ARCADE_MODE
                    If currentScreen = SCREENS_COUNT Then
                        ending()
                    Else
                        moveScreen = 6
                        Return 1
                    End If
                #endif
                currentKeys = currentKeys + 1
                printHud()
                #ifdef MESSAGES_ENABLED
                    printMessage(TEXT_KEY_FOUND, 4, 0)
                #endif
                screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) = 0
                BeepFX_Play(3)
                Return tile
            #endif
        ' #ifdef GLUE_TILE_ENABLED
        '     Elseif tile = GLUE_TERRAIN_TILE then 
        '         isOnGlue = 1
        ' #endif
        Elseif tile = LIFE_TILE Then
            #ifdef ENERGY_ENABLED
                if currentEnergy = INITIAL_ENERGY Then
                    currentLife = currentLife + LIFE_AMOUNT
                else
                    currentEnergy = INITIAL_ENERGY
                End if
            #else
                currentLife = currentLife + LIFE_AMOUNT
            #endif
            
            printHud()
            
            #ifdef MESSAGES_ENABLED
                printMessage(TEXT_LIFE, 2, 0)
            #endif
            
            screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) = 0
            BeepFX_Play(6)
            Return tile
            #ifdef AMMO_ENABLED
            Elseif tile = AMMO_TILE Then
                currentAmmo = currentAmmo + AMMO_INCREMENT
                printHud()
                
                #ifdef MESSAGES_ENABLED
                    printMessage(TEXT_AMMO, 2, 0)
                #endif
                
                screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX) = 0
                BeepFX_Play(6)
                Return tile
            #endif
        End If
    #ifdef FIRED_ITEMS_ENABLED
    else if not isActionPerformed then
        #ifdef SCREEN_DARK_ENABLED
            if tile = SWITCHER_TILE Then
                screenIsDark = not screenIsDark
                BEEP 0.01, 14
                mapDraw(0)
                isActionPerformed = tile
                return tile
            end if
        #endif
        #ifdef TELEPORT_ENABLED
            if tile = TELEPORT_TILE then
                currentScreen = currentTeleportTo - 1
                moveScreen = 10
                isActionPerformed = tile
                ' BeepFX_Play(6)
                
                #ifdef TELEPORT_ANIMATION
                    for color=1 to 7
                        #ifdef TELEPORT_SOUND
                            BEEP 0.01, color
                        #endif
                        mapColor(7-color)
                    next color
                #endif
            End if
        #endif
    #endif
    End if

    Return 0
End Function

Sub checkObjectContact(withoutFire as ubyte)
    for c=protaCol to (protaCol+1)
        for l=protaLin to (protaLin+1)
            If isADamageTile(c, l) Then decrementLife()

            #ifdef IN_GAME_TEXT_ENABLED
                dim tile as ubyte = GetTile(c, l)
                    
                if checkTileObject(tile, withoutFire) then
                    validaTexto(tile)
                    
                    #ifdef SCREEN_ATTRIBUTES
                        if withoutFire then SetTileChecked(currentTileBackground, currentScreenBackground, c, l)
                    #else
                        if withoutFire then SetTileChecked(0, BACKGROUND_ATTRIBUTE, c, l)
                    #endif
                End if
            #else
                If checkTileObject(GetTile(c, l), withoutFire) Then
                    #ifdef SCREEN_ATTRIBUTES
                        if withoutFire then SetTileChecked(currentTileBackground, currentScreenBackground, c, l)
                    #else
                        if withoutFire then SetTileChecked(0, BACKGROUND_ATTRIBUTE, c, l)
                    #endif
                End if
            #endif
        next l
    next c
End Sub

Sub protaMovement()
    #ifdef LIVES_MODE_GRAVEYARD
        #ifdef ENERGY_ENABLED
            if Not currentEnergy and invincible Then Return
        #Else
            If invincible Then Return
        #endif
    #endif
    
    ' If MultiKeys(keyArray(FIRE)) = 0 Then
    '     noKeyPressedForShoot = 1
    ' End If
    keyboardListen()

    if moveScreen then return

    protaCol = protaX >> 1
    protaLin = protaY >> 1
    
    #ifdef GLUE_TILE_ENABLED
        isOnGlue = 0
    #endif
    
    checkObjectContact(1)
    
    #ifdef SIDE_VIEW
        #include "functionsBas/checkJumpGravity.bas"
        
        #ifdef IDLE_ENABLED
            If protaLoopCounter >= IDLE_TIME Then
                If jumpCurrentKey <> jumpStopValue Then Return
                ' If isFalling() Then Return
                if not landed then return

                protaTile = 13 + animatedFrame
            End If
        #endif
    #else
        #ifdef IDLE_ENABLED
            If protaLoopCounter >= IDLE_TIME Then
                protaTile = 13 + animatedFrame
            End If
        #endif
    #endif
    
    #ifdef MESSAGES_ENABLED
        ' checkMessageForDelete()
        if messageLoopCounter Then
            messageLoopCounter = messageLoopCounter - 1
            If not messageLoopCounter Then
                PRINT AT 21, 11; TEXT_EMPTY_STRING
            End If
        End if
    #endif
End Sub