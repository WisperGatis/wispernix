// nom: Noir et blanc
// Affiche tout l'écran en niveaux de gris.

vec4 screen(vec2 uv) {
    vec4 c = umbriel_sample(uv);
    float luma = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    return vec4(vec3(luma), c.a);
}
