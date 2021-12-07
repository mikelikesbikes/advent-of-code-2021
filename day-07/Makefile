all: ruby rust

ruby:
	rspec day.rb
	ruby day.rb

rustcompile:
	rustc day.rs -o day
	rustc --test day.rs -o daytest

rustrun:
	./daytest
	./day

rustclean:
	rm ./day ./daytest

rust: rustcompile rustrun rustclean
