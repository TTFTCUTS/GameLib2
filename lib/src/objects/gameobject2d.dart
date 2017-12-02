import "dart:math";

import "../GameLib2_base.dart";
import "../three/three.dart";

class GameObject2D extends GameObject {
	double angle = 0.0;
	
	GameObject2D(num x, num y) : super(x,y,0);
	
	void updateGraphics(num dt) {
		this.rot.set(this.angle, 0.0, 0.0, 1.0);
		super.updateGraphics(dt);
	}
	
	Vector2 getHeading() {
		double x = sin(angle);
		double y = cos(angle);
		return new Vector2(x,-y);
	}
	
	void setHeadingVec(Vector2 input) {
		this.setHeading(input.x, input.y);
	}
	
	void setHeading(num x, num y) {
		this.angle = atan2(y,x);
	}
	
	double getAngle() {
		return this.angle;
	}
}