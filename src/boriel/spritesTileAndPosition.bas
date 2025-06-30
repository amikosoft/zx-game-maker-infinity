
sub saveSprite(sprite as ubyte, lin as ubyte, col as ubyte, tile as ubyte, directionRight as ubyte)
    if sprite = PROTA_SPRITE then
        protaX = col
        protaY = lin
        protaTile = tile
        protaDirection = directionRight
        return
    end if
    spritesLinColTileAndFrame(sprite, 0) = lin
    spritesLinColTileAndFrame(sprite, 1) = col
    spritesLinColTileAndFrame(sprite, 2) = tile
    spritesLinColTileAndFrame(sprite, 3) = directionRight
    if spritesLinColTileAndFrame(sprite, 4) = 6 then
        spritesLinColTileAndFrame(sprite, 4) = 0
    else
        spritesLinColTileAndFrame(sprite, 4) = spritesLinColTileAndFrame(sprite, 4) + 1
    end if
end sub

#ifdef SIDE_VIEW
    sub resetProtaSpriteToRunning()
        if protaDirection then
            saveSprite(PROTA_SPRITE, protaY, protaX, FIRST_RUNNING_PROTA_SPRITE_RIGHT, protaDirection)
        else
            saveSprite(PROTA_SPRITE, protaY, protaX, FIRST_RUNNING_PROTA_SPRITE_LEFT, protaDirection)
        end if
    end sub
#endif

' sub removeScreenObjectFromBuffer()
'     for i = 0 to 4
'         for j = 0 to spritesDataCount - 1
'             spritesLinColTileAndFrame(i, j) = 0
'         next j
'     next i
' end sub