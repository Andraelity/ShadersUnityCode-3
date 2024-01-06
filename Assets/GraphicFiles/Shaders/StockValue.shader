Shader "StockValue"
{
	Properties
	{
		_TextureChannel0 ("Texture", 2D) = "gray" {}
		_TextureChannel1 ("Texture", 2D) = "gray" {}
		_TextureChannel2 ("Texture", 2D) = "gray" {}
		_TextureChannel3 ("Texture", 2D) = "gray" {}


	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" "DisableBatching" ="true" }
		LOD 100

		Pass
		{
		    ZWrite Off
		    Cull off
		    Blend SrcAlpha OneMinusSrcAlpha
		    
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
                  #pragma multi_compile_instancing
			
			#include "UnityCG.cginc"

			struct vertexPoints
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
                  UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct pixel
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

                  UNITY_INSTANCING_BUFFER_START(CommonProps)
                  UNITY_DEFINE_INSTANCED_PROP(fixed4, _FillColor)
                  UNITY_DEFINE_INSTANCED_PROP(float, _AASmoothing)
                  UNITY_DEFINE_INSTANCED_PROP(float, _rangeZero_Ten)
                  UNITY_DEFINE_INSTANCED_PROP(float, _rangeSOne_One)
                  UNITY_DEFINE_INSTANCED_PROP(float, _rangeZoro_OneH)
                  UNITY_DEFINE_INSTANCED_PROP(float, _mousePosition_x)
                  UNITY_DEFINE_INSTANCED_PROP(float, _mousePosition_y)

                  UNITY_INSTANCING_BUFFER_END(CommonProps)

            

			pixel vert (vertexPoints v)
			{
				pixel o;
				
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.vertex.xy;
				return o;
			}
            
                sampler2D _TextureChannel0;
                sampler2D _TextureChannel1;
                sampler2D _TextureChannel2;
                sampler2D _TextureChannel3;
      			
                #define PI 3.1415927
                #define TIME _Time.y
      
                float2 mouseCoordinateFunc(float x, float y)
                {
                	return normalize(float2(x,y));
                }
            /////////////////////////////////////////////////////////////////////////////////////////////
            // Default 
            /////////////////////////////////////////////////////////////////////////////////////////////


float Logo(float2 p) {
	float y = floor((p.y)*16.)+3.;
	if(y < 0. || y > 4.) return 0.;
	float x = floor((1.-p.x)*16.)-8.;
	if(x < 0. || x > 14.) return 0.;
	float v=31698.0;if(y>0.5)v=19026.0;if(y>1.5)v=17362.0;if(y>2.5)v=18962.0;if(y>3.5)v=31262.0;
	return floor(fmod(v/pow(2.,x), 2.0));
}

float hash( float n ) { return frac(sin(n)*43758.5453); }

float noise( in float2 x )
{
	float2 p = floor(x);
	float2 f = frac(x);
    	f = f*f*(3.0-2.0*f);
    	float n = p.x + p.y*57.0;
    	return lerp(lerp(hash(n+0.0), hash(n+1.0),f.x), lerp(hash(n+57.0), hash(n+58.0),f.x),f.y);
}

float3 cloud(float2 p) {
	p.x *= 1.14;
	p.x -= TIME*.1;
	p.y *= 3.14;
	float3 f = 0.0;
    	f += 0.5000*noise(p*10.0) * float3(0.9, 0.2,0.7);
    	f += 0.2500*noise(p*20.0) * float3(0.9, 1.6, 0.5);
    	f += 0.1250*noise(p*40.0) * float3(0.9, 0.7, 0.3);
    	f += 0.0625*noise(p*80.0) * float3(0.9, 1.2, 0.9);
	return f*f*2.;
}

const float SPEED	= 0.001;
const float SCALE	= 80.0;
const float DENSITY	= 0.8;
const float BRIGHTNESS	= 10.0;
#define ORIGIN	0.5
float rand(float2 co){ return frac(sin(dot(co.xy , float2(12.9898,78.233))) * 43758.5453); }

float3 layer(float i, float2 pos, float dist, float2 coord) {
	float t = i * 10.0 + TIME * i * i;
	float r = coord.x - (t*SPEED);
	float c = frac(coord.y + i*.543 + TIME *i*.01);
	float2  p = float2(r, c*.5)*SCALE*(4.0/(i*i));
	float2 uv = frac(p)*2.0-1.0;
	float a = coord.y*(3.1415926*2.0) - (3.1415926*.5);
	uv = float2(uv.x*cos(a) - uv.y*sin(a), uv.y*cos(a) + uv.x*sin(a));
	float m = clamp((rand(floor(p))-DENSITY/i)*BRIGHTNESS, 0.0, 1.0);
	return  clamp(float3(Logo(uv*.5), Logo(uv*.5), Logo(uv*.5))*m*dist, 0.0, 1.0);
}

float segment(float2 P, float2 P0, float2 P1)
{
	float2 v = P1 - P0;
	float2 w = P - P0;
	float b = dot(w,v) / dot(v,v);
	v *= clamp(b, 0.0, 1.0);
	return length(w-v);
}

float StockValue(float x, float s) {
	return frac(sin(x)*10000.0)*.25*s-x*.5;
}

float3 Chart( float2 p ) {

	float d = 1e20;
	float s = 20.;
	float t = TIME * s * .08;

	p = p*s + float2(t+s*.25,-t*.5);

	float x = floor(p.x);

	float2 p0 = float2(x-.5, StockValue(x+0., s));
	float2 p1 = float2(x+.5, StockValue(x+1., s));
	d = min(d, segment(p+float2(0,0), p0, p1));

	p0 = float2(x+1.5, StockValue(x+2., s));
	d = min(d, segment(p+float2(0,0), p1, p0));

	p = abs(fmod(p, float2(1.,1.))- float2(.5,.5))-.01;
	float b =1.0-clamp(min(p.x, p.y)*2.0/s, 0.0, 1.0);

	float a1=clamp(1.0-d,0.0,1.0);
	a1*=a1;
	return float3(a1*a1,a1*a1*a1,a1+b*0.2);
}




            fixed4 frag (pixel i) : SV_Target
			{
				
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////

			    UNITY_SETUP_INSTANCE_ID(i);
			    
		    	float aaSmoothing = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _AASmoothing);
			    fixed4 fillColor = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _FillColor);
			   	float _rangeZero_Ten = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeZero_Ten);
				float _rangeSOne_One = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeSOne_One);
			    float _rangeZoro_OneH = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeZoro_OneH);
                float _mousePosition_x = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _mousePosition_x);
                float _mousePosition_y = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _mousePosition_y);

                float2 mouseCoordinate = mouseCoordinateFunc(_mousePosition_x, _mousePosition_y);

                float2 coordinateBase = i.uv;
                
                float2 coordinate = i.uv/float2(2,2);
                
                float2 coordinateFull = ceil(coordinateBase);


                float2 mouseCoordinateScale = (mouseCoordinate + 1.0)/ float2(2.0,2.0);

                float2 coordinateScale2 = (coordinateBase + 1.0 )/ float2(2.0,2.0);

                //Test Output 
                float3 col  = 0.0;
                float3 col2 = float3(coordinateBase.x + coordinateBase.y, coordinateBase.y - coordinateBase.x, pow(coordinateBase.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                col = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////

                float2 fragCoord = coordinateBase;
                float2  pos = fragCoord;
				float dist = length(pos) / 2.0;
				float2 coord = float2(pow(dist, 0.1), atan2(abs(pos.x), pos.y) / (3.1415926*2.0));
				float3 color = cloud(coord)*3.0*dist;
				color.b=cloud(coord*0.998).x*(3.0*dist);
				coord = float2(pow(dist, 0.1), atan2(pos.x, pos.y) / (3.1415926*2.0));
				color += layer(2.0, pos, dist, coord)*0.3;
				color += layer(3.0, pos, dist, coord)*0.2;
				color += layer(4.0, pos, dist, coord)*0.1;
				pos.y=-pos.y;
			        float3 c=((clamp(3.0*abs(frac(TIME*0.1 + float3(0,2./3.0,1./3.0))*2.-1.)-1.,0.,1.)-1.)+1.);
			        c*=(0.2-dist*0.1)*Logo(pos/float2(2.0, 2.0));
				
				float4 fragColor = float4( (1.0+(2.0-dist*2.0))*0.4 *Chart(pos/2.0)+c+color*.4 , 1.0);//
				
				return fragColor;
				// 
// // 
//                 float4 mouseNDC = -1.0 + float4(mouseCoordinate)
// // 
//                 float newUV;
//                 mouseNDC.zw -= mouseNDC.xy;
// // 
//                 return float4(col, (col.x + col.y + col.z)/3.0);



                // return float4(col, 1.0);


				
			}

			ENDCG
		}
	}
}

























