/*
	Functions used throughout the Comfysim scripts will be stored here as a central repository / include.
*/

forward Float:GetDistBetweenTwoPoints(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2);
public Float:GetDistBetweenTwoPoints(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2)
{
	return floatsqroot(floatpower(floatabs(floatsub(x, x2)),2)+floatpower(floatabs(floatsub(y, y2)),2)+floatpower(floatabs(floatsub(z, z2)),2));
}
