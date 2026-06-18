#ifdef PERMANENT_MOVEMENT_ENABLED
    #ifndef OVERHEAD_VIEW
        verticalAxisKeyPressed = 0
    #endif
#else
    verticalAxisKeyPressed = 0
    horizontalAxisKeyPressed = 0
#endif

#ifdef PREVENT_JUMP_ON_FIRE
    if shootPressed then shootPressed = shootPressed - 1
#endif

#ifdef CONSOLE_MODE
    #ifdef PERMANENT_MOVEMENT_ENABLED
        #ifdef PERMANENT_MOVEMENT_FREE
            If MultiKeys(keyArray(KEYO)) Then horizontalAxisKeyPressed = -1
            If MultiKeys(keyArray(KEYP)) Then horizontalAxisKeyPressed = 1
            #ifdef OVERHEAD_VIEW
                if MultiKeys(keyArray(KEYQ)) Then verticalAxisKeyPressed = 1
                if MultiKeys(keyArray(KEYA)) Then verticalAxisKeyPressed = -1
            #endif
        #else
            #ifndef PERMANENT_MOVEMENT_BOUNCE
                If horizontalAxisKeyPressed = 0 and verticalAxisKeyPressed = 0 then 
                    if MultiKeys(keyArray(KEYO)) Then horizontalAxisKeyPressed = -1
                    if MultiKeys(keyArray(KEYP)) Then horizontalAxisKeyPressed = 1

                    #ifdef OVERHEAD_VIEW
                        if MultiKeys(keyArray(KEYQ)) Then verticalAxisKeyPressed = 1
                        if MultiKeys(keyArray(KEYA)) Then verticalAxisKeyPressed = -1
                    #endif
                end if
            #endif
        #endif

        If horizontalAxisKeyPressed = -1 Then leftKey(1)
        If horizontalAxisKeyPressed = 1 Then rightKey(1)

        #ifdef OVERHEAD_VIEW
            If verticalAxisKeyPressed = 1 Then upKey()
            If verticalAxisKeyPressed = -1 Then downKey()
                            
            If MultiKeys(KEYSPACE) Then fireKey()
        #else
            #ifdef JUMP_CONTINUOUS
                If MultiKeys(KEYSPACE) Then fireKey()
                upKey()
            #else
                #ifdef PREVENT_JUMP_ON_FIRE
                    If MultiKeys(KEYSPACE) Then shootPressed = 5

                    If MultiKeys(KEYQ) Then 
                        upKey()
                    else if MultiKeys(KEYW) Then 
                        goUp(1)
                    end if
                    
                    If MultiKeys(KEYA) Then downKey()
                #else
                    If MultiKeys(KEYQ) Then 
                        upKey()
                    else if MultiKeys(KEYW) Then 
                        goUp(1)
                    end if

                    If MultiKeys(KEYA) Then downKey()
                    If MultiKeys(KEYSPACE) Then fireKey()
                #endif
            #endif
        #endif
    #else
        If MultiKeys(KEYO) Then leftKey(1)
        If MultiKeys(KEYP) Then rightKey(1)

        #ifdef JUMP_CONTINUOUS
             If MultiKeys(KEYSPACE) Then fireKey()
            upKey()
        #else
            #ifdef PREVENT_JUMP_ON_FIRE
                If MultiKeys(KEYSPACE) Then shootPressed = 5

                #ifdef SIDE_VIEW
                    If MultiKeys(KEYQ) Then 
                        upKey()
                    else if MultiKeys(KEYW) Then 
                        goUp(1)
                    end if
                #Else
                    if MultiKeys(KEYW) Then upKey()
                #endif

                If MultiKeys(KEYA) Then downKey()
            #else
                #ifdef SIDE_VIEW
                    If MultiKeys(KEYQ) Then 
                        upKey()
                    else if MultiKeys(KEYW) Then 
                        goUp(1)
                    end if
                #Else
                    if MultiKeys(KEYW) Then upKey()
                #endif
                If MultiKeys(KEYA) Then downKey()
                If MultiKeys(KEYSPACE) Then fireKey()
            #endif
        #endif
    #endif
#else
    If kempston Then
        Dim n As Ubyte = In(31)

        #ifdef PERMANENT_MOVEMENT_ENABLED
            #ifdef PERMANENT_MOVEMENT_FREE
                If n bAND %10 Then horizontalAxisKeyPressed = -1
                If n bAND %1 Then horizontalAxisKeyPressed = 1
                #ifdef OVERHEAD_VIEW
                    if n bAND %1000 Then verticalAxisKeyPressed = 1
                    if n bAND %100 Then verticalAxisKeyPressed = -1
                #endif
            #else
                #ifndef PERMANENT_MOVEMENT_BOUNCE
                    If horizontalAxisKeyPressed = 0 and verticalAxisKeyPressed = 0 then 
                        if n bAND %10 Then horizontalAxisKeyPressed = -1
                        if n bAND %1 Then horizontalAxisKeyPressed = 1

                        #ifdef OVERHEAD_VIEW
                             if n bAND %1000 Then verticalAxisKeyPressed = 1
                             if n bAND %100 Then verticalAxisKeyPressed = -1
                        #endif
                    end if
                #endif
            #endif

            If horizontalAxisKeyPressed = -1 Then leftKey(1)
            If horizontalAxisKeyPressed = 1 Then rightKey(1)

            #ifdef OVERHEAD_VIEW
                If verticalAxisKeyPressed = 1 Then upKey()
                If verticalAxisKeyPressed = -1 Then downKey()
                                
                If n bAND %10000 Then fireKey()
            #else
                #ifdef JUMP_CONTINUOUS
                    If n bAND %10000 Then fireKey()
                    upKey()
                #else
                    #ifdef PREVENT_JUMP_ON_FIRE
                        If n bAND %10000 Then shootPressed = 5
                        If n bAND %1000 Then upKey()
                        If n bAND %100 Then downKey()
                    #else
                        If n bAND %1000 Then upKey()
                        If n bAND %100 Then downKey()
                        If n bAND %10000 Then fireKey()
                    #endif
                #endif
            #endif
        #else
            If n bAND %10 Then leftKey(1)
            If n bAND %1 Then rightKey(1)
            
            #ifdef JUMP_CONTINUOUS
                If n bAND %10000 Then fireKey()
                upKey()
            #else
                #ifdef PREVENT_JUMP_ON_FIRE
                    If n bAND %10000 Then shootPressed = 5
                    If n bAND %1000 Then upKey()
                    If n bAND %100 Then downKey()
                #else
                    If n bAND %1000 Then upKey()
                    If n bAND %100 Then downKey()
                    If n bAND %10000 Then fireKey()
                #endif
            #endif
        #endif
    Else
        #ifdef PERMANENT_MOVEMENT_ENABLED
            #ifdef PERMANENT_MOVEMENT_FREE
                If MultiKeys(keyArray(LEFT)) Then horizontalAxisKeyPressed = -1
                If MultiKeys(keyArray(RIGHT)) Then horizontalAxisKeyPressed = 1
                #ifdef OVERHEAD_VIEW
                    if MultiKeys(keyArray(UP)) Then verticalAxisKeyPressed = 1
                    if MultiKeys(keyArray(DOWN)) Then verticalAxisKeyPressed = -1
                #endif
            #else
                #ifndef PERMANENT_MOVEMENT_BOUNCE
                    If horizontalAxisKeyPressed = 0 and verticalAxisKeyPressed = 0 then 
                        if MultiKeys(keyArray(LEFT)) Then horizontalAxisKeyPressed = -1
                        if MultiKeys(keyArray(RIGHT)) Then horizontalAxisKeyPressed = 1

                        #ifdef OVERHEAD_VIEW
                             if MultiKeys(keyArray(UP)) Then verticalAxisKeyPressed = 1
                             if MultiKeys(keyArray(DOWN)) Then verticalAxisKeyPressed = -1
                        #endif
                    end if
                #endif
            #endif

            If horizontalAxisKeyPressed = -1 Then leftKey(1)
            If horizontalAxisKeyPressed = 1 Then rightKey(1)

            #ifdef OVERHEAD_VIEW
                If verticalAxisKeyPressed = 1 Then upKey()
                If verticalAxisKeyPressed = -1 Then downKey()
                                
                If MultiKeys(keyArray(FIRE)) Then fireKey()
            #else
                #ifdef JUMP_CONTINUOUS
                    If MultiKeys(keyArray(FIRE)) Then fireKey()
                    upKey()
                #else
                    #ifdef PREVENT_JUMP_ON_FIRE
                        If MultiKeys(keyArray(FIRE)) Then shootPressed = 5
                        If MultiKeys(keyArray(UP)) Then upKey()
                        If MultiKeys(keyArray(DOWN)) Then downKey()
                    #else
                        If MultiKeys(keyArray(UP)) Then upKey()
                        If MultiKeys(keyArray(DOWN)) Then downKey()
                        If MultiKeys(keyArray(FIRE)) Then fireKey()
                    #endif
                #endif
            #endif
        #else
            If MultiKeys(keyArray(LEFT)) Then leftKey(1)
            If MultiKeys(keyArray(RIGHT)) Then rightKey(1)

            #ifdef JUMP_CONTINUOUS
                If MultiKeys(keyArray(FIRE)) Then fireKey()
                upKey()
            #else
                #ifdef PREVENT_JUMP_ON_FIRE
                    If MultiKeys(keyArray(FIRE)) Then shootPressed = 5
                    If MultiKeys(keyArray(UP)) Then upKey()
                    If MultiKeys(keyArray(DOWN)) Then downKey()
                #else
                    If MultiKeys(keyArray(UP)) Then upKey()
                    If MultiKeys(keyArray(DOWN)) Then downKey()
                    If MultiKeys(keyArray(FIRE)) Then fireKey()
                #endif
            #endif
        #endif
    End If
#endif

#ifdef PREVENT_JUMP_ON_FIRE
    if shootPressed = 5 then fireKey()
#endif

#ifdef IDLE_ENABLED
    If not horizontalAxisKeyPressed and not verticalAxisKeyPressed Then
        If protaLoopCounter < IDLE_TIME Then protaLoopCounter = protaLoopCounter + 1
    Else
        protaLoopCounter = 0
    End If
#endif