defmodule Example.Block do
    alias Example.{Block,Transactions}

    @target :binary.decode_unsigned (<<
        0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    >>)

    @type t :: %__MODULE__{
        miningProcess: integer,
        blockHeight: integer,
        previousBlockHash: String.t(),
        currentBlockHash: String.t(),
        merkleRoot: String.t(),
        timestamp: integer,
        nonce: integer,
        transactionCounter: integer,
        transactions: [Transactions.t]
    }
    
    defstruct [ :miningProcess, :blockHeight, :previousBlockHash, :currentBlockHash, :merkleRoot, :timestamp, :nonce, :transactionCounter, :transactions]

    def genesisBlock() do
        %Block{
            miningProcess: 1,
            blockHeight: 0,
            previousBlockHash: "0",
            currentBlockHash: "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
            merkleRoot: "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b",
            timestamp: 1231006505,
            nonce: 208,
            transactionCounter: 1,
            transactions: ["4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b"]
        }
    end

    def createString(nextIndex, previousBlockHash, merkleRoot, timestamp) do
        myString=Integer.to_string(nextIndex)<>previousBlockHash<>merkleRoot<>Integer.to_string(timestamp)
        myString
    end

    def blockHeaderHash(currentBlock) do
        blockHeight=currentBlock.blockHeight
        previousBlockHash=currentBlock.previousBlockHash
        merkleRoot=currentBlock.merkleRoot
        timestamp=currentBlock.timestamp
        nonce=currentBlock.nonce
        myString=createString(blockHeight,previousBlockHash,merkleRoot,timestamp)
        blockHeaderString=myString<>Integer.to_string(nonce)
        :crypto.hash(:sha256,blockHeaderString) |> Base.encode16()
    end

    def getLatestBlock(myState) do
        blockchain=Enum.at(myState,1)
        recentBlock=Enum.at(blockchain,-1)
        recentBlock
    end

    def verifyProofOfWork(currentBlock) do
        {hashInt,_}=Integer.parse(currentBlock.currentBlockHash,16)
        myVar=if(hashInt<@target) do
            true
        else
            false
        end
        myVar
    end

    def verifyHash(currentBlock) do
        myVar=if(currentBlock.currentBlockHash==blockHeaderHash(currentBlock)) do
            true
        else
            false
        end
        myVar
    end

    def generateBlock(index,pbh,mr,ts,cbh,t,n) do
        %Block{
            blockHeight: index,
            previousBlockHash: pbh,
            currentBlockHash: cbh,
            merkleRoot: mr,
            timestamp: ts,
            nonce: n,
            transactionCounter: length(t),
            transactions: t
        }
    end

    def proofOfWork(blockHeaderString, nonce) do
        if(nonce>:math.pow(2,32)) do
            {"notFound",nonce}
        else
            blockString=blockHeaderString<>Integer.to_string(nonce)
            blockHeaderHash=:crypto.hash(:sha256,blockString) |> Base.encode16()
            {hashInt,_}=Integer.parse(blockHeaderHash,16)
                #IO.inspect(hashInt)
            if(hashInt < @target) do
                #IO.inspect("true")
                {blockHeaderHash,nonce}
            else
                #IO.inspect("false")
                proofOfWork(blockHeaderString,nonce+1)
            end
        end
    end
end