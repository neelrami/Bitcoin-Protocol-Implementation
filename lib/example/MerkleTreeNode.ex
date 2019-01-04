defmodule Example.MerkleTreeNode do

    @type t :: %__MODULE__{
        value: String.t,
        children: [MerkleTreeNode.t],
        height: integer
    }

    defstruct [ :value, :children, :height] 
end