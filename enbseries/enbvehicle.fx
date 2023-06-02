
/* VERSION 2.0 */

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//      /XXXXXXX\          __                  |HHHHHHHHH\                                          \HH\     /HH/    // 
//     |XX|   |XX|         XX                  |HH|    \HHH\   /\                                    \HH\   /HH/     //
//     |XX|    |X|        /XX\                 |HH|      \HH\  \/                                     \HH\ /HH/      //
//      \XX\             /XXXX\                |HH|       |HH| __ __  __     ___     ___      __       \HHHHH/       //
//       \XX\           /XX/\XX\               |HH|       |HH| || || /__\   /___\   /___\   __||__      \HHH/        //
//     _   \XX\        /XX/  \XX\              |HH|       |HH| || ||//  \\ //   \\ //   \\ |==  ==|     /HHH\        //
//    |X|    \XX\     /XXXXXXXXXX\             |HH|       |HH| || ||/      ||===|| ||    -    ||       /HHHHH\       //
//    \XX\    |XX|   /XX/      \XX\            |HH|      /HH/  || ||       ||      ||         ||      /HH/ \HH\      // 
//     \XX\   /XX/  /XX/        \XX\  ________ |HH|    /HHH/   || ||       \\    _ \\    _    ||  _  /HH/   \HH\     //
//      \XXXXXXX/  /XX/          \XX\|________||HHHHHHHHH/     || ||        \===//  \===//    \\=// /HH/     \HH\    //
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//++++++++++++++++++++++++++++++++++            ENBSeries effect file              ++++++++++++++++++++++++++++++++++//
//++++++++++++++++++++++++++++++++++      SA_DirectX by Maxim Dubinov(Makarus)     ++++++++++++++++++++++++++++++++++//
//++++++++++++++++++++++++++++++++++    Visit http://www.facebook.com/sadirectx    ++++++++++++++++++++++++++++++++++//
//+++++++++++++++++++++++++    https://www.youtube.com/channel/UCrASy-x5DgwHpYiDv41RL2Q    ++++++++++++++++++++++++++//
//++++++++++++++++++++++++++++++++++          Visit http://enbdev.com              ++++++++++++++++++++++++++++++++++//
//++++++++++++++++++++++++++++++++++    Copyright (c) 2007-2018 Boris Vorontsov    ++++++++++++++++++++++++++++++++++//
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//

float4 tempF1; float4 tempF2; float4 tempF3; float4 ScreenSize; float ENightDayFactor; float EInteriorFactor;
float4 WeatherAndTime; float4 Timer; float FieldOfView; float GameTime; float4 SunDirection; 
float4 CustomShaderConstants1[8]; float4 MatrixVP[4]; float4 MatrixInverseVP[4]; float4 MatrixVPRotation[4];
float4 MatrixInverseVPRotation[4]; float4 MatrixView[4]; float4 MatrixInverseView[4]; float4 CameraPosition;
float4x4 MatrixWVP; float4x4 MatrixWVPInverse; float4x4 MatrixWorld; float4x4 MatrixProj; float4 diffColor;
float4 specColor; float4 ambColor; float4 FogParam; float4 FogFarColor; float4 lightDiffuse[8]; float4 lightSpecular[8];
float4 lightDirection[8]; float4 VehicleParameters1;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//Textures
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//

texture2D texOriginal;
texture2D texRefl;
texture2D texEnv;
sampler2D SamplerOriginal = sampler_state { Texture   = <texOriginal>; };

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//Sampler Inputs
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//

sampler2D SamplerRefl = sampler_state
{
	Texture   = <texRefl>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D SamplerEnv = sampler_state
{
	Texture   = <texEnv>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU  = Mirror;
	AddressV  = Mirror;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

struct PS_OUTPUT3
{
	float4 Color[3] : COLOR0;
};

struct VS_INPUT_N
{
	float3	pos : POSITION;
	float3	normal : NORMAL;
	float2	txcoord0 : TEXCOORD0;
};

struct VS_OUTPUT
{
	float4	pos : POSITION;
	float2	txcoord0 : TEXCOORD0;
	float3	viewnormal : TEXCOORD3;
	float3	eyedir : TEXCOORD4;
	float3	wnormal : TEXCOORD5;
	float4	vposition : TEXCOORD6;
	float3	normal : TEXCOORD7;
};

////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////SA_DirectX/////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
VS_OUTPUT VS_Draw(VS_INPUT_N IN)
{
    VS_OUTPUT OUT;
	float4	pos;
	pos.xyz=IN.pos.xyz;
	pos.w=1.0;
	float4	tpos;
	tpos=mul(pos, MatrixWVP);
	OUT.pos=tpos;
	OUT.vposition=tpos;
	OUT.txcoord0=IN.txcoord0;	
	float3	wnormal=normalize(mul(IN.normal.xyz, MatrixWorld));
	float3	normal;
	normal.x=dot(wnormal.xyz, MatrixView[0]);
	normal.y=dot(wnormal.xyz, MatrixView[1]);
	normal.z=dot(wnormal.xyz, MatrixView[2]);
	OUT.viewnormal=normalize(normal.xyz);
	OUT.normal=normalize(mul(IN.normal.xyz, MatrixWVP));
	OUT.wnormal=wnormal;
	float3	campos=CameraPosition;
	OUT.eyedir=(mul(pos, MatrixWorld) - campos);
    return OUT;
}

////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////SA_DirectX/////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////


float LightingContrast
<
	string UIName="CarColor - Contrast";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.45};

float LightingSaturate
<
	string UIName="CarColor - Saturate";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.15};

////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////SA_DirectX/////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

float CarColor
<
	string UIName="CarColor - Brightness";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {0.75};


PS_OUTPUT3 PS_Draw(VS_OUTPUT IN, in float2 vpos : VPOS)
{
	float4	cd;
    float2  cd0 = IN.txcoord0.xy;
	float4  wx = WeatherAndTime;	
	float3	n0 = normalize(IN.normal.xyz);
	float3	wn = normalize(IN.wnormal.xyz);
	float3	ed = normalize(-IN.vposition.xyz);
	float3	wed = normalize(-IN.eyedir.xyz);
	float4	tex = tex2D(SamplerOriginal, cd0);
	float4	r0;
	float4	rfl;
	float2	rfl0;
	
	float4 fp1;
           fp1.xyz = diffColor*specColor*specColor.w*0.085;
           fp1.w = min(fp1.x, min(fp1.y, fp1.z));
           fp1.w = saturate(1.0-fp1.w);
           fp1.w*= fp1.w;
	cd.zw = 0.0;		
	cd.w = fp1.w*4.0;
		   
   float t0 = GameTime;
   float x1 = smoothstep(0.0, 4.0, t0);
   float x2 = smoothstep(4.0, 5.0, t0);
   float x3 = smoothstep(5.0, 6.0, t0);
   float x4 = smoothstep(6.0, 7.0, t0);
   float xE = smoothstep(8.0, 11.0, t0);
   float x5 = smoothstep(16.0, 17.0, t0);
   float x6 = smoothstep(18.0, 19.0, t0);
   float x7 = smoothstep(19.0, 20.0, t0);
   float xG = smoothstep(20.0, 21.0, t0);  
   float xZ = smoothstep(21.0, 22.0, t0);
   float x8 = smoothstep(22.0, 23.0, t0);
   float x9 = smoothstep(23.0, 24.0, t0); 	

   float opacity = saturate(tex.a*diffColor.a);
   float3 refl = reflect(ed, n0);	
	      rfl0.xy = (IN.vposition.xy /IN.vposition.w)*float2(0.5, -0.5) + 0.5;
	      rfl0.xy+= (refl.xy*float2(-1.0, 1.0)*0.5);	
	cd.xy = rfl0;
	float smix;
		  smix = saturate(wn.z)*saturate(-n0.z);
		  smix*= smix;	
//-------------------------------------
//-------------------------------------						
	cd.y = 1.0-((wn.z*0.5)+0.5);
	cd.x = 0.5;	
 	  		   
	float2 txcoord1;
	       txcoord1.xy = (IN.vposition.xy /IN.vposition.w)*float2(0.5, -0.5) + 0.5;
	       txcoord1.xy+= 0.5*float2(ScreenSize.y, ScreenSize.y*ScreenSize.z);		  	  
//-------------------------------------
//-------------------------------------	
    float3 sv0 = SunDirection.xyz;
    float3 sv1 = normalize(float3(0.0, 0.0, 0.0));

    float yy1 = smoothstep(0.0, 1.0, t0);	
    float yy2 = smoothstep(1.0, 23.0, t0);
    float yy3 = smoothstep(23.0, 24.0, t0);	
   
    float3 sv = lerp(sv1, sv0, yy1);
           sv = lerp(sv, sv0, yy2);
           sv = lerp(sv, sv1, yy3);  

    float4 tc = tex;	
    float4 tc2 = tex;		
    float4 gl0 = 1.0;
    float4 gl1 = 1.0;	
		
	float3 st5 = normalize(tc.xyz);
	float3 ct5 = tc.xyz/st5.xyz;
	       ct5 = pow(ct5, 9.0);
		   st5.xyz = pow(st5.xyz, -5.9);
	       tc.xyz = ct5*st5.xyz;
		
	float3 st6 = normalize(tc2.xyz);
	float3 ct6 = tc2.xyz/st6.xyz;
	       ct6 = pow(ct6, 8.0);
		   st6.xyz = pow(st6.xyz, 4.0);
	       tc2.xyz = ct6*st6.xyz;
		
	float3 nt = gl0.xyz*0.6;
	       nt.xyz = min(nt, gl0);
	float3 tr = gl0.xyz*(-3.0)/saturate(opacity + 0.02 + VehicleParameters1.y);
	       gl0.xyz = lerp(tr, nt, saturate(opacity+VehicleParameters1.y));
	float3 nt0 = gl1.xyz*0.0;
	       nt0.xyz = min(nt0, gl1);
	float3 tr0 = gl1.xyz*10.0/saturate(opacity + 0.02 + VehicleParameters1.y);
	       gl1.xyz = lerp(tr0, nt0, saturate(opacity+VehicleParameters1.y));

    float4 sc1 = specColor*1000.0;
    float4 sc2 = tex;
	float3 g2 = normalize(sc1.xyz);
	float3 g4 = normalize(sc2.xyz);
	float3 s2 = sc1.xyz/g2.xyz;
	float3 s4 = sc2.xyz/g4.xyz;
	       s2 = pow(s2, -15.0);
	       s4 = pow(s4, -34.0);
		   g4.xyz = pow(g4.xyz, 3.0);
	       sc2.xyz = s4*g4.xyz;
		   
	float mask0 = max(specColor.x, max(specColor.y, specColor.z));
	      mask0 = saturate(mask0*1000.0);				
	float mask2 = max(sc2.x, max(sc2.y, sc2.z));
	      mask2 = saturate(mask2);					
	float mask3 = max(tc.x, max(tc.y, tc.z));
	      mask3 = saturate(mask3);				
	float mask4 = max(tc2.x, max(tc2.y, tc2.z));
	      mask4 = saturate(mask4);						
	float mask5 = max(gl0.x, max(gl0.y, gl0.z));
	      mask5 = saturate(mask5);	
    float mask6 = max(gl1.x, max(gl1.y, gl1.z));	
		  mask6 = saturate(mask6*0.3)*1.0;				

    float3 sv3 = normalize(float3(0.0, 0.0, 1.0)+wed.xyz);   
    float3 sv2 = normalize(sv.xyz+wed.xyz);
    float3 sv4 = normalize(sv.xyz);

	 
	float3	specular=0.0;	
	for (int li=0; li<8; li++)
	{	 	 		 
		float3 sv5 = normalize(lightDirection[li].xyz);
		float specfact = saturate(dot(sv5, wn.xyz));
		      specfact = pow(specfact, 10.0);
		      specular+= saturate(lightDiffuse[li]-lightSpecular[li]) * specfact;		 
	}	
   
    float4 dc1 = diffColor;
	float3 st8 = normalize(dc1.xyz);
	float3 ct8=dc1.xyz/st8.xyz;
	       ct8=pow(ct8, LightingContrast);
		   st8.xyz = pow(st8.xyz, LightingSaturate);
	       dc1.xyz = ct8*st8.xyz;
		   	
    float gg = saturate(1.1*mask0*mask3*mask2*mask5)*1.0;
    float gg0 = saturate(10.0*mask0*mask4*mask5)*1.0;	
	
	float fadefact = (FogParam.w - IN.vposition.z) / (FogParam.w - FogParam.z);
	
	float nonlineardepth = (IN.vposition.z/IN.vposition.w)*1.0;	
	float3 ssnormal = normalize(IN.viewnormal);
	       ssnormal.yz = -ssnormal.yz;
		   
		   
   float amb0 = lerp(1.0, 1.0, x1);
         amb0 = lerp(amb0, 1.0, x2);
         amb0 = lerp(amb0, 0.2, x3);
         amb0 = lerp(amb0, 0.0, x4);
         amb0 = lerp(amb0, 0.0, xE);
         amb0 = lerp(amb0, 0.0, x5);
         amb0 = lerp(amb0, 0.2, x6);
         amb0 = lerp(amb0, 0.6, x7);
		 amb0 = lerp(amb0, 0.7, xG);
		 amb0 = lerp(amb0, 0.8, xZ);
         amb0 = lerp(amb0, 1.0, x8); 		   
		   
   float4 r5 = 0.0;		     			
          r5.xyz = CarColor*(dc1+ambColor)*tex;
		   
   float spc0 = lerp(1.0, 1.0, x1);
         spc0 = lerp(spc0, 1.0, x2);
         spc0 = lerp(spc0, 0.2, x3);
         spc0 = lerp(spc0, 0.0, x4);
         spc0 = lerp(spc0, 0.0, xE);
         spc0 = lerp(spc0, 0.0, x5);
         spc0 = lerp(spc0, 0.2, x6);
         spc0 = lerp(spc0, 0.6, x7);
		 spc0 = lerp(spc0, 0.7, xG);
		 spc0 = lerp(spc0, 0.8, xZ);
         spc0 = lerp(spc0, 1.0, x8); 	   
		   
           r5.xyz+= dc1*specular*tex*6.0*spc0;  // Ночное Освещение 1
           r5.xyz+= specular*tex*0.1*spc0;  // Ночное Освещение 2			   
		   //r5.xyz = diffColor;
		   
   float cc5x = lerp(0.2, 0.2, x1);
         cc5x = lerp(cc5x, 0.45, x2);
         cc5x = lerp(cc5x, 0.7, x3);
         cc5x = lerp(cc5x, 1.0, x4);
         cc5x = lerp(cc5x, 1.0, xE);
         cc5x = lerp(cc5x, 1.0, x5);
         cc5x = lerp(cc5x, 0.8, x6);
         cc5x = lerp(cc5x, 0.7, x7);
		 cc5x = lerp(cc5x, 0.6, xG);
		 cc5x = lerp(cc5x, 0.4, xZ);
         cc5x = lerp(cc5x, 0.2, x8); 		   
		   
           r5.xyz*= cc5x;

           r5.xyz = lerp(FogFarColor.xyz, r5.xyz, saturate(fadefact));		   
           r5.w = lerp(1.0, opacity, 1.0);		   
	float4 r1;
	       r1.xyz = ssnormal*0.5+0.5;
		   r1.w = lerp(0.98, 0.94, gg+gg0+mask6);	
		   
	float4 r2;	
	       r2.xyz = nonlineardepth;
	       r2.w = 1.0;
	PS_OUTPUT3	OUT;
	OUT.Color[0]=r5;
	OUT.Color[1]=r1;
	OUT.Color[2]=r2;
	return OUT;
}

////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////SA_DirectX/////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

technique Draw
{
    pass p0
    {
	VertexShader = compile vs_3_0 VS_Draw();
	PixelShader  = compile ps_3_0 PS_Draw();
	}
}

technique DrawTransparent
{
    pass p0
    {
	VertexShader = compile vs_3_0 VS_Draw();
	PixelShader  = compile ps_3_0 PS_Draw();
	}
}

