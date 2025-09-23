#ifdef SIDE_VIEW
    Function checkPlatformHasProtaOnTop(x As Ubyte, y As Ubyte) As Ubyte
        If (protaX + 3) < x Or protaX > (x + 3) Then Return 0
        If (protaY + 4) > (y - 2) and (protaY + 4) < (y + 3) Then Return 1
        
        Return 0
    End Function
    
    Function checkPlatformByXY(protaX As Ubyte, protaY4 As Ubyte) As Ubyte
        If not enemiesScreen Then Return 0
        
        For enemyId=0 To enemiesScreen - 1
            If decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 Then
                Dim enemyCol As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
                Dim enemyLin As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
                
                If (protaX + 3) < enemyCol Or protaX > (enemyCol + 3) Then continue for
                If protaY4 < enemyLin or protaY4 > (enemyLin + 1) Then continue For

                Return 1
            End If
        Next enemyId
        
        Return 0
    End Function
#endif

#ifdef BULLET_ENEMIES
    Sub enemyShoot(bulletId as ubyte, posX as ubyte, posY as ubyte, direction as byte)
        If direction = BULLET_DIRECTION_RIGHT Then
            enemyBullets(bulletId, 0) = posX + 2
            enemyBullets(bulletId, 1) = posY + 1
        Elseif direction = BULLET_DIRECTION_LEFT
            enemyBullets(bulletId, 0) = posX
            enemyBullets(bulletId, 1) = posY + 1
        Elseif direction = BULLET_DIRECTION_UP
            enemyBullets(bulletId, 0) = posX + 1
            enemyBullets(bulletId, 1) = posY + 1
        Else
            enemyBullets(bulletId, 0) = posX + 1
            enemyBullets(bulletId, 1) = posY + 2
        End If
        
        enemyBullets(bulletId, 2) = direction
        BeepFX_Play(2)
    End Sub
#endif

#ifdef SHOOTING_ENABLED
    function checkEnemyBullet(enemyId as ubyte, enemyCol as ubyte, enemyLin as ubyte) as Ubyte
        if (bulletPositionX + 1) < enemyCol or bulletPositionX > (enemyCol + 2) then return 0
        if (bulletPositionY + 1) < enemyLin or bulletPositionY > (enemyLin+2) then return 0
        
        resetBullet()
        damageEnemy(enemyId)
        return 1
    end function
#endif

Sub moveEnemies()
    #ifdef PLATFORM_MOVEABLE
        isOnPlatform = 0
    #endif

    enemiesFrame = enemiesFrame + 1
    if enemiesFrame > 9 Then enemiesFrame = 1
    
    If enemiesScreen Then
        For enemyId=0 To enemiesScreen - 1
            if firstTimeEnemiesScreen Then 
                #ifdef ENEMIES_RESPAWN_IN_SCREEN_ENABLED
                    enemiesInitialLife(enemyId) = decompressedEnemiesScreen(enemyId, ENEMY_ALIVE)
                #EndIf

                #ifdef BULLET_ENEMIES
                    enemyBullets(enemyId, 0) = 0
                #endif

                continue For
            end if
            
            Dim tile As Byte = decompressedEnemiesScreen(enemyId, ENEMY_TILE) + 1
            
            If not tile Then continue For

            #ifdef BULLET_ENEMIES
                if moveEnemyBullet(enemyId) Then Draw1x1Sprite(BULLET_SPRITE_ENEMY_ID, enemyBullets(enemyId, 0), enemyBullets(enemyId, 1))
            #endif

            Dim enemyLive As Byte = decompressedEnemiesScreen(enemyId, ENEMY_ALIVE)
            
            If not enemyLive Then continue For
            
            #ifndef ENEMIES_SLOW_DOWN
                #ifdef ENEMIES_NOT_RESPAWN_ENABLED
                    If enemyLive < 1 And tile > 16 Then
                        If screensWon(currentScreen) Then continue For
                    End If
                #endif
            #endif

            Dim enemyMode As Byte = decompressedEnemiesScreen(enemyId, ENEMY_MODE)
            Dim enemyCol As Byte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
            Dim enemyLin As Byte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
            Dim enemyColIni As Byte = decompressedEnemiesScreen(enemyId, ENEMY_COL_INI)
            Dim enemyLinIni As Byte = decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI)
            Dim enemySpeed As Byte = decompressedEnemiesScreen(enemyId, ENEMY_SPEED)

            #ifdef ENEMIES_SLOW_DOWN
                if enemyLive > -100 and enemyLive < 0 then
                    if enemySpeed < 3 Then
                        enemyLive = enemyLive + 1

                        if not enemyLive Then
                            enemySpeed = enemySpeed + 1
                            decompressedEnemiesScreen(enemyId, ENEMY_SPEED) = enemySpeed
                            if enemySpeed < 3 Then 
                                enemyLive = -50
                            Else
                                enemyLive = 1
                            end if
                        end if

                        decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) = enemyLive
                    end if

                    ' siempre tiene que tener vida
                    enemyLive = 1
                end if

                #ifdef SHOOTING_ENABLED
                    if bulletPositionX then
                        checkEnemyBullet(enemyId, enemyCol, enemyLin)
                    End If
                #endif
            #else
                #ifdef ENEMIES_RESPAWN_IN_SCREEN_ENABLED
                    if enemyLive > -100 and enemyLive < 1 then
                        enemyLive = enemyLive + 1
                        
                        if not enemyLive Then
                            enemyLive = enemiesInitialLife(enemyId)
                        end if
                        decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) = enemyLive
                        
                        if enemyMode = 2 Then
                            enemyCol = enemyColIni
                            enemyLin = enemyLinIni
                            GO TO EnemiesFinal
                        End if
                        #ifdef SHOOTING_ENABLED
                        Else
                            ' Se comprueba si tiene colision de bala
                            if bulletPositionX and enemyLive > 0 then
                                if checkEnemyBullet(enemyId, enemyCol, enemyLin) Then
                                    enemyLive = enemyLive - 1
                                End if
                            End If
                        #endif
                    End if
                #else
                    ' Se comprueba si tiene colision de bala
                    #ifdef SHOOTING_ENABLED
                        if bulletPositionX and enemyLive > 0 then
                            if checkEnemyBullet(enemyId, enemyCol, enemyLin) Then
                                enemyLive = enemyLive - 1
                            End if
                        End If
                    #endif
                #endif
            #endif
            
            'Dim enemySpeed As Byte = decompressedEnemiesScreen(enemyId, ENEMY_SPEED)
            Dim horizontalDirection As Byte = decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)
            Dim verticalDirection As Byte = decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION)
            
            #ifdef ENEMIES_SLOW_DOWN
                If not enemySpeed or (enemySpeed = 1 and (enemiesFrame bAnd 3) <> 3) or (enemySpeed = 2 and (enemiesFrame bAnd 1) = 1) Then
                    GO TO EnemiesFinal
                End If
            #else
                If (enemySpeed = 1 and (enemiesFrame bAnd 3) <> 3) or (enemySpeed = 2 and (enemiesFrame bAnd 1) = 1) Then
                    GO TO EnemiesFinal
                End If
            #endif
            
            Dim enemyColEnd As Byte = decompressedEnemiesScreen(enemyId, ENEMY_COL_END)
            Dim enemyLinEnd As Byte = decompressedEnemiesScreen(enemyId, ENEMY_LIN_END)
            
            if enemyMode < ENEMY_MODE_PURSUIT Then
                If horizontalDirection Then
                    If enemyColIni = enemyCol Or enemyColEnd = enemyCol Then
                        horizontalDirection = horizontalDirection * -1
                    End If
                End If
                
                If verticalDirection Then
                    If enemyLinIni = enemyLin Or enemyLinEnd = enemyLin Then
                        verticalDirection = verticalDirection * -1
                    End If
                End If

                #ifdef ENEMIES_NORMAL_COLLIDE
                    dim counter as byte = 0
                    while counter < 3 and CheckCollision(enemyCol + horizontalDirection, enemyLin + verticalDirection)
                        if not counter Then 
                            horizontalDirection = horizontalDirection * -1
                        Elseif counter = 1 Then
                            horizontalDirection = horizontalDirection * -1 
                            verticalDirection = verticalDirection * -1       
                        Else
                            horizontalDirection = horizontalDirection * -1       
                        end if

                        counter = counter +1
                    Wend
                #endif
                
                #ifdef ENEMIES_ALERT_ENABLED
                    If Not invincible And enemyMode = ENEMY_MODE_ALERT Then
                        If Abs(protaX - enemyCol) < ENEMIES_ALERT_DISTANCE And Abs(protaY - enemyLin) < (ENEMIES_ALERT_DISTANCE * 2) Then
                            enemyMode = ENEMY_MODE_PURSUIT
                        End if
                    End if
                #endif
                #ifdef ENEMIES_PURSUIT_ENABLED
                ElseIf enemyMode = ENEMY_MODE_PURSUIT Then
                    if invincible Then
                        horizontalDirection = Sgn(enemyColIni - enemyCol)
                        verticalDirection = Sgn(enemyLinIni - enemyLin)
                    Else
                        horizontalDirection = Sgn(protaX - enemyCol)
                        verticalDirection = Sgn(protaY - enemyLin)
                        
                        #ifdef ENEMIES_PURSUIT_COLLIDE
                            if CheckCollision(enemyCol + horizontalDirection, enemyLin) Then horizontalDirection = 0
                            if CheckCollision(enemyCol, enemyLin + verticalDirection) Then verticalDirection = 0
                        #endif
                    End if
                #endif
                #ifdef ENEMIES_ANTICLOCKWISE_ENABLED
                ElseIf enemyMode = ENEMY_MODE_ANTICLOCKWISE Then
                    If enemyColIni = enemyCol Then
                        If enemyLinIni = enemyLin Then
                            ' Esquina sup iz
                            verticalDirection = 1
                            horizontalDirection = 0
                        Elseif enemyLinEnd = enemyLin Then
                            ' Esquina inf iz
                            horizontalDirection = 1
                            verticalDirection = 0
                        End If
                    Elseif enemyColEnd = enemyCol Then
                        If enemyLinEnd = enemyLin Then
                            ' Esquina inf der
                            verticalDirection = -1
                            horizontalDirection = 0
                        Elseif enemyLinIni = enemyLin Then
                            ' Esquina sup der
                            horizontalDirection = -1
                            verticalDirection = 0
                        End If
                    End if
                #endif
                #ifdef ENEMIES_CLOCKWISE_ENABLED
                Elseif enemyMode = ENEMY_MODE_CLOCKWISE Then
                    If enemyColIni = enemyCol Then
                        If enemyLinIni = enemyLin Then
                            ' Esquina sup iz
                            verticalDirection = 0
                            horizontalDirection = 1
                        Elseif enemyLinEnd = enemyLin Then
                            ' Esquina inf iz
                            horizontalDirection = 0
                            verticalDirection = -1
                        End If
                    Elseif enemyColEnd = enemyCol Then
                        If enemyLinEnd = enemyLin Then
                            ' Esquina inf der
                            verticalDirection = 0
                            horizontalDirection = -1
                        Elseif enemyLinIni = enemyLin Then
                            ' Esquina sup der
                            horizontalDirection = 0
                            verticalDirection = 1
                        End If
                    End if
                #endif
                #ifdef ENEMIES_ONE_DIRECTION_ENABLED
                ElseIf enemyMode = ENEMY_MODE_ONEDIRECTION Then
                    If enemyColEnd = enemyCol And enemyLinEnd = enemyLin Then
                        enemyCol = enemyColIni
                        enemyLin = enemyLinIni
                    End If
                #endif
                #ifdef ENEMIES_TRAP_ENABLED
                ElseIf enemyMode >= ENEMY_MODE_TRAP_ALL Then
                    If enemyColIni = enemyCol And enemyLinIni = enemyLin Then
                        #ifdef ENEMIES_TRAP_VERTICAL_ENABLED
                            if enemyCol = protaX or enemyLinEnd Then
                                if enemyMode <> ENEMY_MODE_TRAP_HORIZONAL Then
                                    verticalDirection = Sgn(protaY - enemyLin)
                                end if
                            end if
                        #endif
                        
                        #ifdef ENEMIES_TRAP_HORIZONTAL_ENABLED
                            if enemyLin = protaY or enemyColEnd Then
                                if enemyMode <> ENEMY_MODE_TRAP_VERTICAL Then
                                    horizontalDirection = Sgn(protaX - enemyCol)
                                end if
                            end if
                        #endif
                    Elseif enemyLin = MAX_LINE or enemyLin = 0 or enemyCol = 60 or enemyCol = 0 Then
                        enemyCol = enemyColIni
                        enemyLin = enemyLinIni
                        verticalDirection = 0
                        horizontalDirection = 0
                    End if
                #endif
            End if
            
            enemyCol = enemyCol + horizontalDirection
            enemyLin = enemyLin + verticalDirection
            
            ' Is a platform Not an enemy, only 2 frames, 1 direction
            #ifdef SIDE_VIEW
                If tile < 17 Then
                    if jumpCurrentKey = jumpStopValue Then
                        If checkPlatformHasProtaOnTop(enemyCol, enemyLin) Then
                            #ifdef PLATFORM_MOVEABLE
                                if enemySpeed = 3 and not verticalDirection and not horizontalDirection Then
                                    if downKeyPressed Then
                                        If protaY - 1 > 2 and Not CheckCollision(protaX, protaY - 1) Then enemyLin = enemyLin - 1
                                    ElseIf Not CheckCollision(protaX, protaY + 3) and enemyLin < 40 Then
                                        enemyLin = enemyLin + 1
                                    End If
                                    
                                    enemyCol = protaX
                                    protaY = enemyLin - 4
                                    isOnPlatform = tile
                                Else
                                    If Not CheckCollision(protaX, protaY + verticalDirection) Then
                                        protaY = enemyLin - 4
                                    End if
                                    
                                    If horizontalDirection Then
                                        If Not CheckCollision(protaX + horizontalDirection, protaY) Then
                                            protaX = protaX + horizontalDirection
                                        End If
                                    End If
                                End if
                            #Else
                                If Not CheckCollision(protaX, protaY + verticalDirection) Then
                                    protaY = enemyLin - 4
                                End if
                                
                                If horizontalDirection Then
                                    If Not CheckCollision(protaX + horizontalDirection, protaY) Then
                                        protaX = protaX + horizontalDirection
                                    End If
                                End If
                            #endif
                        End If
                    End If
                End if
            #endif
            
            
            ' se guarda el estado final del enemigo
            'if enemyMode <> 2 And enemyMode <> 3 Then
            decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = horizontalDirection
            decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = verticalDirection
            'End if
            decompressedEnemiesScreen(enemyId, ENEMY_MODE) = enemyMode
            
            EnemiesFinal:
            
            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyCol
            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLin

            #ifdef ENEMIES_TRAP_ENABLED
            If enemyMode >= ENEMY_MODE_TRAP_ALL Then
                if not horizontalDirection and not verticalDirection Then Continue For
            End if
            #endif

            if tile > 16 and horizontalDirection = -1 Then tile = tile + 16
            
            If enemiesFrame > 4 Then tile = tile + 1
            
            If enemyLive = -100 or enemyLive > 0 Then
                #ifdef BULLET_ENEMIES
                    #ifndef BULLET_ENEMIES_MUST_LOOK
                        if tile < 17 then Draw2x2Sprite(tile, enemyCol, enemyLin)
                        #ifndef BULLET_ENEMIES_LOOK_AT
                            Draw2x2Sprite(tile, enemyCol, enemyLin)
                        #endif
                    #else
                        Draw2x2Sprite(tile, enemyCol, enemyLin)
                    #endif
                #Else
                    Draw2x2Sprite(tile, enemyCol, enemyLin)
                #endif
                
                
                if tile > 16 and Not invincible Then
                    checkProtaCollision(enemyId, enemyCol, enemyLin, enemyLive)
                    
                    #ifdef BULLET_ENEMIES
                        if not enemyBullets(enemyId, 0) and (tile mod 17) < BULLET_ENEMIES_RANGE then
                            #ifdef BULLET_ENEMIES_DIRECTION_HORIZONTAL
                                if enemyLin > (protaY-2) and enemyLin < (protaY+4) Then
                                    #ifndef BULLET_ENEMIES_MUST_LOOK
                                        #ifdef BULLET_ENEMIES_LOOK_AT
                                            dim lookDirection as ubyte = decompressedEnemiesScreen(enemyId, ENEMY_TILE) + 1
                                        #endif
                                        
                                        if enemyCol < protaX Then
                                            enemyShoot(enemyId,enemyCol, enemyLin, BULLET_DIRECTION_RIGHT)
                                        else
                                            #ifdef BULLET_ENEMIES_LOOK_AT
                                                lookDirection = lookDirection + 16
                                            #endif
                                            enemyShoot(enemyId,enemyCol, enemyLin, BULLET_DIRECTION_LEFT)
                                        End if
                                        
                                        #ifdef BULLET_ENEMIES_LOOK_AT
                                            Draw2x2Sprite(lookDirection, enemyCol, enemyLin)
                                        #endif
                                        
                                        continue for
                                    #else
                                        if enemyCol < protaX and horizontalDirection = 1 Then
                                            enemyShoot(enemyId,enemyCol, enemyLin, BULLET_DIRECTION_RIGHT)
                                            continue for
                                        elseif enemyCol > protaX and horizontalDirection = -1 Then
                                            enemyShoot(enemyId,enemyCol, enemyLin, BULLET_DIRECTION_LEFT)
                                            continue for
                                        end if
                                    #endif
                                End if
                            #endif
                            #ifdef BULLET_ENEMIES_DIRECTION_VERTICAL
                                if enemyCol > (protaX-2) and enemyCol < (protaX+4) Then
                                    #ifndef BULLET_ENEMIES_MUST_LOOK
                                        #ifdef BULLET_ENEMIES_LOOK_AT
                                            Draw2x2Sprite(tile, enemyCol, enemyLin)
                                        #endif
                                    #endif
                                    
                                    #ifndef BULLET_ENEMIES_MUST_LOOK
                                        if enemyLin < protaY Then
                                            enemyShoot(enemyId,enemyCol, enemyLin, BULLET_DIRECTION_DOWN)
                                        else
                                            enemyShoot(enemyId,enemyCol, enemyLin, BULLET_DIRECTION_UP)
                                        end if
                                        
                                        continue for
                                    #Else
                                        if enemyLin < protaY and verticalDirection = 1 Then
                                            enemyShoot(enemyId,enemyCol, enemyLin, BULLET_DIRECTION_DOWN)
                                            continue for
                                        elseif enemyLin > protaY and verticalDirection = -1 Then
                                            enemyShoot(enemyId,enemyCol, enemyLin, BULLET_DIRECTION_UP)
                                            continue for
                                        end if
                                    #endif
                                end if
                            #endif
                        end if
                    #endif
                End if
                
                #ifdef BULLET_ENEMIES
                    #ifndef BULLET_ENEMIES_MUST_LOOK
                        #ifdef BULLET_ENEMIES_LOOK_AT
                            Draw2x2Sprite(tile, enemyCol, enemyLin)
                        #endif
                    #endif
                #endif
            Else
                ' #ifdef ENEMIES_SLOW_DOWN
                '     Draw2x2Sprite(tile, enemyCol, enemyLin)
                ' #else
                    #ifdef ENEMIES_RESPAWN_IN_SCREEN_ENABLED
                        if enemyLive > -30 and enemiesFrame bAnd 1 Then Draw2x2Sprite(tile, enemyCol, enemyLin)
                    #endif
                ' #endif
            End if
        Next enemyId

        ' #ifdef ENEMIES_RESPAWN_IN_SCREEN_ENABLED
        firstTimeEnemiesScreen = 0
        ' #endif
    End if
End Sub

Sub checkProtaCollision(enemyId As Ubyte, enemyX0 As Ubyte, enemyY0 As Ubyte, enemyLive As Ubyte)
    'If invincible Then Return
    
    If (protaX + 2) < enemyX0 Or protaX > (enemyX0 + 2) Then Return
    
    #ifdef SIDE_VIEW
        #ifdef JUMP_ON_ENEMIES
            If (protaY + 4) > (enemyY0 - 2) And (protaY + 4) < (enemyY0 + 2) Then
                #ifdef KILL_JUMPING_ON_TOP
                    if enemyLive <> -100 Then damageEnemy(enemyId)
                #endif
                landed = 1
                jumpCurrentKey = jumpStopValue
                jump()
                Return
            End if
        #endif
    #endif
    
    If (protaY + 2) < (enemyY0) Or protaY > (enemyY0 + 2) Then Return
    
    decrementLife()
End Sub
