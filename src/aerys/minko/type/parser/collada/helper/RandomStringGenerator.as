package aerys.minko.type.parser.collada.helper
{
	public class RandomStringGenerator
	{
		private static const DEFAULT_ALPHABET : String = 
			"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		
		public static function generateRandomString(newLength		: uint		= 12, 
													userAlphabet	: String	= null) : String
		{
			var alphabet		: String	= userAlphabet || DEFAULT_ALPHABET;
			var alphabetLength	: int		= alphabet.length;
			var randomLetters	: String	= "";
			
			for (var i : uint = 0; i < newLength; ++i)
				randomLetters += alphabet.charAt(int(Math.random() * alphabetLength));
			
			return randomLetters;
		}
	}
}
