import "dart:math";

import "../../GameLib2_base.dart";
import "../three.dart";

class TileGridGeometry extends Geometry {
    int tilesize;
    int width;
    int height;

    static Vector3 topnormal = new Vector3( 0.0, 0.0, 1.0 );

    Map<String, int> vertmap = {};

    static Geometry create(WorldGrid grid, TileSet tileset, bool background) {
        Geometry geo = new SphereGeometry(0.1);

        print("verts: ${geo.vertices}");
        /*this.tilesize = grid.tilesize;
        this.width = grid.width;
        this.height = grid.height;

        List<TileType> tiles = background ? grid.backgroundTiles : grid.tiles;

        Random rand = new Random();

        int i;
        for (int x=0; x<width; x++) {
            for (int y=0; y<height; y++) {
                i = y*width+x;

                TileType tile = tiles[i];

                if (tile != null) {
                    String tname = tile.getTileNameForLocation(grid, x, y, rand, background);

                    if (tname != null) {
                        Box2 tt = tileset.tiles[tname];

                        if (tt != null) {
                            this._maketile(x, y, tt);
                        } else {
                            print("null aabb for $tname");
                        }
                    }
                }
            }
        }

        this.uvsNeedUpdate = true;
        this.elementsNeedUpdate = true;

        this.computeCentroids();*/

        return geo;
    }

    String _tileid(int x, int y) {
        return "${x},${y}";
    }

    void _maketile(int x, int y, Box2 uvbox) {
        String idA = _tileid(x,y);
        String idB = _tileid(x,y+1);
        String idC = _tileid(x+1,y+1);
        String idD = _tileid(x+1,y);

        if (!vertmap.containsKey(idA)) {
            Vector3 v = new Vector3((-(y)*this.tilesize).toDouble(), (-(x)*this.tilesize).toDouble(), 0.0);
            vertmap[idA] = this.vertices.length;
            this.vertices.add(v);
        }
        if (!vertmap.containsKey(idB)) {
            Vector3 v = new Vector3((-(y+1)*this.tilesize).toDouble(), (-(x)*this.tilesize).toDouble(), 0.0);
            vertmap[idB] = this.vertices.length;
            this.vertices.add(v);
        }
        if (!vertmap.containsKey(idC)) {
            Vector3 v = new Vector3((-(y+1)*this.tilesize).toDouble(), (-(x+1)*this.tilesize).toDouble(), 0.0);
            vertmap[idC] = this.vertices.length;
            this.vertices.add(v);
        }
        if (!vertmap.containsKey(idD)) {
            Vector3 v = new Vector3((-(y)*this.tilesize).toDouble(), (-(x+1)*this.tilesize).toDouble(), 0.0);
            vertmap[idD] = this.vertices.length;
            this.vertices.add(v);
        }

        //Face4 face = new Face4(vertmap[idA], vertmap[idB], vertmap[idC], vertmap[idD]);
        //face.normal = topnormal.clone();
        //face.vertexNormals = [topnormal.clone(),topnormal.clone(),topnormal.clone(),topnormal.clone()];

        Face3 face1 = new Face3(vertmap[idA], vertmap[idC], vertmap[idD]);
        face1.normal = topnormal.clone();

        Face3 face2 = new Face3(vertmap[idA], vertmap[idB], vertmap[idC]);
        face2.normal = topnormal.clone();

        this.faces.add(face1);
        this.faces.add(face2);

        List<List<Vector2>> faceVertexUV = faceVertexUvs[ 0 ];

        {
            List<Vector2> newUVs = <Vector2>[];
            newUVs.addAll([
                new Vector2(uvbox.min.x, uvbox.min.y),
                new Vector2(uvbox.max.x, uvbox.max.y),
                new Vector2(uvbox.max.x, uvbox.min.y),
            ]);
            faceVertexUV.add(newUVs);
        }

        {
            List<Vector2> newUVs = <Vector2>[];
            newUVs.addAll([
                new Vector2(uvbox.min.x, uvbox.min.y),
                new Vector2(uvbox.min.x, uvbox.max.y),
                new Vector2(uvbox.max.x, uvbox.max.y),
            ]);
            faceVertexUV.add(newUVs);
        }
    }
}