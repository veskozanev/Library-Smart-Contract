// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract Library {

    // Book structure
    struct book {
        uint bookId; // book ID
        string title; // book title
        uint copies; // book copies
        uint curentReaders; // the count of current borrowers
        address[] borrowersAllTime; // Arrays for iteration
        mapping(address => bool) curentBorrowers; // Mapping for lookups 
    }

    // Events
    event NewBookAdded(string name, uint id);
    event NewCopiesAdded(uint copies, uint id);
    event BorrowBook(string name, uint id, address borrower);
    event ReturnBook(string name, uint id, address borrower);
    
    // Library administrator
    address private administrator;

    // Number of all books available to borrow
    book[] public books;

    // When the contract is created, the creator address is assigned as administrator.
    constructor() {
        administrator = msg.sender;
    }

    // Modifier to check if sender is administrator
    modifier Administrator() {
        assert(msg.sender == administrator);
        _;
    }

    // Add book in library
    function addNewBook(string memory title, uint copies) public Administrator {
        
        // Current count of books
        uint count = books.length;

        // Push new empty book object
        books.push();

        // Access the empty book object
        book storage b = books[count];
        
        // Set new book properties
        b.bookId = count;
        b.title = title;
        b.copies = copies;
        b.curentReaders = 0;
        b.borrowersAllTime = new address[](0);
        
        // Emit event after success
        emit NewBookAdded(title, copies);
    }

    // Add copies to a book
    function addNewCopies(uint bookId, uint copies) public Administrator {
        
        // Require that there is a book with a such id
        require(bookId >= 0 && bookId < books.length, "Book not in library!");

        // Require that there are copies
        require(copies > 0, "Add copies to the library");

        books[bookId].copies+=copies;

        // Emit event after success
        emit NewCopiesAdded(copies, bookId);
    }

    // Borrow a book
    function borrow(uint bookId) public {
        
        // Require that there is a book with a such id
        require(bookId >= 0 && bookId < books.length, "Book not in library!");

        // Book must be available
        require(books[bookId].curentReaders < books[bookId].copies, "Not available copies!");
        
        // Sender should not borrow more than one copy
        require(!books[bookId].curentBorrowers[msg.sender], "You have alreade borrowed the book!");

        // Add sender to curent borrowers 
        books[bookId].curentBorrowers[msg.sender] = true;
        books[bookId].curentReaders++;

        // Add sender to all-time borrowers
        books[bookId].borrowersAllTime.push(msg.sender);

        // Emit event for success
        emit BorrowBook(books[bookId].title, bookId, msg.sender);
    }
    
    // Return book
    function returnBook(uint bookId) public {
        // Validate bookId is within array
        require(bookId >= 0 && bookId < books.length, "Book not in library!");

        // Require that sender once borrowed the book
        require(books[bookId].curentBorrowers[msg.sender]);

        // Require that sender is curently having the book
        require(books[bookId].curentBorrowers[msg.sender] == true);


        // Remove the sender as borrower
        books[bookId].curentBorrowers[msg.sender] = false;
        books[bookId].curentReaders--;
        
        // Return Success
        emit ReturnBook(books[bookId].title, bookId, msg.sender);
    }

    // Show available books
    function availableBooks() public view returns (uint[] memory) {
       
        // Get total amount of books 
        uint count = books.length;

        // Create an array for available books
        uint[] memory allAvailableBooks = new uint[](count);    

        // Loop through all books and find all available 
        for(uint index = 0; index < count; index++){

            // If copies > readers = book is available
            if(books[index].copies > books[index].curentReaders) {

                // Save available book in tha array
                allAvailableBooks[index] = index; 
            }
        }

        // Return result
        return allAvailableBooks;
    }

    // People who borrowed a specific book
    function borrowers(uint bookId) public view returns(address[] memory) {

        // Validate bookId is within array
        require(bookId >= 0 && bookId < books.length, "Book not in library!");
        
        // Return all time borrowers
        return books[bookId].borrowersAllTime;
    }

}

