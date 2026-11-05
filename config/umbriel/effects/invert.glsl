// name: Invert
// Inverts all colors (negative).

vec4 screen(vec2 uv) {
    vec4 c = umbriel_sample(uv);
    return vec4((vec3(1.0) - c.rgb) * c.a, c.a);
}
