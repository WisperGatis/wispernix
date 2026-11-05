#version 300 es
// 이름: 색상 반전
// 색상을 반전합니다 (네거티브).
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 c = texture(tex, v_texcoord);
    fragColor = vec4(vec3(1.0) - c.rgb, c.a);
}
