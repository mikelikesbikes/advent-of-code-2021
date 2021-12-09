all: ruby rust

ruby:
	rspec day.rb
	time ruby day.rb

rustcompile:
	rustc day.rs -o day
	rustc --test day.rs -o daytest

rustrun:
	./daytest
	time ./day

rustclean:
	rm ./day ./daytest

rust: rustcompile rustrun rustclean
