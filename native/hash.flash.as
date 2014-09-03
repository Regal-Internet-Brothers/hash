
class external_hash
{
	// Functions:
	public static function Lsr(data:Number, shiftBy:Number):Number
	{
		return (data >>> shiftBy);
	}
	
	public static function Lsl(data:Number, shiftBy:Number):Number
	{
		return (data << shiftBy);
	}
}
