
class external_hash
{
	// Functions:
	public static int Lsr(int data, int shiftBy)
	{
		return (int)((uint)data >> shiftBy);
	}
	
	public static int Lsl(int data, int shiftBy)
	{
		return (int)((uint)data << shiftBy);
	}
}
