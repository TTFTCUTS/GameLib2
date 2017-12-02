import "dart:math";

import "../../GameLib2_base.dart";
import "../three.dart";

abstract class TileGridGeometry {
    static Vector3 topnormal = new Vector3( 0.0, 0.0, 1.0 );

    static Geometry create(WorldGrid grid, TileSet tileset, bool background) {
        Geometry geo = new PlaneGeometry(1,1,1,1);

        geo.vertices.clear();
        geo.faceVertexUvs[0].clear();
        geo.faces.clear();

        print("verts pre: ${geo.vertices}");

        Map<String, int> vertmap = {};

        int tilesize = grid.tilesize;
        int width = grid.width;
        int height = grid.height;

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
                            _maketile(geo, tilesize, vertmap, x, y, tt);
                        } else {
                            print("null aabb for $tname");
                        }
                    }
                }
            }
        }

        geo.verticesNeedUpdate = true;
        geo.elementsNeedUpdate = true;
        geo.uvsNeedUpdate = true;

        print("verts post: ${geo.vertices}");

        return geo;
    }

    static String _tileid(int x, int y) {
        return "${x},${y}";
    }

    static void _maketile(Geometry geo, int tilesize, Map<String, int> vertmap, int x, int y, Box2 uvbox) {
        String idA = _tileid(x,y);
        String idB = _tileid(x,y+1);
        String idC = _tileid(x+1,y+1);
        String idD = _tileid(x+1,y);

        if (!vertmap.containsKey(idA)) {
            Vector3 v = new Vector3((-(y)*tilesize).toDouble(), (-(x)*tilesize).toDouble(), 0.0);
            vertmap[idA] = geo.vertices.length;
            geo.vertices.add(v);
        }
        if (!vertmap.containsKey(idB)) {
            Vector3 v = new Vector3((-(y+1)*tilesize).toDouble(), (-(x)*tilesize).toDouble(), 0.0);
            vertmap[idB] = geo.vertices.length;
            geo.vertices.add(v);
        }
        if (!vertmap.containsKey(idC)) {
            Vector3 v = new Vector3((-(y+1)*tilesize).toDouble(), (-(x+1)*tilesize).toDouble(), 0.0);
            vertmap[idC] = geo.vertices.length;
            geo.vertices.add(v);
        }
        if (!vertmap.containsKey(idD)) {
            Vector3 v = new Vector3((-(y)*tilesize).toDouble(), (-(x+1)*tilesize).toDouble(), 0.0);
            vertmap[idD] = geo.vertices.length;
            geo.vertices.add(v);
        }

        //Face4 face = new Face4(vertmap[idA], vertmap[idB], vertmap[idC], vertmap[idD]);
        //face.normal = topnormal.clone();
        //face.vertexNormals = [topnormal.clone(),topnormal.clone(),topnormal.clone(),topnormal.clone()];

        Face3 face1 = new Face3(vertmap[idA], vertmap[idC], vertmap[idD]);
        face1.normal = topnormal.clone();

        Face3 face2 = new Face3(vertmap[idA], vertmap[idB], vertmap[idC]);
        face2.normal = topnormal.clone();

        geo.faces.add(face1);
        geo.faces.add(face2);

        List<List<Vector2>> faceVertexUV = geo.faceVertexUvs[ 0 ];

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