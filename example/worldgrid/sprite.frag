varying vec2 vUv;
varying vec3 vNormal;

uniform sampler2D tDiffuse;
uniform vec3 vTint;
uniform vec4 vSprite;

uniform float fLight;


void main() {
    vec2 spriteuv = vec2(vSprite.x + (vSprite.z-vSprite.x)*vUv.x, vSprite.y + (vSprite.w-vSprite.y)*vUv.y);
    vec4 tex = texture2D(tDiffuse, spriteuv);
    tex.rgb = tex.rgb * vTint;

    float hurt = 0.0;

    vec3 final = tex.rgb * fLight * (1.0-hurt) + hurt * vec3(1.0,1.0,1.0);
    gl_FragColor = tex;
    gl_FragColor.rgb = final;
}
