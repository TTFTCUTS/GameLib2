import "GameLib2_base.dart";
import "three/three.dart";

import "utils.dart";

class SpatialHash {
	final double bucketsize;
	final int xsize;
	final int ysize;
	final int zsize;
	
	Map<Collider, Box3> objects;
	Map<SpatialHashKey,List<Collider>> _map;
	
	SpatialHash(double this.bucketsize, int this.xsize, int this.ysize, int this.zsize) {
		this.clear();
	}
	
	void clear() {
		this.objects = new Map<Collider, Box3>();
		this._map = new Map<SpatialHashKey,List<Collider>>();
	}
	
	void insert(Collider col) {
		if (col.spatialhash == null || col.spatialhash == this) {
			Box3 bounds = col.getBounds();
			
			if (col.spatialhash == this) {
				Box3 oldbounds = this.objects[col];
				if (GameLibUtil.AABB3equal(bounds, oldbounds)) {
					return; // object is already in and is in the same place it was before
				} else {
					this.remove(col); // remove the object in preparation for re-adding
				}
			}
			
			col.spatialhash = this;

			List<SpatialHashKey> keys = this.getKeysForAabb(bounds);
			for (SpatialHashKey k in keys) {
				this.addToBucket(k, col);
			}
			
			col.spatialbuckets = keys;
			this.objects[col] = bounds;
		} else {
			// error because can't be in more than one
		}
	}
	
	List<SpatialHashKey> getKeysForAabb(Box3 bounds) {
		List<SpatialHashKey> keys = [];
		
		int minx = bounds.min.x ~/ this.bucketsize;
		int maxx = bounds.max.x ~/ this.bucketsize;
		int miny = bounds.min.y ~/ this.bucketsize;
		int maxy = bounds.max.y ~/ this.bucketsize;
		int minz = bounds.min.z ~/ this.bucketsize;
		int maxz = bounds.max.z ~/ this.bucketsize;
		
		for (int x = minx; x <= maxx; x++) {
			for (int y = miny; y <= maxy; y++) {
				for (int z = minz; z <= maxz; z++) {
					SpatialHashKey key = new SpatialHashKey(this, x,y,z);
    				keys.add(key);
    			}			
			}
		}
		
		return keys;
	}
	
	void remove(Collider col) {
		for (SpatialHashKey key in col.spatialbuckets) {
			this.removeFromBucket(key, col);
		}
		this.objects.remove(col);
		
		col.spatialbuckets = null;
		col.spatialhash = null;
	}
	
	void addToBucket(SpatialHashKey key, Collider val) {
		if (!_map.containsKey(key)) {
			_map[key] = [];
		}
		_map[key].add(val);
	}
	
	void removeFromBucket(SpatialHashKey key, Collider val) {
		_map[key].remove(val);
		if (_map[key].isEmpty) {
			_map.remove(key);
		}
	}
	
	Set<Collider> query(Collider test) {
		if (test.spatialhash != this) { return null; }
		Set<Collider> collided = new Set<Collider>();
		
		for (SpatialHashKey key in test.spatialbuckets) {
			if (_map.containsKey(key)) {
				collided.addAll(_map[key]);
			}
		}
		
		return collided;
	}
	
	Set<Collider> queryAabb(Box3 bounds) {
		Set<Collider> collided = new Set<Collider>();
		
		List<SpatialHashKey> keys = this.getKeysForAabb(bounds);
		
		for (SpatialHashKey key in keys) {
			if (_map.containsKey(key)) {
				collided.addAll(this._map[key]);
			}
		}
		
		return collided;
	}
}

class SpatialHashKey {
	final int x;
	final int y;
	final int z;
	
	int _hash;
	
	SpatialHashKey(SpatialHash sh, int this.x, int this.y, int this.z) {
		int xh = x + sh.xsize + 31;
		int yh = y + sh.ysize + 37;
		int zh = z + sh.zsize + 41;
		
		this._hash = yh + ((yh * 43) * (xh+(xh * 47)) * zh) + (zh * 53);
	}
	
	int get hashCode => _hash;
	
	bool operator ==(other) {
		return (other is SpatialHashKey) && other._hash == this._hash;
	}
}