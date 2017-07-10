Shader "Custom/UI/Gradation/Stencil"
{
    Properties
    {
        _MainTex          ("Font Texture", 2D) = "white" {}
        _ColorCount       ("Color Count", Int) = 1
        _Direction        ("Direction",   Int) = 0
        _StencilReference ("Stencil ID",  Int) = 1
    }

    SubShader
    {
        Tags
        {
            "Queue"           = "Transparent+2"
            "IgnoreProjector" = "True"
            "RenderType"      = "Transparent"
        }
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha

        Stencil
        {
            Ref  [_StencilReference]
            Comp Equal
        }

        Pass
        {
            CGPROGRAM

            #pragma vertex   vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
                fixed4 color    : COLOR;
            };

            struct v2f
            {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
                fixed4 color    : COLOR;
            };

            sampler2D      _MainTex;
            uniform float4 _MainTex_ST;

            int _ColorCount;
            int _Direction;

            fixed4 _Colors[8];

            v2f vert(appdata_t v)
            {
                v2f output;
                output.vertex   = mul(UNITY_MATRIX_MVP, v.vertex);
                output.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                output.color    = v.color;
                return output;
            }

            fixed4 frag(v2f input) : COLOR
            {
                fixed4 col = input.color;

                if (_ColorCount <= 0) {
                    return col;
                }

                fixed4 colTo;
                fixed4 colFrom;

                fixed unit = 1.0 / _ColorCount;
                fixed f = 1.0 * _ColorCount - 2.0;

                float graph = (_Direction == 1)
                    ? input.texcoord.x
                    : input.texcoord.y;

                for (int i = 0; i < _ColorCount; i++) {
                    if (graph < unit * f) {
                        f -= 1.0f;
                        continue;
                    }

                    colTo   = _Colors[i + 1];
                    colFrom = _Colors[i] - colTo;
                    break;
                }

                colFrom *= (graph - unit * f) / unit;

                col.r = colTo.r + colFrom.r;
                col.g = colTo.g + colFrom.g;
                col.b = colTo.b + colFrom.b;
                col.a *= UNITY_SAMPLE_1CHANNEL(_MainTex, input.texcoord);

                return col;
            }
            ENDCG 
        }
    }   
}