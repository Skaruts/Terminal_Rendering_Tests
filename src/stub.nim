# Copyright 2017 Xored Software, Inc.

## Import independent scene objects here
## (no need to import everything, just independent roots)

when not defined(release):
  import segfaults # converts segfaults into NilAccessError

# import terminal_gdn_sprites
# import terminal_gdn_draw
# import terminal_gdn_shaders
# import terminal_gdn_server
import terminal
import game_camera
import map_gdn

