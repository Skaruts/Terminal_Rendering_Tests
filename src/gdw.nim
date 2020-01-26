import strutils
import godot

################################################################################
#    This is just a sort of wrapper around some unwieldy godot-nim procs
################################################################################

template vec2*(x, y: int):untyped =
    vec2(float(x), float(y))

template `*`*(v:Vector2, s:int):untyped =
    v * float(s)

# Rect2
template rect2*(x, y, w, h:untyped):Rect2 =
  initRect2( float32(x), float32(y), float32(w), float32(h) )

template rect2*(v1, v2:untyped):Rect2 =
  initRect2( float32(v1.x), float32(v1.y), float32(v2.x), float32(v2.y) )


# RGBA colors
template col*(): Color =
    initColor()

template col*(r,g,b:untyped, a:untyped = 1.0): Color =
    initColor( float32(r), float32(g), float32(b), float32(a) )

proc col*(c:uint32): Color =
    col(
        float( (c shr 24) and 0xff ) / 255.0,
        float( (c shr 16) and 0xff ) / 255.0,
        float( (c shr  8) and 0xff ) / 255.0,
        float( (c shr  0) and 0xff ) / 255.0
    )

# color in HTML format, as
# "rrggbbaa" or "rrggbb"
proc col*(c:string): Color =
    let invalid = AllChars - HexDigits
    if not c.find(invalid) == -1:
        return col(1.0, 1.0, 1.0, 1.0)

    # make sure the string includes alpha
    var str = c
    if   len(str) == 6: str &= "ff"
    elif len(str) == 7: str &= "f"    # TODO: this should be an error?

    col(uint32(parseHexInt(str)))

