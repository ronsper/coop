
; RULES
; It takes 3 positive readings in a row to trigger an action (open or close)
; If the door is at rest and its nether open or closed it will close the door


; constants
SYMBOL light_tolerance = 75
SYMBOL sleep_amout = 1

; pins
SYMBOL pin_close_relay = 0
SYMBOL pin_open_relay = 1
SYMBOL pin_light_sensor = 2
SYMBOL pin_open_reed = 4
SYMBOL pin_close_reed = 3

; vars
SYMBOL light_sensor = b0
SYMBOL open_votes = b1
SYMBOL close_votes = b2


; main loop
main:
	LET open_votes = 0
	LET close_votes = 0
	GOTO start

; start the process
start:	
	; load pin output into vars
	READADC pin_light_sensor, light_sensor
	
	; figure out what to do
	IF light_sensor < light_tolerance AND close_votes IS 3 AND pin4 IS 1 AND open_votes IS 0 THEN 
		GOTO close_door
	ELSEIF light_sensor < light_tolerance AND close_votes < 3 AND pin4 IS 1 AND open_votes IS 0 THEN 
		GOTO vote_close
	ELSEIF light_sensor > light_tolerance AND open_votes = 3 AND pin3 IS 1 AND close_votes IS 0 THEN
		GOTO open_door
	ELSEIF light_sensor > light_tolerance AND open_votes < 3 AND pin3 IS 1 AND close_votes IS 0 THEN 
		GOTO vote_open
	ELSEIF pin4 IS 1 OR pin3 IS 1 THEN 
		GOTO reset_timeout
	ELSE 
		GOTO close_door
	ENDIF

; close the coop door
close_door:
	HIGH pin_close_relay
	LOW pin_open_relay
	
	IF pin3 != 1 THEN 
		GOTO close_door
	ENDIF
	
	GOTO main

; open the coop door
open_door: 
	LOW pin_close_relay
	HIGH pin_open_relay
	
	IF pin4 != 1 THEN 
		GOTO open_door
	ENDIF
	
	GOTO main

; inc the close votes count
vote_close:
	LET close_votes = close_votes + 1
	SLEEP sleep_amout
	GOTO start
	
; inc the open votes count
vote_open:
	LET open_votes = open_votes + 1
	SLEEP sleep_amout
	GOTO start

; set chip to sleep for 2.4 sec
reset_timeout:
	SLEEP sleep_amout
	GOTO main