#version 300 es
// 이름: CRT 스캔라인
// 옛날 CRT 느낌: 가로 줄무늬와 약한 비네트 (1080p 기준).
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

const float lines = 540.0;
const float intensity = 0.18;

void main() {
    vec4 c = texture(tex, v_texcoord);
    float scan = 1.0 - intensity * (0.5 + 0.5 * sin(v_texcoord.y * lines * 6.2831853));
    vec2 d = v_texcoord - vec2(0.5);
    float v = 1.0 - 0.25 * smoothstep(0.3, 0.9, length(d));
    fragColor = vec4(c.rgb * scan * v, c.a);
}
