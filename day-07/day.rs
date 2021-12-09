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

    println!("{}", min_alignment_cost("linear", input));
    println!("{}", min_alignment_cost("triangular", input));
}

fn read_input(file: File) -> Vec<String> {
    let reader = BufReader::new(file);
    reader.lines().map(|l| l.unwrap()).collect()
}

fn parse_input(input: Vec<String>) -> Vec<isize> {
    input[0].split(",").map(|l| {
        // replace 'String' with the type we're trying to parse
        l.parse().unwrap()
    }).collect()
}

fn min_alignment_cost(strategy: &str, positions: &Vec<isize>) -> isize {
    let (min, max) = positions[1..].iter().fold((positions[0], positions[0]), |(mut min, mut max), x| {
        if *x < min { min = *x; }
        if *x > max { max = *x; }
        (min, max)
    });

    let fuel_calc = fuel_strategy(strategy);
    let mut min_fuel = None;
    for i in min..max {
        let s: isize = positions.iter().map(|p| fuel_calc(*p, i) ).sum();
        match min_fuel {
            None => min_fuel = Some(s),
            Some(m) => {
                if s < m { min_fuel = Some(s); }
            }
        }
    }
    min_fuel.unwrap()
}

fn fuel_strategy(s: &str) -> impl Fn(isize, isize) -> isize {
    if s == "linear" {
        |p: isize, i: isize| { (p - i).abs() }
    } else if s == "triangular" {
        |p: isize, i: isize| { let n = (p - i).abs(); n * (n + 1) / 2 }
    } else {
        panic!("unsupported strategy {}", s)
    }
}

#[cfg(test)]
mod aoc_tests {
    use super::*;

    fn test_input() -> Vec<isize> {
        let filename = "test.txt";
        let file = File::open(filename).expect("input file to be found");
        parse_input(read_input(file))
    }

    fn actual_input() -> Vec<isize> {
        let filename = "input.txt";
        let file = File::open(filename).expect("input file to be found");
        parse_input(read_input(file))
    }

    #[test]
    fn test_part1() {
        assert_eq!(min_alignment_cost("linear", &test_input()), 37);
        assert_eq!(min_alignment_cost("linear", &actual_input()), 341558);
    }

    #[test]
    fn test_part2() {
        assert_eq!(min_alignment_cost("triangular", &test_input()), 168);
        assert_eq!(min_alignment_cost("triangular", &actual_input()), 93214037);
    }
}
