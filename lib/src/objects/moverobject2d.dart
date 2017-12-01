import "../GameLib2_base.dart";

class MoverObject2D extends GameObject2D with Mover {
	
	MoverObject2D(num x, num y) : super(x,y);
	
	void update(num dt) {
		this.updateMovement(dt);	
	}
	
	void updateMovement(num dt) {
		this.vel.z = 0.0;
		this.angvel.y = 0.0;
		this.angvel.z = 0.0;
		super.updateMovement(dt);
	}
}