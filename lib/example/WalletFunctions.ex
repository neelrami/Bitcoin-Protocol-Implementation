defmodule Example.WalletFunctions do
  
    alias Example.{Base58Check}
    @upperBoundPrivateKey :binary.decode_unsigned(<<
      0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
      0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE,
      0xBA, 0xAE, 0xDC, 0xE6, 0xAF, 0x48, 0xA0, 0x3B,
      0xBF, 0xD2, 0x5E, 0x8C, 0xD0, 0x36, 0x41, 0x41
    >>)
  
    _privateKeyList=[]
    
    def generatePrivateKey() do
      pvKey=:crypto.strong_rand_bytes(32)

      finalPVKey = case checkValidity(pvKey) do
        true -> pvKey
        false -> generatePrivateKey()
      end
  
      finalPVKey
    end
  
    def generatePublicKey(privateKey) do
        :crypto.generate_key(:ecdh,:crypto.ec_curve(:secp256k1),privateKey) |> elem(0)
    end
  
    def generatePublicAddress(privateKey) do
        generatePublicKey(privateKey) |> hashFunction(:sha256) |> hashFunction(:ripemd160) |> Base58Check.encode(<<0x00>>)
    end

    def checkValidity(key) do
        key |> :binary.decode_unsigned() |> valid() 
    end
    
    def valid(key) when key > 1 and key < @upperBoundPrivateKey, do: true
        
    def valid(_), do: false
      
    def hashFunction(msg,algorithm) do
        :crypto.hash(algorithm,msg)
    end

    def wifPrivateKey(privateKey) do
        myString="80"<>Base.encode16(privateKey)
        checkSum=myString |> hashFunction(:sha256) |> hashFunction(:sha256) |> String.slice(0..3)
        myString=myString<>checkSum
        Base58Check.encode(myString,<<0x00>>)
    end
end