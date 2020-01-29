import gdw
import godot
import godotapi/[
    node,
    # resource_loader,
    # godottypes,
    # packed_scene,
    # sprite,
    # gd_script
]


const HIDDEN:int = 0
const VISIBLE:int = 1
const OPAQUE:int = 2
const OBSTACLE:int = 3

gdobj Fov of Node:
    var circlemap:seq[seq[int]]
    var last_radius = 0
    var rounded = true
    var collmap:seq[seq[bool]]
    var opctmap:seq[seq[bool]]
    var fovmap:seq[seq[int]]
    var w = 0
    var h = 0

    proc init*(w, h:int) {.gdExport.} =
        self.w = w
        self.h = h
        self.init_maps()

    proc init_maps() =
        self.collmap = newSeq[seq[bool]](self.h)
        self.opctmap = newSeq[seq[bool]](self.h)
        self.fovmap = newSeq[seq[int]](self.h)
        for j in 0..<self.h:
            self.collmap[j] = newSeq[bool](self.w)
            self.opctmap[j] = newSeq[bool](self.w)
            self.fovmap[j] = newSeq[int](self.w)

    proc clear() =
        for j in 0..<self.h:
            for i in 0..<self.w:
                self.fovmap[j][i] = HIDDEN



    #==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#
    #
    #      interface
    #
    #==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#
    proc is_opaque*(x, y:int):bool {.gdExport.} =
        x < 0 or x >= self.w or y < 0 or y >= self.h or
        self.collmap[y][x]

    proc is_opaque_nc*(x, y:int):bool {.gdExport.} =
        self.collmap[y][x]

    proc set_visible*(x, y:int, enable = true) {.gdExport.} =
        if x >= 0 or x < self.w or y >= 0 or y < self.h:
            self.fovmap[y][x] = int(enable)

    proc set_visible_nc*(x, y:int, enable = true) {.gdExport.} =
        self.fovmap[y][x] = int(enable)

    proc is_visible*(x, y:int):bool {.gdExport.} =
        x < 0 or x >= self.w or y < 0 or y >= self.h or
            self.fovmap[y][x] == VISIBLE

    proc is_visible_nc*(x, y:int):bool {.gdExport.} =
        self.fovmap[y][x] == VISIBLE

    proc set_cell*(x, y:int, visible, obstacle, opaque:bool) {.gdExport.} =
        self.fovmap[y][x] = int(visible)
        self.collmap[y][x] = obstacle
        self.opctmap[y][x] = opaque



    #==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#
    #      Filled Mid-point Circle
    #
    #  Used here to perform a second pass on square fovs and make them round
    #==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#
    proc make_fov_circle_mask(radius:int) =
        var size = radius * 2 + 1
        var cx = radius
        var cy = radius
        var err = -radius
        var x = radius
        var y = 0

        # print(string.format("r:%s | size:%s | cx,cy:%s,%s", radius, size, cx, cy))
        self.circlemap = newSeq[seq[int]](self.h)
        for j in 0..<size:
            self.circlemap[j] = newSeq[int](self.w)
            # for i in 0..<size:
            #     self.circlemap[j].add(0)

        while x >= y:
            let last_y = y
            err += y
            y   += 1
            err += y

            self.make_lines(cx, cy, x, last_y, size)

            if err >= 0:
                if x != last_y:
                    self.make_lines(cx, cy, last_y, x, size)

                err -= x
                x   -= 1
                err -= x

    proc apply_fov_circle_mask(pos_x, pos_y, radius:int) =
        let size = radius * 2 + 1

        for j in 0..<size:
            for i in 0..<size:
                let x = pos_x + i - radius
                let y = pos_y + j - radius
                if self.circlemap[j][i] == HIDDEN:
                    if x >= 0 and y >= 0 and x < self.w and y < self.h:
                        self.set_visible(x, y, false)

    proc make_lines(cx, cy, x, y, size:int) =
        self.line(cx-x, cy+y, cx+x, size)
        if y != 0: self.line(cx-x, cy-y, cx+x, size)

    proc line(x0, y0, x1, size:int) =
        for x in x0..<x1:
            self.put_pixel(x, y0, size)

    proc put_pixel(x, y, size:int) =
        if x >= 0 and y >= 0 and x < size and y < size:
            self.circlemap[y][x] = VISIBLE



    #==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#
    #       Restrictive Precise Angle Shadowcasting (from js)
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
    # Works perfectly, as far as I can tell.
    #
    # Ported from:
    #     https://github.com/domasx2/mrpas-js/blob/master/mrpas.js
    #==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#==#

    proc recompute*(pos_x, pos_y, radius:int, rounded = false) {.gdExport.} =
        self.clear()
        self.set_visible(pos_x, pos_y, true)   # make starting vec visible

        # compute the 4 quadrants of the self
        self.mrpas_js_compute_quadrant(pos_x, pos_y, radius,  1,  1)
        self.mrpas_js_compute_quadrant(pos_x, pos_y, radius,  1, -1)
        self.mrpas_js_compute_quadrant(pos_x, pos_y, radius, -1,  1)
        self.mrpas_js_compute_quadrant(pos_x, pos_y, radius, -1, -1)

        if rounded:
            if self.last_radius != radius:
                self.make_fov_circle_mask(radius)
            self.apply_fov_circle_mask(pos_x, pos_y, radius)
            self.last_radius = radius

    proc mrpas_js_compute_quadrant(pos_x, pos_y, radius, dx, dy:int) =
        # print("computing")
        var start_angle = newSeq[float](100)
        var end_angle = newSeq[float](100)


        #  octant: vertical edge:
        #  - - - - - - - - - - - - - - - - - - - - - - -
        var iteration = 1
        var done = false
        var total_obstacles = 0
        var obstacles_in_last_line = 0
        var min_angle = 0.0

        var x = 0
        var y = pos_y + dy

        var slopes_per_cell:float
        var half_slopes:float
        var processed_cell:int
        var minx:int
        var maxx:int
        var miny:int
        var maxy:int
        # var pos:Vector2i
        var visible:bool
        var idx:int
        var start_slope:float
        var center_slope:float
        var end_slope:float

        if y < 0 or y >= self.h or y < pos_y-radius or y > pos_y+radius:
            done = true

        while not done:
            # process cells in the line
            slopes_per_cell = 1.0 / float(iteration + 1)
            half_slopes = slopes_per_cell * 0.5
            processed_cell = int(min_angle / slopes_per_cell)

            minx = max(        0, pos_x - iteration)
            maxx = min(self.w - 1, pos_x + iteration)

            done = true

            x = pos_x + (processed_cell * dx)

            while x >= minx and x <= maxx:
                # pos = sf_Vector2(x, y)
                visible = true

                start_slope = float(processed_cell) * slopes_per_cell
                center_slope = start_slope + half_slopes
                end_slope = start_slope + slopes_per_cell

                if obstacles_in_last_line > 0 and not self.is_visible(x, y):
                    idx = 0

                    while visible and idx < obstacles_in_last_line:
                        if not self.is_opaque(x, y):
                            if center_slope > start_angle[idx] and center_slope < end_angle[idx]:
                                visible = false
                        elif start_slope >= start_angle[idx] and end_slope <= end_angle[idx]:
                            visible = false

                        let xdx = x-dx
                        let ydy = y-dy

                        if visible and ( not self.is_visible(x, ydy) or self.is_opaque(x, ydy) ) and
                            ( xdx >= 0 and xdx < self.w and ( not self.is_visible(xdx, ydy) or self.is_opaque(xdx, ydy) )):
                                visible = false

                        idx += 1

                if visible:
                    self.set_visible(x, y, true)
                    done = false

                    # if the cell is opaque, block the adjacent slopes
                    if self.is_opaque(x, y):
                        if min_angle >= start_slope:
                            min_angle = end_slope
                        else:
                            start_angle[total_obstacles] = start_slope
                            end_angle[total_obstacles] = end_slope
                            total_obstacles += 1

                processed_cell += 1
                x += dx

            if iteration == radius: done = true

            iteration += 1
            obstacles_in_last_line = total_obstacles

            y += dy
            if y < 0 or y >= self.h: done = true
            if min_angle == 1.0: done = true

        # octant: horizontal edge
        #  - - - - - - - - - - - - - - - - - - - - - - -
        iteration = 1 # iteration of the algo for this octant
        done = false
        total_obstacles = 0
        obstacles_in_last_line = 0
        min_angle = 0.0

        x = pos_x + dx # the outer slope's coordinates (first processed line)
        y = 0

        slopes_per_cell = 0
        half_slopes = 0
        processed_cell = 0
        minx = 0
        maxx = 0
        miny = 0
        maxy = 0
        # pos = sf_Vector2()
        visible = false
        idx = 0
        start_slope = 0
        center_slope = 0
        end_slope = 0

        if x < 0 or x >= self.w: done = true

        while not done:
            # process cells in the line
            slopes_per_cell = 1.0 / float(iteration + 1)
            half_slopes = slopes_per_cell * 0.5
            processed_cell = int(min_angle / slopes_per_cell)

            miny = max(      0, pos_y - iteration)
            maxy = min(self.h-1, pos_y + iteration)

            done = true

            y = pos_y + (processed_cell * dy)

            while y >= miny and y <= maxy:
                # pos = sf_Vector2(x, y)
                visible = true

                start_slope = float(processed_cell) * slopes_per_cell
                center_slope = start_slope + half_slopes
                end_slope = start_slope + slopes_per_cell

                if obstacles_in_last_line > 0 and not self.is_visible(x, y):
                    idx = 0

                    while visible and idx < obstacles_in_last_line:
                        if not self.is_opaque(x, y):
                            if center_slope > start_angle[idx] and center_slope < end_angle[idx]:
                                visible = false
                        elif start_slope >= start_angle[idx] and end_slope <= end_angle[idx]:
                            visible = false

                        let xdx = x - dx
                        let ydy = y - dy

                        if visible and ( not self.is_visible(xdx, y) or self.is_opaque(xdx, y) ) and
                            ( ydy >= 0 and ydy < self.h and ( not self.is_visible(xdx, ydy) or self.is_opaque(xdx, ydy) ) ):
                                visible = false

                        idx = idx + 1

                if visible:
                    self.set_visible(x, y, true)
                    done = false

                    # if the cell is opaque, block the adjacent slopes
                    if self.is_opaque(x, y):
                        if min_angle >= start_slope:
                            min_angle = end_slope
                        else:
                            start_angle[total_obstacles] = start_slope
                            end_angle[total_obstacles] = end_slope
                            total_obstacles = total_obstacles + 1

                processed_cell += 1
                y += dy

            if iteration == radius: done = true

            iteration += 1
            obstacles_in_last_line = total_obstacles

            x += dx
            if x < 0 or x >= self.w: done = true
            if min_angle == 1.0: done = true
