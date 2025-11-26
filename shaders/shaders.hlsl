cbuffer ConstantBuffer: register(b0)
{
    float4x4 mwpMatrix;
    float4x4 worldMatrix;
    float4 lightPosition;
    float4 lightColor;
    float4 cameraPosition;
}

struct PSInput
{
    float4 position : SV_POSITION;
    float3 worldPos : POSITION0;
    float3 normal : NORMAL;
    float3 ambient : COLOR0;
    float3 diffuse : COLOR1;
    float3 emissive : COLOR2;
};

PSInput VSMain(float4 position : POSITION, float3 normal: NORMAL, float3 ambient : COLOR0, float3 diffuse : COLOR1, float3 emissive : COLOR2)
{
    PSInput result;
    result.position = mul(mwpMatrix, position);
    
    // Transform position and normal to world space
    float4 worldPos4 = mul(worldMatrix, position);
    result.worldPos = worldPos4.xyz;
    
    // Transform normal to world space (using inverse transpose for proper normal transformation)
    float3x3 normalMatrix = (float3x3)worldMatrix;
    result.normal = normalize(mul(normal, normalMatrix));
    
    result.ambient = ambient;
    result.diffuse = diffuse;
    result.emissive = emissive;
    
    return result;
}

float4 PSMain(PSInput input) : SV_TARGET
{
    // Phong lighting calculation
    float3 N = normalize(input.normal);
    float3 L = normalize(lightPosition.xyz - input.worldPos);
    float3 V = normalize(cameraPosition.xyz - input.worldPos);
    float3 R = reflect(-L, N);
    
    // Ambient component
    float3 ambient = input.ambient * 0.2f;
    
    // Diffuse component
    float NdotL = max(dot(N, L), 0.0f);
    float3 diffuse = input.diffuse * lightColor.rgb * NdotL;
    
    // Specular component
    float RdotV = max(dot(R, V), 0.0f);
    float shininess = 32.0f;
    float3 specular = lightColor.rgb * pow(RdotV, shininess) * 0.5f;
    
    // Emissive component
    float3 emissive = input.emissive;
    
    // Combine all components
    float3 finalColor = ambient + diffuse + specular + emissive;
    
    return float4(finalColor, 1.0f);
}