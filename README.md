Collateralized Loan Web App
This is a web app that allows users to request and fund loans using ERC721 tokens as collateral.

How to use the app
Install a web3 wallet like MetaMask on your browser.
Connect your wallet to the Ethereum network.
Open index.html in your browser.
The web app will load available assets from the smart contract and display them in a list.
To request a loan, fill in the form with the collateral asset ID, loan amount, interest rate and due date, and click "Request Loan". This will trigger a transaction that creates a new loan request on the smart contract. The loan terms will be displayed in a list.
To fund a loan, fill in the form with the loan ID and loan amount, and click "Fund Loan". This will trigger a transaction that transfers ETH to the loan and marks it as funded.
Your active loans will be displayed in a list.
How the app works
The app uses a Solidity smart contract to manage loans. The contract allows users to request loans by depositing ERC721 tokens as collateral. Other users can fund these loans by sending ETH to the contract. The borrower must repay the loan with interest by a specified due date, or the collateral asset will be transferred to the lender. If the borrower repays the loan on time, the collateral asset will be returned to them.

The app is built using HTML and JavaScript with the web3.js library. web3.js allows the app to interact with the smart contract on the Ethereum network. The app uses web3.js to call functions on the smart contract, retrieve data from it, and display it on the webpage.

The app has four main sections:

Available Assets: This section displays the ERC721 tokens that are available to be used as collateral. It retrieves this data by calling the getAvailableAssets() function on the smart contract using web3.js, and displays it on the webpage as a list.

Request Loan: This section allows users to request a loan by filling in a form with the collateral asset ID, loan amount, interest rate, and due date. When the user clicks "Request Loan", the app triggers a transaction that calls the requestLoan() function on the smart contract using web3.js. The function creates a new loan request with the specified terms and emits a LoanRequested event that contains the loan ID. The app displays the loan terms in a list.

Fund Loan: This section allows users to fund a loan by filling in a form with the loan ID and loan amount. When the user clicks "Fund Loan", the app triggers a transaction that calls the fundLoan() function on the smart contract using web3.js. The function transfers the specified amount of ETH to the loan and marks it as funded, and emits a LoanFunded event that contains the loan ID. The app displays the funded loan in a list.

My Loans: This section displays the loans that the current user has borrowed or funded. It retrieves this data by calling the getMyLoans() function on the smart contract using web3.js, and displays it on the webpage as a list.
