import "dart:html";

import "GameLib2_base.dart";

class GameLogic {
	DivElement container;
	
	Renderer render;
	
	List<GameObject> objects;
	List<GameObject> registryQueue = <GameObject>[];
	bool iteratingGameObjects = false;
	SpatialHash collision;
	
	int windowWidth;
	int windowHeight;
	
	bool stopLoop = false;

	GameLogic(DivElement this.container, int width, int height, [double gamesizex = 1000.0, double gamesizey = 1000.0, double gamesizez = 1000.0, double collisionsize = 30.0]) {
		this.objects = new List<GameObject>();
		
		double bucketsize = collisionsize * 2;
		int xbuckets = gamesizex ~/ bucketsize;
		int ybuckets = gamesizey ~/ bucketsize;
		int zbuckets = gamesizez ~/ bucketsize;
		
		this.collision = new SpatialHash(bucketsize, xbuckets, ybuckets, zbuckets);
		
		this.render = new Renderer(container, width, height);
		this.windowWidth = width;
		this.windowHeight = height;
	}
	
	double simtime = 0.0;
	double simstep = 1.0/30.0;
	void update(num dt) {
		if (dt <= 0.0) { return; }
		
		simtime += dt;
		
		while (simtime >= simstep) {
			simtime -= simstep;
			logicUpdate(simstep);
		}

		iteratingGameObjects = true;
		for (GameObject o in objects) {
			o.updateGraphics(dt);
		}
		iteratingGameObjects = false;
		
		render.draw(dt);
	}
	
	void logicUpdate(num dt) {
		GameObject o;
		iteratingGameObjects = true;
		for (int i=0; i<objects.length; i++) {
			o = objects[i];
			if (!o.getDestroyed()) {
				o.update(dt);
			}
			if (o.getDestroyed()) {
				if (o is Collider) {
					(o as Collider).destroyCollider();
				}
				objects.removeAt(i);
				i--;
			}
		}
		
		Set<Collider> others;
		for (Collider c in this.collision.objects.keys) {
			if (c.getDestroyed()) {continue;}
			others = this.collision.query(c);
			for (Collider other in others) {
				if (c.testCollision(other)) {
					c.collide(other);
				}
			}
		}
		iteratingGameObjects = false;

		while (registryQueue.isNotEmpty) {
			this.objects.add(registryQueue.removeAt(0));
		}
	}

	// main game loop
	num then = 0;
	List<double> frametimes = [];
	void gameLoop(num now) {
		if (this.stopLoop) { 
			this.stopLoop = false;
			return; 
		}
    	window.requestAnimationFrame(gameLoop);
    	
    	num dt = now - then;
    	then = now;
    	
    	frametimes.add(dt/1000.0);
    	if (frametimes.length > 2.0 / this.simstep) {
    		frametimes.removeAt(0);
    	}
    	
    	this.update(dt/1000.0);
    }
	
	void startGameLoop() {
		this.gameLoop(0);
	}
	
	double getfps() {
		double frametime = 0.0;
		for (double time in frametimes) {
			frametime += time;
		}
		frametime /= frametimes.length;
		
		if (frametime > 0) {
			return 1/frametime;
		}
		return 0.0;
	}
	
	void win() {}
	void lose() {}
}