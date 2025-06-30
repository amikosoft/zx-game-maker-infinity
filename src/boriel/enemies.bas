#ifdef SIDE_VIEW
    Function checkPlatformHasProtaOnTop(x As Ubyte, y As Ubyte) As Ubyte
        If (protaX + 3) < x Or protaX > (x + 3) Then Return 0
        If (protaY + 4) > (y - 2) and (protaY + 4) < (y + 3) Then Return 1
        
        Return 0
    End Function
    
    Function checkPlatformByXY(protaX As Ubyte, protaY4 As Ubyte) As Ubyte
        If enemiesScreen = 0 Then Return 0
        
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
    Sub enemyShoot(posX as ubyte, posY as ubyte, direction as byte)
        If direction = BULLET_DIRECTION_RIGHT Then
            enemyBulletPositionX = posX + 2
            enemyBulletPositionY = posY + 1
            enemyBulletEndPositionX = MAX_SCREEEN_RIGHT
        Elseif direction = BULLET_DIRECTION_LEFT
            enemyBulletPositionX = posX
            enemyBulletPositionY = posY + 1
            enemyBulletEndPositionX = MAX_SCREEN_LEFT
        Elseif direction = BULLET_DIRECTION_UP
            enemyBulletPositionX = posX + 1
            enemyBulletPositionY = posY + 1
            enemyBulletEndPositionY = MAX_SCREEN_TOP
        Else
            enemyBulletPositionX = posX + 1
            enemyBulletPositionY = posY + 2
            enemyBulletEndPositionY = MAX_SCREEN_BOTTOM
        End If
        
        enemyBulletDirection = direction
        BeepFX_Play(2)
    End Sub
#endif

function checkEnemyBullet(enemyId as ubyte, enemyCol as ubyte, enemyLin as ubyte) as Ubyte
    if (bulletPositionX + 1) < enemyCol or bulletPositionX > (enemyCol + 2) then return 0
    if (bulletPositionY + 1) < enemyLin or bulletPositionY > (enemyLin+2) then return 0
    
    resetBullet(0)
    damageEnemy(enemyId)
    return 1
end function

#ifndef ENABLED_128
    dim enemiesFrame as ubyte = 0
#endif

Sub moveEnemies()
    If enemiesScreen Then
        #ifndef ENABLED_128
            enemiesFrame = enemiesFrame + 1
            if enemiesFrame > 9 Then enemiesFrame = 1
        #endif
        For enemyId=0 To enemiesScreen- 1
            Dim tile As Byte = decompressedEnemiesScreen(enemyId, ENEMY_TILE)
            Dim enemyLive As Byte = decompressedEnemiesScreen(enemyId, ENEMY_ALIVE)
            Dim enemyCol As Byte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
            Dim enemyLin As Byte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
            
            If tile = 0 Then continue For
            #ifdef ENEMIES_NOT_RESPAWN_ENABLED
                If enemyLive <> 99 And tile > 15 Then
                    If screensWon(currentScreen) Then continue For
                End If
            #endif
            
            ' Se comprueba si tiene colision de bala
            if enemyLive > 0 And tile > 15 and bulletPositionX Then
                if checkEnemyBullet(enemyId, enemyCol, enemyLin) Then
                    enemyLive = enemyLive - 1
                End if
            End If
            
            'In the Screen And still live
            If enemyLive > 0 Then
                Dim enemySpeed As Byte = decompressedEnemiesScreen(enemyId, ENEMY_SPEED)
                Dim horizontalDirection As Byte = decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)
                
                #ifdef ENABLED_128
                    If (enemySpeed = 1 and (framec bAnd 3) <> 3) or (enemySpeed = 2 and (framec bAnd 1) = 1) Then
                        Draw2x2Sprite(spritesLinColTileAndFrame(enemyId, 2), enemyCol, enemyLin)
                        if tile > 15 and not invincible Then checkProtaCollision(enemyId, enemyCol, enemyLin)
                        continue For
                    End If
                #Else
                    If (enemySpeed = 1 and (enemiesFrame bAnd 3) <> 3) or (enemySpeed = 2 and (enemiesFrame bAnd 1) = 1) Then
                        Draw2x2Sprite(spritesLinColTileAndFrame(enemyId, 2), enemyCol, enemyLin)
                        if tile > 15 and not invincible Then checkProtaCollision(enemyId, enemyCol, enemyLin)
                        continue For
                    End If
                #endif
                Dim enemyMode As Byte = decompressedEnemiesScreen(enemyId, ENEMY_MODE)
                Dim enemyColIni As Byte = decompressedEnemiesScreen(enemyId, ENEMY_COL_INI)
                Dim enemyLinIni As Byte = decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI)
                Dim enemyColEnd As Byte = decompressedEnemiesScreen(enemyId, ENEMY_COL_END)
                Dim enemyLinEnd As Byte = decompressedEnemiesScreen(enemyId, ENEMY_LIN_END)
                Dim verticalDirection As Byte = decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION)
                
                if enemyMode < 2 Then
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
                    
                    #ifdef ENEMIES_ALERT_ENABLED
                        If Not invincible And enemyMode = 1 Then
                            If Abs(protaX - enemyCol) < ENEMIES_ALERT_DISTANCE And Abs(protaY - enemyLin) < (ENEMIES_ALERT_DISTANCE * 2) Then
                                enemyMode = 3
                            End if
                        End if
                    #endif
                    #ifdef ENEMIES_PURSUIT_ENABLED
                    ElseIf enemyMode < 4 Then
                        if invincible Then
                            horizontalDirection = 0
                            verticalDirection = 0
                        Else
                            horizontalDirection = Sgn(protaX - enemyCol)
                            verticalDirection = Sgn(protaY - enemyLin)
                            
                            #ifdef OVERHEAD_VIEW
                                if CheckCollision(enemyCol + horizontalDirection, enemyLin) Then horizontalDirection = 0
                                if CheckCollision(enemyCol, enemyLin + verticalDirection) Then verticalDirection = 0
                            #endif
                        End if
                    #endif
                    #ifdef ENEMIES_ONE_DIRECTION_ENABLED
                    ElseIf enemyMode = 4 Then
                        If enemyColEnd = enemyCol And enemyLinEnd = enemyLin Then
                            enemyCol = enemyColIni
                            enemyLin = enemyLinIni
                        End If
                    #endif
                    #ifdef ENEMIES_ANTICLOCKWISE_ENABLED
                    ElseIf enemyMode = 5 Then
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
                    Elseif enemyMode = 6 Then
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
                End if
                
                enemyCol = enemyCol + horizontalDirection
                enemyLin = enemyLin + verticalDirection
                
                ' Is a platform Not an enemy, only 2 frames, 1 direction
                If tile < 16 Then
                    #ifdef SIDE_VIEW
                        if landed Then
                            If jumpCurrentKey = jumpStopValue and checkPlatformHasProtaOnTop(enemyCol, enemyLin) Then
                                ' If verticalDirection Then
                                protaY = enemyLin - 4
                                
                                ' If protaY < 2 Then moveScreen = 8
                                ' End If
                                
                                If horizontalDirection Then
                                    If Not CheckCollision(protaX + horizontalDirection, protaY) Then
                                        protaX = protaX + horizontalDirection
                                    End If
                                End If
                            End If
                        End if
                    #endif
                Elseif horizontalDirection = -1 Then
                    tile = tile + 16
                End If
                
                If enemFrame Then
                    tile = tile + 1
                End If
                
                ' se guarda el estado final del enemigo
                'if enemyMode <> 2 And enemyMode <> 3 Then
                decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = horizontalDirection
                decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = verticalDirection
                'End if
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyCol
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLin
                decompressedEnemiesScreen(enemyId, ENEMY_MODE) = enemyMode
                
                ' se actualiza el sprite
                saveSprite(enemyId, enemyLin, enemyCol, tile + 1, horizontalDirection)
                Draw2x2Sprite(tile + 1, enemyCol, enemyLin)

                if tile > 15 and Not invincible Then
                    checkProtaCollision(enemyId, enemyCol, enemyLin)
                    
                    #ifdef BULLET_ENEMIES
                        if enemyBulletPositionX = 0 then
                            if (tile mod 16) < BULLET_ENEMIES_RANGE Then
                                if enemyLin > (protaY-2) and enemyLin < (protaY+4) Then
                                    if enemyCol < protaX Then
                                        enemyShoot(enemyCol, enemyLin, BULLET_DIRECTION_RIGHT)
                                    else
                                        enemyShoot(enemyCol, enemyLin, BULLET_DIRECTION_LEFT)
                                    End if
                                elseif enemyCol > (protaX-2) and enemyCol < (protaX+4) Then
                                    if enemyLin < protaY Then
                                        enemyShoot(enemyCol, enemyLin, BULLET_DIRECTION_DOWN)
                                    else
                                        enemyShoot(enemyCol, enemyLin, BULLET_DIRECTION_UP)
                                    end if
                                end if
                            End if
                        end if
                    #endif
                End if
            End If
        Next enemyId
    End if
End Sub

Sub checkProtaCollision(enemyId As Ubyte, enemyX0 As Ubyte, enemyY0 As Ubyte)
    'If invincible Then Return
    
    If (protaX + 2) < enemyX0 Or protaX > (enemyX0 + 2) Then Return
    
    #ifdef SIDE_VIEW
        #ifdef KILL_JUMPING_ON_TOP
            If (protaY + 4) > (enemyY0 - 2) And (protaY + 4) < (enemyY0 + 2) Then
                damageEnemy(enemyId)
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
