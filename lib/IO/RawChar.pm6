class IO::RawChar {
	has $!file;
	has $!saved;
	has $!tap;

	method BUILD(Int :$wait = 0) {
	    use Term::termios;
		$!file = "/dev/tty".IO.open;
		$!file.encoding('ascii');
		my $fd = $!file.native-descriptor;
		$!saved := Term::termios.new(:$fd).getattr;
		$!tap = signal(SIGTERM).tap: { $!saved.setattr };
		my $termios := Term::termios.new(:$fd).getattr;
		$termios.unset_iflags(<BRKINT ICRNL ISTRIP IXON>);
		$termios.set_oflags(<ONLCR>);
		$termios.set_cflags(<CS8>);
		$termios.unset_lflags(<ECHO ICANON IEXTEN ISIG>);
		$termios.cc_VMIN = 0;
		$termios.cc_VTIME = $wait;
		$termios.setattr(:DRAIN);
	}
	method get()
	{
		my $f = '/dev/tty'.IO.open;
		LEAVE $f.close;
		$f.encoding('ascii');
		$f.getc // '';
	}
	method clean() {
		$!saved.setattr;
		$!file.close;
		$!tap.close;
	}
}

