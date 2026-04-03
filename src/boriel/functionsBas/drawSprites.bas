' Sub drawSprites()
    If protaY < MAX_SCREEN_BOTTOM_PRINT Then
        #ifdef LIVES_MODE_GRAVEYARD
            #ifdef ENERGY_ENABLED
                If not currentEnergy or Not invincible Or invincible bAnd 2 Then
                    #ifdef SPRITES_COLOR_ENABLED
                        #ifdef PLAYER_COLOR_ENABLED
                            drawSpriteWithColor(protaTile, protaX, protaY, PLAYER_COLOR)
                        #Else
                            drawSpriteWithColor(protaTile, protaX, protaY, currentScreenBackground)
                        #endif
                    #Else
                        Draw2x2Sprite(protaTile, protaX, protaY)
                    #endif
                End If
            #else
                #ifdef SPRITES_COLOR_ENABLED
                    #ifdef PLAYER_COLOR_ENABLED
                        drawSpriteWithColor(protaTile, protaX, protaY, PLAYER_COLOR)
                    #Else
                        drawSpriteWithColor(protaTile, protaX, protaY, currentScreenBackground)
                    #endif
                #Else
                    Draw2x2Sprite(protaTile, protaX, protaY)
                #endif
            #endif
        #else
            If not currentLife or Not invincible Or (invincible bAnd 2) Then
                #ifdef SPRITES_COLOR_ENABLED
                    #ifdef PLAYER_COLOR_ENABLED
                        drawSpriteWithColor(protaTile, protaX, protaY, PLAYER_COLOR)
                    #Else
                        drawSpriteWithColor(protaTile, protaX, protaY, currentScreenBackground)
                    #endif
                #Else
                    Draw2x2Sprite(protaTile, protaX, protaY)
                #endif
            End If
        #endif
    End If
    
    #ifdef SHOOTING_ENABLED
        If bulletPositionX <> 0 Then
            Draw1x1Sprite(currentBulletSpriteId, bulletPositionX, bulletPositionY)
        End If
    #endif
    
    RenderFrame()
' End Sub
