const BURST_SPRITE_ID as ubyte = 16
const BULLET_SPEED as ubyte = 2

' sub createBullet(directionRight as ubyte)
'     if directionRight
'         spritesSet(BULLET_SPRITE_RIGHT_ID) = Create1x1Sprite(@bulletRight)
'     else
'         spritesSet(BULLET_SPRITE_RIGHT_ID) = Create1x1Sprite(@bulletLeft)
'     end if
' end sub

Function checkBulletTileCollision(direction as ubyte, posx as ubyte, posy as ubyte) as ubyte
    dim xToCheck as ubyte = posx
    
    if direction = BULLET_DIRECTION_RIGHT then xToCheck = posx + 1
    
    dim tile as ubyte = isSolidTileByColLin(xToCheck >> 1, posy >> 1)
    
    if not tile then tile = isSolidTileByColLin(xToCheck >> 1, (posy + 1) >> 1)
    return tile
End Function

#ifdef SHOOTING_ENABLED
    #ifdef BULLET_ENEMIES
        #ifdef BULLET_COLLIDE_BULLET
            Sub checkBulletsCollision()
                if Not enemyBulletPositionX or not bulletPositionY Then Return
                if (enemyBulletPositionY + 2) < bulletPositionY or enemyBulletPositionY  > (bulletPositionY + 2) then Return
                if (enemyBulletPositionX + 2) < bulletPositionX or enemyBulletPositionX  > (bulletPositionX + 2) then Return
                
                resetBullet(0)
                resetBullet(1)
            End sub
        #endif
    #endif
#endif

#ifdef SHOOTING_ENABLED
    sub moveBullet()
        if bulletPositionX = 0 then return
        
        #ifdef BULLET_BOOMERANG
            if bulletDirection = BULLET_DIRECTION_BOOMERANG Then
                bulletPositionX = bulletPositionX + (sgn((protaX+1) - bulletPositionX)*BULLET_SPEED)
                bulletPositionY = bulletPositionY + (sgn((protaY+1) - bulletPositionY)*BULLET_SPEED)
                if bulletPositionX >= protaX and bulletPositionX <= (protaX+4) Then
                    if bulletPositionY >= protaY and bulletPositionY <= (protaY+4) Then
                        resetBullet(0)
                        
                        #ifdef AMMO_ENABLED
                            currentAmmo = currentAmmo + 1
                            printLife()
                        #endif
                        Return
                    end if
                End if
            else
            #endif
            ' desplazamiento de bala
            if bulletDirection = BULLET_DIRECTION_RIGHT then
                if bulletPositionX >= bulletEndPositionX then
                    #ifdef BULLET_BOOMERANG
                        bulletDirection = BULLET_DIRECTION_BOOMERANG
                    #else
                        resetBullet(0)
                        return
                    #endif
                Else
                    bulletPositionX = bulletPositionX + BULLET_SPEED
                end if
                
                #ifndef BULLET_BOOMERANG
                    #ifdef SIDE_VIEW
                        #ifdef BULLET_ANIMATION
                            if currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID Then
                                currentBulletSpriteId = BULLET_SPRITE_RIGHT_2_ID
                            Else
                                currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
                            End if
                        #endif
                    #endif
                #endif
            elseif bulletDirection = BULLET_DIRECTION_LEFT then
                if bulletPositionX <= bulletEndPositionX then
                    #ifdef BULLET_BOOMERANG
                        bulletDirection = BULLET_DIRECTION_BOOMERANG
                    #else
                        resetBullet(0)
                        return
                    #endif
                else
                    bulletPositionX = bulletPositionX - BULLET_SPEED
                end if
                
                #ifndef BULLET_BOOMERANG
                    #ifdef SIDE_VIEW
                        #ifdef BULLET_ANIMATION
                            if currentBulletSpriteId = BULLET_SPRITE_LEFT_ID Then
                                currentBulletSpriteId = BULLET_SPRITE_LEFT_2_ID
                            Else
                                currentBulletSpriteId = BULLET_SPRITE_LEFT_ID
                            End if
                        #endif
                    #endif
                #endif
                #ifdef OVERHEAD_VIEW
                elseif bulletDirection = BULLET_DIRECTION_DOWN then
                    if bulletPositionY >= bulletEndPositionY then
                        #ifdef BULLET_BOOMERANG
                            bulletDirection = BULLET_DIRECTION_BOOMERANG
                        #else
                            resetBullet(0)
                            return
                        #endif
                    else
                        bulletPositionY = bulletPositionY + BULLET_SPEED
                    end if
                elseif bulletDirection = BULLET_DIRECTION_UP
                    if bulletPositionY <= bulletEndPositionY then
                        #ifdef BULLET_BOOMERANG
                            bulletDirection = BULLET_DIRECTION_BOOMERANG
                        #else
                            resetBullet(0)
                            return
                        #endif
                    else
                        bulletPositionY = bulletPositionY - BULLET_SPEED
                    end if
                    
                #endif
            end if
            
            #ifdef BULLET_BOOMERANG
                #ifdef BULLET_ANIMATION
                    if currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID Then
                        currentBulletSpriteId = BULLET_SPRITE_LEFT_ID
                    Else
                        currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
                    End if
                #endif
            #endif
            
            #ifdef BULLET_COLLISIONS
                dim tile as ubyte = checkBulletTileCollision(bulletDirection, bulletPositionX, bulletPositionY)
                if tile Then
                    #ifdef USE_BREAKABLE_TILE
                        checkAndRemoveBreakableTile(tile)
                    #endif
                    
                    #ifdef BULLET_BOOMERANG
                        bulletDirection = BULLET_DIRECTION_BOOMERANG
                    #else
                        resetBullet(0)
                    #endif
                    
                end if
            #endif
            
            #ifdef BULLET_BOOMERANG
            End If
        #endif
    end sub
#endif

#ifdef BULLET_ENEMIES
    sub moveEnemyBullet()
        if enemyBulletPositionX = 0 then return
        
        ' desplazamiento de bala
        #ifdef BULLET_ENEMIES_DIRECTION_HORIZONTAL
            if enemyBulletDirection = BULLET_DIRECTION_RIGHT then
                if enemyBulletPositionX >= MAX_SCREEEN_RIGHT then
                    resetBullet(1)
                    return
                end if
                enemyBulletPositionX = enemyBulletPositionX + BULLET_ENEMIES_SPEED
            elseif enemyBulletDirection = BULLET_DIRECTION_LEFT then
                if enemyBulletPositionX <= MAX_SCREEN_LEFT then
                    resetBullet(1)
                    return
                end if
                enemyBulletPositionX = enemyBulletPositionX - BULLET_ENEMIES_SPEED
            end if
        #endif
        #ifdef BULLET_ENEMIES_DIRECTION_VERTICAL
            if enemyBulletDirection = BULLET_DIRECTION_DOWN then
                if enemyBulletPositionY >= MAX_SCREEN_BOTTOM then
                    resetBullet(1)
                    return
                end if
                enemyBulletPositionY = enemyBulletPositionY + BULLET_ENEMIES_SPEED
            elseif enemyBulletDirection = BULLET_DIRECTION_UP
                if enemyBulletPositionY <= MAX_SCREEN_TOP then
                    resetBullet(1)
                    return
                end if
                enemyBulletPositionY = enemyBulletPositionY - BULLET_ENEMIES_SPEED
            end if
        #endif
        
        #ifdef BULLET_ENEMIES_COLLIDE
            if checkBulletTileCollision(enemyBulletDirection, enemyBulletPositionX, enemyBulletPositionY) Then resetBullet(1)
        #endIf
        
        'colision con el player si es de enemigo
        if (enemyBulletPositionX + 1) < protaX or enemyBulletPositionX > (protaX + 4) then Return
        if (enemyBulletPositionY + 1) < protaY or enemyBulletPositionY > (protaY + 4) then Return
        decrementLife()
        resetBullet(1)
    end sub
#endif

#ifdef USE_BREAKABLE_TILE
    sub checkAndRemoveBreakableTile(tile as ubyte)
        if tile = BREAKABLE_TILE then
            brokenTiles(currentScreen) = 1
            BeepFX_Play(0)
            removeTilesFromScreen(BREAKABLE_TILE)
        end if
    end sub
#EndIf


sub resetBullet(isEnemyBullet as ubyte)
    #ifdef BULLET_ENEMIES
        if isEnemyBullet Then
            enemyBulletPositionX = 0
            enemyBulletPositionY = 0
            enemyBulletDirection = 0
        Else
            bulletPositionX = 0
            bulletPositionY = 0
            bulletDirection = 0
        end if
    #Else
        bulletPositionX = 0
        bulletPositionY = 0
        bulletDirection = 0
    #endif
end sub

sub damageEnemy(enemyToKill as Ubyte)
    #ifdef ENEMIES_SLOW_DOWN
        decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) = -50
        decompressedEnemiesScreen(enemyToKill, ENEMY_SPEED) = 0
        
        #ifdef HISCORE_ENABLED
            score = score + 5
            If score > hiScore Then
                hiScore = score
            End If
            printLife()
        #endif
        
        BeepFX_Play(1)
    #else
        dim alive as ubyte = decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE)
        if alive < 1 then return
        
        alive = alive - 1
        
        #ifdef HISCORE_ENABLED
            score = score + 5
            If score > hiScore Then
                hiScore = score
            End If
            printLife()
        #endif
        
        decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) = alive
        if alive = 0 then
            ' enemySpriteTempTile(enemyToKill) = 0
            decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) = -99
            BeepFX_Play(0)
            
            #ifdef DROP_ENABLED
                dim eneX as ubyte = decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_COL) >> 1
                dim eneY as ubyte = decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_LIN) >> 1

                if enemiesFrame band 2 = 2 Then
                    #ifdef SCREEN_ATTRIBUTES
                        if DROP_TILE < MAX_GENERIC_TILE Then
                            drawDrop(eneX, eneY)
                        elseif GetTile(eneX, eneY) = currentTileBackground Then
                            SetTileChecked(DROP_TILE, tileAttrWithBackground(DROP_TILE), eneX, eneY)
                        End if
                    #else
                        if DROP_TILE < MAX_GENERIC_TILE Then
                            drawDrop(eneX, eneY)
                        elseif not GetTile(eneX, eneY) Then
                            SetTileChecked(DROP_TILE, tileAttrWithBackground(DROP_TILE), eneX, eneY)
                        End if
                    #endif
                ' Else
                '     Draw2x2Sprite(BURST_SPRITE_ID, eneX, eneY)
                End if
                Draw2x2Sprite(BURST_SPRITE_ID, eneX << 1, eneY << 1)
            #else
                Draw2x2Sprite(BURST_SPRITE_ID, decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_LIN))
            #endif
            
            ' si ambos estan definidos
            #ifdef ENEMIES_NOT_RESPAWN_ENABLED
                #ifdef SHOULD_KILL_ENEMIES
                    ' if not screensWon(currentScreen) then
                    if allEnemiesKilled() then
                        screensWon(currentScreen) = 1
                        removeTilesFromScreen(ENEMY_DOOR_TILE)
                    end if
                    ' end if
                #endif
            #endif
            
            ' si solo uno esta definido
            #ifndef ENEMIES_NOT_RESPAWN_ENABLED
                #ifdef SHOULD_KILL_ENEMIES
                    ' if not screensWon(currentScreen) then
                    if allEnemiesKilled() then
                        screensWon(currentScreen) = 1
                        removeTilesFromScreen(ENEMY_DOOR_TILE)
                    end if
                    ' end if
                #endif
            #endif
            
            #ifndef SHOULD_KILL_ENEMIES_ENABLED
                #ifdef ENEMIES_NOT_RESPAWN_ENABLED
                    ' if not screensWon(currentScreen) then
                    if allEnemiesKilled() then
                        screensWon(currentScreen) = 1
                        removeTilesFromScreen(ENEMY_DOOR_TILE)
                    end if
                    ' end if
                #endif
            #endif
        else
            BeepFX_Play(1)
        end if
    #endif
end sub