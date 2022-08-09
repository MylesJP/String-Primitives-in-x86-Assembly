TITLE String Primivitves and Macros    (Proj6_pennermy.asm)

; Author: Myles Penner
; Last Modified: August 8, 2022
; OSU email address: pennermy@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                 Due Date: August 12, 2022
; Description: This program will prompt the user for signed integers and process them as strings to display the numbers, the sum, and the truncated average
;					- It will use macros to convert the user ASCII string input to an a numeric value and validate the input
;					- A macro will convert the numeric value back to an ASCII string for output

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
;	inputLength = the variable to store the number of bytes of user input
;	
; Returns:
;	inputArray = a DWORD array of user-enter values
;	inputLength = the length of the user input
;------------------------------------------------------------------------------------------------------------------
mGetString MACRO	userPrompt, numCount, inputArray, inputLength
	; Use PUSH to preserve the regos used
	; Display prompt, get user input from memory, may also need a count for length of input
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	MOV		EDX, userPrompt
	CALL	WriteString
	MOV		ECX, numCount

	CALL	ReadString
	; convert ASCII to number
		; probably a loop that adds whatever offset to go from ASCII to number
	; provide number of bytes as output
	; Use POP to restore regos used
	POP		EAX
	POP		EBX
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

NUMINTEGERS = 10	; Constant for the 10 integers required from the user

.data

progTitle	BYTE	"Programming Assignment 6: Designing Low-Level I/O Procedures",13,10,
					"Written by: Myles Penner",13,10,13,10,0
introText	BYTE	"Please provide 10 signed decimal integers.",13,10,
					"Each number needs to be small enough to fit inside a 32 bit register. When you are done,",13,10,
					"I will display a list of the integers, their sum, and their average value.",13,10,13,10,0
prompt		BYTE	"Please enter a signed number: ",0
tryAgain	BYTE	"Please try again: ",0
error		BYTE	"ERROR: You did not enter a signed number or your number was too big",13,10,0
youEntered	BYTE	"You entered the following numbers:",13,10,0
sumNums		BYTE	"The sum of these numbers is: ",0
avgNums		BYTE	"The truncated average is: ",0
goodbye		BYTE	13,10,13,10,"Thanks for playing!",0

numberArray	SDWORD	NUMINTEGERS	DUP(?)

.code
main PROC

	mDisplayString	OFFSET progTitle	; Display the title of the program
	mDisplayString	OFFSET introText	; Provide instruction to the user

	; ReadVal procedure
	PUSH	OFFSET numberArray		; EBP + 28
	PUSH	OFFSET progTitle		; EBP + 24
	PUSH	OFFSET introText		; EBP + 20
	PUSH	OFFSET prompt			; EBP + 16
	PUSH	OFFSET tryAgain			; EBP + 12
	PUSH	OFFSET error			; EBP + 8
	CALL	ReadVal

	; WriteVal procedure
	CALL	WriteVal

	mDisplayString	OFFSET goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

;------------------------------------------------------------------------------------------------------------------
; Name: ReadVal
;
; This procedure reads the user input string...
;
; Preconditions:
;	...
; Postconditions:
;	...
; Receives:
;	...
;	...
; Returns:
;	...
;------------------------------------------------------------------------------------------------------------------
ReadVal PROC
	; Use the mGetString macro to get user input in form of string
	; Convert string of ASCII digits to number (SDWORD, and validate)
	; Store the value in memory
	PUSH	EBP
	MOV		EBP, ESP

	mGetString	[EBP+16], NUMINTEGERS

	POP		EBP
	RET 24
ReadVal ENDP


;------------------------------------------------------------------------------------------------------------------
; Name: WriteVal
;
; This procedure displays the input string...
;
; Preconditions:
;	...
; Postconditions:
;	...
; Receives:
;	...
;	...
; Returns:
;	...
;------------------------------------------------------------------------------------------------------------------
WriteVal PROC
	; Convert SDWORD value to ASCII
	; Invoke mDisplayString to print ASCII representation to output
	PUSH	EBP
	MOV		EBP, ESP

	POP		EBP
	RET
WriteVal ENDP

END main
