SUB switch2ShadowScreen()
    DIM bankM AS UBYTE = peek $5b5c
    bankM = bankM bOr %00001000
    POKE $5b5c,bankM
    OUT $7ffd,bankM
END SUB

SUB switch2NormalScreen()
    DIM bankM AS UBYTE = peek $5b5c
    bankM = bankM bAnd %11110111
    POKE $5b5c,bankM
    OUT $7ffd,bankM
END SUB

sub ActivarBuffer() 
    SetBank(7)
    SetScreenBufferAddr($C000) '49152
    SetAttrBufferAddr($D800) '55296
end sub

sub DesactivarBuffer() 
    SetBank(0)
    SetScreenBufferAddr($4000) 
    SetAttrBufferAddr($5800)
end sub

