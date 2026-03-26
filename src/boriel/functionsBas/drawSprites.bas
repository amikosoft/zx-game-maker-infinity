' Sub drawSprites()
    If protaY < MAX_SCREEN_BOTTOM_PRINT Then
        #ifdef LIVES_MODE_GRAVEYARD
            #ifdef ENERGY_ENABLED
                If not currentEnergy or Not invincible Or invincible bAnd 2 Then
                    Draw2x2Sprite(protaTile, protaX, protaY)
                End If
            #else
                Draw2x2Sprite(protaTile, protaX, protaY)
            #endif
        #else
            If not currentLife or Not invincible Or (invincible bAnd 2) Then
                Draw2x2Sprite(protaTile, protaX, protaY)
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
