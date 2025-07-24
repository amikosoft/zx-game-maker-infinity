sub pauseUntilPressKey()
    while INKEY$<>"":wend
    while INKEY$="":wend
end sub

sub pauseUntilPressEnter()
    Do
    Loop Until MultiKeys(KEYENTER)
end sub

Function pressingDown() As Ubyte
    Return ((kempston = 0 And MultiKeys(keyArray(DOWN))) Or (kempston = 1 And (In(31) bAND %100)))
End Function

Function pressingUp() As Ubyte
    Return ((kempston = 0 And MultiKeys(keyArray(UP)) <> 0) Or (kempston = 1 And In(31) bAND %1000 <> 0))
End Function

sub pauseUntilPressFire()
    Do
    Loop Until ((kempston = 0 And MultiKeys(keyArray(FIRE)) <> 0) Or (kempston = 1 And In(31) bAND %10000 <> 0))
End Sub

#ifdef DROP_ENABLED
sub drawDrop(tileX as ubyte, tileY as ubyte)
    for tx=0 to 1
        for ty=0 to 1
            if not GetTile(tileX + tx, tileY + ty) Then 
                SetTileChecked(DROP_TILE, attrSet(DROP_TILE), tileX + tx, tileY + ty)
            end if
        next ty
    next tx
end sub
#endif

Function checkProtaTop() As Ubyte
    If protaY < 2 Then
        #ifdef ARCADE_MODE
            protaY = 39
        #Else
            #ifdef LEVELS_MODE
                protaY = 2
            #Else
                moveScreen = 8
            #endif
        #endif
        Return 1
    End If

    return 0
end Function

sub decrementLife()
    if not currentLife then return
    
    invincible = INVINCIBLE_FRAMES

    #ifdef BORDER_DAMAGE_COLOR
        Border BORDER_DAMAGE_VALUE
    #endif

    #ifdef LIVES_MODE_ENABLED
        ' if currentLife > 1 then
        #ifdef ENERGY_ENABLED
            currentEnergy = currentEnergy - 1

            if not currentEnergy Then

            #ifndef LIVES_MODE_GRAVEYARD
                currentEnergy = INITIAL_ENERGY
            #endif 
        #endif
        
        currentLife = currentLife - 1
        
        ' #ifdef DROP_ENABLED
        '     drawDrop(protaX>>1, protaY>>1)
        ' #endif

        #ifdef LIVES_MODE_GRAVEYARD
            'saveSprite( protaY, protaX, 15, 0)
            protaTile = 15
        #endif
        
        #ifdef LIVES_MODE_RESPAWN
            #ifndef ARCADE_MODE
            #ifdef CHECKPOINTS_ENABLED
                if currentScreen <> protaScreenRespawn Then
                    currentScreen = protaScreenRespawn
                    moveScreen = 1
                end if

                jumpCurrentKey = jumpStopValue
            #endif
            #endif

            if currentLife Then saveSprite( protaYRespawn, protaXRespawn, 1, protaDirection)
        #endif

        #ifdef ENERGY_ENABLED
            end if
        #endif
    #else
        if currentLife > DAMAGE_AMOUNT then
            currentLife = currentLife - DAMAGE_AMOUNT
        else
            currentLife = 0
        end if
    #endif
    printLife()
    BeepFX_Play(1)
end sub

sub printLife()
    PRINT AT 22, 5; "   "
    PRINT AT 22, 5; currentLife
    
    #ifdef ENERGY_ENABLED
        PRINT AT 23, 5; "   "
        PRINT AT 23, 5; currentEnergy
    #endif
    
    #ifdef JETPACK_FUEL
        PRINT AT 23, 5; "   "
        PRINT AT 23, 5; jumpEnergy
    #endif
    #ifdef AMMO_ENABLED
        PRINT AT 22, 10; "   "
        PRINT AT 22, 10; currentAmmo
    #endif
    #ifndef ARCADE_MODE
        #ifdef KEYS_ENABLED
            PRINT AT 22, 16; currentKeys
        #endif
    #endif
    #ifdef HISCORE_ENABLED
        PRINT AT 22, 25 - LEN(STR$(hiScore)); hiScore
        PRINT AT 23, 25 - LEN(STR$(score)); score
    #endif
    #ifndef ARCADE_MODE
        #ifdef ITEMS_ENABLED
            PRINT AT 22, 30; "  "
            PRINT AT 22, 30; currentItems
        #endif
    #endif
    
    #ifdef LEVELS_MODE
        PRINT AT 23, 10; "   "
        PRINT AT 23, 10; currentLevel + 1
    #endif
end sub

#ifdef MESSAGES_ENABLED
    sub printMessage(line1 as string, p as ubyte, i as ubyte)
        Paper p: Ink i: Flash 1
        PRINT AT 22, 18; line1
        Paper 0: Ink 7: Flash 0
        messageLoopCounter = MESSAGE_LOOPS_VISIBLE
    end sub
    
    sub checkMessageForDelete()
        if messageLoopCounter Then
            messageLoopCounter = messageLoopCounter - 1
            If not messageLoopCounter Then
                PRINT AT 22, 18; "         "
            End If
        End if
    end sub
#endif

function isADamageTile(x as ubyte, y as ubyte) as UBYTE
    for i = 0 to DAMAGE_TILES_COUNT
        if peek(@damageTiles + i) = GetTile(x,y) then
            return 1
        end if
    next i
    return 0
end function

function allEnemiesKilled() as ubyte
    if Not enemiesScreen then return 1
    
    for enemyId=0 TO enemiesScreen - 1
        if decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 then
            continue for
        end if
        if decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) > 0 then
            return 0
        end if
    next enemyId
    
    return 1
end function

function isSolidTileByColLin(col as ubyte, lin as ubyte) as ubyte
    dim tile as ubyte = GetTile(col, lin)
    
    ' if tile < 1 then return 0
    
    if tile < 1 or tile > 64 then 
        #ifdef MESSAGES_ENABLED
            If tile = ENEMY_DOOR_TILE Then
                printMessage("Kill All!", 2, 0)
            End If
        #endif
        return 0
    End if
    
    return tile
end function

#ifdef ARCADE_MODE
    sub countItemsOnTheScreen()
        dim index, y, x as integer
        
        x = 0
        y = 0
        
        itemsToFind = 0
        currentItems = 0
        for index=0 to SCREEN_LENGTH
            if peek(@decompressedMap + index) - 1 = ITEM_TILE then
                itemsToFind = itemsToFind + 1
            end if
            
            x = x + 1
            if x = screenWidth then
                x = 0
                y = y + 1
            end if
        next index
    end sub
#endif

#ifdef SIDE_VIEW
    function CheckStaticPlatform(x as uByte, y as uByte) as uByte
        Dim col as uByte = x >> 1
        Dim lin as uByte = y >> 1
        
        dim tile as ubyte = GetTile(col, lin)
        
        if tile > 63 and tile < 80 then return 1
        
        return 0
    end function
#endif

function CheckCollision(x as uByte, y as uByte) as uByte
    ' Dim xIsEven as uByte = (x bAnd 1) = 0
    ' Dim yIsEven as uByte = (y bAnd 1) = 0
    Dim col as uByte = x >> 1
    Dim lin as uByte = y >> 1
    
    Dim maxCol as uByte = 1
    Dim maxLin as uByte = 1

    if (x bAnd 1) <> 0 Then maxCol = 2
    if (y bAnd 1) <> 0 Then maxLin = 2
    
    for c=0 to maxCol
        for l=0 to maxLin
            if isSolidTileByColLin(col+c, lin+l) then return 1
        next l
    next c

    ' if isSolidTileByColLin(col, lin) then return 1
    ' if isSolidTileByColLin(col + 1, lin) then return 1
    ' if isSolidTileByColLin(col, lin + 1) then return 1
    ' if isSolidTileByColLin(col + 1, lin + 1) then return 1
    
    ' if not yIsEven then
    '     if isSolidTileByColLin(col, lin + 2) then return 1
    '     if isSolidTileByColLin(col + 1, lin + 2) then return 1
    ' end if
    
    ' if not xIsEven then
    '     if isSolidTileByColLin(col + 2, lin) then return 1
    '     if isSolidTileByColLin(col + 2, lin + 1) then return 1
    ' end if
    
    ' if not xIsEven and not yIsEven then
    '     if isSolidTileByColLin(col + 2, lin + 2) then return 1
    ' end if
    
    return 0
end function

sub removeTilesFromScreen(tile as ubyte)
    dim index as uinteger
    dim y, x as ubyte
    
    x = 0
    y = 0
    
    for index=0 to SCREEN_LENGTH
        if peek(@decompressedMap + index) - 1 = tile then
            SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
        end if
        
        x = x + 1
        if x = screenWidth then
            x = 0
            y = y + 1
        end if
    next index
end sub

sub saveSprite(lin as ubyte, col as ubyte, tile as ubyte, directionRight as ubyte)
    ' if sprite = PROTA_SPRITE then
    protaX = col
    protaY = lin
    protaTile = tile
    protaDirection = directionRight
end sub

#ifdef SIDE_VIEW
    sub jump()
        if jumpCurrentKey = jumpStopValue and landed then
            landed = 0
            jumpCurrentKey = 0
        end if
    end sub
#endif

sub debugA(value as uBYTE)
    PRINT AT 0, 0; "----"
    PRINT AT 0, 0; value
end sub

sub debugB(value as uBYTE)
    PRINT AT 0, 5; "  "
    PRINT AT 0, 5; value
end sub

sub debugC(value as uBYTE)
    PRINT AT 0, 10; "  "
    PRINT AT 0, 10; value
end sub

' sub debugD(value as UBYTE)
'     PRINT AT 18, 25; "  "
'     PRINT AT 18, 25; value
' end sub
