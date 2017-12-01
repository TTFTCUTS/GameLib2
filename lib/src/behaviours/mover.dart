import "../three/three.dart";

abstract class Mover {
	Vector3 vel = new Vector3.zero();
	double resistance = 0.99;
	double mass = 1.0;
	
	Vector3 angvel = new Vector3.zero();
	double angresist = 0.96;
	
	Vector3 getVel() {
		return this.vel;
	}
	
	void setVel(Vector3 v) {
		this.vel.copy(v);
	}
	
	void updateMovement(num dt) {
		this.setRot(this.getRot().clone()..multiply(new Quaternion.identity()..setFromEuler(new Euler(this.angvel.x*dt, this.angvel.y*dt, this.angvel.z*dt))));
		this.angvel.multiplyScalar(this.angresist);
		this.setPos(this.getPos().clone()..add(this.vel.clone()..multiplyScalar(dt)));
		this.vel.multiplyScalar(this.resistance);
	}
	
	Vector3 getPos();
	void setPos(Vector3 v);
	Quaternion getRot();
	void setRot(Quaternion q);
}