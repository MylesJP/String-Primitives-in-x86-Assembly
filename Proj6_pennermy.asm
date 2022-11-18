TITLE String Primivitves and Macros    (Proj6_pennermy.asm)

; Author: Myles Penner
; Last Modified: August 11, 2022
; OSU email address: pennermy@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                 Due Date: August 12, 2022
; Description: This program will prompt the user for signed integers and process them as strings to display the numbers, the sum, and the truncated average
;					- It will use macros to collect a ASCII string input and a procedure to convert it to a signed integer value and validate the input
;					- A procedure will convert the numeric value back to an ASCII string for output
;					- The program also numbers the valid input lines and displays a running sum of the numbers

INCLUDE Irvine32.inc

;------------------------------------------------------------------------------------------------------------------
; Name: mGetString
;
; Displays a prompt and reads a user-entered value to memory as a string
;
; Preconditions:
;	Irvine32.inc must be present
; Receives:
;	userPrompt = the prompt to display before the user inputs a value
;	numCount = the number of signed integers the user is to enter (10, in this case)
;	inputArray = the blank initialized array to store the user-enter integers
;	numCharsEntered = the variable to store the number of bytes of user input
;	
; Returns:
;	inputStrArray = a SWORD array of user-enter values
;	numCharsEntered = the number of digits of the user input
;------------------------------------------------------------------------------------------------------------------
mGetString MACRO	userPrompt, maxSize, inputStrArray, numCharsEntered

	PUSH	EAX
	PUSH	ECX
	PUSH	EDX

	MOV		EDX, userPrompt
	CALL	WriteString				; Prompts the user
	MOV		ECX, maxSize			; The buffer size indicating the maximum number of character the user is allowed
	MOV		EDX, inputStrArray		; The blank array to store the user input string
	CALL	ReadString				; Stores the user input values in EDX and the number of characters in EAX
	MOV		numCharsEntered, EAX	; Stores the number of characters entered in numCharsEntered variable
	
	POP		EAX
	POP		ECX
	POP		EDX

ENDM

;------------------------------------------------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints out string passed in as parameter
;
; Preconditions:
;	Irvine32.inc must be present
; Receives:
;	stringForPrint = the string to be printed as output
; Returns:
;	stringForPrint printed as output
;------------------------------------------------------------------------------------------------------------------
mDisplayString	MACRO	stringForPrint

	PUSH	EDX
	MOV		EDX, stringForPrint
	CALL	WriteString
	POP		EDX

ENDM

ARRAY_SIZE = 10			; Constant for the 10 integers required from the user to store in an array
MAX_CHARS = 11			; Constant for the maximum allowable characters the user is allowed to enter
BUFFER_SIZE = 13		; Constant for the buffer size of the user input - larger than allowable to catch overflow
MAX_NUM = 2147483647	; Constant for the highest value for 32 bit integer
MIN_NUM = -2147483647	; Constant for lowest value for 32 bit integer
NULL = 0				; Use to terminate strings after conversion
SPACE = 32


.data

progTitle		BYTE	"Programming Assignment 6: Designing Low-Level I/O Procedures",13,10,
						"Written by: Myles Penner",13,10,13,10,0
introText		BYTE	"Please provide 10 signed decimal integers.",13,10,
						"Each number needs to be small enough to fit inside a 32 bit register. When you are done,",13,10,
						"I will display a list of the integers, their sum, and their average value.",13,10,13,10,0
extraCredit		BYTE	"**EC: Number each line of user input and display running subtotal of valid inputs",13,10,13,10,0
prompt			BYTE	" Please enter a signed number: ",0
error			BYTE	"ERROR: You did not enter a signed number or your number was too big.",13,10,0
youEntered		BYTE	13,10,"You entered the following numbers:",13,10,0
subtotalText	BYTE	"Subtotal: ",0
commaSpace		BYTE	", ",0
sumNums			BYTE	13,10,13,10,"The sum of these numbers is: ",0
avgNums			BYTE	13,10,13,10,"The truncated average is: ",0
goodbye			BYTE	13,10,13,10,"Thanks for playing!",13,10,0

stringArray		BYTE	ARRAY_SIZE	DUP(?)			; The array of raw user input strings of length ARRAY_SIZE
rawInputString	BYTE	13	DUP(?)					; The raw user input for validation of length 13 to catch overflow
integerArray	SDWORD	ARRAY_SIZE  DUP(?)			; The array of 10 SDWORDS after conversion
isNeg			DWORD	?							; Will be set to 1 if the first character is a negative sign
numChars		DWORD	?							; The number of characters the user entered for each integer
displayString	BYTE	4 DUP(?)					; The displayed string array of size 4 Bytes
intSum			SDWORD	0							; A variable to store the sum from CalcSum procedure
lineCount		DWORD	1							; Variable for counting lines, initialized to 1


.code
main PROC

	mDisplayString	OFFSET progTitle	; Display the title of the program
	mDisplayString	OFFSET introText	; Provide instruction to the user
	mDisplayString	OFFSET extraCredit  ; Extra credit #1 description

	; ReadVal procedure
	PUSH	lineCount					; EBP + 44
	PUSH	OFFSET displayString		; EBP + 40
	PUSH	OFFSET subtotalText			; EBP + 36
	PUSH	intSum						; EBP + 32
	PUSH	OFFSET numChars				; EBP + 28
	PUSH	OFFSET integerArray			; EBP + 24
	PUSH	OFFSET isNeg				; EBP + 20
	PUSH	OFFSET rawInputString		; EBP + 16
	PUSH	OFFSET prompt				; EBP + 12
	PUSH	OFFSET error				; EBP + 8
	CALL	ReadVal


	mDisplayString	OFFSET youEntered	; Prints "You entered the following numbers:"
	; DisplayArray procedure for displaying the array
	PUSH	OFFSET commaSpace			; EBP + 16
	PUSH	OFFSET integerArray			; EBP + 12
	PUSH	OFFSET displayString		; EBP + 8
	CALL	DisplayArray


	mDisplayString	OFFSET sumNums		; Prints "The sum of the numbers is:"
	; CalcSum procedure for displaying the sum
	PUSH	OFFSET intSum				; EBP + 16
	PUSH	OFFSET integerArray			; EBP + 12
	PUSH	OFFSET displayString		; EBP + 8
	CALL	CalcSum


	mDisplayString	OFFSET avgNums		; Prints "The truncated average is:"
	; CalcAverage procedure for displaying truncated average
	PUSH	intSum						; EBP + 12
	PUSH	OFFSET displayString		; EBP + 8
	CALL	CalcAverage

	mDisplayString	OFFSET goodbye		; Prints "Thanks for playing!"

	Invoke ExitProcess,0	; exit to operating system

main ENDP


;------------------------------------------------------------------------------------------------------------------
; Name: ReadVal
;
; This procedure prompts the user for an input as a string, reads the user input and converts it a signed integer value.
;
; Preconditions:
;	mDisplayString macro must be present
; Postconditions:
;	None.
; Receives:
;	lineCount [EBP + 44] - the current line count
;	displayString [EBP + 40] - the blank string used by WriteVal to display characters
;	subtotalText [EBP + 36] - "Subtotal:"
;	intSum [EBP + 32] - the running total of value sums
;	numChars [EBP + 28] - the number of characters the user entered
;	integerArray [EBP + 24] - a blank array of SDWORDS to hold the converted values
;	isNeg [EBP + 20] - a flag to determine if the input value is negative
;	rawInputString [EBP + 16] - a string representing the user input
;	prompt [EBP + 12] - a prompt for the user to enter a value
;	error [EBP + 8] - an error message for the user
; Returns:
;	integerArray [EBP + 24] - an array of signed int values after conversion
;------------------------------------------------------------------------------------------------------------------
ReadVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDI
	PUSH	ESI
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX

	MOV		EDI, [EBP + 24]
	MOV		ECX, ARRAY_SIZE		; Main counter to count the number of integers the user is to enter

_userPrompt:
	PUSH	ECX					; Preserve the main counter, ECX will be used as a sub counter within this routine
	MOV		EAX, 0				; Reset the negative indicator back to 0 (non-negative)
	MOV		[EBP + 20], EAX
	PUSH	[EBP + 44]
	PUSH	[EBP + 40]
	CALL	WriteVal			; Write the current line number
	mGetString	[EBP + 12], BUFFER_SIZE, [EBP + 16], [EBP + 28]
	MOV		EDX, [EBP + 16]
	MOV		EAX, [EBP + 28]
	MOV		ECX, [EBP + 28]		; The number of chars in user input to ECX counter
	MOV		ESI, [EBP + 16]		; Put the input string in ESI to perform validation
	
; First step is to check the sign of the number
_checkNegative:
	; Check the first character in the string for ASCII 45 (-)
	LODSB						; Loads current value in ESI to AL
	CMP		AL, 45
	JE		_isNegative			; First character is a - sign
	CMP		AL, 43
	JE		_remPlusSign		; First character is a + sign, need to remove that before conversion
	JMP		_validation			; If first 

_isNegative:
	MOV		EBX, 1
	MOV		[EBP + 20], EBX
	DEC		ECX					; Reduce digit count by 1 since the + sign doesn't count
	JMP		_nextDigit

_remPlusSign:
	DEC		ECX					; Reduce digit count by 1 since the + sign doesn't count
	JMP		_nextDigit

_nextDigit:
	LODSB						; Increments ESI to the next char if first char is + or - and stores in AL
	JMP		_validation

; Now that we know the sign, loop through the characters to make sure they are digits
_validation:
	MOV		EBX, [EBP + 28]		; Check if the user entered too many characters for 32 bit number
	CMP		EBX, 11
	JA		_invalidInput
	CMP		AL, 48
	JB		_invalidInput
	CMP		AL, 57
	JA		_invalidInput
	JMP		_convertToInt

_invalidInput:
	mDisplayString	[EBP + 8]	; Print out the error string stored at EBP + 8
	POP		ECX
	MOV		EAX, 0
	MOV		[EDI], EAX			; If invalid input, clear the invalid number from [EDI]
	JMP		_userPrompt

_convertToInt:
	MOV		EBX, [EDI]	
	PUSH	EAX					; Preserve AL which holds the current string character
	PUSH	EBX					; Preserve previous value in EBX

; Method of converting ASCII to integer:
;	1. Subtract 48 from ASCII to get decimal number
;	2. Move the result to EDI and multiply by 10
;	3. Next digit, subtract 48 and add to EDI
;	4. Multiply result by 10 and repeat the process until end of the string
;	- Each iteration shifts the number to the left and adds a digit to the 1's place
	MOV		EAX, EBX			; Move previous value to EAX
	MOV		EBX, 10
	MUL		EBX					; Multiply previous value by 10
	MOV		[EDI], EAX			; Move the 10x value to the destination array
	POP		EBX					
	POP		EAX
	JO		_invalidInput		; Check for overflow, if so, error

	SUB		AL, 48				; Subtract the ASCII offset to get the decimal value
	ADD		[EDI], AL			; Add the result to current position of EDI
	JC		_invalidInput		; Check for carry, if so, error

; Check if we are at the end of the string, if so, next digit, else, negate the number if required
	DEC		ECX
	CMP		ECX, 0
	JA		_nextDigit			; If not at the end of the number, next digit
	PUSH	EAX
	MOV		EAX, [EBP + 20]		; Check if the negative flag variable is set
	CMP		EAX, 1
	JE		_addNegative
	JMP		_addToSubtotal

; Negates the number is the isNeg variable is set to 1
_addNegative:
	MOV		EAX, [EDI]
	NEG		EAX		
	MOV		[EDI], EAX
	JMP		_addToSubtotal

; Subtotal calculations for EC#1
_addToSubtotal:
	MOV		EAX, [EDI]			; Move current value to EAX
	ADD		[EBP + 32], EAX		; Add EAX to the running sum
	mDisplayString [EBP + 36]	
	MOV		EBX, [EBP + 32]
	PUSH	EBX
	PUSH	[EBP + 40]
	CALL	WriteVal			; Write the subtotal as a string
	CALL	CrLf

; Jumps to the next iteration of string input and processing
_nextElement:
	POP		EAX
	ADD		EDI, 4				; Next element in array

	PUSH	EAX
	MOV		EAX, [EBP + 44]
	INC		EAX
	MOV		[EBP + 44], EAX
	POP		EAX

	POP		ECX					; Restores main counter to decrement and check if 0
	DEC		ECX	
	CMP		ECX, 0
	JNE		_userPrompt

_return:
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		ESI
	POP		EDI
	POP		EBP
	RET 40
ReadVal ENDP


;------------------------------------------------------------------------------------------------------------------
; Name: WriteVal
;
; This procedure converts a signed integer value to a string and displays it. It is called by other procedures.
;
; Preconditions:
;	mDisplayString macro must be present
;	NULL must be defined as 0
; Postconditions:
;	None
; Receives:
;	source integer array [EBP + 12] - an array of integers to convert to strings
;	desination array [EBP + 8] - a destination array to hold values as they are displayed
; Returns:
;	destination array is populated, string is printed
;------------------------------------------------------------------------------------------------------------------
WriteVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDI
	PUSH	EAX
	PUSH	EBX
	PUSH	EDX
	MOV		EAX, [EBP + 12]			; Source integer array
	MOV		EDI, [EBP + 8]			; Move the destination array to EDI

_checkNeg:
	CMP		EAX, -1
	JLE		_negative
	JMP		_addNullChar			; If number is not negative, push null character to stack to be added to string

; If integer is negative, print a negative sign in front of string
_negative:
	PUSH		EAX					; Push current integer to stack to allow for negative sign to be printed
	MOV			AL, 45
	STOSB							; Store negative sign in AL to EDI
	mDisplayString	[EBP + 8]		; Print the negative sign in EDI	
	DEC		EDI					
	POP		EAX						; Restore current integer
	NEG		EAX						; Negate the integer back to positive so it can be interpreted by the conversion algorithm						

; Add null character to signal end of string
_addNullChar:
	PUSH	NULL

; Converting integer to ASCII will happen in reverse of the ReadVal procedure:
;	1. Divide the value by 10 and remainder is the digit we want to convert
;	2. Add 48 to the remainder to get the ASCII character
;	3. Use STOSB to store the value in the destination array
_convertToString:
	MOV		EBX, 10	
	MOV		EDX, 0
	DIV		EBX
	MOV		EBX, EDX				; Remainder is the value we want to add to the string, move to EBX
	ADD		EBX, 48					; Convert from decimal to ASCII 
	PUSH	EBX						; Preserve value on the stack
	CMP		EAX, 0					; If we are at the end of the integer
	JE		_display
	JMP		_convertToString
	

_display:
	POP		EAX						; Put top of stack value in EAX
	STOSB							
	mDisplayString	[EBP + 8]
	DEC		EDI						; Override the autoincrement of the STOSB so we use the same byte in the array

	CMP		EAX, 0					; Loop until a null character is encountered
	JE		_return
	JMP		_display

_return:
	POP		EDX
	POP		EBX
	POP		EAX
	POP		EDI
	POP		EBP
	RET		8
WriteVal ENDP


;------------------------------------------------------------------------------------------------------------------
; Name: DisplayArray
;
; This procedure displays the array of user input numbers as strings.
;
; Preconditions:
;	WriteVal procedure must be present
;	mDisplayString macro must be present
;	ARRAY_SIZE must be defined
;	integerArray must be populated
; Postconditions:
;	None
; Receives:
;	commaSpace [EBP + 16] - a string of a comma and a space to separate values
;	integerArray [EBP + 12] - array is signed integers
;	displayString [EBP + 8] - blank array to store the converted values for display
; Returns:
;	Printed values separated by a comma and a space
;------------------------------------------------------------------------------------------------------------------
DisplayArray PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ECX
	PUSH	ESI
	PUSH	EDI

	MOV		ECX, ARRAY_SIZE			; The loop will run ARRAY_SIZE (10) times
	MOV		EDI, [EBP + 8]			; Move destination array to EDI
	MOV		ESI, [EBP + 12]			; Move source array to ESI
	
_displayElement:
	PUSH	[ESI]					; Pass the contents of the source array to WriteVal
	PUSH	EDI						; Pass the address of the destination array to WriteVal
	CALL	WriteVal
	ADD		ESI, 4					; Jump to next element in source array
	DEC		EDI						; Move to the next

	CMP		ECX, 1					; Don't print comma for last element
	JE		_return

_printCommaSpace:
	mDisplayString	[EBP + 16]		; String of comma and a space
	LOOP	_displayElement

_return:
	POP		EDI
	POP		ESI
	POP		ECX
	POP		EBP
	RET		12
DisplayArray ENDP


;------------------------------------------------------------------------------------------------------------------
; Name: CalcSum
;
; This procedure calculates the sum of the user-entered values and displays the sum.
;
; Preconditions:
;	WriteVal procedure must be present
;	integerArray must be populated with integers
;	ARRAY_SIZE	must be defined
; Postconditions:
;	None
; Receives:
;	intSum [EBP + 16] - blank variable to store the sum
;	integerArray [EBP + 12] - array of converted signed integers
;	displayString [EBP + 8] - blank array to store the converted values for display
; Returns:
;	The sum of values stored in intSum
;------------------------------------------------------------------------------------------------------------------
CalcSum PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX

	MOV		ECX, ARRAY_SIZE
	MOV		EBX, 0					; EBX is the running sum counter
	MOV		ESI, [EBP + 12]			; integerArray is source
	MOV		EDI, [EBP + 8]			; displayString is destination

; Running sum is in EBX
_sumCurrentInt:
	ADD		EBX, [ESI]
	ADD		ESI, 4
	LOOP	_sumCurrentInt

; Print EBX with WriteVal
	PUSH	EBX						; Push to EBP + 12
	PUSH	EDI						; Push to EBP + 8
	CALL	WriteVal

; Store the resulting sum in intSum to use in the CalcAverage procedure
	MOV		EAX, [EBP + 16]
	MOV		[EAX], EBX

_return:
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		12
CalcSum ENDP


;------------------------------------------------------------------------------------------------------------------
; Name: CalcAverage
;
; This procedure calculates the truncated average of the user-entered values and displays the average.
;
; Preconditions:
;	WriteVal procedure must be present.
;	intSum must be populated
;	ARRAY_SIZE must be defined
; Postconditions:
;	None
; Receives:
;	intSum [EBP + 12] - the sum of the values the user entered
;	displayString [EBP + 8] - a blank 4 array to display the converted integer value
; Returns:
;	Printed value of the truncated average of the sum
;------------------------------------------------------------------------------------------------------------------
CalcAverage PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX

	ADD		EDI, 4
	MOV		EDI, [EBP + 8]			; displayString is destination
	MOV		EAX, 0
	MOV		EAX, [EBP + 12]			; EAX is the sum
	MOV		EBX, ARRAY_SIZE					
	
	CDQ
	IDIV	EBX
	
	PUSH	EAX
	PUSH	EDI
	CALL	WriteVal

_return:
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		8
CalcAverage ENDP

END main
