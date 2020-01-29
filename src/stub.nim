# Copyright 2017 Xored Software, Inc.

## Import independent scene objects here
## (no need to import everything, just independent roots)

when not defined(release):
  import segfaults # converts segfaults into NilAccessError

import rl_terminal  # avoid conflict with std terminal
import rl_camera
import rl_base_map
# import fov
import data
export rl_base_map
