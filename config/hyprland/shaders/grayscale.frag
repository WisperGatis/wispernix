#version 300 es
// 이름: 흑백
// 화면 전체를 흑백으로 표시합니다.
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 c = texture(tex, v_texcoord);
    float luma = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    fragColor = vec4(vec3(luma), c.a);
}
