#ifdef SIDE_VIEW
    Function checkPlatformHasProtaOnTop(x As Ubyte, y As Ubyte) As Ubyte
        If (protaX + 2) < x Or protaX > (x + 2) Then Return 0
        If (protaY + 4) > (y - 2) And (protaY + 4) < (y + 2) Then Return 1
        
        Return 0
    End Function

    Function checkPlatformByXY(x As Ubyte, y As Ubyte) As Ubyte
        If not enemiesScreen Then Return 0
        
        For enemyId=0 To enemiesScreen - 1
            If decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 Then
                If y <> decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) Then continue For
                
                Dim enemyCol As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
                
                If (x + 2) < enemyCol Or x > (enemyCol + 3) Then continue For
                
                Return 1
            End If
        Next enemyId
        
        Return 0
    End Function
#endif

dim enemiesFrame as ubyte = 0

Sub moveEnemies()
    If enemiesScreen Then
        enemiesFrame = enemiesFrame + 1
        if enemiesFrame > 9 Then enemiesFrame = 1
        For enemyId=0 To enemiesScreen- 1
            Dim tile As Byte = decompressedEnemiesScreen(enemyId, ENEMY_TILE)
            Dim enemyLive As Byte = decompressedEnemiesScreen(enemyId, ENEMY_ALIVE)
            
            If tile = 0 Then continue For
            #ifdef ENEMIES_NOT_RESPAWN_ENABLED
                If enemyLive <> 99 And tile > 15 Then
                    If screensWon(currentScreen) Then continue For
                End If
            #endif
            
            'In the Screen And still live
            If enemyLive > 0 Then
                Dim enemySpeed As Byte = decompressedEnemiesScreen(enemyId, ENEMY_SPEED)
                Dim horizontalDirection As Byte = decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)
                Dim enemyCol As Byte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
                Dim enemyLin As Byte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
                
                If (enemySpeed = 1 and (enemiesFrame bAnd 3) <> 3) or (enemySpeed = 2 and (enemiesFrame bAnd 1) = 1) Then 
                    Draw2x2Sprite(getSpriteTile(enemyId), enemyCol, enemyLin)
                    continue For
                End If
            
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
                        horizontalDirection = 0
                        verticalDirection = 0
                        if invincible Then
                            enemyCol = enemyColIni
                            enemyLin = enemyLinIni
                            
                            #ifdef ENEMIES_ALERT_ENABLED
                                if enemyMode = 3 Then enemyMode = 1
                            #endif
                        Else
                            If protaX <> enemyCol Then
                                If protaX > enemyCol Then horizontalDirection = 1 Else horizontalDirection = -1
                                
                                #ifdef OVERHEAD_VIEW
                                    if CheckCollision(enemyCol + horizontalDirection, enemyLin) Then horizontalDirection = 0
                                #endif
                            End If
                            
                            If protaY <> enemyLin Then
                                If protaY > enemyLin Then verticalDirection = 1 Else verticalDirection = -1
                                
                                #ifdef OVERHEAD_VIEW
                                    if CheckCollision(enemyCol, enemyLin + verticalDirection) Then verticalDirection = 0
                                #endif
                            End If
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
                        If checkPlatformHasProtaOnTop(enemyCol, enemyLin) Then
                            jumpCurrentKey = jumpStopValue
                            If verticalDirection Then
                                protaY = enemyLin - 4
                            
                                ' If protaY < 2 Then moveScreen = 8
                            End If
                            
                            If horizontalDirection Then
                                If Not CheckCollision(protaX + horizontalDirection, protaY) Then
                                    protaX = protaX + horizontalDirection
                                End If
                            End If
                        End If
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
                Draw2x2Sprite(getSpriteTile(enemyId), getSpriteCol(enemyId), getSpriteLin(enemyId))
            End If
        Next enemyId
        
        'checkEnemiesCollection()
        If Not invincible Then
            For enemyId=0 To enemiesScreen - 1
                Dim vidaColision As Byte = decompressedEnemiesScreen(enemyId, ENEMY_ALIVE)
            
                If decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 or vidaColision = 0 Then continue For
                
                #ifdef ENEMIES_NOT_RESPAWN_ENABLED
                    If vidaColision <> 99 Then
                        If screensWon(currentScreen) Then continue For
                    End If
                #endif
                
                checkProtaCollision(enemyId)
            Next enemyId
        End If
    End if
End Sub


Sub checkProtaCollision(enemyId As Ubyte)
    Dim enemyX0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
    Dim enemyY0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
    
    If (protaX + 2) < enemyX0 Or protaX > (enemyX0 + 2) Then Return

    #ifdef SIDE_VIEW 
        #ifdef KILL_JUMPING_ON_TOP
            If (protaY + 4) > (enemyY0 - 2) And (protaY + 4) < (enemyY0 + 2) Then
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

' #ifdef SIDE_VIEW
'     Function checkPlatformByXY(x As Ubyte, y As Ubyte) As Ubyte
'         If not enemiesScreen Then Return 0
        
'         For enemyId=0 To enemiesScreen - 1
'             If decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 Then
'                 Dim enemyCol As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
                 
'                 If (x + 3) < enemyCol Or x > enemyCol + 3 Or y <> decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) Then continue For
                
'                 Return 1
'             End If
'         Next enemyId
        
'         Return 0
'     End Function
' #endif