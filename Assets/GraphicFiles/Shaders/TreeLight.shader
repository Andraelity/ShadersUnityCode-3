Shader "TreeLight"
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

			float2 ObjUnion(float2 obj0, float2 obj1)
			{
				if(obj0.x < obj1.x)
				{
					return obj0;
				}
				else
				{
					return obj1;
				}
			}

			float3 sim(float3 p, float s)
			{
				float3 ret = p;
				ret = p + (s/2.0);
				ret = frac(ret/s) * s - (s/2.0);
				return ret;
			}

			float2 rot(float2 p, float r)
			{
				float2 ret;
				ret.x = p.x * cos(r) - p.y * sin(r);
				ret.y = p.x * sin(r) + p.y * cos(r);
				return ret;
			}

			float2 rotsim(float2 p, float s)
			{
				float2 ret = p;
				ret = rot(p, -PI/(s * 2.0));
				ret = rot(p, floor(atan2(ret.x, ret.y)/PI * s) * (PI/s));
				return ret;
			}

			float rnd(float2 v)
			{
				return sin((sin(((v.y - 1453.0)/(v.x + 1229.0)) * 23232.124)) * 16283.223) * 0.5 + 0.5;
			}

			float noise(float2 v)
			{
				float2 v1 = floor(v);
				float2 v2 = smoothstep(0.0, 1.0, frac(v));
				float n00 = rnd(v1);
				float n01 = rnd(v1 + float2(0.0,1.0));
				float n10 = rnd(v1 + float2(1.0,0.0));
				float n11 = rnd(v1 + float2(1.0,1.0));
				return lerp(lerp(n00, n01, v2.y), lerp(n10, n11, v2.y), v2.x);
			}



			float2 obj0(in float3 p){
			  if (p.y<0.4)
			  p.y+=sin(p.x)*0.4*cos(p.z)*0.4;
			  return float2(p.y,0);
			}

			float3 obj0_c(float3 p){
			  	float f=
			    noise(p.xz)*0.5+
			    noise(p.xz*2.0+13.45)*0.25+
			    noise(p.xz*4.0+23.45)*0.15;
				
				float pc = min(max(1.0/length(p.xz), 0.0), 1.0) * 0.5;
			  	return float3(f,f,f) * 0.3 + pc + 0.5;
			}

			//Snow
			float makeshowflake(float3 p){
			  return length(p)-0.03;
			}

			float makeShow(float3 p,float tx,float ty,float tz){
			  p.y = p.y + TIME * tx;
			  p.x = p.x + TIME * ty;
			  p.z = p.z + TIME * tz;
			  p=sim(p,4.0);
			  return makeshowflake(p);
			}

			float2 obj1(float3 p){
			  float f=makeShow(p,1.11, 1.03, 1.38);
			  f = min(f,makeShow(p,1.72, 0.74, 1.06));
			  f = min(f,makeShow(p,1.93, 0.75, 1.35));
			  f = min(f,makeShow(p,1.54, 0.94, 1.72));
			  f = min(f,makeShow(p,1.35, 1.33, 1.13));
			  f = min(f,makeShow(p,1.55, 0.23, 1.16));
			  f = min(f,makeShow(p,1.25, 0.41, 1.04));
			  f = min(f,makeShow(p,1.49, 0.29, 1.31));
			  f = min(f,makeShow(p,1.31, 1.31, 1.13));  
			  return float2(f,1.0);
			}

			float3 obj1_c(float3 p){
			    return float3(1,1,1);
			}


			//Star
			float2 obj2(float3 p){
				p.y = p.y - 4.3;
				p = p * 4.0;
				float l = length(p);
				if (l < 2.0)
				{
					p.xy = rotsim(p.xy, 2.5);
					p.y = p.y - 2.0; 
					p.z = abs(p.z);
					p.x = abs(p.x);
					return float2(dot(p, normalize(float3(2.0,1.0,3.0)))/4.0,2);
				} 
				else 
				{
					return float2((l-1.9)/4.0,2.0);
				}
			}

			float3 obj2_c(float3 p){
			  return float3(1.0,0.5,0.2);
			}

			//Objects union
			float2 inObj(float3 p){
			  return ObjUnion( ObjUnion( obj0(p), obj1(p)) ,obj2(p));
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

                float2 mouseCoordinateScale = (mouseCoordinate + 1.0)/ float2(2.0,2.0);
                // float2 coordinateBase = i.uv;

                float2 coordinate = i.uv;

				float2 coordinateHalf = i.uv /float2(2, 2);
                // float2 scaleResolution = i.uv /float2(2, 2);

                // float2 coordinateScale = (coordinateBase + 1.0 )/ float2(4.0,2.0);

                float2 coordinateScale = (coordinate + 1.0 )/ float2(2.0,2.0);

    			// float2 coordinateScale = float2(scaleResolution.x + 1.0 + _rangeZero_Ten,scaleResolution.y + 1.0 + _rangeSOne_One);

                //Test Output 
                float3 col  = 0.0;
                float3 col2 = float3(coordinate.x + coordinate.y, coordinate.y - coordinate.x, pow(coordinate.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                col = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////


	float2 vPos = coordinate;
//Camera animation
  float3 vuv = normalize(float3(sin(TIME) * 0.3, 1, 0));
  float3 vrp = float3(0, cos(TIME * 0.5) + 2.5, 0);
  float3 prp = float3(sin(TIME * 0.5) * (sin(0.39) * 2.0 + 3.5), sin( 0.5) + 3.5, cos( 0.5) * (cos(TIME * 0.45) * 2.0 + 3.5));
  float vpd=1.5;  
 
  //Camera setup
  float3 vpn = normalize(vrp-prp);
  float3 u = normalize(cross(vuv,vpn));
  float3 v = cross(vpn,u);
  float3 scrCoord = prp + vpn * vpd + vPos.x * u+vPos.y * v;
  float3 scp = normalize(scrCoord - prp);
 
  //lights are 2d, no raymarching
  float4x4 cm= {
    u.x,   u.y,   u.z,   -dot(u,prp),
    v.x,   v.y,   v.z,   -dot(v,prp),
    vpn.x, vpn.y, vpn.z, -dot(vpn,prp),
    0.0,   0.0,   0.0,   1.0
			};
 
  float4 pc = float4(0,0,0,0);
  const float maxl = 80.0;
  for(float i=0.0;i<maxl;i++){
  float4 pt = float4(
    sin(i * PI * 2.0 * 7.0/maxl) * 2.0 * (1.0-i/maxl),
    i/maxl * 4.0,
    cos(i * PI * 2.0 * 7.0/maxl) * 2.0 * (1.0-i/maxl),
    1.0);
  pt = mul(pt, cm);
  float2 xy = (pt/(-pt.z/vpd)).xy + vPos ;//* flaot2(iResolution.x/iResolution.y,1.0);
  float c;
  c = 0.4/length(xy);
  pc += float4(
          (sin(i * 5.0 + TIME * 10.0)* 0.5 + 0.5) * c,
          (cos(i * 3.0 + TIME * 8.0) * 0.5 + 0.5) * c,
          (sin(i * 6.0 + TIME * 9.0) * 0.5 + 0.5) * c,0.0);
  }
  pc=pc/maxl;

  pc=smoothstep(0.0,1.0,pc);
  
  //Raymarching
  const float3 e = float3(0.1,0,0);
  const float maxd=15.0; //Max depth
 
  float2 s = float2(0.1,0.0);
  float3 c,p,n;
 
  float f=1.0;
  for(int i=0;i<64;i++){
    if (abs(s.x) < 0.001 || f > maxd) break;
    f += s.x;
    p = prp + scp * f;
    s = inObj(p);
  }

float4 fragColor = 0;

  if (f < maxd){
    if (s.y == 0.0)
      c = obj0_c(p);
    else if (s.y == 1.0)
      c = obj1_c(p);
    else
      c = obj2_c(p);
      if (s.y <= 1.0)
	  {
        fragColor = float4(c * max(1.0-f *0.08,0.0), 1.0) + pc;
      } 
	  else
	  {
         //tetrahedron normal   
         const float n_er = 0.01;
         float v1 = inObj(float3(p.x + n_er, p.y - n_er, p.z - n_er)).x;
         float v2 = inObj(float3(p.x - n_er, p.y - n_er, p.z + n_er)).x;
         float v3 = inObj(float3(p.x - n_er, p.y + n_er, p.z - n_er)).x;
         float v4 = inObj(float3(p.x + n_er, p.y + n_er, p.z + n_er)).x;
         n = normalize(float3(v4 + v1 - v3 - v2, v3 + v4 - v1 - v2, v2 + v4 - v3 - v1));
  
        float b=max(dot(n,normalize(prp-p)),0.0);
        fragColor=float4((b*c+pow(b,8.0))*(1.0-f*.01),1.0)+pc;
      }
  }
                return float4(fragColor);


				
			}

			ENDCG
		}
	}
}

























