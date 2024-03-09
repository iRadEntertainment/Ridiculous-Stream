shader_type canvas_item;

uniform float projector_power : hint_range(0,1) = 0.5;
uniform sampler2D distortionTexture;
uniform float vignette_param: hint_range(1,10)=20.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

//vars related to the passing lines


//noise for the projector flickering
float noise(vec2 input){
	return fract(sin(dot(input,vec2(3.1415,8952.37)*12.29))*93.116);
}

void fragment() {
	//vignette-related:
	float vignette_param2 =vignette_param+0.5*(noise(vec2(TIME/60.0,TIME/59.0)));
	float vig=-vignette_param2*((UV.x-0.5)*(UV.x-0.5)+(UV.y-0.5)*(UV.y-0.5));
	vec4 vignette=vec4(vig,vig,vig,1.0);

	//grayscale-related:
	vec4 pixelcolor = texture(SCREEN_TEXTURE, SCREEN_UV);
	float brightness = (.299*pixelcolor.r + 0.487*pixelcolor.g + 0.114*pixelcolor.b);
	vec4 grayscale= vec4(brightness,brightness,brightness,pixelcolor.a);
	
	//random-fluctuation:
	vec4 random=texture(distortionTexture,UV);
	
	//Small speckles:
	float RTIME1=round(TIME*20.0);
	vec2 position1=vec2(noise(vec2(RTIME1,RTIME1)),noise(vec2(RTIME1/2.0,RTIME1/2.0)));
	float energy= 1000000.0*(1.0+0.5*noise(vec2(RTIME1,RTIME1)));
	float xdev1=(UV.x-position1.x);
	float ydev1=(UV.y-position1.y);
	float spec=energy*(xdev1*xdev1+0.5*ydev1*ydev1)+.1*noise(vec2(UV.x,UV.y));
	vec4 speckle=vec4(max(0.0,20.0-spec),max(0.0,20.0-spec),max(0.0,20.0-spec),1.0);
	
	//lines:
	float RTIME2=round(TIME*5.0);
	vec2 positionline=vec2(noise(vec2(RTIME2,RTIME2))/4.0,noise(vec2(RTIME2/3.0,RTIME2/3.0)));
	float xline=(UV.x-positionline.x);
	float yline=(UV.y-positionline.y);
	float lin=energy*(xline*xline+0.00001*yline*yline)+.1*noise(vec2(UV.x,UV.y));
	vec4 line=vec4(max(0.0,8.0-lin),max(0.0,8.0-lin),max(0.0,8.0-lin),1.0);
	
	//combining-the parts:
	vec4 dirt=mix(speckle,line,0.5);
	vec4 grayscale2=mix(random,vignette,0.7);
	vec4 grayscale3=mix(dirt,grayscale2,0.7);
	COLOR = mix(grayscale, grayscale3, projector_power);
}