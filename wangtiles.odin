package wangtiles
import rl   "vendor:raylib"

Window :: struct { 
    title:	cstring,
    width:	i32, 
    height:	i32,
}

Coord :: struct {
	X: i32,
	Y: i32
}

World :: struct {
    width:   i32,
    height:  i32,
    size: i32,
    tile:   []i32,
}



Tile :: struct {
	source: rl.Rectangle,
}



getSourceRect :: proc(tile: i32) -> rl.Rectangle {
	x : i32 = tile % 4
	y : i32 = tile / 4
	return {f32(x * 64), f32(y * 64), 64, 64}
}



main :: proc() {
	window := Window{"wang maze", 768, 768}
	world := World{ 12, 12, 12 * 12, make([]i32, 12 * 12) }

	// rl.SetRandomSeet(48)

	rl.InitWindow(window.width, window.height, window.title)
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)


	tilemap : rl.Texture2D = rl.LoadTexture("tilemap.png"); 
	
	tiles := make([]rl.Rectangle, world.size)

	for i : i32 = 0; i < world.size; i += 1 {
		world.tile[i] = rl.GetRandomValue(0,16)
		tiles[i] = getSourceRect(world.tile[i])
	}


	
	for !rl.WindowShouldClose() {


		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		for i : i32 = 0; i < world.size; i += 1 {
			x : f32 = f32(i % world.width) * 64
			y : f32 = f32(i / world.height) * 64
			rl.DrawTextureRec(tilemap, tiles[i], {x, y}, rl.WHITE)
		}


		rl.EndDrawing()
	}
}