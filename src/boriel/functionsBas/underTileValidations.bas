
#ifdef SIDE_VIEW
    #ifdef UNDER_PLAYER_VALIDATION
        #ifdef FADE_TILES_ENABLED
            #ifndef TRAMPOLIN_ENABLED
                #ifndef GLUE_TILE_ENABLED
                    #ifndef MECHANICAL_BELT_ENABLED
                        if not maxFadeTile then return
                    #endif
                #endif
            #endif
        #endif

        ' Dim col as uByte = protaX >> 1
        Dim lin as uByte = protaLin + 2

        for c=protaCol to (protaCol+2)
            dim tileFound as ubyte = isSolidTileByColLin(c, lin)
            
            #ifdef TRAMPOLIN_ENABLED
                if tileFound = TRAMPOLIN_TILE Then
                    jump()
                    exit for
                end if
            #endif
            
            #ifdef GLUE_TILE_ENABLED
                if tileFound = GLUE_TILE then isOnGlue = 1
            #endif
            
            #ifdef MECHANICAL_BELT_ENABLED
                #ifdef MECHANICAL_BELT_SLOW
                    if enemiesFrame band 1 then
                    #endif
                    if tileFound = LEFT_TILE Then
                        leftKey(0)
                        exit for
                    else if tileFound = RIGHT_TILE Then
                        rightKey(0)
                        exit for
                    end if
                    #ifdef MECHANICAL_BELT_SLOW
                    end if
                #endif
            #endif
            
            #ifdef FADE_TILES_ENABLED
                if tileFound = FADE_TILE or tileFound = FADE_TILE_END Then
                    for i = 0 to maxFadeTile - 1
                        dim tileStatus as ubyte = fadeTileStatus(i, 2)
                        if tileStatus and fadeTileStatus(i, 0) = c and fadeTileStatus(i, 1) = lin then
                            tileStatus = tileStatus - 1
                            
                            if not tileStatus then
                                #ifdef SCREEN_ATTRIBUTES
                                    SetTile(currentTileBackground, currentScreenBackground, c, lin)
                                #else
                                    SetTile(0, BACKGROUND_ATTRIBUTE, c, lin)
                                #endif
                            else if tileStatus < (FADE_TILE_FRAMES/2) and tileFound = FADE_TILE then
                                ' SetTile(FADE_TILE_END, tileAttrWithBackground(FADE_TILE_END), c, lin)
                                SetTileWithBackground(FADE_TILE_END, c, lin)
                            end if
                            fadeTileStatus(i, 2) = tileStatus
                        end if
                    next i
                End if
            #endif
        next c
    #endif
#endif