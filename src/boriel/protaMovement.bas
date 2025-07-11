Function canMoveLeft() As Ubyte
    #ifdef KEYS_ENABLED
        If CheckDoor(protaX - 1, protaY) Then
            Return 0
        End If
    #endif
    Return Not CheckCollision(protaX - 1, protaY)
End Function

Function canMoveRight() As Ubyte
    #ifdef KEYS_ENABLED
        If CheckDoor(protaX + 1, protaY) Then
            Return 0
        End If
    #endif
    Return Not CheckCollision(protaX + 1, protaY)
End Function

Function canMoveUp() As Ubyte
    #ifdef ARCADE_MODE
        If protaY = 0 Then
            protaY = 39
            Return 1
        End If
    #endif
    #ifdef KEYS_ENABLED
        If CheckDoor(protaX, protaY - 1) Then
            Return 0
        End If
    #endif
    Return Not CheckCollision(protaX, protaY - 1)
End Function

Function canMoveDown() As Ubyte
    #ifdef ARCADE_MODE
        If protaY > 39 Then
            protaY = 0
            Return 1
        End If
    #endif
    #ifdef KEYS_ENABLED
        If CheckDoor(protaX, protaY + 1) Then
            Return 0
        End If
    #endif
    If CheckCollision(protaX, protaY + 1) Then Return 0
    #ifdef SIDE_VIEW
        If checkPlatformByXY(protaX, protaY + 4) Then Return 0
        If CheckStaticPlatform(protaX, protaY + 4) Then Return 0
        If CheckStaticPlatform(protaX + 1, protaY + 4) Then Return 0
        If CheckStaticPlatform(protaX + 2, protaY + 4) Then Return 0
    #endif
    Return 1
End Function

Function getNextFrameRunning() As Ubyte
    #ifdef SIDE_VIEW
        #ifdef MAIN_CHARACTER_EXTRA_FRAME
            If protaDirection = 1 Then
                If protaFrame = 0 Then
                    protaLastFrame = protaFrame
                    Return 1
                Else If protaFrame = 1 And protaLastFrame = 0 Then
                    protaLastFrame = protaFrame
                    Return 2
                Else If protaFrame = 2 Then
                    protaLastFrame = protaFrame
                    Return 1
                Else If protaFrame = 1 And protaLastFrame = 2 Then
                    protaLastFrame = protaFrame
                    Return 0
                End If
            Else
                If protaFrame = 4 Then
                    protaLastFrame = protaFrame
                    Return 5
                Else If protaFrame = 5 And protaLastFrame = 4 Then
                    protaLastFrame = protaFrame
                    Return 6
                Else If protaFrame = 6 Then
                    protaLastFrame = protaFrame
                    Return 5
                Else If protaFrame = 5 And protaLastFrame = 6 Then
                    protaLastFrame = protaFrame
                    Return 4
                End If
            End If
        #Else
            If protaDirection = 1 Then
                If protaFrame = 0 Then
                    Return 1
                Else
                    Return 0
                End If
            Else
                If protaFrame = 4 Then
                    Return 5
                Else
                    Return 4
                End If
            End If
        #endif
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


#ifdef SIDE_VIEW
    Function getNextFrameJumpingFalling() As Ubyte
        If (protaDirection) Then
            Return 4
        Else
            Return 8
        End If
    End Function
    
    #ifndef JETPACK_FUEL
        Sub checkIsJumping()
            If jumpCurrentKey >= jumpStopValue Then Return
            If jumpCurrentKey >= jumpStepsCount - 1 Then
                jumpCurrentKey = jumpStopValue
                Return
            End If
            
            ' If protaY < 2 Then
            '     #ifdef ARCADE_MODE
            '         protaY = 39
            '     #Else
            '         #ifdef LEVELS_MODE
            '             protaY = 2
            '         #Else
            '             moveScreen = 8
            '         #endif
            '     #endif
            '     jumpCurrentKey = jumpCurrentKey + 1
            '     Return
            ' End If
            if checkProtaTop() Then
                jumpCurrentKey = jumpCurrentKey + 1
                Return
            End if
            
            If CheckCollision(protaX, protaY + jumpArray(jumpCurrentKey)) Then
                ' If jumpArray(jumpCurrentKey) > 0 Then
                '     jumpCurrentKey = jumpStopValue
                ' Else
                jumpCurrentKey = jumpCurrentKey + 1
                ' End If
                Return
            End If
            
            saveSprite( protaY + jumpArray(jumpCurrentKey), protaX, getNextFrameJumpingFalling(), protaDirection)
            jumpCurrentKey = jumpCurrentKey + 1
        End Sub
    #endif
    
    #ifdef JETPACK_FUEL
        Sub checkIsFlying()
            If jumpCurrentKey = jumpStopValue Then Return
            
            ' If protaY < 2 Then
            '     If jumpEnergy > 0 Then
            '         #ifdef ARCADE_MODE
            '             protaY = 39
            '         #Else
            '             #ifdef LEVELS_MODE
            '                 protaY = 2
            '             #Else
            '                 moveScreen = 8
            '             #endif
            '         #endif
            '     End If
            ' End If
            If jumpEnergy > 0 Then
                checkProtaTop()
            End if
            
            If pressingUp() And jumpEnergy > 0 Then
                If Not CheckCollision(protaX, protaY - 1) Then
                    saveSprite( protaY - 1, protaX, getNextFrameJumpingFalling(), protaDirection)
                End If
                jumpCurrentKey = jumpCurrentKey + 1
                jumpEnergy = jumpEnergy - 1
                PRINT AT 23, 5; "   "
                PRINT AT 23, 5; jumpEnergy
                Return
            End If
            
            ' stop flight
            jumpCurrentKey = jumpStopValue
        End Sub
    #endif
    
    Function isFalling() As Ubyte
        If canMoveDown() Then
            #ifdef JETPACK_FUEL
                If pressingUp() Then
                    jumpCurrentKey = 0
                End If
            #endif
            Return 1
        Else
            If landed = 0 Then
                landed = 1
                jumpCurrentKey = jumpStopValue
                #ifdef JETPACK_FUEL
                    jumpEnergy = jumpStepsCount
                    printLife()
                #endif
                If protaY bAND 1 <> 0 Then
                    ' saveSpriteLin(PROTA_SPRITE, protaY - 1)
                    protaY = protaY - 1
                End If
                'resetProtaSpriteToRunning()
                if protaDirection then
                    saveSprite(protaY, protaX, FIRST_RUNNING_PROTA_SPRITE_RIGHT, protaDirection)
                else
                    saveSprite(protaY, protaX, FIRST_RUNNING_PROTA_SPRITE_LEFT, protaDirection)
                end if
            End If
            Return 0
        End If
    End Function
    
    Sub gravity()
        If jumpCurrentKey = jumpStopValue And isFalling() Then
            landed = 0
            If protaY >= MAX_LINE Then
                #ifdef LEVELS_MODE
                    landed = 1
                    decrementLife()
                    
                    #ifndef LIVES_MODE_ENABLED
                        jump()
                    #endif
                #else
                    moveScreen = 2
                #endif
            Else
                #ifndef JETPACK_FUEL
                    saveSprite( protaY + 2, protaX, getNextFrameJumpingFalling(), protaDirection)
                #Else
                    saveSprite( protaY + 1, protaX, getNextFrameJumpingFalling(), protaDirection)
                #endif
            End If
        End If
    End Sub
    
    Sub shoot()
        If Not noKeyPressedForShoot Then Return
        noKeyPressedForShoot = 0
        
        If bulletPositionX <> 0 Then Return
        
        #ifdef AMMO_ENABLED
            If currentAmmo = 0 Then Return
            currentAmmo = currentAmmo - 1
            printLife()
        #endif
        
        currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
        If protaDirection Then
            #ifdef IDLE_ENABLED
                saveSprite( protaY, protaX, 1, 1)
            #endif
            
            currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
            bulletPositionX = protaX + 2
            If BULLET_DISTANCE <> 0 Then
                If protaX + BULLET_DISTANCE > MAX_SCREEEN_RIGHT Then
                    bulletEndPositionX = MAX_SCREEEN_RIGHT
                Else
                    bulletEndPositionX = protaX + BULLET_DISTANCE + 1
                End If
            Else
                bulletEndPositionX = MAX_SCREEEN_RIGHT
            End If
        Elseif protaDirection = 0
            #ifdef IDLE_ENABLED
                saveSprite( protaY, protaX, 5, 0)
            #endif
            currentBulletSpriteId = BULLET_SPRITE_LEFT_ID
            bulletPositionX = protaX
            If BULLET_DISTANCE <> 0 Then
                If BULLET_DISTANCE > protaX Then
                    bulletEndPositionX = MAX_SCREEN_LEFT
                Else
                    bulletEndPositionX = protaX - BULLET_DISTANCE + 1
                End If
            Else
                bulletEndPositionX = MAX_SCREEN_LEFT
            End If
        End If
        
        bulletPositionY = protaY + 1
        bulletDirection = protaDirection
        BeepFX_Play(2)
    End Sub
#endif


#ifdef OVERHEAD_VIEW
    Sub shoot()
        If Not noKeyPressedForShoot Then Return
        
        noKeyPressedForShoot = 0
        
        #ifdef AMMO_ENABLED
            If currentAmmo = 0 Then Return
            currentAmmo = currentAmmo - 1
            printLife()
        #endif
        
        If bulletPositionX <> 0 Then Return
        
        If protaDirection = 1 Then
            currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
            bulletPositionX = protaX + 2
            bulletPositionY = protaY + 1
            If BULLET_DISTANCE <> 0 Then
                If protaX + BULLET_DISTANCE > MAX_SCREEEN_RIGHT Then
                    bulletEndPositionX = MAX_SCREEEN_RIGHT
                Else
                    bulletEndPositionX = protaX + BULLET_DISTANCE + 1
                End If
            Else
                bulletEndPositionX = MAX_SCREEEN_RIGHT
            End If
        Elseif protaDirection = 0
            currentBulletSpriteId = BULLET_SPRITE_LEFT_ID
            bulletPositionX = protaX
            bulletPositionY = protaY + 1
            If BULLET_DISTANCE <> 0 Then
                If BULLET_DISTANCE > protaX Then
                    bulletEndPositionX = MAX_SCREEN_LEFT
                Else
                    bulletEndPositionX = protaX - BULLET_DISTANCE + 1
                End If
            Else
                bulletEndPositionX = MAX_SCREEN_LEFT
            End If
        Elseif protaDirection = 8
            currentBulletSpriteId = BULLET_SPRITE_UP_ID
            bulletPositionX = protaX + 1
            bulletPositionY = protaY + 1
            If BULLET_DISTANCE <> 0 Then
                If BULLET_DISTANCE > protaY Then
                    bulletEndPositionY = MAX_SCREEN_TOP
                Else
                    bulletEndPositionY = protaY - BULLET_DISTANCE + 1
                End If
            Else
                bulletEndPositionY = MAX_SCREEN_TOP
            End If
        Else
            currentBulletSpriteId = BULLET_SPRITE_DOWN_ID
            bulletPositionX = protaX + 1
            bulletPositionY = protaY + 2
            If BULLET_DISTANCE <> 0 Then
                If protaY + BULLET_DISTANCE > MAX_SCREEN_BOTTOM Then
                    bulletEndPositionY = MAX_SCREEN_BOTTOM
                Else
                    bulletEndPositionY = protaY + BULLET_DISTANCE + 1
                End If
            Else
                bulletEndPositionY = MAX_SCREEN_BOTTOM
            End If
        End If
        
        bulletDirection = protaDirection
        BeepFX_Play(2)
    End Sub
#endif

Sub leftKey()
    If protaDirection <> 0 Then
        #ifdef SIDE_VIEW
            protaFrame = 4
        #Else
            protaFrame = 2
        #endif
    End If
    
    If protaX = 0 Then
        #ifdef ARCADE_MODE
            protaX = 60
            Return
        #Else
            moveScreen = 4
        #endif
    Elseif canMoveLeft()
        saveSprite( protaY, protaX - 1, protaFrame + 1, 0)
    End If
End Sub

Sub rightKey()
    If protaDirection <> 1 Then
        protaFrame = 0
    End If
    
    If protaX = 60 Then
        #ifdef ARCADE_MODE
            protaX = 0
            Return
        #Else
            moveScreen = 6
        #endif
    Elseif canMoveRight()
        saveSprite( protaY, protaX + 1, protaFrame + 1, 1)
    End If
End Sub

Sub upKey()
    #ifdef SIDE_VIEW
        jump()
    #Else
        If protaDirection <> 8 Then
            protaFrame = 4
        End If
        If canMoveUp() Then
            saveSprite( protaY - 1, protaX, protaFrame + 1, 8)
            ' If protaY < 2 Then
            '     #ifdef ARCADE_MODE
            '         protaY = 39
            '     #Else
            '         #ifdef LEVELS_MODE
            '             protaY = 2
            '         #Else
            '             moveScreen = 8
            '         #endif
            '     #endif
            ' End If
            checkProtaTop()
        End If
    #endif
End Sub

Sub downKey()
    #ifdef OVERHEAD_VIEW
        If protaDirection <> 2 Then
            protaFrame = 6
        End If
        If canMoveDown() Then
            If protaY >= MAX_LINE Then
                #ifndef LEVELS_MODE
                    #ifndef ARCADE_MODE
                        moveScreen = 2
                    #endif
                #endif
            Else
                saveSprite( protaY + 1, protaX, protaFrame + 1, 2)
            End If
        End If
    #Else
        If CheckStaticPlatform(protaX, protaY + 4) Or CheckStaticPlatform(protaX + 1, protaY + 4) Or CheckStaticPlatform(protaX + 2, protaY + 4) Then
            protaY = protaY + 2
        End If
    #endif
End Sub

#ifdef IN_GAME_TEXT_ENABLED
    Sub muestraDialogo(texto as ubyte, tile as ubyte)
        #ifdef FULLSCREEN_TEXTS
            FillWithTile(0, 32, 22, BACKGROUND_ATTRIBUTE, 0, 0)

            if tile > 1 Then SetTile(tile, attrSet(tile), 16, 4)
        #EndIf

        for fila=0 to ((TEXTS_SIZE / 15 ) - 1)
            for letra=0 to 14
                #ifndef FULLSCREEN_TEXTS
                    if tile > 1 and fila = 0 Then Print AT 5, 9 + letra; " "
                #endif
                Print AT 6+fila, 9 + letra; Chr$(textToDisplay(textsCoord(texto, 3), (fila*15)+letra))
            Next letra
            #ifndef FULLSCREEN_TEXTS
                if tile > 1 Then SetTile(tile, attrSet(tile), 16, 5)
            #endif
        Next fila
        pauseUntilPressEnter()
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
            If (protaX-1) <= cordX And (protaX+5) >= cordX Then
                If (protaY-1) <= cordY And (protaY+5) >= cordY Then
                    textFound = 1
                    
                    #ifdef IS_TEXT_ADVENTURE
                        #ifndef ARCADE_MODE
                            #ifndef LEVELS_MODE
                                dim textState as ubyte = textsCoord(texto, 5)
                                
                                if not textState or textState = adventureStateTmp Then
                                    dim adventureAction as ubyte = textsCoord(texto, 4)
                                    
                                    if adventureAction then
                                        if adventureAction = 1 Then
                                            if textState = adventureStateTmp Then
                                                currentAdventureState = currentAdventureState + 1
                                                
                                                If currentAdventureState > MAX_ADVENTURE_STATE Then
                                                    muestraDialogo(textsCoord(texto, 3), GetTile(cordX>>1, cordY>>1))
                                                    ending()
                                                end if
                                            End if
                                        elseif validateTile <> adventureAction Then
                                            textFound = 0
                                        end if
                                    end if
                                    
                                    if textFound Then muestraDialogo(textsCoord(texto, 3), GetTile(cordX>>1, cordY>>1))
                                else
                                    textFound = 0
                                end if
                            #EndIf
                        #EndIf
                    #Else
                        muestraDialogo(textsCoord(texto, 3), 0)
                    #EndIf
                End If
            End if
        Next texto
        
        return textFound
    End Function
#endif

Sub fireKey()
    #ifdef IN_GAME_TEXT_ENABLED
        #ifdef SHOOTING_ENABLED
            if not validaTexto(0) then shoot()
        #Else
            validaTexto(0)
        #endif
    #else
        #ifdef SHOOTING_ENABLED
            shoot()
        #endif
    #endif
End Sub

Sub keyboardListen()
    If kempston Then
        Dim n As Ubyte = In(31)
        If n bAND %10 Then leftKey()
        If n bAND %1 Then rightKey()
        If n bAND %1000 Then upKey()
        If n bAND %100 Then downKey()
        If n bAND %10000 Then fireKey()
        #ifdef SIDE_VIEW
            #ifdef IDLE_ENABLED
                If n = 0 Then
                    If protaLoopCounter < IDLE_TIME Then protaLoopCounter = protaLoopCounter + 1
                Else
                    protaLoopCounter = 0
                End If
            #endif
        #endif
    Else
        If MultiKeys(keyArray(LEFT))<>0 Then leftKey()
        If MultiKeys(keyArray(RIGHT))<>0 Then rightKey()
        If MultiKeys(keyArray(UP))<>0 Then upKey()
        If MultiKeys(keyArray(DOWN))<>0 Then downKey()
        If MultiKeys(keyArray(FIRE))<>0 Then fireKey()
        
        #ifdef SIDE_VIEW
            #ifdef IDLE_ENABLED
                If MultiKeys(keyArray(LEFT))=0 And MultiKeys(keyArray(RIGHT))=0 And MultiKeys(keyArray(UP))=0 And MultiKeys(keyArray(DOWN))=0 And MultiKeys(keyArray(FIRE))=0 Then
                    If protaLoopCounter < IDLE_TIME Then protaLoopCounter = protaLoopCounter + 1
                Else
                    protaLoopCounter = 0
                End If
            #endif
        #endif
    End If
End Sub

Function checkTileObject(tile As Ubyte) As Ubyte
    If tile = ITEM_TILE Then
        #ifndef ARCADE_MODE
            If Not screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX) Then
                Return 0
            End If
        #endif
        currentItems = currentItems + ITEMS_INCREMENT
        #ifdef HISCORE_ENABLED
            score = score + 100
            If score > hiScore Then
                hiScore = score
            End If
        #endif
        printLife()
        #ifdef MESSAGES_ENABLED
            printMessage("NEW ITEM!", 4, 0)
        #endif
        #ifdef ARCADE_MODE
            If currentItems = itemsToFind Then
                drawKey()
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
        Return 1
        #ifdef KEYS_ENABLED
        Elseif tile = KEY_TILE And screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) Then
            #ifdef ARCADE_MODE
                If currentScreen = SCREENS_COUNT Then
                    ending()
                Else
                    moveScreen = 6
                    Return 1
                End If
            #endif
            currentKeys = currentKeys + 1
            printLife()
            #ifdef MESSAGES_ENABLED
                printMessage("KEY FOUND", 4, 0)
            #endif
            screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) = 0
            BeepFX_Play(3)
            Return 1
        #endif
    Elseif tile = LIFE_TILE And screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) Then
        currentLife = currentLife + LIFE_AMOUNT
        printLife()
        screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) = 0
        BeepFX_Play(6)
        Return 1
        #ifdef AMMO_ENABLED
        Elseif tile = AMMO_TILE And screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX) Then
            currentAmmo = currentAmmo + AMMO_INCREMENT
            printLife()
            screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX) = 0
            BeepFX_Play(6)
            Return 1
        #endif
    End If
    Return 0
End Function

Sub checkObjectContact()
    Dim col As Ubyte = protaX >> 1
    Dim lin As Ubyte = protaY >> 1
    
    for c=0 to 1
        for l=0 to 1
            #ifdef IN_GAME_TEXT_ENABLED
                dim tile = GetTile(col+c, lin+l)
                
                if checkTileObject(tile) then
                    validaTexto(tile)
                    FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col + c, lin + l)
                End if
            #else
                If checkTileObject(GetTile(col+c, lin+l)) Then
                    FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col + c, lin + l)
                End if
            #endif
        next l
    next c
    
    ' If checkTileObject(GetTile(col, lin)) Then
    '     #ifdef IN_GAME_TEXT_ENABLED
    '         validaTexto(GetTile(col, lin))
    '     #endif
    '     FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col, lin)
    
    ' Elseif checkTileObject(GetTile(col + 1, lin))
    '    #ifdef IN_GAME_TEXT_ENABLED
    '         validaTexto(GetTile(col + 1, lin))
    '     #endif
    '     FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col + 1, lin)
    '  Elseif checkTileObject(GetTile(col, lin + 1))
    '     #ifdef IN_GAME_TEXT_ENABLED
    '         validaTexto(GetTile(col, lin + 1))
    '     #endif
    '     FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col, lin + 1)
    ' Elseif checkTileObject(GetTile(col + 1, lin + 1))
    '     #ifdef IN_GAME_TEXT_ENABLED
    '         validaTexto(GetTile(col + 1, lin + 1))
    '     #endif
    '    FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col + 1, lin + 1)
    '  End If
End Sub


Sub checkDamageByTile()
    If invincible Then Return
    
    Dim col As Ubyte = protaX >> 1
    Dim lin As Ubyte = protaY >> 1
    
    If isADamageTile(col, lin) Or isADamageTile(col + 1, lin) Then
        decrementLife()
        Return
    End If
    if isADamageTile(col, lin + 1) Or isADamageTile(col + 1, lin + 1) Then
        decrementLife()
        Return
    End If
End Sub

Sub protaMovement()
    #ifdef LIVES_MODE_GRAVEYARD
        If invincible Then Return
    #endif
    
    If MultiKeys(keyArray(FIRE)) = 0 Then
        noKeyPressedForShoot = 1
    End If
    keyboardListen()
    checkObjectContact()
    
    #ifdef SIDE_VIEW
        #ifndef JETPACK_FUEL
            checkIsJumping()
        #Else
            checkIsFlying()
        #endif
        gravity()
        
        #ifdef IDLE_ENABLED
            If protaLoopCounter >= IDLE_TIME Then
                If jumpCurrentKey <> jumpStopValue Then Return
                If isFalling() Then Return
                
                If framec - lastFrameTiles = ANIMATE_PERIOD_TILE - 2 Then
                    If protaTile = 13 Then
                        'saveSprite( protaY, protaX, 14, protaDirection)
                        protaTile = 14
                    Else
                        'saveSprite( protaY, protaX, 13, protaDirection)
                        protaTile = 13
                    End If
                End If
            End If
        #endif
    #endif
    
    #ifdef MESSAGES_ENABLED
        checkMessageForDelete()
    #endif
End Sub