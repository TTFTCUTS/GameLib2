import "dart:async";
import "dart:html";

import 'package:GameLib2/GameLib2.dart';
import 'package:GameLib2/three.dart' as THREE;

main() async {
    print("pre");
    await Loader.loadJavaScript("worldgrid/three.min.js");
    print("post");
    GameLogic game = new GameLogic(querySelector("#box"), 800, 800);

    new TileSet("test", 64, 64)
        ..fixedTile("test_0", 0, 0, 32)
        ..fixedTile("test_1", 1, 0, 32)
        ..fixedTile("test_2", 0, 1, 32)
        ..fixedTile("test_3", 1, 1, 32);

    new TileType(0, "test", ["0","1","2","3"]);

    WorldGrid testgrid = new WorldGrid(32, 5, 5);
    testgrid
        ..setTileByName(1, 2, "test")
        ..setTileByName(2, 2, "test")
        ..setTileByName(3, 2, "test");

    game.render.scene.add(await testgrid.buildGeometry("test", false, new THREE.Texture(await Loader.getResource("worldgrid/testtile.png")), "worldgrid/basic.vert", "worldgrid/sprite.frag"));

    game.startGameLoop();
}