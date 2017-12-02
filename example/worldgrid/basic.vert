attribute vec3 aVertexPosition;
attribute vec2 aTextureCoord;

varying vec2 vUv;
varying vec3 vNormal;

void main() {
    vNormal = normal;

    gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
    vUv = uv;
}