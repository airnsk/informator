#!/usr/bin/expect --

set LINPHONEC "/usr/bin/linphonec"
set RECIPIENT [lindex $argv 0]
set exit_status 10
set call 1
set dontcall 2
set audio 3
set repeat 4
set busy 5
set answered 6
set ringing 7

spawn $LINPHONEC

expect "linphonec> " { sleep 3}
expect "linphonec> " { 
	send "soundcard use files\r" 
	sleep 1 
}


send "call $RECIPIENT\r"
set timeout 20 
expect {
	
	"Remote ringing" {
	set exit_status $ringing
	exp_continue -continue_timer
	}

	"answered" {		
		set exit_status $answered
	}
	"busy" {		
		set exit_status $busy
	}
		
	timeout {
		send "quit\r"
		sleep 9
		exit $exit_status
	}
}

set timeout 15 
expect {
		"(audio)" {	
		
		sleep 2	
		send "play wav/greeting.wav\r"
		sleep 5
		send "play wav/vashkodvlk.wav\r"
		sleep 4
		send "play wav/[lindex $argv 1].wav\r"
		sleep 1
		send "play wav/[lindex $argv 2].wav\r"
		sleep 1
		send "play wav/[lindex $argv 3].wav\r"
		sleep 1
		send "play wav/[lindex $argv 4].wav\r"
		sleep 1
		send "play wav/[lindex $argv 5].wav\r"
		sleep 1
		send "play wav/[lindex $argv 6].wav\r"
		sleep 1
		set exit_status $audio	
		send "play wav/repeat.wav\r"
		sleep 1
		exp_continue
		}
		
		"Receiving" {
		
		send "speak_info\r"
		send "\r"
		send "play wav/vashkodvlk.wav\r"
		sleep 4
		send "play wav/[lindex $argv 1].wav\r"
		sleep 1
		send "play wav/[lindex $argv 2].wav\r"
		sleep 1
		send "play wav/[lindex $argv 3].wav\r"
		sleep 1
		send "play wav/[lindex $argv 4].wav\r"
		sleep 1
		send "play wav/[lindex $argv 5].wav\r"
		sleep 1
		send "play wav/[lindex $argv 6].wav\r"
		sleep 1
		set exit_status $repeat
		send "play wav/repeat.wav\r"
		sleep 1

		exp_continue
		}
		
		"terminated" {
		send "quit\r"
		sleep 7
		exit $exit_status
		}
		timeout {

		send "terminate\r"
		sleep 3
		send "quit\r"
		sleep 7
		exit $exit_status
		}
	}


exit $exit_status
