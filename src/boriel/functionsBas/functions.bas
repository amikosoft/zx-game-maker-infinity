' dim dmAddress as integer = arrayBasePtr(decompressedMap)

sub waitForReleaseKey()
    while GetKeyScanCode():wend
end sub

sub pauseUntilPressKey()
    ' while INKEY$<>"":wend
    ' while INKEY$="":wend
    ' Do Loop While GetKeyScanCode()
    waitForReleaseKey()
    Do Loop Until GetKeyScanCode()
end sub

Sub loadScreen(screen_address as Integer)
    ' clearScreen()
    'Ink 7: Paper 0: Border 0: BRIGHT 0: FLASH 0: Cls

    #ifdef ENABLED_128k
        SetBank(screensBank)
        dzx0Standard(screen_address, $4000)
        SetBank(gameBank)
    #else
        dzx0Standard(screen_address, $4000)
    #endif 
end sub

#ifdef HUD2_SCREEN_ENABLED
    #ifdef SCREEN_HUD2_ENABLED
        Sub loadHUDScreen()
            currentHud = screenHud
            if currentHud then
                loadScreen(HUD2_SCREEN_ADDRESS)
            else
                loadScreen(HUD_SCREEN_ADDRESS)
            end if
        end sub
    #endif
#endif



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
    waitForReleaseKey()
End Sub

function tileAttrSet(tile as ubyte) as ubyte
    if screenIsDark then return darkAttrSet(tile)
    return attrSet(tile)
end function

Function checkProtaTop() As Ubyte
    If protaY < PLAYER_BOUNDS_TOP Then
        #ifdef ARCADE_MODE
            protaY = MAX_SCREEN_BOTTOM
        #Else
            #ifdef LEVELS_MODE
                protaY = PLAYER_BOUNDS_TOP
            #Else
                moveScreen = 8
            #endif
        #endif
        Return 1
    End If

    return 0
end Function

sub decrementLife()
    if not currentLife or invincible then return
    
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

        #ifdef LIVES_MODE_GRAVEYARD
            #ifdef MAP_COLOR_DEAD_ENABLED
                mapColor(MAP_COLOR_DEAD_COLOR)
            #endif
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

            if currentLife Then updateProtaData( protaYRespawn, protaXRespawn, 1, protaDirection)
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
    printHud()
    BeepFX_Play(1)
end sub

sub printEnergyBar(partial as ubyte, total as ubyte, x as ubyte, y as ubyte)
    dim percent as uinteger = (partial*9)/total

    if percent < 4 then flash 1
    for posX=0 to 8
        if posX < percent then
            PAPER 4
        else
            PAPER 2
        end if

        PRINT AT y, x + posX; " "
    next posX

    Paper PAPER_VALUE: flash 0
end sub

sub printHud()
    Ink INK_VALUE: Paper PAPER_VALUE: BRIGHT BRIGHT_VALUE: FLASH 0
    
    PRINT AT 22, 4; TEXT_3_SPACES
    PRINT AT 22, 4; currentLife

    #ifdef ENERGY_ENABLED
        if currentEnergy > INITIAL_ENERGY Then currentEnergy = 0

        #ifdef HUD_PROTA_ENERGY_BAR        
            'printEnergyBar(currentEnergy, INITIAL_ENERGY, 1, 21)
            printEnergyBar(currentEnergy, INITIAL_ENERGY, 3, 23)
        #else
            PRINT AT 23, 4; TEXT_3_SPACES
            PRINT AT 23, 4; currentEnergy
        #endif
    #endif
    
    #ifdef JETPACK_FUEL
        PRINT AT 21, 4; TEXT_3_SPACES
        PRINT AT 21, 4; jumpEnergy
    #endif
    #ifdef AMMO_ENABLED
        PRINT AT 22, 9; TEXT_3_SPACES
        PRINT AT 22, 9; currentAmmo
    #endif
    #ifndef ARCADE_MODE
        #ifdef KEYS_ENABLED
            PRINT AT 22, 22; currentKeys
        #endif
    #endif
    #ifdef HISCORE_ENABLED
        ' Print AT 22, 20; "00000"
        ' Print AT 23, 20; "00000"
        PRINT AT 22, 18 - LEN(STR$(hiScore)); hiScore
        PRINT AT 23, 18 - LEN(STR$(score)); score
    #endif
    #ifndef ARCADE_MODE
        #ifdef ITEMS_ENABLED
            PRINT AT 22, 28; TEXT_3_SPACES
            PRINT AT 22, 28; currentItems
        #endif
    #endif
    
    #ifdef LEVELS_MODE
        PRINT AT 23, 9; TEXT_3_SPACES
        PRINT AT 23, 9; currentLevel + 1
    #endif
end sub

#ifdef MESSAGES_ENABLED
    sub printMessage(line1 as string, p as ubyte, i as ubyte)
        Paper p: Ink i: Flash 1
        PRINT AT 21, 11; line1
        Paper PAPER_VALUE: Ink INK_VALUE: Flash 0: Bright BRIGHT_VALUE
        messageLoopCounter = MESSAGE_LOOPS_VISIBLE
    end sub
#endif

dim dtAddress as Integer = arrayBasePtr(damageTiles)

function isADamageTile(x as ubyte, y as ubyte) as UBYTE
    for i = 0 to DAMAGE_TILES_COUNT
        if peek(dtAddress + i) = GetTile(x,y) then return 1
    next i
    return 0
end function

function allEnemiesKilled() as ubyte
    'if Not enemiesScreen then return 1
    
    if enemiesScreen then
        for enemyId=0 TO enemiesScreen - 1
            'ENEMY_PLATFORM
            #ifdef ENEMIES_PLATFORM_ENABLED
                if decompressedEnemiesScreen(enemyId, ENEMY_PLATFORM) then continue for
            #else
                if decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 then continue for
            #endif
            if decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) > 0 then return 0
        next enemyId
    end if
    return 1
end function

Function attrWithBackground(attr As Ubyte) As Ubyte
     #ifdef SCREEN_ATTRIBUTES
        Dim backgroundAttr as ubyte = currentScreenBackground
    #else
        Dim backgroundAttr as ubyte = BACKGROUND_ATTRIBUTE
    #endif

    ' Dim tinta As Ubyte = attr bAnd 7
    ' Dim papelTile As Ubyte = (attr bAnd 56) / 8
    Dim papelBack As Ubyte = (backgroundAttr bAnd 56) / 8
    ' Dim brillo As Ubyte = (backgroundAttr bAnd 64) / 64
    ' Dim parpadeo As Ubyte = (attr bAnd 128) / 128

    ' Montar el atributo: papel, tinta, brillo, parpadeo
    'if ((attr bAnd 56) / 8) or tile <= ENEMY_DOOR_TILE or not papelBack Then return attr
    if ((attr bAnd 56) / 8) or not papelBack Then return attr

    Return (papelBack * 8) + (attr bAnd 7) + (((backgroundAttr bAnd 64) / 64) * 64) + (((attr bAnd 128) / 128) * 128)
End Function

Function tileAttrWithBackground(tile As Ubyte) As Ubyte
    #ifdef SCREEN_DARK_ENABLED
        return attrWithBackground(tileAttrSet(tile))
    #Else
        return attrWithBackground(attrSet(tile))
    #endif
End Function

function isSolidTileByColLin(col as ubyte, lin as ubyte) as ubyte
    dim tile as ubyte = GetTile(col, lin)
    
    ' if tile < 1 then return 0
    
    if tile < 1 or tile > ENEMY_DOOR_TILE then return 0
    
    ' if tile = FADE_TILE or tile = (FADE_TILE + 1) Then
    '     if timeToBreakTile then timeToBreakTile = timeToBreakTile - 1

    '     if not timeToBreakTile Then
    '         tile = tile + 1
    '         if tile > (FADE_TILE + 1) Then

    '         end if
    '     end if
    ' else
    #ifdef KEYS_ENABLED
    If tile = DOOR_TILE Then
        If currentKeys Then
            currentKeys = currentKeys - 1
            
            #ifdef LEVELS_MODE
                moveScreen = 2
            #Else
                screenObjects(currentScreen, SCREEN_OBJECT_DOOR_INDEX) = 0
                removeTilesFromScreen(DOOR_TILE)
            #endif
            
            printHud()
            BeepFX_Play(4)
            #ifdef MESSAGES_ENABLED
                #ifdef HUD_SHOW_DOOR_MESSAGE
                    Else
                        printMessage(TEXT_NEED_KEYS, 2, 0)
                #endif
            #endif
        End If
    End If
    #endif

    #ifdef MESSAGES_ENABLED
        #ifdef HUD_SHOW_WALL_MESSAGE
            If tile = ENEMY_DOOR_TILE Then
                printMessage(TEXT_KILL_ALL, 2, 0)
            End If
        #endif    
    #endif
    ' end if
    
    return tile
end function

function isInStep(x as ubyte) as ubyte
    Dim col as uByte = x >> 1
    Dim lin as uByte = (protaY + 3) >> 1

    if GetTile(col, lin) < STEPS_TILE_INIT or GetTile(col, lin) > STEPS_TILE_END then return 0
    
    return 1
end function

#ifdef ARCADE_MODE
    sub countItemsOnTheScreen()
        dim index, y, x as integer
        
        x = 0
        y = 0
        
        itemsToFind = 0
        currentItems = 0
        for index=0 to SCREEN_LENGTH
            if GetTile(x, y) = ITEM_TILE then
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

        if tile > ENEMY_DOOR_TILE and tile < TRANSPASABLE_ITEMS then return tile
        
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

    if (x bAnd 1) Then maxCol = 2
    if (y bAnd 1) Then maxLin = 2
    
    for c=0 to maxCol
        for l=0 to maxLin
            if isSolidTileByColLin(col+c, lin+l) then return 1
        next l
    next c
    
    return 0
end function

sub removeTilesFromScreen(tile as ubyte)
    for tmpX = SKIP_WIDTH_SIZE to SKIP_WIDTH_SIZE + screenWidth - 1
        for tmpY = SKIP_HEIGHT_SIZE to SKIP_HEIGHT_SIZE + screenHeight - 1
            if GetTile(tmpX, tmpY) = tile then
                #ifdef SCREEN_ATTRIBUTES
                    SetTileChecked(currentTileBackground, currentScreenBackground, tmpX, tmpY)
                #else
                    SetTileChecked(0, BACKGROUND_ATTRIBUTE, tmpX, tmpY)
                #endif
            end if
        next tmpY
    next tmpX
end sub

sub updateProtaData(lin as ubyte, col as ubyte, tile as ubyte, directionRight as ubyte)
    ' if sprite = PROTA_SPRITE then
    protaX = col
    protaY = lin
    protaTile = tile
    protaDirection = directionRight
end sub

#ifdef SIDE_VIEW
    sub jump()
        #ifdef GLUE_PREVENT_JUMP
            if isOnGlue then return
        #endif

        if jumpCurrentKey = jumpStopValue and landed then
            landed = 0
            jumpCurrentKey = 0
        #ifdef DOUBLE_JUMP
            otherJump = 1
        Elseif jumpCurrentKey > 2 And otherJump Then
            otherJump = 0
            landed = 0
            jumpCurrentKey = 0
        #endif
        #ifdef WALL_JUMP
        Elseif jumpCurrentKey > 2 Then
            if CheckCollision(protaX - 1, protaY + 1) or CheckCollision(protaX + 1, protaY + 1) Then
                landed = 0
                jumpCurrentKey = 0

                #ifdef DOUBLE_JUMP
                    otherJump = 1
                #endif
            end if
        #endif
        end if
    end sub
#endif

Sub SetTileWithBackground(tile as uByte, x as ubyte, y as ubyte)
    #ifdef SCREEN_ATTRIBUTES
        SetTile(tile, tileAttrWithBackground(tile), x, y)
    #else
        #ifdef SCREEN_DARK_ENABLED
            SetTile(tile, tileAttrSet(tile), cordX, cordY)
        #Else
            SetTile(tile, attrSet(tile), cordX, cordY)
        #endif
    #endif
end sub

sub debugA(value as uBYTE)
    PRINT AT 0, 0; "----"
    PRINT AT 0, 0; value
end sub

sub debugB(value as uBYTE)
    PRINT AT 0, 5; "  "
    PRINT AT 0, 5; value
end sub

sub debugC(value as BYTE)
    PRINT AT 0, 10; "  "
    PRINT AT 0, 10; value
end sub

' sub debugD(value as UBYTE)
'     PRINT AT 18, 25; "  "
'     PRINT AT 18, 25; value
' end sub
