import "dart:async";
import "dart:math";

import "../GameLib2_base.dart";
import "../three/three.dart";

class WorldGrid {
	int width;
	int height;
	int tilesize;
	
	List<TileType> backgroundTiles;
	List<TileType> tiles;
	
	WorldGrid(int this.tilesize, int this.width, int this.height) {
		this.tiles = new List<TileType>.filled(width*height, null);
		this.backgroundTiles = new List<TileType>.filled(width*height, null);
	}
	
	int index(int x, int y) {
		if (x < 0 || x >= width || y < 0 || y >= height) {
			return -1;
		}
		
		return y*width + x;
	}
	
	void setTile(int x, int y, TileType tile, [bool bg = false]) {
		int i = index(x,y);
		if (i != -1) {
			if (bg) {
				backgroundTiles[i] = tile;
			} else {
				tiles[i] = tile;
			}
		}
	}
	
	void setTileById(int x, int y, int tileid, [bool bg = false]) {
		setTile(x,y, TileType.types[tileid], bg);
	}
	
	void setTileByName(int x, int y, String name, [bool bg = false]) {
		setTile(x,y, TileType.typesByName[name], bg);
	}
	
	Future<Mesh> buildGeometry(String tileset, bool background, Texture texture, String vertexShaderPath, String fragmentShaderPath) async {
		ShaderMaterial mat = await makeShaderMaterial(vertexShaderPath, fragmentShaderPath);
			//..depthWrite = false
		setUniform(mat, "fLight", new ShaderUniform<double>(value: background ? 0.4 : 1.0));
		setUniform(mat, "vTint", new ShaderUniform<Vector3>(value: new Vector3.all(1.0)));
		setUniform(mat, "tDiffuse", new ShaderUniform<TextureBase>(value: texture));
		setUniform(mat, "vSprite", new ShaderUniform<Vector4>(value: new Vector4(0.0, 0.0, 1.0, 1.0)));

		Mesh mesh = new Mesh(TileGridGeometry.create(this, TileSet.tilesets[tileset], background), mat);//..renderDepth = (background? 10:0);
		mesh.position.z = background ? -5.0 : 5.0;
		mesh.rotation.x = PI;
		mesh.rotation.z = PI*0.5;
		return mesh;
	}
	
	TileType getTile(int x, int y, [bool bg = false]) {
		int i = index(x,y);
		if (i == -1) { 
			//print("$x,$y oob"); 
			return null; 
		}
		
		if (bg) {
			return this.backgroundTiles[i];
		}
		return this.tiles[i];
	}
	
	bool spaceFor(Box2 bounds) {
		int left = bounds.min.x ~/ this.tilesize;
		int right = bounds.max.x ~/ this.tilesize;
		int top = bounds.min.y ~/ this.tilesize;
		int bottom = bounds.max.y ~/ this.tilesize;
		
		for (int x = left; x <= right; x++) {
			for (int y = top; y <= bottom; y++) {
				TileType t = this.getTile(x, y);
				if (t != null && t.solid) {
					return false;
				}
			}
		}
		return true;
	}
	
	bool solidAt(int x, int y, [bool bg = false]) {
		TileType t = this.getTile(x, y, bg);
		if (t == null) { return false; }
		return t.solid;
	}
	
	/*bool trace(int x0, int y0, int x1, int y1, [bool bg = false]) {
		print("$x0,$y0 -> $x1,$y1");
		
		double dx = (x1-x0 + this.tilesize/2).toDouble();
		double dy = (y1-y0 + this.tilesize/2).toDouble();
		double error = -1.0;
		double deltaerror = dx == 0.0 ? 0.0 : (dy/dx).abs();
		
		int inc = x0 > x1 ? -1 : 1;
		
		int y = y0;
		for (int x = x0; x<= x1; x+= inc) {
			print("test: $x,$y");
			if (this.solidAt(x, y, bg)) {
				return true;
			}
			error = error + deltaerror;
			if (error >= 0.0) {
				y += 1;
				error -= 1.0;
			}
		}
		return false;
	}*/
	
	bool trace(int x,int y,int x2, int y2) {
        int w = x2 - x ;
        int h = y2 - y ;
        int dx1 = 0, dy1 = 0, dx2 = 0, dy2 = 0 ;
        if (w<0) dx1 = -1 ; else if (w>0) dx1 = 1 ;
        if (h<0) dy1 = -1 ; else if (h>0) dy1 = 1 ;
        if (w<0) dx2 = -1 ; else if (w>0) dx2 = 1 ;
        int longest = w.abs() ;
        int shortest = h.abs();
        if (!(longest>shortest)) {
            longest = h.abs();
            shortest = h.abs() ;
            if (h<0) dy2 = -1 ; else if (h>0) dy2 = 1 ;
            dx2 = 0 ;            
        }
        int numerator = longest >> 1 ;
        for (int i=0;i<=longest;i++) {
            if (this.solidAt(x, y)) {
            	return true;
            }
            numerator += shortest ;
            if (!(numerator<longest)) {
                numerator -= longest ;
                x += dx1 ;
                y += dy1 ;
            } else {
                x += dx2 ;
                y += dy2 ;
            }
        }
        return false;
    }
}

class TileType {
	static Map<int, TileType> types = {};
	static Map<String, TileType> typesByName = {};
	
	final int id;
	final String name;
	bool solid = false;
	List<String> variants;
	
	TileType(int this.id, String this.name, [List<String> this.variants]) {
		types[this.id] = this;
		typesByName[this.name] = this;
	}
	
	String getTileNameForLocation(WorldGrid grid, int x, int y, Random rand, bool background) {
		if (this.variants != null) {
			return this.name + "_" +this.variants[rand.nextInt(this.variants.length)];
		}
		return this.name;
	}
}

class TileTypeChess extends TileType { 
	List<String> alternates;
	
	TileTypeChess(int id, String name, List<String> variants, List<String> this.alternates) : super(id, name, variants);
	
	String getTileNameForLocation(WorldGrid grid, int x, int y, Random rand, bool background) {
		List<String> vars = ((x ^ y)%2==0) ? variants : alternates;
	
		if (vars != null) {
			return this.name + "_" + vars[rand.nextInt(vars.length)];
		}
		
		return this.name;
	}
	
}

class TileTypeBrick extends TileTypeChess {
	List<String> singles;
	
	TileTypeBrick(int id, String name, List<String> variants, List<String> alternates, List<String> this.singles) : super(id, name, variants, alternates) {}
	
	String getTileNameForLocation(WorldGrid grid, int x, int y, Random rand, bool background) {
		String fill = super.getTileNameForLocation(grid, x, y, rand, background);
		
		int offset = ((x ^ y)%2==0) ? 1 : -1;
		
		if (grid.getTile(x+offset, y, background) != this) {
			return this.name + "_" + this.singles[rand.nextInt(this.singles.length)];
		}
		return fill;
	}
}

class TileTypeConnected extends TileType { 
	List<String> connectTo;
	bool track;
	
	TileTypeConnected(int id, String name, {List<String> this.connectTo, List<String> variants, bool this.track : false}) : super(id, name, variants);
	
	String getTileNameForLocation(WorldGrid grid, int x, int y, Random rand, bool background) {
		String tile = this.name;
		
		bool tl = ok(grid.getTile(x-1, y-1, background));
		bool t = ok(grid.getTile(x, y-1, background));
		bool tr = ok(grid.getTile(x+1, y-1, background));
		
		bool l = ok(grid.getTile(x-1, y, background));
		bool r = ok(grid.getTile(x+1, y, background));
		
		bool bl = ok(grid.getTile(x-1, y+1, background));
		bool b = ok(grid.getTile(x, y+1, background));
		bool br = ok(grid.getTile(x+1, y+1, background));
		
		//print("$tl, $t, $tr - $l, $r - $bl, $b, $br");
		
		if (!track) {
			// normal connected stuff. Walls etc
			if (tl && t && tr && l && r && bl && b && br) {
				// MIDDLE!
			} else if (t && l && !tl) {
				tile += "_tli";
			} else if (t && r && !tr) {
				tile += "_tri";
			} else if (b && l && !bl) {
				tile += "_bli";
			} else if (b && r && !br) {
				tile += "_bri";
 			} else {
				if (!t) {
					tile += "_t";
					if (!l) {
						tile += "l";
					} else if (!r) {
						tile += "r";
					}
				} else if (!b) {
					tile += "_b";
					if (!l) {
						tile += "l";
					} else if (!r) {
						tile += "r";
					}
				} else if (!l) {
					tile += "_l";
				} else if (!r) {
					tile += "_r";
				}
			}
		} else {
			// tracks and wire
			
			if (t || b || l || r) {
				tile += "_";
				if (t) {
					tile += "t";
				}
				if (b) {
					tile += "b";
				}
				if (l) {
					tile += "l";
				}
				if (r) {
					tile += "r";
				}
			}
		}
		
		if (this.variants != null) {
			tile += "_${variants[rand.nextInt(variants.length)]}";
		}
		
		//print("out: $tile");
		return tile;
	}
	
	bool ok(TileType t) {
		//print(t == null ? "null" : t.name);
		if (t == null) { return false; }
		return t == this || (this.connectTo != null && this.connectTo.contains(t.name));
	}
}