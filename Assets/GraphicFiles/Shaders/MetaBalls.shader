Shader "MetaBalls"
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
    

float metaball(float3 p, float4 spr){
    float fv[5];
    float t = TIME;
    fv[0] = length(p - float3(2.0 * sin(t), 0.0, 2.0 * cos(t)));
    fv[1] = length(p - float3(4.0 * sin(t), sin(t), 2.0 * cos(t * 0.7)));
    fv[2] = length(p - float3(1.0 * sin(t), 2.0 * cos(t * 1.3), 1.0 * cos(t)));
    fv[3] = length(p - float3(4.0 * cos(t), 2.0 * cos(t * 1.3), 1.5 * cos(t)));
    fv[4] = length(p - float3(0.5 * sin(t * 0.2), 2.0 * cos(t * 1.6), 0.5 * sin(t)));
    float len = 0.0;
    float fs = 1.0;
    for (int i = 0; i < 5; i ++) {
        len += fs / (fv[i] * fv[i]);
    }
    len = min(16.0, len);
    len = 1.0 - len;
    return len;
}


float4x4 getrotz(float angle) {
    float4x4 matrixOut = { cos(angle), -sin(angle), 0.0, 0.0,
                           sin(angle),  cos(angle), 0.0, 0.0,
                           0.0,         0.0, 1.0, 0.0,
                           0.0,         0.0, 0.0, 1.0};

    return matrixOut;
}
float4x4 getrotx(float angle) {
    float4x4 matrixOut = {       1.0,         0.0, 0.0, 0.0,
                0.0, cos(angle), -sin(angle), 0.0,
                0.0, sin(angle), cos(angle), 0.0,
                0.0, 0.0, 0.0, 1.0};

    return matrixOut;
}

float scene(float3 p) {
    float angle = TIME;
    float4x4 rotmat = mul(getrotz(angle), getrotx(angle * 0.5));
    float4 q = mul(rotmat, float4(p, 0.0));
    float d = metaball(q.xyz,float4(0.0, 0.0, 2.0 , 6.0));
    return d;
}

float3 getN(float3 p){
    float eps=0.01;
    return normalize(float3(
        scene(p + float3(eps,0,0))-scene(p - float3(eps,0,0)),
        scene(p + float3(0,eps,0))-scene(p - float3(0,eps,0)),
        scene(p + float3(0,0,eps))-scene(p - float3(0,0,eps))
    ));
}
float AO(float3 p,float3 n){
    float dlt=0.5;
    float oc=0.0,d=1.0;
    for(float i=0.0;i<6.;i++){
        oc+=(i*dlt-scene(p+n*i*dlt))/d;
        d*=2.0;
    }
    
    float tmp = 1.0-oc;
    return tmp;
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

                
                float2 coordinate = i.uv;
                
                float2 coordinateBase = i.uv/(float2(2.0, 2.0));
                
                float2 coordinateScale2 = (coordinate + 1.0 )/ float2(2.0,2.0);
                
                float2 coordinateFull = ceil(coordinateBase);

                //Test Output 
                float3 colBase  = 0.0;
                float3 col2 = float3(coordinate.x + coordinate.y, coordinate.y - coordinate.x, pow(coordinate.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                colBase = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////

                
                

                
                float2 var = coordinate;
                
                float3 org = float3(var, -18);
                org.y *= 1.0;
                
                float3 camera_pos = float3(0.0, 0.0, -23.0);
                float3 dir = normalize(org - camera_pos);
                float4 col = float4(0.0, 0.0, 0.0, 1.0);
                float3 p = org.xyz;
                float d, g;
                
                for (int i = 0; i < 64; i++) {
                    d = scene(p.xyz) * 1.0;
                    p = p + d * dir;
                }
                
                
                float3 n = getN(p);
                float a = AO(p,n);
                float3 s = float3(0,0,0);
                float3 lp[3],lc[3];
                lp[0] = float3(4.0 * cos(TIME),0, 4.0 * sin(TIME));
                lp[1] = float3(2,3,-18);
                lp[2] = float3(4,-2,-24);  
                lc[0] = float3(1.0,0.5,0.4);  
                
                
                float theta = acos(p.y / length(p));
                float phi = acos(p.x / length(p.xz)) + TIME;
                lc[1] = float3(sin(TIME), cos(TIME), sin(TIME) * cos(TIME));
                lc[2] = float3(0.2,1.0,0.5);
                
                for(int i=0;i<3;i++){
                    float3 l,lv;
                    lv=lp[i]-p;
                    l=normalize(lv);
                    float3 r = reflect(-l, n);
                    float3 v = normalize(camera_pos - p);
                    g = length(lv);
                    g = (max(0.0,dot(l,n)) + pow(max(0.0, dot(r, v)), 2.0))/(g)*5.;
                    s += g*lc[i];
                }
                float fg=min(1.0,20.0/length(p-org));
                col = float4(s*a,1)*fg*fg;
    

                return col;
                // return float4(color, 1.0);

                // col = tex2D(_TextureChannel0, coordinate);
                // return float4(col,1.0) ;
                // 
                // if (colFour.x >= 0.01)
                // {
                	// return colFour;
                // }
                // else
                // {
                	// return float4(col2, 1.0);
                // }


				
			}

			ENDCG
		}
	}
}

























