// name: Vivid colors
// Slightly raises saturation (1.0 = original).

const float saturation = 1.15;

vec4 screen(vec2 uv) {
    vec4 c = umbriel_sample(uv);
    float luma = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    return vec4(mix(vec3(luma), c.rgb, saturation), c.a);
}
