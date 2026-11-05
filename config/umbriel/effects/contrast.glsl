// 이름: 고대비
// 대비를 높이고 밝기는 그대로 둡니다.

const float contrast = 1.25;

vec4 screen(vec2 uv) {
    vec4 c = umbriel_sample(uv);
    vec3 v = (c.rgb - 0.5) * contrast + 0.5;
    return vec4(clamp(v, 0.0, 1.0), c.a);
}
