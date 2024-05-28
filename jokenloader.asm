org 0x7c00
bits 16

main:
	;definir segmentos de dados
	xor ax, ax
	mov ds, ax
	mov es, ax
	
	; definir topo pilha
	mov ss, ax
	mov sp, 0x7c00
	
	; limpar a tela
	mov ax, 0x3
	int 0x10
	
;mostrar titulo
print_start_msg:
	mov ah, 0x0e
	mov cx, instructions - start_msg
	mov si, start_msg
.nextchar0:
	lodsb
	int 0x10
	loop .nextchar0
	
;mostrar instrucoes 
print_instructions:
	mov ah, 0x0e
	mov cx, escolha_msg - instructions
	mov si, instructions
.nextchar1:
	lodsb
	int 0x10
	loop .nextchar1

;espera jogador apertar enter
wait_player:
	mov ah, 0x0
	int 0x16
	cmp al, 13
	je start
	jmp wait_player

;limpar tela e comecar jogo  
start:
	mov ah, 0x0
	mov al, 0x3
	int 0x10
	jmp game_loop
	
	game_loop:
		call print_escolha_msg
		call computer_escolha
		call player_escolha	

	;msg antes do input
	print_escolha_msg: 	
		mov ah, 0x0e
		mov cx, bot_escolha - escolha_msg
		mov si, escolha_msg
	.nextchar2:
		lodsb
		int 0x10
		loop .nextchar2
		ret
	
	;gera um numero aleatorio de 0 a 2 com base no tempo
	computer_escolha:
		rdtsc
		xor ax, dx
		cmp al, 0x1
		je .continue
		cmp al, 0x2
		je .continue
		cmp al, 0x0
		je .continue
		jmp computer_escolha
	.continue:		;guarda o valor em bl apenas se for 0, 1 ou 2
		add al, '0'	;converte para char
		mov bl, al
		ret

	;jogador escolhe um numero entre 0 e 2
	player_escolha:
		mov ah, 0x0 		;espera entrada do jogador
		int 0x16
	
		cmp al, 0x30		
		je .enviar
		cmp al, 0x31
		je .enviar
		cmp al, 0x32
		je .enviar
	
		jmp start		;se jogador escolher um numero diferente de 0,1 e 2, o programa nao avanca
	.enviar:
		mov ah, 0x0e		;mostra a escolha do jogador 
		int 0x10
		call comparar_escolhas
		ret
	
;mostra o resultado da partida
print_vitoria:
	mov ah, 0x0e
	mov cx, botwinmsg - youwinmsg
	mov si, youwinmsg
.nextchar3:
	lodsb
	int 0x10
	loop .nextchar3
	ret

print_derrota:
	mov ah, 0x0e
	mov cx, empatemsg - botwinmsg
	mov si, botwinmsg
.nextchar4:
	lodsb
	int 0x10
	loop .nextchar4
	ret

print_empate:
	mov ah, 0x0e
	mov cx, againmsg - empatemsg
	mov si, empatemsg
.nextchar5:
	lodsb
	int 0x10
	loop .nextchar5
	ret

print_bot_escolha:	
	mov ah, 0x0e
	mov cx, youwinmsg - bot_escolha
	mov si, bot_escolha
.nextchar6:
	lodsb
	int 0x10
	loop .nextchar6
	ret

;pergunta se o jogador deseja continuar jogando 
print_again:
	mov ah, 0x0e
	mov cx, pad - againmsg
	mov si, againmsg
.nextchar7:
	lodsb
	int 0x10
	loop .nextchar7
	mov ah, 0x0
	int 0x16
	cmp al, 13 
	je start	;se o jogador apertar enter, inicia um novo jogo, se nao, o programa congela
	jmp halt
	
comparar_escolhas:
	cmp al, bl	;se os dois escolheram o mesmo valor empata
	je empate
	
	cmp al, 0x30	
	je .player0

	cmp al, 0x31
	je .player1
	
	cmp al, 0x32
	je .player2
	
	.player0: ; se player escolheu pedra
		call print_bot_escolha
		mov ah, 0x0e
		mov al, bl
		int 0x10
		cmp bl, 0x31 ; e bot escolheu papel 
		je botwin

		cmp bl, 0x32 ; e bot escolheu tesoura 
		je playerwin
	
	.player1: ; se player escolheu papel
		call print_bot_escolha
		mov ah, 0x0e
		mov al, bl
		int 0x10
		cmp bl, 0x30 ; e bot escolheu pedra
		je playerwin

		cmp bl, 0x32 ; e bot escolheu tesoura
		je botwin

	.player2: ; se player escolheu tesoura
		call print_bot_escolha
		mov ah, 0x0e
		mov al, bl
		int 0x10
		cmp bl, 0x30 ; e bot escolheu pedra
		je botwin
	
		cmp bl, 0x31 ; e bot escolheu papel  
		je playerwin

		empate:
			call print_empate
			call print_again
		
		botwin:
			call print_derrota
			call print_again
	
		playerwin:	
			call print_vitoria
			call print_again
		halt:
			cli 	;limpa flag de interrupcoes
			hlt	;para cpu

;textos usados no programa
start_msg:
	db '==JOKENLOADER==', 0xA, 0xD 

instructions:
	db 'Como jogar:', 0xA , 0xD
	db '0 - Pedra', 0xA, 0xD
	db '1 - Papel', 0xA, 0xD
	db '2 - Tesoura', 0xA, 0xD
	db 'Clique ENTER para iniciar...'
	
escolha_msg:
	db 'Pedra, papel, tesoura...'

bot_escolha:
	db 0xA, 0xD, 'O Bot escolheu '

youwinmsg:
	db 0xA, 0xD, 'Vc ganhou!'
	
botwinmsg:
	db 0xA, 0xD, 'Vc perdeu!'   

empatemsg:	
	db 0xA, 0xD, 'Empatou!'

againmsg:
	db 0xA, 0xD, 'Clique ENTER para jogar novamente'

pad:
	times 510-($-$$) db 0
sig:
	dw 0xaa55
