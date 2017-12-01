import "../GameLib2_base.dart";

class MoverObject extends GameObject with Mover {
	
	MoverObject(num x, num y, num z) : super(x,y,z);
	
	void update(num dt) {
		this.updateMovement(dt);	
	}
}