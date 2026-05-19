from pathlib import Path
from builder import helper
from builder.GenerateShiftedData import GenerateShiftedData
from builder.GenerateUnshiftedData import GenerateUnshiftedData
from builder.Charset import CharSet
from builder.ZXPToSpritesConversor import ZXPToSpritesConversor
from builder.PreshiftedSpritesWriter import PreshiftedSpritesWriter

class ConvertZXPToGuSprites:
    @staticmethod
    def preshiftSprites(sprites):
        preshiftedSprites = []
        for sprite in sprites:
            charset = CharSet.createFromSprite(sprite.data, sprite.width // 8, sprite.height // 8)
            preshiftedSprites.append(GenerateShiftedData.generate(charset))
        
        return preshiftedSprites
    
    @staticmethod
    def unshiftSprites(sprites):
        unshiftedSprites = []
        for sprite in sprites:
            charset = CharSet.createFromSprite(sprite.data, sprite.width // 8, sprite.height // 8)
            unshiftedSprites.append(GenerateUnshiftedData.generate(charset))
        
        return unshiftedSprites
    
    @staticmethod
    def convert():
        output_file = "boriel/lib/Sprites.zxbas"

        sprites = ZXPToSpritesConversor.convert(str(Path("../assets/map/sprites.zxp")))

        # bulletFile = "../assets/map/bullet.zxp"
        bulletFile = "../assets/map/bulletOverhead.zxp"
        bulletCount = 4
        
        if helper.getBulletAnimation() == True or helper.getBoomerangEnabled() == True:
            bulletCount = 2
            bulletFile = "../assets/map/bullet.zxp"
            if helper.getEnemiesShoot() > 0:
                bulletCount = 3
        else:
            if helper.getEnemiesShoot() > 0:
                bulletCount = 5
    

           
        sprites.extend(ZXPToSpritesConversor.convert(str(Path(bulletFile)), bulletCount, 8, 8))  # Use extend instead of append

        # ConvertZXPToGuSprites.writeSimple(sprites)

        preshiftedSprites = ConvertZXPToGuSprites.preshiftSprites(sprites)
        unshiftedSprites = ConvertZXPToGuSprites.unshiftSprites(sprites)

        PreshiftedSpritesWriter.write(preshiftedSprites, output_file)
        PreshiftedSpritesWriter.write(unshiftedSprites, "boriel/lib/sprites.bas")
    
    @staticmethod
    def writeSimple(sprites):
        if not sprites or not isinstance(sprites, list):
            raise TypeError("sprites must be a non-empty list.")

        with open('boriel/lib/sprites.bas', "w") as f:
            f.write("'REM --SPRITE SECTION--\n\n")
            f.write("asm\n\n")
            f.write("SPRITE_BUFFER:\n")
            
            charsetOffsets = [0]
            for spriteIdx, sprite in enumerate(sprites):
                charset = CharSet.createFromSprite(sprite.data, sprite.width // 8, sprite.height // 8)
                
                f.write("\tDEFB ")
                for idx, spriteData in enumerate(charset.Data):
                    if idx > 0:
                        f.write(',')
                    f.write(str(spriteData).replace("[", "").replace("]", ""))
                
                charsetOffsets.append(charsetOffsets[spriteIdx] + (len(charset.Data)*8))
                f.write('\n')
            
            f.write("SPRITE_INDEX:\n")
            
            for idx, sprite in enumerate(sprites):
                f.write("\tDEFW (SPRITE_BUFFER + " + str(charsetOffsets[idx]) + ")\n")
            
            f.write("SPRITE_COUNT:\n")
            f.write("\tDEFB " + str(len(sprites)) + "\n")

            f.write("end asm\n")
            
            f.write("\n")

    @staticmethod
    def writeGuSpritesBinary(sprites, filename_16="boriel/lib/gusprites_16.bin", filename_8="boriel/lib/gusprites_8.bin"):
        sprites_16 = bytearray()
        sprites_8 = bytearray()
        
        for sprite in sprites:
            charset = CharSet.createFromSprite(sprite.data, sprite.width // 8, sprite.height // 8)
            
            flat_data = [byte for block in charset.Data for byte in block]
            
            if sprite.width == 16 and sprite.height == 16:
                sprites_16.extend(flat_data)
            elif sprite.width == 8 and sprite.height == 8:
                sprites_8.extend(flat_data)
                
        with open(filename_16, 'wb') as f:
            f.write(sprites_16)
            
        with open(filename_8, 'wb') as f:
            f.write(sprites_8)