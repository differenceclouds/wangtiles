package wangtiles
import rl   "vendor:raylib"
import time "core:time"

Window :: struct { 
    title:	cstring,
    width:	i32, 
    height:	i32,
}

World :: struct {
    width:   i32,
    height:  i32,
    size: 	i32,
    tile:   []i32,
    mazeStyle: MazeStyle,
}

getSourceRect :: proc(tile: i32) -> rl.Rectangle {
	x : i32 = tile % 4
	y : i32 = tile / 4
	return {f32(x * 64), f32(y * 64), 64, 64}
}

MazeStyle :: enum {
	OpenRandom,
	ClosedRandom,
	OpenOffscreen,
}

//Tilesheet, Bitwise order
Connectedness :: enum {
	None,	//	0000
	___E,	//	0001 -> 0100
	__S_,	//	0010 -> 1000
	__SE,	//	0011

	_W__,	//	0100 -> 0001
	_W_E,	//	0101
	_WS_,	//	0110
	_WSE,	//	0111

	N___,	//	1000 -> 0010
	N__E,	//	1001
	N_S_,	//	1010
	N_SE,	//	1011

	NW__,	//	1100
	NW_E,	//	1101
	NWS_,	//	1110
	NWSE	//	1111
}


generate :: proc(world : World) -> []rl.Rectangle {
	t := make([]rl.Rectangle, world.size)
	w := make([]i32, world.size)
	for y:i32 = 0; y < world.height; y += 1 {
		for x:i32 = 0; x < world.width; x += 1 {
			index := y * world.width + x

			left  := y * world.width + ((x - 1) %% world.width )
			right := y * world.width + ((x + 1) %% world.width )
			up    := ((y - 1) %% world.height ) * world.width + x
			down  := ((y + 1) %% world.height ) * world.width + x

			connected_N : bool = (w[up]   & cast(i32)Connectedness.__S_) == cast(i32)Connectedness.__S_
			connected_W : bool = (w[left] & cast(i32)Connectedness.___E) == cast(i32)Connectedness.___E
			connected_S : bool = (w[down] & cast(i32)Connectedness.N___) == cast(i32)Connectedness.N___
			connected_E : bool = (w[right] & cast(i32)Connectedness._W__) == cast(i32)Connectedness._W__

			if connected_N {
				w[index] = (cast(i32)Connectedness.N___)
			}
			if connected_W {
				w[index] = w[index] | cast(i32)Connectedness._W__
			}
			// if connected_S {
			// 	w[index] = w[index] | cast(i32)Connectedness.__S_
			// }
			// if connected_E {
			// 	w[index] = w[index] | cast(i32)Connectedness.___E
			// }

			switch world.mazeStyle {
				case MazeStyle.OpenRandom:
					if (x !=  world.width - 1 && y != world.height - 1) {
						w[index] |= rl.GetRandomValue(0,3)
					} else if (x ==  world.width - 1 && y != world.height - 1) {
						w[index] |= rl.GetRandomValue(0,1) * 2
					} else if (x !=  world.width - 1 && y == world.height - 1) {
						w[index] |= rl.GetRandomValue(0,1)
					}
				case MazeStyle.ClosedRandom:
					w[index] |= rl.GetRandomValue(0,3)
				case MazeStyle.OpenOffscreen:
				w[index] |= rl.GetRandomValue(0,3)
			}

			
		}
	}

	for i:i32 = 0; i < world.size; i+=1 {
		t[i] = getSourceRect(w[i])
	}
	return t
}

main :: proc() {
	window := Window{"wang maze", 768, 768}
	mazeStyle := MazeStyle.OpenOffscreen
	width : i32 = window.width / 64
	height : i32 = window.height / 64
	if mazeStyle == MazeStyle.OpenOffscreen {
		width += 1
		height += 1
	}
	size : i32 = width * height
	world := World{ width, height, size, make([]i32, size), mazeStyle }


	rl.InitWindow(window.width, window.height, window.title)
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	rl.ChangeDirectory(rl.GetApplicationDirectory())
	tilemap : rl.Texture2D = rl.LoadTexture("tilemap_bitwise.png"); 
	
	
	tiles := generate(world)
	

	for !rl.WindowShouldClose() {
		if rl.IsKeyPressed(.SPACE) {
			tiles = generate(world)
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		for i : i32 = 0; i < world.size; i += 1 {
			switch world.mazeStyle {
				case .ClosedRandom, .OpenRandom:
					x : f32 = f32(i % world.width) * 64 - 8
					y : f32 = f32(i / world.height) * 64 - 8
					rl.DrawTextureRec(tilemap, tiles[i], {x, y}, rl.WHITE)
				case .OpenOffscreen:
					x : f32 = f32(i % world.width) * 64 - 40
					y : f32 = f32(i / world.height) * 64 - 40
					rl.DrawTextureRec(tilemap, tiles[i], {x, y}, rl.WHITE)
			}


			
		}

		rl.EndDrawing()
	}
}