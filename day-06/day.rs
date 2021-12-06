use std::env;
use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;
use std::collections::HashMap;
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

    println!("{}", evolve(input, 80));
    println!("{}", evolve(input, 256));
}

fn evolve(counts: &HashMap<usize, usize>, count: usize) -> usize {
    match count {
        0 => counts.values().sum(),
        _ => {
            let mut new_counts = HashMap::new();
            for k in counts {
                match k {
                    (0, v) => {
                        *new_counts.entry(8).or_insert(0) += v;
                        *new_counts.entry(6).or_insert(0) += v;
                    },
                    (k, v) => {
                        *new_counts.entry(k - 1).or_insert(0) += v;
                    },
                }
            }
            evolve(&new_counts, count - 1)
        }
    }
}

fn read_input(file: File) -> Vec<String> {
    let reader = BufReader::new(file);
    reader.lines().map(|l| l.unwrap()).collect()
}

fn parse_input(input: Vec<String>) -> HashMap<usize, usize> {
    let mut vals = HashMap::new();
    for s in input[0].split(",") {
        let k = s.parse::<usize>().unwrap();
        *vals.entry(k).or_insert(0) += 1;
    }
    vals
}

#[cfg(test)]
mod aoc_tests {
    use super::*;

    fn test_input() -> HashMap<usize, usize> {
        let filename = "test.txt";
        let file = File::open(filename).expect("input file to be found");
        parse_input(read_input(file))
    }

    fn actual_input() -> HashMap<usize, usize> {
        let filename = "input.txt";
        let file = File::open(filename).expect("input file to be found");
        parse_input(read_input(file))
    }

    #[test]
    fn test_part1() {
        assert_eq!(evolve(&test_input(), 18), 26);
        assert_eq!(evolve(&test_input(), 80), 5934);
        assert_eq!(evolve(&actual_input(), 80), 362346);
    }

    #[test]
    fn test_part2() {
        assert_eq!(evolve(&test_input(), 256), 26984457539);
        assert_eq!(evolve(&actual_input(), 256), 1639643057051);
    }
}
