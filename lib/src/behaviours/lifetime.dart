import "dart:math";

abstract class Lifetime {
	double lifetime = 10.0;
	double maxlifetime = 10.0;
	
	void setLifetime(double time) {
		this.maxlifetime = time;
		this.lifetime = time;
	}
	
	void setRemainingTime(double time) {
		this.lifetime = min(time, this.maxlifetime);
	}
	
	void updateLifetime(num dt) {
		this.lifetime = max(0.0, this.lifetime - dt);
		if (this.lifetime <= 0.0) {
			this.destroy();
		}
	}
	
	double getLifetime() {
		return this.lifetime;
	}
	
	double getMaxLifetime() {
		return this.maxlifetime;
	}
	
	double getLifetimeFraction() {
		double maxtime = this.getMaxLifetime();
		double curtime = this.getLifetime();
		
		if (maxtime != 0.0) {
			return curtime/maxtime;
		}
		return 0.0;
	}
	
	void destroy();
}