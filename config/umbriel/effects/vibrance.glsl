// 이름: 선명한 색감
// 채도를 살짝 높입니다 (1.0 = 원본).

const float saturation = 1.15;

vec4 screen(vec2 uv) {
    vec4 c = umbriel_sample(uv);
    float luma = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    return vec4(mix(vec3(luma), c.rgb, saturation), c.a);
}
