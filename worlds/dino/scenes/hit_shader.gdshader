shader_type canvas_item;

uniform bool isDead = false;
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	vec4 white = vec4(1.0, 1.0, 1.0, original.a);
	vec4 black = vec4(0.0, 0.0, 0.0, original.a);
	if(isDead) COLOR = mix(original, black, flash_amount * original.a);
	else COLOR = mix(original, white, flash_amount * original.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
