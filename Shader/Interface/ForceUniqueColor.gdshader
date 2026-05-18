shader_type canvas_item;

// Controle no Inspector: escolha a cor que vai definir a nova Matiz (Hue)
uniform vec4 cor_alvo : source_color = vec4(0.5, 0.35, 0.2, 1.0);

// Função que converte RGB para HSV
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Função que converte HSV de volta para RGB
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    // 1. Pega a cor original da logo da Godot (RGB)
    vec4 cor_original = texture(TEXTURE, UV);
    
    // 2. Converte a cor original e a sua cor customizada para HSV
    vec3 hsv_original = rgb2hsv(cor_original.rgb);
    vec3 hsv_alvo = rgb2hsv(cor_alvo.rgb);
    
    // 3. A MÁGICA: Criamos uma nova cor misturando o melhor dos dois mundos
    vec3 hsv_final;
    hsv_final.x = hsv_alvo.x;       // Pegamos a Matiz (Hue) da sua cor marrom
    hsv_final.y = hsv_original.y * hsv_alvo.y;   // Mantemos a Saturação original da logo
    hsv_final.z = hsv_original.z * hsv_alvo.z;   // Mantemos o Brilho (Value) original da logo
    
    // 4. Converte de volta para RGB e aplica mantendo a transparência (Alpha)
    COLOR = vec4(hsv2rgb(hsv_final), cor_original.a);
}
