#ifdef SIDE_VIEW
    Function getNextFrameJumpingFalling() As Ubyte
        If protaDirection Then
            Return PROTA_FRAME_JUMP_RIGHT
        Else
            Return PROTA_FRAME_JUMP_LEFT
        End If
    End Function
    
    Function isFalling() As Ubyte
        If canMoveDown() Then
            #ifdef JETPACK_FUEL
                If pressingUp() Then
                    jumpCurrentKey = 0
                End If
            #endif
            Return 1
        Else
            If not landed Then
                landed = 1
                jumpCurrentKey = jumpStopValue
                #ifdef JETPACK_FUEL
                    jumpEnergy = jumpStepsCount
                    printHud()
                #endif
                If protaY bAND 1 Then
                    protaY = protaY - 1
                End If

                if protaDirection then
                    protaTile = FIRST_RUNNING_PROTA_SPRITE_RIGHT
                else
                    protaTile = FIRST_RUNNING_PROTA_SPRITE_LEFT
                end if
            End If
            Return 0
        End If
    End Function

    #ifndef JETPACK_FUEL
        #ifdef SCREEN_TERRAIN_ENABLED
        If screenIsTerrain = 1 or jumpCurrentKey >= jumpStopValue or jumpCurrentKey >= jumpStepsCount - 1 Then
        #else
        If jumpCurrentKey >= jumpStopValue or jumpCurrentKey >= jumpStepsCount - 1 Then
        #endif
            jumpCurrentKey = jumpStopValue
            
            'gravity()
            #ifdef SCREEN_TERRAIN_ENABLED
                if screenIsTerrain then
                    ' jumpCurrentKey = jumpStopValue
                    if protaY >= MAX_SCREEN_BOTTOM then 
                        moveScreen = 2
                    end if
                    return
                end if
            #endif
            
            If isFalling() Then
                landed = 0
                If protaY >= MAX_SCREEN_BOTTOM Then
                    #ifdef LEVELS_MODE
                        landed = 1
                        decrementLife()
                        
                        #ifndef LIVES_MODE_ENABLED
                            jump()
                        #endif
                    #else
                        moveScreen = 2
                    #endif
                Else
                    protaTile = getNextFrameJumpingFalling()
                    
                    #ifndef JETPACK_FUEL
                        #ifndef LOW_GRAVITY
                            protaY = protaY + 2
                        #Else
                            protaY = protaY + 1
                        #endif
                    #Else
                        protaY = protaY + 1
                    #endif
                End If
            #ifdef UNDER_PLAYER_VALIDATION
                Else
                    'CheckAutoBreakableTile()
                    #include "underTileValidations.bas"
                #endif
            End If
            Return
        End If
        
        protaTile = getNextFrameJumpingFalling()
        
        if not (checkProtaTop() or CheckCollision(protaX, protaY + jumpArray(jumpCurrentKey))) Then
            protaY = protaY + jumpArray(jumpCurrentKey)
        End if

        jumpCurrentKey = jumpCurrentKey + 1
    #else
        #ifdef SCREEN_TERRAIN_ENABLED
        If screenIsTerrain = 1 or jumpCurrentKey = jumpStopValue Then
        #else
        If jumpCurrentKey = jumpStopValue Then
        #endif
            'gravity()
            #ifdef SCREEN_TERRAIN_ENABLED
                if screenIsTerrain then
                    ' jumpCurrentKey = jumpStopValue
                    if protaY >= MAX_SCREEN_BOTTOM then 
                        moveScreen = 2
                    end if
                    return
                end if
            #endif
            
            If isFalling() Then
                landed = 0
                If protaY >= MAX_SCREEN_BOTTOM Then
                    #ifdef LEVELS_MODE
                        landed = 1
                        decrementLife()
                        
                        #ifndef LIVES_MODE_ENABLED
                            jump()
                        #endif
                    #else
                        moveScreen = 2
                    #endif
                Else
                    protaTile = getNextFrameJumpingFalling()
                    
                    #ifndef JETPACK_FUEL
                        #ifndef LOW_GRAVITY
                            protaY = protaY + 2
                        #Else
                            protaY = protaY + 1
                        #endif
                    #Else
                        protaY = protaY + 1
                    #endif
                End If
            #ifdef UNDER_PLAYER_VALIDATION
                Else
                    'CheckAutoBreakableTile()
                    #include "underTileValidations.bas"
                #endif
            End If 
            Return
        end if
        
        If jumpEnergy > 0 Then
            checkProtaTop()
        End if
        
        If pressingUp() And jumpEnergy > 0 Then
            If Not CheckCollision(protaX, protaY - 1) Then
                protaY = protaY - 1
                protaTile = getNextFrameJumpingFalling()
            End If
            jumpCurrentKey = jumpCurrentKey + 1
            jumpEnergy = jumpEnergy - 1
            PRINT AT 23, 5; TEXT_3_SPACES
            PRINT AT 23, 5; jumpEnergy
            Return
        End If
        
        ' stop flight
        jumpCurrentKey = jumpStopValue
    #endif
#endif