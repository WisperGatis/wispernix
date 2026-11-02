// Hausse de saturation légère appliquée à tout l'écran.
// 1.0 = inchangé ; au-dessus, les couleurs ressortent davantage.
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

const float saturation = 1.15;

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);
    float luma = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    vec3 boosted = mix(vec3(luma), pixColor.rgb, saturation);
    gl_FragColor = vec4(boosted, pixColor.a);
}
