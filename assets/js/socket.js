// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()


let initChannel=socket.channel("initializationChannel",{})

function myFunction1()
{
  initChannel.push("initProcesses",{})
  console.log("Init")
}

$(document).ready(function() {
  myFunction1()
})

var nonceList=[]
var blockList=[1]
var transactionList=[1]

function generateNonceLabelList(labelListLength)
{
  var nonceLabelList=[]
  for(var i=0;i<labelListLength;i++)
  {
    nonceLabelList.push(i)
  }
  return nonceLabelList
}

function generateBlockLabelList(labelListLength)
{
  var blockLabelList=[0]
  for(var i=1;i<labelListLength;i++)
  {
    blockLabelList.push(i)
  }
  return blockLabelList
}

function generateTLabelList(labelListLength)
{
  var tLabelList=[0]
  for(var i=1;i<labelListLength;i++)
  {
    tLabelList.push(i)
  }
  return tLabelList
}

// Now that you are connected, you can join channels with a topic:
let channel=socket.channel("miningChannel",{})
let tChannel=socket.channel("transactionChannel",{})

var miningButton=document.getElementById("mineButton")
miningButton.onclick=function() {myFunction()};

var transactionButton=document.getElementById("transactionButton")
transactionButton.onclick=function() {transactionFunction()}

var nonceChart = document.getElementById("nonceChart");
var blockChart = document.getElementById("blockChart");
var transactionChart = document.getElementById("transactionChart");

function myFunction() 
{  
  var lastElement=blockList.pop()
  blockList.push(lastElement)
  blockList.push(lastElement+1)
  channel.push("startMining", {})
  console.log("Channel Push")
}

function transactionFunction()
{
  var sender=document.getElementById("sender")
  var receiver=document.getElementById("receiver")
  var amount=document.getElementById("amount")
  var fee=document.getElementById("fee")
  
  if(sender.value && receiver.value && amount.value && fee.value && sender.value!=receiver.value)
  {
    if((sender.value>0 && sender.value<=100) && (receiver.value>0 && receiver.value<=100))
    {
      if(fee.value>=0 && fee.value<5)
      {
        tChannel.push("transactionProcedure", {sender: parseInt(sender.value), receiver: parseInt(receiver.value), amount: parseInt(amount.value), fee: parseInt(fee.value)})
      }
      else
      {
        window.alert("Fee can take only 5 values which are 0,1,2,3,4")
      }
    }
    else
    {
      window.alert("Sender and Receiver values should be integers from 1 to 100.")
    }
  }
  else
  {
    window.alert("Please enter all the 4 fields. Also Sender and Receiver values should not be same.")
  }
}

channel.on("startMiningResponse", payload => {
  window.alert("Mining Completed and Block Received")
  var blockHeight=payload.output.blockHeight
  var currentBlockHash=payload.output.currentBlockHash
  var nonce=payload.output.nonce
  var processNumber=payload.output.miningProcess
  var transactions=payload.output.transactions

  var table=document.getElementById("blockTable")
  var row=table.insertRow(1)
  var cell0=row.insertCell(0)
  var cell1=row.insertCell(1)
  var cell2=row.insertCell(2)
  var cell3=row.insertCell(3)
  cell0.innerHTML=blockHeight
  cell1.innerHTML=currentBlockHash.toLowerCase()
  cell2.innerHTML=nonce
  cell3.innerHTML=processNumber
  
  var table1=document.getElementById("transactionTable")
  for(var k=0;k<transactions.length;k++)
  {
    var tRow=table1.insertRow(1)
    var tCell0=tRow.insertCell(0)
    var tCell1=tRow.insertCell(1)
    var tCell2=tRow.insertCell(2)
    var tCell3=tRow.insertCell(3)
    var tCell4=tRow.insertCell(4)
    tCell0.innerHTML=transactions[k].transactionID
    tCell1.innerHTML=transactions[k].type
    tCell2.innerHTML="-"
    tCell3.innerHTML=processNumber
    tCell4.innerHTML=25
  }

  nonceList.push(nonce)
  var nonceLabelList=generateNonceLabelList(nonceList.length)

  var myNonceChart = new Chart(nonceChart, {
    type: 'line',
    data: {
      labels: nonceLabelList,
      datasets: [{ 
          data: nonceList,
          label: "Nonce",
          borderColor: "#3e95cd",
          fill: false
        }
      ]
    },
    options: {
      title: {
        display: true,
        text: 'Nonce Value for each Block'
      },
      responsive:false,
    }
  });

  var blockLabelList=generateBlockLabelList(blockList.length)
  var myBlockChart = new Chart(blockChart, {
    type: 'line',
    data: {
      labels: blockLabelList,
      datasets: [{ 
          data: blockList,
          label: "Number of Blocks",
          borderColor: "#3e95cd",
          fill: false
        }
      ]
    },
    options: {
      title: {
        display: true,
        text: 'Number of Blocks mined till now'
      },
      responsive:false,
    }
  });

  var lastT=transactionList.pop()
  transactionList.push(lastT)
  lastT=lastT+1
  transactionList.push(lastT)
  
  var tLabelList=generateTLabelList(transactionList.length)
  var myTChart = new Chart(transactionChart, {
    type: 'line',
    data: {
      labels: tLabelList,
      datasets: [{ 
          data: transactionList,
          label: "Number of Blocks",
          borderColor: "#3e95cd",
          fill: false
        }
      ]
    },
    options: {
      title: {
        display: true,
        text: 'Number of Transactions till now'
      },
      responsive:false,
    }
  });
})

initChannel.on("initProcessesResponse", payload => {
  window.alert("Genesis Block Mined")
  var blockHeight=payload.output.blockHeight
  var currentBlockHash=payload.output.currentBlockHash
  var nonce=payload.output.nonce
  var processNumber=payload.output.miningProcess
  var transactions=payload.output.transactions

  var table=document.getElementById("blockTable")
  var row=table.insertRow(1)
  var cell0=row.insertCell(0)
  var cell1=row.insertCell(1)
  var cell2=row.insertCell(2)
  var cell3=row.insertCell(3)
  
  cell0.innerHTML=blockHeight
  cell1.innerHTML=currentBlockHash.toLowerCase()
  cell2.innerHTML=nonce
  cell3.innerHTML=processNumber
  
  var table1=document.getElementById("transactionTable")
  for(var k=0;k<transactions.length;k++)
  {
    var tRow=table1.insertRow(1)
    var tCell0=tRow.insertCell(0)
    var tCell1=tRow.insertCell(1)
    var tCell2=tRow.insertCell(2)
    var tCell3=tRow.insertCell(3)
    var tCell4=tRow.insertCell(4)
    tCell0.innerHTML=transactions[0]
    tCell1.innerHTML="coinbase"
    tCell2.innerHTML="-"
    tCell3.innerHTML=processNumber
    tCell4.innerHTML=25
  }

  nonceList.push(nonce)
  var nonceLabelList=generateNonceLabelList(nonceList.length)

  var myNonceChart = new Chart(nonceChart, {
    type: 'line',
    data: {
      labels: nonceLabelList,
      datasets: [{ 
          data: nonceList,
          label: "Nonce",
          borderColor: "#3e95cd",
          fill: false
        }
      ]
    },
    options: {
      title: {
        display: true,
        text: 'Nonce Value for each Block'
      },
      responsive:false,
    }
  });

  var tLabelList=generateTLabelList(transactionList.length)
  var myTChart = new Chart(transactionChart, {
    type: 'line',
    data: {
      labels: tLabelList,
      datasets: [{ 
          data: transactionList,
          label: "Number of Transactions",
          borderColor: "#3e95cd",
          fill: false
        }
      ]
    },
    options: {
      title: {
        display: true,
        text: 'Number of Transactions till now'
      },
      responsive:false,
    }
  });

  var blockLabelList=generateTLabelList(blockList.length)
  var myBlockChart = new Chart(blockChart, {
    type: 'line',
    data: {
      labels: blockLabelList,
      datasets: [{ 
          data: blockList,
          label: "Number of Blocks",
          borderColor: "#3e95cd",
          fill: false
        }
      ]
    },
    options: {
      title: {
        display: true,
        text: 'Number of Blocks mined till now'
      },
      responsive:false,
    }
  });

})

tChannel.on("transactionResponse", payload => {
  var answer=payload.output
  var tStatus=answer[4]
  if(tStatus=="notEnoughBalance")
  {
    window.alert("Invalid Transaction.")
  }
  else
  {
    var newBlock=answer[3]
    var transactions=newBlock.transactions

    var table=document.getElementById("blockTable")
    var row=table.insertRow(1)
    var cell0=row.insertCell(0)
    var cell1=row.insertCell(1)
    var cell2=row.insertCell(2)
    var cell3=row.insertCell(3)
  
    cell0.innerHTML=newBlock.blockHeight
    cell1.innerHTML=newBlock.currentBlockHash.toLowerCase()
    cell2.innerHTML=newBlock.nonce
    cell3.innerHTML=newBlock.miningProcess

    var table1=document.getElementById("transactionTable")
    for(var k=0;k<transactions.length;k++)
    {
      var tRow=table1.insertRow(1)
      var tCell0=tRow.insertCell(0)
      var tCell1=tRow.insertCell(1)
      var tCell2=tRow.insertCell(2)
      var tCell3=tRow.insertCell(3)
      var tCell4=tRow.insertCell(4)
      tCell0.innerHTML=transactions[k].transactionID
      tCell1.innerHTML=transactions[k].type
      if(transactions[k].type=="coinbase")
      {
        tCell2.innerHTML="-"
        tCell3.innerHTML=newBlock.miningProcess
        tCell4.innerHTML=25
      }
      else
      {
        tCell2.innerHTML=answer[0]
        tCell3.innerHTML=answer[1]
        tCell4.innerHTML=answer[2]
      }
    }

    nonceList.push(newBlock.nonce)
    var nonceLabelList=generateNonceLabelList(nonceList.length)

    var myNonceChart = new Chart(nonceChart, {
      type: 'line',
      data: {
        labels: nonceLabelList,
        datasets: [{ 
          data: nonceList,
          label: "Nonce",
          borderColor: "#3e95cd",
          fill: false
          }
        ]
      },
      options: {
        title: {
          display: true,
          text: 'Nonce Value for each Block'
        },
        responsive:false,
      }
    });

    
    var lastT=transactionList.pop()
    transactionList.push(lastT)
    lastT=lastT+transactions.length
    transactionList.push(lastT)
    var tLabelList=generateTLabelList(transactionList.length)
    


    var myTChart = new Chart(transactionChart, {
    type: 'line',
    data: {
      labels: tLabelList,
      datasets: [{ 
          data: transactionList,
          label: "Number of Transactions",
          borderColor: "#3e95cd",
          fill: false
        }
      ]
    },
      options: {
        title: {
          display: true,
          text: 'Number of Transactions till now'
        },
        responsive:false,
      }
    });


    var blockNum=blockList.pop()
    blockList.push(blockNum)
    blockNum=blockNum+1
    blockList.push(blockNum)
    var blockLabelList=generateTLabelList(blockList.length)

    var myBlockChart = new Chart(blockChart, {
      type: 'line',
      data: {
        labels: blockLabelList,
        datasets: [{ 
            data: blockList,
            label: "Number of Blocks",
            borderColor: "#3e95cd",
            fill: false
          }
        ]
      },
        options: {
          title: {
            display: true,
            text: 'Number of Blocks mined till now'
          },
          responsive:false,
        }
    });
  }
})

channel.join()
  .receive("ok", resp => { console.log("Mining Channel joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join mining channel", resp) })


initChannel.join()
  .receive("ok", resp => { console.log("Init Channel joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join init channel", resp) })

tChannel.join()
  .receive("ok", resp => { console.log("Transaction Channel joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join transaction channel", resp) })

  
export default socket