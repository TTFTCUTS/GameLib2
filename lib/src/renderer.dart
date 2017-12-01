import "dart:html";

import "three/three.dart";

class Renderer {
	int width;
	int height;
	DivElement container;
	
	CanvasElement canvasElement;
	
	Scene scene;
	Camera camera;
	
	WebGLRenderer render;
	
	Renderer(DivElement this.container, int this.width, int this.height) {
		
		this.scene = new Scene();
		
		this.render = new WebGLRenderer( new WebGLRendererOptions(antialias: true, alpha: false))
			..setClearColor(0x505050, 1.0)..setSize( this.width, this.height );
		
		this.render.domElement.onContextMenu.listen((MouseEvent e) => e.preventDefault());
		
		this.container.append(this.render.domElement);
	}
	
	void draw(num dt) {
		if (this.camera != null) {
			this.render.render(scene, camera);
		}
	}
	
	void setCamera(Camera cam) {
		this.camera = cam;
		this.scene.add(cam);
	}
}