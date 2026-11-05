// name: Vignette
// Darkens the edges to draw the eye to the center.

const float strength = 0.45;

vec4 screen(vec2 uv) {
    vec4 c = umbriel_sample(uv);
    float v = 1.0 - strength * smoothstep(0.25, 0.85, length(uv - vec2(0.5)));
    return vec4(c.rgb * v, c.a);
}
