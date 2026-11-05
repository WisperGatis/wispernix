#version 300 es
// 이름: 비네트
// 가장자리를 어둡게 해서 중앙에 시선을 모읍니다.
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

const float strength = 0.45;

void main() {
    vec4 c = texture(tex, v_texcoord);
    vec2 d = v_texcoord - vec2(0.5);
    float v = 1.0 - strength * smoothstep(0.25, 0.85, length(d));
    fragColor = vec4(c.rgb * v, c.a);
}
