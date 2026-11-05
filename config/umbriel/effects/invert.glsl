// 이름: 색상 반전
// 색상을 반전합니다 (네거티브).

vec4 screen(vec2 uv) {
    vec4 c = umbriel_sample(uv);
    return vec4((vec3(1.0) - c.rgb) * c.a, c.a);
}
