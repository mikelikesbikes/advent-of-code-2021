use std::env;
use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;
//use std::str::FromStr;
//use std::convert::Infallible;

fn main() {
    let args: Vec<String> = env::args().collect();
    let mut filename = "input.txt";
    if args.len() > 1 {
        filename = &args[1];
    }
    let file = File::open(filename).expect("input file to be found");
    let input = &parse_input(read_input(file));

    println!("input length: {}", input.len());
    println!("{}", "part1");
    println!("{}", "part2");
}

fn read_input(file: File) -> Vec<String> {
    let reader = BufReader::new(file);
    reader.lines().map(|l| l.unwrap()).collect()
}

fn parse_input(input: Vec<String>) -> Vec<String> {
    input.iter().map(|l| {
        // replace 'String' with the type we're trying to parse
        l.parse::<String>().unwrap()
    }).collect()
}

#[cfg(test)]
mod aoc_tests {
    use super::*;

    fn test_input() -> Vec<String> {
        let filename = "test.txt";
        let file = File::open(filename).expect("input file to be found");
        parse_input(read_input(file))
    }

    fn actual_input() -> Vec<String> {
        let filename = "input.txt";
        let file = File::open(filename).expect("input file to be found");
        parse_input(read_input(file))
    }

    #[test]
    fn test_part1() {
        assert!(test_input().len() > 0);
        assert!(actual_input().len() > 0);
        assert_eq!(true, true);
    }

    #[test]
    fn test_part2() {
        assert_eq!(true, true);
    }
}
