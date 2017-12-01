import "three/three.dart";

abstract class GameLibUtil {
	static bool AABB3equal(Box3 first, Box3 second) {
		if (first != null && second != null) {
			return first.min.x == second.min.x
				&& first.max.x == second.max.x
				&& first.min.y == second.min.y
				&& first.max.y == second.max.y
				&& first.min.z == second.min.z
				&& first.max.z == second.max.z;
		}
		return false;
	}
}