// name: CRT scanlines
// Old CRT look: horizontal lines and a light vignette (scaled to the screen height).

const float intensity = 0.18;

vec4 screen(vec2 uv) {
    vec4 c = umbriel_sample(uv);
    float scan = 1.0 - intensity * (0.5 + 0.5 * sin(uv.y * umbriel_size.y * 3.14159265));
    float v = 1.0 - 0.25 * smoothstep(0.3, 0.9, length(uv - vec2(0.5)));
    return vec4(c.rgb * scan * v, c.a);
}
