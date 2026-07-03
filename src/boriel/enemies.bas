Dim enemyModeBucle, enemyColBucle, enemyLinBucle, enemyColIniBucle, enemyLinIniBucle, enemySpeedBucle, _ 
    enemyLiveBucle, enemyColEndBucle, enemyLinEndBucle, horizontalDirectionBucle, verticalDirectionBucle, _
    tileBucle As Byte

#ifdef SIDE_VIEW
    Function checkPlatformHasProtaOnTop(x As Ubyte, y As Ubyte) As Ubyte
        If (protaX + 3) < x Or protaX > (x + 3) Then Return 0
        If (protaY + 4) > (y - 2) and (protaY + 4) < (y + 3) Then Return 1
        
        Return 0
    End Function
    
    Function checkPlatformByXY() As Ubyte
        If enemiesScreen Then 
            dim protaY4 As Ubyte = protaY + 4

            For enemyId=0 To enemiesScreen - 1
                'ENEMY_PLATFORM
                #ifdef ENEMIES_PLATFORM_ENABLED
                    If decompressedEnemiesScreen(enemyId, ENEMY_PLATFORM) Then
                #else
                    If decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 Then
                #endif
                    Dim enemyCol As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
                    Dim enemyLin As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
                    
                    If (protaX + 3) < enemyCol Or protaX > (enemyCol + 3) Then continue for
                    If protaY4 < enemyLin or protaY4 > (enemyLin + 1) Then continue For

                    Return 1
                End If
            Next enemyId
        end if
        Return 0
    End Function
#endif

#ifdef BULLET_ENEMIES
    ' Sub enemyShoot(bulletId as ubyte, posX as ubyte, posY as ubyte, direction as byte)
    '     If direction = BULLET_DIRECTION_RIGHT Then
    '         enemyBullets(bulletId, 0) = posX + 2
    '         enemyBullets(bulletId, 1) = posY + 1
    '     Elseif direction = BULLET_DIRECTION_LEFT
    '         enemyBullets(bulletId, 0) = posX
    '         enemyBullets(bulletId, 1) = posY + 1
    '     Elseif direction = BULLET_DIRECTION_UP
    '         enemyBullets(bulletId, 0) = posX + 1
    '         enemyBullets(bulletId, 1) = posY + 1
    '     Else
    '         enemyBullets(bulletId, 0) = posX + 1
    '         enemyBullets(bulletId, 1) = posY + 2
    '     End If
        
    '     enemyBullets(bulletId, 2) = direction
    '     BeepFX_Play(2)
    ' End Sub

    Sub enemyShoot(bulletId as ubyte, direction as byte)
        enemyBullets(bulletId, 2) = 0
        enemyBullets(bulletId, 3) = 0

        if not direction or direction = 1 then
            enemyBullets(bulletId, 2) = sgn(protaX - enemyColBucle)
        end if
        
        if not direction or direction = 2 then
            enemyBullets(bulletId, 3) = sgn(protaY - enemyLinBucle)
        end if
        
        enemyBullets(bulletId, 0) = enemyColBucle + 1 + enemyBullets(bulletId, 2)
        enemyBullets(bulletId, 1) = enemyLinBucle + 1 + enemyBullets(bulletId, 3)
        
        BeepFX_Play(2)
    End Sub
#endif

#ifdef SHOOTING_ENABLED
    function checkEnemyBullet(enemyId as ubyte) as Ubyte
        if (bulletPositionX + 1) < enemyColBucle or bulletPositionX > (enemyColBucle + 2) then return 0
        if (bulletPositionY + 1) < enemyLinBucle or bulletPositionY > (enemyLinBucle + 2) then return 0
        
        resetBullet()
        damageEnemy(enemyId)
        return 1
    end function
#endif


#ifdef ENEMIES_PLATFORM_ENABLED
Dim enemyPlatformBucle as byte
#endif

#ifdef ENEMIES_RANDOM_MOVEMENTS
Dim enemyChangeModeTimer as ubyte = 255
#endif

Sub moveEnemies()
    #ifdef PLATFORM_MOVEABLE
        isOnPlatform = 0
    #endif

    #ifdef SPRITES_COLOR_ENABLED
        Dim colorBucle as ubyte = currentScreenBackground
    #endif 

    enemiesFrame = enemiesFrame + 1
    if enemiesFrame > 9 Then enemiesFrame = 1

    #ifdef ENEMIES_RANDOM_MOVEMENTS
    enemyChangeModeTimer = enemyChangeModeTimer - 1
    #endif

    If enemiesScreen Then
        isPlayerBucle = 0
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
            
            tileBucle = decompressedEnemiesScreen(enemyId, ENEMY_TILE) + 1
            
            If not tileBucle Then continue For

            #ifdef BULLET_ENEMIES
                if moveEnemyBullet(enemyId) Then Draw1x1Sprite(BULLET_SPRITE_ENEMY_ID, enemyBullets(enemyId, 0), enemyBullets(enemyId, 1))
            #endif

            enemyLiveBucle = decompressedEnemiesScreen(enemyId, ENEMY_ALIVE)
            
            If not enemyLiveBucle Then continue For
            
            #ifdef ENEMIES_PLATFORM_ENABLED
                enemyPlatformBucle = decompressedEnemiesScreen(enemyId, ENEMY_PLATFORM)
            #endif

            #ifndef ENEMIES_SLOW_DOWN
                #ifdef ENEMIES_NOT_RESPAWN_ENABLED
                    'ENEMY_PLATFORM
                    #ifdef ENEMIES_PLATFORM_ENABLED
                        If enemyLiveBucle > 0 and not enemyPlatformBucle Then
                            If screensStatus(currentScreen) = SCREEN_STATUS_COMPLETED Then continue For
                        End If
                    #else
                        If enemyLiveBucle > 0 and tileBucle > 16 Then
                            If screensStatus(currentScreen) = SCREEN_STATUS_COMPLETED Then continue For
                        End If
                    #endif
                #endif
            #endif

            enemyModeBucle = decompressedEnemiesScreen(enemyId, ENEMY_MODE)
            enemyColBucle = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
            enemyLinBucle = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
            enemyColIniBucle = decompressedEnemiesScreen(enemyId, ENEMY_COL_INI)
            enemyLinIniBucle = decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI)
            enemySpeedBucle = decompressedEnemiesScreen(enemyId, ENEMY_SPEED)

            #ifdef SPRITES_COLOR_ENABLED
                #ifdef ENEMIES_COLOR_ENABLED
                    if decompressedEnemiesScreen(enemyId, ENEMY_COLOR) then 
                        colorBucle = decompressedEnemiesScreen(enemyId, ENEMY_COLOR)
                    end if
                #endif
            #endif

            #ifdef ENEMIES_SLOW_DOWN
                if enemyLiveBucle > -100 and enemyLiveBucle < 0 then
                    if enemySpeedBucle < 3 Then
                        enemyLiveBucle = enemyLiveBucle + 1

                        if not enemyLiveBucle Then
                            enemySpeedBucle = enemySpeedBucle + 1
                            decompressedEnemiesScreen(enemyId, ENEMY_SPEED) = enemySpeedBucle
                            if enemySpeedBucle < 3 Then 
                                enemyLiveBucle = -50
                            Else
                                enemyLiveBucle = 1
                            end if
                        end if

                        decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) = enemyLiveBucle
                    end if

                    ' siempre tiene que tener vida
                    enemyLiveBucle = 1
                end if

                #ifdef SHOOTING_ENABLED
                    if bulletPositionX and enemyLiveBucle > 0  then
                        checkEnemyBullet(enemyId)
                    End If
                #endif
            #else
                #ifdef ENEMIES_RESPAWN_IN_SCREEN_ENABLED
                    if enemyLiveBucle > -100 and enemyLiveBucle < 1 then
                        enemyLiveBucle = enemyLiveBucle + 1
                        
                        if not enemyLiveBucle Then
                            enemyLiveBucle = enemiesInitialLife(enemyId)
                        end if
                        decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) = enemyLiveBucle
                        
                        if enemyModeBucle = ENEMY_MODE_PURSUIT Then
                            enemyColBucle = enemyColIniBucle
                            enemyLinBucle = enemyLinIniBucle
                            GO TO EnemiesFinal
                        End if
                        #ifdef SHOOTING_ENABLED
                        Else
                            ' Se comprueba si tiene colision de bala
                            if bulletPositionX and enemyLiveBucle > 0 then
                                if checkEnemyBullet(enemyId) Then
                                    enemyLiveBucle = enemyLiveBucle - 1
                                End if
                            End If
                        #endif
                    End if
                #else
                    ' Se comprueba si tiene colision de bala
                    #ifdef SHOOTING_ENABLED
                        if bulletPositionX and enemyLiveBucle > 0 then
                            if checkEnemyBullet(enemyId) Then
                                enemyLiveBucle = enemyLiveBucle - 1
                            End if
                        End If
                    #endif
                #endif
            #endif
            
            'Dim enemySpeedBucle As Byte = decompressedEnemiesScreen(enemyId, ENEMY_SPEED)
            horizontalDirectionBucle = decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)
            verticalDirectionBucle = decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION)
            
            #ifdef ENEMIES_SLOW_DOWN
                If not enemySpeedBucle or (enemySpeedBucle = 1 and (enemiesFrame bAnd 3) <> 3) or (enemySpeedBucle = 2 and (enemiesFrame bAnd 1) = 1) Then
                    GO TO EnemiesFinal
                End If
            #else
                If (enemySpeedBucle = 1 and (enemiesFrame bAnd 3) <> 3) or (enemySpeedBucle = 2 and (enemiesFrame bAnd 1) = 1) Then
                    GO TO EnemiesFinal
                End If
            #endif
            
            enemyColEndBucle = decompressedEnemiesScreen(enemyId, ENEMY_COL_END)
            enemyLinEndBucle = decompressedEnemiesScreen(enemyId, ENEMY_LIN_END)
            
            #ifdef ENEMIES_RANDOM_MOVEMENTS
                #ifdef ENEMIES_PLATFORM_ENABLED
                    if not enemyPlatformBucle and not enemyChangeModeTimer then
                        if enemyModeBucle < ENEMY_MODE_TRAP_ALL and enemyModeBucle <> ENEMY_MODE_ONEDIRECTION then
                            If enemyColIniBucle <> enemyColBucle and enemyColEndBucle <> enemyColBucle Then
                                horizontalDirectionBucle = horizontalDirectionBucle * -1
                            End If

                            If enemyLinIniBucle <> enemyLinBucle and enemyLinEndBucle <> enemyLinBucle Then
                                verticalDirectionBucle = verticalDirectionBucle * -1
                            End If
                        end if
                    end if
                #else
                    if tile > 16 and enemyModeBucle <> ENEMY_MODE_ONEDIRECTION and not enemyChangeModeTimer then
                        if enemyModeBucle < ENEMY_MODE_TRAP_ALL and enemyModeBucle <> ENEMY_MODE_ONEDIRECTION then
                            If enemyColIniBucle <> enemyColBucle and enemyColEndBucle <> enemyColBucle Then
                                horizontalDirectionBucle = horizontalDirectionBucle * -1
                            End If

                            If enemyLinIniBucle <> enemyLinBucle and enemyLinEndBucle <> enemyLinBucle Then
                                verticalDirectionBucle = verticalDirectionBucle * -1
                            End If
                        end if
                    end if
                #endif
            #endif

            if enemyModeBucle < ENEMY_MODE_PURSUIT Then
                If horizontalDirectionBucle Then
                    If enemyColIniBucle = enemyColBucle Or enemyColEndBucle = enemyColBucle Then
                        horizontalDirectionBucle = horizontalDirectionBucle * -1
                    End If
                End If
                
                If verticalDirectionBucle Then
                    If enemyLinIniBucle = enemyLinBucle Or enemyLinEndBucle = enemyLinBucle Then
                        verticalDirectionBucle = verticalDirectionBucle * -1
                    End If
                End If

                #ifdef ENEMIES_NORMAL_COLLIDE
                    dim counter as byte = 0
                    while counter < 3 and CheckCollision(enemyColBucle + horizontalDirectionBucle, enemyLinBucle + verticalDirectionBucle)
                        if not counter Then 
                            horizontalDirectionBucle = horizontalDirectionBucle * -1
                        Elseif counter = 1 Then
                            horizontalDirectionBucle = horizontalDirectionBucle * -1 
                            verticalDirectionBucle = verticalDirectionBucle * -1       
                        Else
                            horizontalDirectionBucle = horizontalDirectionBucle * -1       
                        end if

                        counter = counter +1
                    Wend
                #endif
                
                #ifdef ENEMIES_ALERT_ENABLED
                    If Not invincible And enemyModeBucle = ENEMY_MODE_ALERT Then
                        If Abs(protaX - enemyColBucle) < ENEMIES_ALERT_DISTANCE And Abs(protaY - enemyLinBucle) < (ENEMIES_ALERT_DISTANCE * 2) Then
                            enemyModeBucle = ENEMY_MODE_PURSUIT
                        End if
                    End if
                #endif
                #ifdef ENEMIES_PURSUIT_ENABLED
                ElseIf enemyModeBucle = ENEMY_MODE_PURSUIT Then
                    if invincible Then
                        horizontalDirectionBucle = Sgn(enemyColIniBucle - enemyColBucle)
                        verticalDirectionBucle = Sgn(enemyLinIniBucle - enemyLinBucle)
                    Else
                        horizontalDirectionBucle = Sgn(protaX - enemyColBucle)
                        verticalDirectionBucle = Sgn(protaY - enemyLinBucle)
                    End if

                    #ifdef ENEMIES_PURSUIT_COLLIDE
                        if CheckCollision(enemyColBucle + horizontalDirectionBucle, enemyLinBucle) Then horizontalDirectionBucle = 0
                        if CheckCollision(enemyColBucle, enemyLinBucle + verticalDirectionBucle) Then verticalDirectionBucle = 0
                    #endif
                #endif
                #ifdef ENEMIES_ANTICLOCKWISE_ENABLED
                ElseIf enemyModeBucle = ENEMY_MODE_ANTICLOCKWISE Then
                    If enemyColIniBucle = enemyColBucle Then
                        If enemyLinIniBucle = enemyLinBucle Then
                            ' Esquina sup iz
                            verticalDirectionBucle = 1
                            horizontalDirectionBucle = 0
                        Elseif enemyLinEndBucle = enemyLinBucle Then
                            ' Esquina inf iz
                            horizontalDirectionBucle = 1
                            verticalDirectionBucle = 0
                        End If
                    Elseif enemyColEndBucle = enemyColBucle Then
                        If enemyLinEndBucle = enemyLinBucle Then
                            ' Esquina inf der
                            verticalDirectionBucle = -1
                            horizontalDirectionBucle = 0
                        Elseif enemyLinIniBucle = enemyLinBucle Then
                            ' Esquina sup der
                            horizontalDirectionBucle = -1
                            verticalDirectionBucle = 0
                        End If
                    End if
                #endif
                #ifdef ENEMIES_CLOCKWISE_ENABLED
                Elseif enemyModeBucle = ENEMY_MODE_CLOCKWISE Then
                    If enemyColIniBucle = enemyColBucle Then
                        If enemyLinIniBucle = enemyLinBucle Then
                            ' Esquina sup iz
                            verticalDirectionBucle = 0
                            horizontalDirectionBucle = 1
                        Elseif enemyLinEndBucle = enemyLinBucle Then
                            ' Esquina inf iz
                            horizontalDirectionBucle = 0
                            verticalDirectionBucle = -1
                        End If
                    Elseif enemyColEndBucle = enemyColBucle Then
                        If enemyLinEndBucle = enemyLinBucle Then
                            ' Esquina inf der
                            verticalDirectionBucle = 0
                            horizontalDirectionBucle = -1
                        Elseif enemyLinIniBucle = enemyLinBucle Then
                            ' Esquina sup der
                            horizontalDirectionBucle = 0
                            verticalDirectionBucle = 1
                        End If
                    End if
                #endif
                #ifdef ENEMIES_ONE_DIRECTION_ENABLED
                ElseIf enemyModeBucle = ENEMY_MODE_ONEDIRECTION Then
                    If enemyColEndBucle = enemyColBucle And enemyLinEndBucle = enemyLinBucle Then
                        enemyColBucle = enemyColIniBucle
                        enemyLinBucle = enemyLinIniBucle

                        #ifdef ENEMIES_SOUND
                            BEEP .01, 4
                        #endif
                    End If
                #endif
                #ifdef ENEMIES_TRAP_ENABLED
                ElseIf enemyModeBucle >= ENEMY_MODE_TRAP_ALL Then
                    If enemyColIniBucle = enemyColBucle And enemyLinIniBucle = enemyLinBucle Then
                        #ifdef ENEMIES_TRAP_VERTICAL_ENABLED
                            if enemyColBucle = protaX or enemyLinEndBucle Then
                                if enemyModeBucle <> ENEMY_MODE_TRAP_HORIZONAL Then
                                    verticalDirectionBucle = Sgn(protaY - enemyLinBucle)
                                end if
                            end if
                        #endif
                        
                        #ifdef ENEMIES_TRAP_HORIZONTAL_ENABLED
                            if enemyLinBucle = protaY or enemyColEndBucle Then
                                if enemyModeBucle <> ENEMY_MODE_TRAP_VERTICAL Then
                                    horizontalDirectionBucle = Sgn(protaX - enemyColBucle)
                                end if
                            end if
                        #endif

                        #ifdef ENEMIES_TRAP_DIAGONAL_ENABLED
                            if ABS(protaX - enemyColBucle) = ABS(protaY - enemyLinBucle) Then
                                if enemyModeBucle = ENEMY_MODE_TRAP_DIAGONAL or enemyModeBucle = ENEMY_MODE_TRAP_ALL Then
                                    verticalDirectionBucle = Sgn(protaY - enemyLinBucle)
                                    horizontalDirectionBucle = Sgn(protaX - enemyColBucle)
                                end if
                            end if
                        #endif

                        #ifdef ENEMIES_SOUND
                            if horizontalDirectionBucle or verticalDirectionBucle then
                                BEEP .01, 4
                            end if
                        #endif
                    Elseif enemyLinBucle >= PLAYER_BOUNDS_BOTTOM or enemyLinBucle < PLAYER_BOUNDS_TOP or enemyColBucle >= PLAYER_BOUNDS_RIGHT or enemyColBucle <= PLAYER_BOUNDS_LEFT Then
                        enemyColBucle = enemyColIniBucle
                        enemyLinBucle = enemyLinIniBucle
                        verticalDirectionBucle = 0
                        horizontalDirectionBucle = 0
                    End if
                #endif
            End if
            
            enemyColBucle = enemyColBucle + horizontalDirectionBucle
            enemyLinBucle = enemyLinBucle + verticalDirectionBucle
            
            ' Is a platform Not an enemy, only 2 frames, 1 direction
            #ifdef SIDE_VIEW
                #ifdef ENEMIES_PLATFORM_ENABLED
                    If enemyPlatformBucle Then
                #else
                    If tileBucle < 17 Then
                #endif
                    if jumpCurrentKey = jumpStopValue Then
                        If checkPlatformHasProtaOnTop(enemyColBucle, enemyLinBucle) Then
                            #ifdef PLATFORM_MOVEABLE
                                if enemySpeedBucle = 3 and not verticalDirectionBucle and not horizontalDirectionBucle Then
                                    #ifdef CONSOLE_MODE
                                    if verticalAxisKeyPressed = 1 Then
                                    #else
                                    if verticalAxisKeyPressed = -1 Then
                                    #endif
                                        If (protaY - 1) > (PLAYER_BOUNDS_TOP + 2) and Not CheckCollision(protaX, protaY - 1) Then enemyLinBucle = enemyLinBucle - 1
                                    ElseIf Not CheckCollision(protaX, protaY + 3) and enemyLinBucle < PLAYER_BOUNDS_BOTTOM Then
                                        enemyLinBucle = enemyLinBucle + 1
                                    End If
                                    
                                    enemyColBucle = protaX
                                    protaY = enemyLinBucle - 4
                                    isOnPlatform = tileBucle
                                Else
                                    If Not CheckCollision(protaX, protaY + verticalDirectionBucle) Then
                                        protaY = enemyLinBucle - 4
                                    End if
                                    
                                    If horizontalDirectionBucle Then
                                        If Not CheckCollision(protaX + horizontalDirectionBucle, protaY) Then
                                            protaX = protaX + horizontalDirectionBucle
                                        End If
                                    End If
                                End if
                            #Else
                                If Not CheckCollision(protaX, protaY + verticalDirectionBucle) Then
                                    protaY = enemyLinBucle - 4
                                End if
                                
                                If horizontalDirectionBucle Then
                                    If Not CheckCollision(protaX + horizontalDirectionBucle, protaY) Then
                                        protaX = protaX + horizontalDirectionBucle
                                    End If
                                End If
                            #endif
                        End If
                    End If
                End if
            #endif
            
            
            ' se guarda el estado final del enemigo
            'if enemyModeBucle <> 2 And enemyModeBucle <> 3 Then
            decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = horizontalDirectionBucle
            decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = verticalDirectionBucle
            'End if
            decompressedEnemiesScreen(enemyId, ENEMY_MODE) = enemyModeBucle
            
            EnemiesFinal:
            
            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyColBucle
            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLinBucle

            #ifdef ENEMIES_TRAP_ENABLED
            #ifndef ENEMIES_TRAP_SHOW_STATIC
            If enemyModeBucle >= ENEMY_MODE_TRAP_ALL Then
                if not horizontalDirectionBucle and not verticalDirectionBucle Then Continue For
            End if
            #endif
            #endif

            #ifdef ENEMIES_SPRITES_ENABLED
                if decompressedEnemiesScreen(enemyId, ENEMY_SPRITE) and horizontalDirectionBucle = -1 Then tileBucle = tileBucle + 16
            #else
                'ENEMY_PLATFORM
                #ifdef ENEMIES_PLATFORM_ENABLED
                    if not enemyPlatformBucle and horizontalDirectionBucle = -1 Then tileBucle = tileBucle + 16
                #else
                    if tileBucle > 16 and horizontalDirectionBucle = -1 Then tileBucle = tileBucle + 16
                #endif
            #endif
            
            If enemiesFrame > 4 Then tileBucle = tileBucle + 1
            
            If enemyLiveBucle = -100 or enemyLiveBucle > 0 Then
                #ifdef BULLET_ENEMIES
                    #ifndef BULLET_ENEMIES_MUST_LOOK
                        ' if tileBucle < 17 then Draw2x2Sprite(tileBucle, enemyColBucle, enemyLinBucle)
                        #ifndef BULLET_ENEMIES_LOOK_AT
                            #ifdef SPRITES_COLOR_ENABLED
                                drawSpriteWithColor(tileBucle, enemyColBucle, enemyLinBucle, colorBucle)
                            #else
                                Draw2x2Sprite(tileBucle, enemyColBucle, enemyLinBucle)
                            #endif
                        ' #Else
                        '     if tileBucle < 17 then drawSpriteWithColor(tileBucle, enemyColBucle, enemyLinBucle, 6)
                        #endif
                    #else
                        #ifdef SPRITES_COLOR_ENABLED
                            drawSpriteWithColor(tileBucle, enemyColBucle, enemyLinBucle, colorBucle)
                        #else
                            Draw2x2Sprite(tileBucle, enemyColBucle, enemyLinBucle)
                        #endif
                    #endif
                #Else
                    #ifdef SPRITES_COLOR_ENABLED
                        drawSpriteWithColor(tileBucle, enemyColBucle, enemyLinBucle, colorBucle)
                    #else
                        Draw2x2Sprite(tileBucle, enemyColBucle, enemyLinBucle)
                    #endif
                #endif
                
                 'ENEMY_PLATFORM
                #ifdef ENEMIES_PLATFORM_ENABLED
                    if not enemyPlatformBucle Then
                #else
                    if tileBucle > 16 Then
                #endif
                    ' if Not invincible then checkProtaCollision(enemyId, enemyColBucle, enemyLinBucle, enemyLiveBucle)
                    if Not invincible then checkProtaCollision(enemyId)
                    
                    #ifdef BULLET_ENEMIES
                        if not enemyBullets(enemyId, 0) and decompressedEnemiesScreen(enemyId, ENEMY_SHOOT) then
                            #ifdef BULLET_ENEMIES_DIRECTION_HORIZONTAL
                                if enemyLinBucle > (protaY-2) and enemyLinBucle < (protaY+4) Then
                                    #ifndef BULLET_ENEMIES_MUST_LOOK
                                        ' forzar dirección en horizontal
                                        enemyShoot(enemyId, 1)
                                        
                                        #ifdef BULLET_ENEMIES_LOOK_AT
                                            dim lookDirection as ubyte = decompressedEnemiesScreen(enemyId, ENEMY_TILE) + 1
                                            
                                            if enemyColBucle > protaX Then
                                                lookDirection = lookDirection + 16
                                            end if

                                            #ifdef SPRITES_COLOR_ENABLED
                                                drawSpriteWithColor(lookDirection, enemyColBucle, enemyLinBucle, colorBucle)
                                            #else
                                                Draw2x2Sprite(lookDirection, enemyColBucle, enemyLinBucle)
                                            #endif
                                        #endif
                                        
                                        continue for
                                    #else
                                        if enemyColBucle < protaX and horizontalDirectionBucle = 1 Then
                                            enemyShoot(enemyId, 1)
                                            continue for
                                        elseif enemyColBucle > protaX and horizontalDirectionBucle = -1 Then
                                           enemyShoot(enemyId, 1)
                                            continue for
                                        end if
                                    #endif
                                End if
                            #endif
                            #ifdef BULLET_ENEMIES_DIRECTION_VERTICAL
                                if enemyColBucle > (protaX-2) and enemyColBucle < (protaX+4) Then
                                    #ifndef BULLET_ENEMIES_MUST_LOOK
                                        #ifdef BULLET_ENEMIES_LOOK_AT
                                            #ifdef SPRITES_COLOR_ENABLED
                                                drawSpriteWithColor(tileBucle, enemyColBucle, enemyLinBucle, colorBucle)
                                            #else
                                                Draw2x2Sprite(tileBucle, enemyColBucle, enemyLinBucle)
                                            #endif
                                        #endif
                                    #endif
                                    
                                    #ifndef BULLET_ENEMIES_MUST_LOOK
                                        enemyShoot(enemyId, 2)
                                        continue for
                                    #Else
                                        if enemyLinBucle < protaY and verticalDirectionBucle = 1 Then
                                            ' enemyShoot(enemyId,enemyColBucle, enemyLinBucle, BULLET_DIRECTION_DOWN)
                                            enemyShoot(enemyId, 2)
                                            continue for
                                        elseif enemyLinBucle > protaY and verticalDirectionBucle = -1 Then
                                            ' enemyShoot(enemyId,enemyColBucle, enemyLinBucle, BULLET_DIRECTION_UP)
                                            enemyShoot(enemyId, 2)
                                            continue for
                                        end if
                                    #endif
                                end if
                            #endif
                            #ifdef BULLET_ENEMIES_DIRECTION_DIAGONAL
                                if ABS(protaX - enemyColBucle) = ABS(protaY - enemyLinBucle) THEN
                                    enemyShoot(enemyId, 0)
                                    continue for
                                END IF
                            #endif
                        end if
                    #endif
                End if
                
                #ifdef BULLET_ENEMIES
                    #ifndef BULLET_ENEMIES_MUST_LOOK
                        #ifdef BULLET_ENEMIES_LOOK_AT
                            #ifdef SPRITES_COLOR_ENABLED
                                drawSpriteWithColor(tileBucle, enemyColBucle, enemyLinBucle, colorBucle)
                            #else
                                Draw2x2Sprite(tileBucle, enemyColBucle, enemyLinBucle)
                            #endif
                        #endif
                    #endif
                #endif
            Else
                #ifdef ENEMIES_RESPAWN_IN_SCREEN_ENABLED
                    #ifdef SPRITES_COLOR_ENABLED
                        if enemyLiveBucle > -30 and enemiesFrame bAnd 1 Then drawSpriteWithColor(tileBucle, enemyColBucle, enemyLinBucle, colorBucle)
                    #else
                        if enemyLiveBucle > -30 and enemiesFrame bAnd 1 Then Draw2x2Sprite(tileBucle, enemyColBucle, enemyLinBucle)
                    #endif
                #endif
            End if
        Next enemyId

        ' #ifdef ENEMIES_RESPAWN_IN_SCREEN_ENABLED
        firstTimeEnemiesScreen = 0
        ' #endif
    End if

    #ifdef ENEMIES_RANDOM_MOVEMENTS
        if not enemyChangeModeTimer Then
            enemyChangeModeTimer = 100 + (enemiesFrame*enemiesFrame)
        end if
    #endif
End Sub

' Sub checkProtaCollision(enemyId As Ubyte, enemyX0 As Ubyte, enemyY0 As Ubyte, enemyLive As Ubyte)
Sub checkProtaCollision(enemyId As Ubyte)
    'If invincible Then Return
    
    If (protaX + 2) < enemyColBucle Or protaX > (enemyColBucle + 2) Then Return
    
    #ifdef SIDE_VIEW
        #ifdef JUMP_ON_ENEMIES
            If (protaY + 4) > (enemyLinBucle - 2) And (protaY + 4) < (enemyLinBucle + 2) Then
                #ifdef KILL_JUMPING_ON_TOP
                    if enemyLiveBucle <> -100 Then damageEnemy(enemyId)
                #endif
                landed = 1
                jumpCurrentKey = jumpStopValue
                jump()
                Return
            End if
        #endif
    #endif
    
    If (protaY + 2) < (enemyLinBucle) Or protaY > (enemyLinBucle + 2) Then Return
    
    #ifdef ENEMY_COLLISION_PROTA_DAMAGE
        if enemyLiveBucle <> -100 Then damageEnemy(enemyId)
    #endif
    
    decrementLife()
End Sub
