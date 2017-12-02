import "../GameLib2_base.dart";
import "../three/three.dart";

abstract class Collider {
	SpatialHash spatialhash;
	List<SpatialHashKey> spatialbuckets;
	
	Box3 getBounds() {
		return new Box3.zero()..setFromCenterAndSize(this.getPos(), new Vector3.all(this.getSize()*2.0));
	}
	
	Vector3 getPos();
	double getSize();
	double getMass();
	bool getDestroyed();
	
	void updateCollider(num dt) {
		if (this.spatialhash != null) {
			this.spatialhash.insert(this);
		}
	}
	void destroyCollider() {
		if (this.spatialhash != null) {
			this.spatialhash.remove(this);
		}
	}
	void registerCollider(GameLogic game) {
		game.collision.insert(this);
	}
	
	bool testCollision(Collider other) {
		if (this == other) {return false;}
		if (this.getBounds().intersectsBox(other.getBounds())) {
			return this.getPos().distanceTo(other.getPos()) <= this.getSize() + other.getSize();
		}
		return false;
	}
	
	void collide(Collider other) {}
}