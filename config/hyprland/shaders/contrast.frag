#version 300 es
// 이름: 고대비
// 대비를 높이고 밝기는 그대로 둡니다.
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

const float contrast = 1.25;

void main() {
    vec4 c = texture(tex, v_texcoord);
    vec3 v = (c.rgb - 0.5) * contrast + 0.5;
    fragColor = vec4(clamp(v, 0.0, 1.0), c.a);
}
