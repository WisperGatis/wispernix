#version 300 es
// 이름: 선명한 색감
// Hausse de saturation légère appliquée à tout l'écran.
// 1.0 = inchangé ; au-dessus, les couleurs ressortent davantage.
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

const float saturation = 1.15;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    float luma = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    vec3 boosted = mix(vec3(luma), pixColor.rgb, saturation);
    fragColor = vec4(boosted, pixColor.a);
}
