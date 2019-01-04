defmodule Example.Wallet do
  alias Example.{Wallet,UTXO,Transactions}
  
  @type t :: %__MODULE__{
    privateKey: String.t(),
    publicKey: String.t(),
    publicAddress: String.t()
  }

  defstruct [ :privateKey, :publicKey, :publicAddress]

  @spec generateWallet() :: t
  def generateWallet() do
    myPrivateKey=Example.WalletFunctions.generatePrivateKey()
    myPublicKey=Example.WalletFunctions.generatePublicKey(myPrivateKey)
    myPublicAddress=Example.WalletFunctions.generatePublicAddress(myPrivateKey)
    
    %Wallet{
      privateKey: Base.encode16(myPrivateKey),
      publicKey: Base.encode16(myPublicKey),
      publicAddress: myPublicAddress
    }
  end

  def sign(myState,myMessage) do
    myPrivateKey=Enum.at(myState,2).privateKey
    signature=:crypto.sign(:ecdsa, :sha256, myMessage, [Base.decode16!(myPrivateKey), :secp256k1])
    Base.encode16(signature)
  end

  def verify(myState, myMessage, signature) do
    myPublicKey=(Enum.at(myState,2)).publicKey
    decodedSignature=Base.decode16!(signature)
    decodedPublicKey=Base.decode16!(myPublicKey)
    :crypto.verify(:ecdsa, :sha256, myMessage, decodedSignature, [decodedPublicKey, :secp256k1])
  end

  def send(myState,receiverList,amountList,transactionFee) do
    myPublicAddress=Enum.at(myState,2).publicAddress
    totalAmount=Enum.reduce(amountList, fn x, acc -> x + acc end)+transactionFee
    myUTXOList=Enum.at(myState,3)
    myList=UTXO.selectUTXO(myUTXOList,totalAmount)
    selectedUTXOList=Enum.at(myList,0)

    emptyFlag=Enum.empty?(selectedUTXOList)

    newUTXOList=Enum.at(myList,1)

    if(emptyFlag==true) do
      ["notEnoughBalance",[],[]]
    else

      prevTIDList=for i <- 1..length(selectedUTXOList) do
        myUTXO=Enum.at(selectedUTXOList,i-1)
        myUTXO.transactionID
      end

      prevVList=for i <- 1..length(selectedUTXOList) do
        myUTXO=Enum.at(selectedUTXOList,i-1)
        myUTXO.index
      end
      
      myBalance=UTXO.calculateBalance(myUTXOList)
      myList=if(totalAmount==myBalance) do
        [length(receiverList),receiverList,amountList]
      else
        [length(receiverList)+1,receiverList++[myPublicAddress],amountList++[(myBalance-totalAmount)]]
      end
      newTX=Transactions.createTransaction(myState,length(selectedUTXOList),Enum.at(myList,0),prevTIDList,prevVList,Enum.at(myList,1),Enum.at(myList,2),transactionFee)
      myNewState=[Enum.at(myState,0),Enum.at(myState,1),Enum.at(myState,2),newUTXOList,Enum.at(myState,4),Enum.at(myState,5)]
      ["ok",newTX,myNewState]
    end
  end
end