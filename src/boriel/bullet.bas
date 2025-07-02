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
    
    if tile then
        return tile
    else
        tile = isSolidTileByColLin(xToCheck >> 1, (posy + 1) >> 1)
        return tile
    end if
End Function

sub moveBullet()
    if bulletPositionX = 0 then return
    
    ' desplazamiento de bala
    if bulletDirection = BULLET_DIRECTION_RIGHT then
        if bulletPositionX >= bulletEndPositionX then
            resetBullet(0)
            return
        end if
        
        #ifdef SIDE_VIEW
            #ifdef BULLET_ANIMATION
                if currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID Then
                    currentBulletSpriteId = BULLET_SPRITE_RIGHT_2_ID
                Else
                    currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
                End if
            #endif
        #endif
        
        bulletPositionX = bulletPositionX + BULLET_SPEED
    elseif bulletDirection = BULLET_DIRECTION_LEFT then
        if bulletPositionX <= bulletEndPositionX then
            resetBullet(0)
            return
        end if
        bulletPositionX = bulletPositionX - BULLET_SPEED
        
        #ifdef SIDE_VIEW
            #ifdef BULLET_ANIMATION
                if currentBulletSpriteId = BULLET_SPRITE_LEFT_ID Then
                    currentBulletSpriteId = BULLET_SPRITE_LEFT_2_ID
                Else
                    currentBulletSpriteId = BULLET_SPRITE_LEFT_ID
                End if
            #endif
        #endif
        #ifdef OVERHEAD_VIEW
        elseif bulletDirection = BULLET_DIRECTION_DOWN then
            if bulletPositionY >= bulletEndPositionY then
                resetBullet(0)
                return
            end if
            bulletPositionY = bulletPositionY + BULLET_SPEED
        elseif bulletDirection = BULLET_DIRECTION_UP
            if bulletPositionY <= bulletEndPositionY then
                resetBullet(0)
                return
            end if
            bulletPositionY = bulletPositionY - BULLET_SPEED
        #endif
    end if
    
    dim tile as ubyte = checkBulletTileCollision(bulletDirection, bulletPositionX, bulletPositionY)
    if tile Then
        resetBullet(0)
        
        #ifdef USE_BREAKABLE_TILE
            checkAndRemoveBreakableTile(tile)
        #endif
    end if
end sub

#ifdef BULLET_ENEMIES
    sub moveEnemyBullet()
        if enemyBulletPositionX = 0 then return
    
        ' desplazamiento de bala
        if enemyBulletDirection = BULLET_DIRECTION_RIGHT then
            if enemyBulletPositionX >= MAX_SCREEEN_RIGHT then
                resetBullet(1)
                return
            end if
            enemyBulletPositionX = enemyBulletPositionX + BULLET_ENEMIES_SPEED
        elseif enemyBulletDirection = BULLET_DIRECTION_LEFT then
            if enemyBulletPositionX <= MAX_SCREEEN_LEFT then
                resetBullet(1)
                return
            end if
            enemyBulletPositionX = enemyBulletPositionX - BULLET_ENEMIES_SPEED
        elseif enemyBulletDirection = BULLET_DIRECTION_DOWN then
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
        if tile = 62 then
            brokenTiles(currentScreen) = 1
            BeepFX_Play(0)
            removeTilesFromScreen(62)
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
    
    if alive = 0 then
        alive = -99
        enemySpriteTempTile(enemyToKill) = 0
        Draw2x2Sprite(BURST_SPRITE_ID, decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_LIN))
        
        BeepFX_Play(0)
        
        ' si ambos estan definidos
        #ifdef ENEMIES_NOT_RESPAWN_ENABLED
            #ifdef SHOULD_KILL_ENEMIES_ENABLED
                if not screensWon(currentScreen) then
                    if allEnemiesKilled() then
                        screensWon(currentScreen) = 1
                        removeTilesFromScreen(63)
                    end if
                end if
            #endif
        #endif
        
        ' si solo uno esta definido
        #ifndef ENEMIES_NOT_RESPAWN_ENABLED
            #ifdef SHOULD_KILL_ENEMIES_ENABLED
                if not screensWon(currentScreen) then
                    if allEnemiesKilled() then
                        screensWon(currentScreen) = 1
                        removeTilesFromScreen(63)
                    end if
                end if
            #endif
        #endif
        
        #ifndef SHOULD_KILL_ENEMIES_ENABLED
            #ifdef ENEMIES_NOT_RESPAWN_ENABLED
                if not screensWon(currentScreen) then
                    if allEnemiesKilled() then
                        screensWon(currentScreen) = 1
                        removeTilesFromScreen(63)
                    end if
                end if
            #endif
        #endif
    else
        BeepFX_Play(1)
    end if
    
    decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) = alive
end sub