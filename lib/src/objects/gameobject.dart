import "../GameLib2_base.dart";
import "../three/three.dart";

class GameObject {
	GameLogic game;
	
	Vector3 pos;
	Quaternion rot;
	double size = 30.0;
	double mass = 1.0;
	
	bool destroyed = false;

	Mesh model;
	Vector3 scale;
	
	GameObject(num x, num y, num z) {
		pos = new Vector3(x.toDouble(), y.toDouble(), z.toDouble());
		rot = new Quaternion.identity();
		scale = new Vector3.all(1.0);
	}
	
	/**
	 * Register object to a parent game and add it to relevant lists
	 */
	void register(GameLogic game) {
		this.game = game;
		game.objects.add(this);
		if (this.model != null) {
			game.render.scene.add(this.model);
		}
	}
	
	/**
	 * Set object destroyed and remove its model from the scene
	 */
	void destroy() {
		this.destroyed = true;
		if (this.game != null && this.model != null) {
			this.game.render.scene.remove(this.model);
		}
	}
	
	/**
	 * Logic update
	 */
	void update(num dt) {
		
	}
	
	/**
	 * Graphics update for specific model manipulation
	 */
	void updateGraphics(num dt) {
		if (this.model != null) {
			this.model.position.copy(this.pos);
			this.model.setRotationFromQuaternion(this.rot);
			this.model.scale.copy(this.scale);
			
			if (this.model.material != null && this.model.material is ShaderMaterial) {
				this.updateShader(dt);
			}
		}
	}
	
	/**
	 * For updating shader normals
	 */
	void updateShader(num dt) {
		
	}
	
	// getters and stuff

	Vector3 getPos() {
		return this.pos;
	}
	
	void setPos(Vector3 v) {
		this.pos.copy(v);
	}
	
	double getSize() { 
		return this.size; 
	}

	Quaternion getRot() {
		return this.rot;
	}
	
	void setRot(Quaternion q) {
		this.rot.copy(q);
	}

	Vector3 getScale() {
		return this.scale;
	}
	
	void setScale(Vector3 v) {
		this.scale.copy(v);
	}
	
	bool getDestroyed() {
		return this.destroyed;
	}
	
	double getMass() {
		return this.mass;
	}
}