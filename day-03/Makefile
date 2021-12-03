all: ruby rust clean

ruby:
	echo "===== running ruby ====="
	rspec day_spec.rb
	ruby day.rb

rustc:
	rustc day.rs -o day
	rustc --test day.rs -o daytest

rust: rustc
	echo "===== running rust ====="
	./daytest
	./day

clean:
	rm ./day ./daytest
