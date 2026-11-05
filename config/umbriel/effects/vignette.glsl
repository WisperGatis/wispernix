// 이름: 비네트
// 가장자리를 어둡게 해서 중앙에 시선을 모읍니다.

const float strength = 0.45;

vec4 screen(vec2 uv) {
    vec4 c = umbriel_sample(uv);
    float v = 1.0 - strength * smoothstep(0.25, 0.85, length(uv - vec2(0.5)));
    return vec4(c.rgb * v, c.a);
}
