defmodule Example.MerkleTree do
    alias Example.{MerkleTree,MerkleTreeNode}
    
    @type transactions :: [String.t(), ...]
    
    @type root :: MerkleTreeNode.t
    
    @type t :: %__MODULE__{
        transactions: transactions,
        root: root
    }

    defstruct [:transactions, :root]

    def new(transactions) when transactions != [] do
        root = build(transactions)
        
        %MerkleTree{
            transactions: transactions, 
            root: root
        }
    end

    def build(transactions) do
        starting_height = 0
        leaves = Enum.map(transactions, fn(transactions) ->
          %MerkleTreeNode{
            value: :crypto.hash(:sha256,transactions),
            children: [],
            height: starting_height
          }
        end)
        _build(leaves,starting_height)
    end
    
    defp _build([root], _), do: root 
    
    defp _build(nodes, previous_height) do 
        children_partitions = Enum.chunk_every(nodes, 2)
        height = previous_height+1
        parents = Enum.map(children_partitions, fn(partition) ->
          concatenated_values = partition
            |> Enum.map(&(&1.value))
            |> Enum.reduce("", fn(x, acc) -> acc <> x end)
          %MerkleTreeNode{
                value: :crypto.hash(:sha256, concatenated_values),
                children: partition,
                height: height
            }
        end)
        _build(parents, height)
    end
end