import "../three/three.dart";

class TileSet {
	static Map<String, TileSet> tilesets = {};
	
	int width;
	int height;
	String name;
	
	Map<String, Box2> tiles = {};
	
	TileSet(String this.name, int this.width, int this.height) {
		tilesets[name] = this;
	}
	
	void addTile(String name, int x, int y, int w, int h) {
		double umin = x/width;
		double umax = (x+w)/width;
		double vmin = y/height;
		double vmax = (y+h)/height;
		
		//print("uvs for tile $name: u:$umin-$umax, v:$vmin-$vmax");
		
		tiles[name] = new Box2(new Vector2(umin, vmin), new Vector2(umax, vmax));
	}
	
	void fixedTile(String name, int x, int y, int size) {
		this.addTile(name, x*size, y*size, size, size);
	}
	
	void fixedTileRange(String name, List<String> suffixes, int x, int y, int size) {
		for (String s in suffixes) {
			fixedTile(name + s, x,y,size);
		}
	}
	
	void fixedTileNumRange(String name, int min, int max, int x, int y, int size) {
		for (int i=min; i<=max; i++) {
			fixedTile("$name$i", x,y,size);
		}
	}
	
	void flip(String suffix) {
		Map<String, Box2> flipped = {};
		
		for (String tilename in tiles.keys) {
			Box2 box = tiles[tilename];
			
			Box2 mirrored = new Box2(new Vector2(box.max.x, box.min.y), new Vector2(box.min.x, box.max.y));
			flipped[tilename + suffix] = mirrored;
		}
		
		for (String tilename in flipped.keys) {
			this.tiles[tilename] = flipped[tilename];
		}
	}
}