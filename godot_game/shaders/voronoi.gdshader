shader_type canvas_item;


uniform vec4 color = vec4(0.0,0.0,0.0,1.0);
uniform float scale : hint_range(0.1, 5.0, 0.1) = 1;
uniform vec2 disp = vec2(0.0, 0.0);
uniform float speed : hint_range(0.1, 5.0, 0.1) = 1.0;
uniform float nucleus = 1.0;
uniform float contrast : hint_range(0.0, 5.0, 0.1) = 0.5;
uniform float line : hint_range(0.0, 5.0, 0.1) = 1.0;
uniform float layer1 : hint_range(0.0, 5.0, 0.1) = 1.0;
uniform float layer2 : hint_range(0.0, 2.0, 0.1) = 1.0;

#define iTime TIME * speed
#define iResolution 1.0/ SCREEN_PIXEL_SIZE

varying vec4 iMouse;
float hash12(vec2 p)
{
        vec3 p3  = fract(vec3(p.xyx) * .1031);
        p3 += dot(p3, p3.zyx + 33.33);
        return fract((p3.x + p3.y) * p3.z);
}

// 轨迹半径
float rcel(vec2 ip){return mix(.25,.45, hash12(ip+.2));}                                      

vec2 cell(vec2 ip)
{// 求细胞核位置
        float ag = 6.28*hash12(ip + 1.23) + 5.*iTime ;//  * mix(.5,1.5,hash12(ip+3.));// 不同转速，有误差, 数字大点差就大了?                  
        return vec2(cos(ag), sin(ag)) * rcel(ip);
}

void fragment()
{
        vec4 O = color;
		float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
        vec2 U = (SCREEN_UV-disp) * 1000.0 * scale / vec2(ratio, 1.0);
        #define bl if(iMouse.x < iResolution.x * .52)
        vec2 R = iResolution.xy,
             u = 3.*(U + U - R) / R.y+vec2(0,iTime),
             g =(u-.5)- round(u-.5);
        // 画格子
        g = abs(g); if( g.x<g.y )g = g.yx;
        bl O += .4 * exp(-1e2 * g.y) * layer1;
        // 原点
        bl O += exp(-1e2 * length(u)) * layer1;
        
        vec2 p  = u,
             ip = round(p),
             fp = p - ip,
             ct;
        
        //ct = normalize(hash22(ip))*rc;
        ct = cell(ip);
        
        // 细胞核轨迹
        O.x += exp(-30. * length(fp - ct)) * nucleus;
        bl O += .2 * exp(-99. * abs(length(fp) - rcel(ip))) * layer1 ;
        
        // 参考：https://iquilezles.org/articles/voronoilinex/
        // 找最近细胞核
        vec2 a,ia;
        float i,j,md=1e8,d;
        for(float j=-1.;j<2.;j++)
        for(float i=-1.;i<2.;i++)
        {
                vec2 e = ip + vec2(i,j),
                     c = cell(e)+e;
                d = length(c-p);
                if(d<md)
                {
                        md = d;
                        ia = e; // 正方形中心
                        a  = c; // 细胞核位置
                }
        }
        // 细胞上色，点 p 在细胞 a 里
        O += mix(vec4(.5,0,(ia.y-iTime)/2.,1)+.3,vec4(0,.3,(ia.x-0.)*.3,0)+.2,hash12(ia) ) * layer2;
        
        // 求到相交边界的距离
        md=1e8;
        for(float j=-2.;j<=2.;j++)
        for(float i=-2.;i<=2.;i++)
        {
                if(abs(i)+abs(j)>.1) // 不在原点，不跟自己比较
                //if(length(vec2(i,j))>.1)
                {
                        vec2 e = ia + vec2(i,j), // 邻居所在正方形
                             b = cell(e)+e;      // 第二细胞核位置
                        d = dot( p- (a+b)/2., normalize(a-b));
                        md=min(md, d);//md=min(md,abs(d));
                }
        }
        
        // 线框
        d = 10. * clamp(exp(-2e2*md), 0., 1.) * layer2;
        
        // 条纹
        d += .1* clamp(exp(-2e2*cos(80.*md)), 0., 1.) * line;
        
        O = (max(O-contrast*d,0.)+d );
		COLOR = vec4(O);
		COLOR.a *= color.a;
}