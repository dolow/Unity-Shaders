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

                // let CPU take care of _ColorCount == 0 case

                int   maxIndex = _ColorCount - 1;
                fixed unit     = 1.0 / maxIndex;

                float phase  = input.texcoord[_Direction] * maxIndex;
                fixed volume = input.texcoord[_Direction] % unit / unit;

                fixed4 colTo   = _Colors[max(0, phase) + 1];
                fixed4 colFrom = _Colors[min(phase, maxIndex)];

                colFrom *= 1.0 - volume;
                colTo   *= volume;

                col.rgb  = colFrom.rgb + colTo.rgb;
                col.a   *= UNITY_SAMPLE_1CHANNEL(_MainTex, input.texcoord);

                return col;
            }
            ENDCG 
        }
    }   
}