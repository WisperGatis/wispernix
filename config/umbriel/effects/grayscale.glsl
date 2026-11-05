// 이름: 흑백
// 화면 전체를 흑백으로 표시합니다.

vec4 screen(vec2 uv) {
    vec4 c = umbriel_sample(uv);
    float luma = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    return vec4(vec3(luma), c.a);
}
