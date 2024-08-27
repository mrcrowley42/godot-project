/*
original: https://godotshaders.com/shader/voronoi-%e7%bb%86%e8%83%9e%e8%be%b9%e7%95%8c%e8%b7%9d%e7%a6%bb/
*/

shader_type canvas_item;


uniform vec4 color = vec4(0.0,0.0,0.0,1.0);
uniform float pixel_size : hint_range(2., 20., 1.) = 5;
uniform float scale : hint_range(0.01, 1., 0.01) = .5;
uniform float speed : hint_range(0.01, 5.0, 0.01) = 0.05;
uniform float layer : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float opacity : hint_range(0.0, 1.0, 0.01) = 0.2;

#define iTime TIME * speed
#define iResolution 1.0 / screen_pixel_size

float hash12(vec2 p) {
	vec3 p3  = fract(vec3(p.xyx) * .1031);
	p3 += dot(p3, p3.zyx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

// 轨迹半径
float rcel(vec2 ip){return mix(.25,.45, hash12(ip+.2));}                                      

vec2 cell(vec2 ip) {// 求细胞核位置
	float ag = 6.28*hash12(ip + 1.23) + 5.*iTime ;//  * mix(.5,1.5,hash12(ip+3.));// 不同转速，有误差, 数字大点差就大了?                  
	return vec2(cos(ag), sin(ag)) * rcel(ip);
}

vec4 voronoi(vec2 screen_pixel_size, vec2 screen_uv) {
	vec4 O = color;
	float ratio = screen_pixel_size.x / screen_pixel_size.y;
	vec2 U = (screen_uv) * 1000.0 * scale / vec2(ratio, 1.0);
	#define bl if(iMouse.x < iResolution.x * .52)
	vec2 R = iResolution.xy,
		u = 3.*(U + U - R) / R.y+vec2(0,iTime),
		g =(u-.5)- round(u-.5);
	// 画格子
	g = abs(g); if( g.x<g.y )g = g.yx;

	vec2 p = u,
		ip = round(p);

	// 参考：https://iquilezles.org/articles/voronoilinex/
	// 找最近细胞核
	vec2 a,ia;
	float i,j,md=1e8,d;
	for(float j=-1.;j<2.;j++)
	for(float i=-1.;i<2.;i++) {
		vec2 e = ip + vec2(i,j),
			c = cell(e)+e;
		d = length(c-p);
		if(d<md) {
			md = d;
			ia = e; // 正方形中心
			a  = c; // 细胞核位置
		}
	}
	// colour
	O += mix(vec4(.5,0,(ia.y-iTime)/2.,1)+.3,vec4(0,.3,(ia.x-0.)*.3,0)+.2,hash12(ia) ) * layer;

	// 求到相交边界的距离
	md=1e8;
	for(float j=-2.;j<=2.;j++)
	for(float i=-2.;i<=2.;i++) {
		if(abs(i)+abs(j)>.1) {
			vec2 e = ia + vec2(i,j), // 邻居所在正方形
			        b = cell(e)+e;      // 第二细胞核位置
			d = dot( p- (a+b)/2., normalize(a-b));
			md=min(md, d);//md=min(md,abs(d));
		}
	}

	// colour
	d = 10. * clamp(exp(-2e2*md), 0., 1.) * layer;

	// outline
	return vec4((max(O-.1*d,0.)+d));
}

void fragment() {
	vec2 screenDim = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 remainder = SCREEN_UV * screenDim;  // to screen space
	remainder /= vec2(pixel_size);  // to pixel space
	remainder -= floor(remainder);
	remainder *= vec2(pixel_size);  // revert pixel space
	remainder /= screenDim;  // revert screen space
	
	COLOR = voronoi(SCREEN_PIXEL_SIZE, SCREEN_UV - remainder);
	COLOR.a = opacity;
}