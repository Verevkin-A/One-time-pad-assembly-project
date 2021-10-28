; Vernamova sifra na architekture DLX
; Aleksandr Verevkin xverev00

        .data 0x04          ; zacatek data segmentu v pameti
login:  .asciiz "xverev00"  ; <-- nahradte vasim loginem
cipher: .space 9 ; sem ukladejte sifrovane znaky (za posledni nezapomente dat 0)

        .align 2            ; dale zarovnavej na ctverice (2^2) bajtu
laddr:  .word login         ; 4B adresa vstupniho textu (pro vypis)
caddr:  .word cipher        ; 4B adresa sifrovaneho retezce (pro vypis)

        .text 0x40          ; adresa zacatku programu v pameti
        .global main        ; 

main:
	;klic
	addi r15, r0, 118  	; v
	addi r26, r0, 101  	; e
	
	addi r17, r0, 96   	; a

	sub r15, r15, r17  	; delka pricitani k sifru(+22 k sifru)
	sub r17, r17, r26  	; delka odcitani od sifru(-5 k sifru)

	add r28, r0, r0  	; inicializace registru (r28 kontroluje cislo zpracovaneho znaku)
	add r26, r0, r0  	; inicializace registru (r26 kontroluje jestli nutne pricitat nebo odcitat)
	j startFirst
	nop
start: 
	addi r28, r28, 1  	; dalsi znak

startFirst:	
	lb r30, login(r28)  	; load znak z loginu
	slti r30, r30, 97   	; pokud znak je cislice, pricte 0 a ukonci program
	bnez r30, addZero   	; branch pokud znak je cislice
	
	seq r30, r28, r26  	; controla pricitani a odcitani
	beqz r30, substraction  ; skok na odcitani pokud nutne
	
	lb r30, login(r28)  	; load znaku z loginu
	add r30, r30, r15  	; pricitani k loginu 

	sgti r30, r30, 122  	; pokud delka ascii hodnota vetsi nez 122, skok
	bnez r30, bigger

	lb r30, login(r28)  	; load znaku z loginu
	add r30, r30, r15  	; sifrovani
	sb cipher(r28), r30  	; store sifrovany znak na vystup
	
	j start  		; skok na zacatek
	nop

bigger: 
	lb r30, login(r28)  	; load znaku z loginu
	add r30, r30, r15  	; sifrovani
	subi r30, r30, 26
	sb cipher(r28), r30  	; store sifrovany znak na vystup

	j start  		; skok na zacatek
	nop

substraction:
	lb r30, login(r28)	; load znaku z loginu
	add r30, r30, r17	; odcitani od loginu
	
	slti r30, r30, 97	; pokud vysledny znak preskoci ascii 97, skok
	bnez r30, lesser
	
	lb r30, login(r28)	; load znaku z loginu
	add r30, r30, r17	; sifrovani
	sb cipher(r28), r30	; store sifrovany znak na vystup

	addi r26, r26, 2	; pricitani pro kontrolu pricitani a odcitani pro sifr
	
	j start			; skok na zacatek
	nop
lesser:
	lb r30, login(r28)	; load znaku z loginu
	add r30, r30, r17	; sifrovani
	addi r30, r30, 26
	sb cipher(r28), r30	; store sifrovany znak na vystup

	addi r26, r26, 2	; pricitani pro kontrolu pricitani a odcitani pro sifr
	
	j start			; skok na zacatek
	nop

addZero:
	sb cipher(r26), r0	; 0 za posledni znak
	
end:    addi r14, r0, caddr ; <-- pro vypis sifry nahradte laddr adresou caddr
        trap 5  ; vypis textoveho retezce (jeho adresa se ocekava v r14)
        trap 0  ; ukonceni simulace
