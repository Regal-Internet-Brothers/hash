
class external_hash
{
	public:
		// Functions:
		static int Lsr(int data, int shiftBy)
		{
			return (int)((unsigned int)data >> shiftBy);
		}
		
		static int Lsl(int data, int shiftBy)
		{
			return (int)((unsigned int)data << shiftBy);
		}
	private:
		// Nothing so far.
};
