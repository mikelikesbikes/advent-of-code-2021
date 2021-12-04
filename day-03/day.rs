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

    println!("input length: {}", input.readings.len());
    println!("{}", input.gamma_rate() * input.epsilon_rate());
    println!("{}", input.oxygen_generator_rating() * input.co2_scrubber_rating());
}

fn read_input(file: File) -> Vec<String> {
    let reader = BufReader::new(file);
    reader.lines().map(|l| l.unwrap()).collect()
}

fn parse_input(input: Vec<String>) -> Readings {
    Readings { readings: input }
}

struct Readings {
    readings: Vec<String>
}

impl Readings {
    pub fn gamma_rate(&self) -> usize {
        let width = self.readings[0].len();
        let mut gamma = 0;
        for i in 0..width {
            let (zeros, ones) = count_ones_and_zeros(&self.readings, i);
            gamma = gamma << 1;
            if ones >= zeros {
                gamma |= 1;
            }
        }
        gamma
    }

    pub fn epsilon_rate(&self) -> usize {
        let width = self.readings[0].len();
        let mut epsilon = 0;
        for i in 0..width {
            let (zeros, ones) = count_ones_and_zeros(&self.readings, i);
            epsilon = epsilon << 1;
            if ones < zeros {
                epsilon |= 1;
            }
        }
        epsilon
    }

    pub fn oxygen_generator_rating(&self) -> usize {
        let width = self.readings[0].len();
        let mut readings = self.readings.clone();
        for i in 0..width {
            let (zeros, ones) = count_ones_and_zeros(&readings, i);
            readings = readings
                .into_iter()
                .filter(|reading| {
                    match bit_at(reading, i) {
                        0 => zeros > ones,
                        1 => ones >= zeros,
                        _ => panic!("wtf"),
                    }
                })
                .collect();
            if readings.len() == 1 {
                return usize::from_str_radix(&readings[0], 2).unwrap();
            }
        }
        0
    }

    pub fn co2_scrubber_rating(&self) -> usize {
        let width = self.readings[0].len();
        let mut readings = self.readings.clone();
        for i in 0..width {
            let (zeros, ones) = count_ones_and_zeros(&readings, i);
            readings = readings
                .into_iter()
                .filter(|reading| {
                    match bit_at(reading, i) {
                        0 => zeros <= ones,
                        1 => ones < zeros,
                        _ => panic!("wtf"),
                    }
                })
                .collect();
            if readings.len() == 1 {
                return usize::from_str_radix(&readings[0], 2).unwrap();
            }
        }
        0
    }
}

fn bits_at(readings: &Vec<String>, col: usize) -> Vec<u8> {
    readings.iter().map(|s| bit_at(s, col) ).collect()
}

fn count_ones_and_zeros(readings: &Vec<String>, col: usize) -> (usize, usize) {
    let mut zeros = 0;
    let mut ones = 0;
    for bit in bits_at(readings, col) {
        if bit == 0 {
            zeros += 1;
        } else {
            ones += 1;
        }
    }
    (zeros, ones)
}

fn bit_at(s: &String, col: usize) -> u8 {
    s.as_bytes()[col] - 48
}

#[cfg(test)]
mod aoc_tests {
    use super::*;

    fn test_input() -> Readings {
        let filename = "test.txt";
        let file = File::open(filename).expect("input file to be found");
        parse_input(read_input(file))
    }

    fn actual_input() -> Readings {
        let filename = "input.txt";
        let file = File::open(filename).expect("input file to be found");
        parse_input(read_input(file))
    }

    #[test]
    fn test_part1() {
        assert_eq!(test_input().gamma_rate(), 22);
        assert_eq!(test_input().epsilon_rate(), 9);
        assert_eq!(test_input().gamma_rate() * test_input().epsilon_rate(), 198);
        assert_eq!(actual_input().gamma_rate() * actual_input().epsilon_rate(), 2583164);
    }

    #[test]
    fn test_part2() {
        assert_eq!(test_input().oxygen_generator_rating(), 23);
        assert_eq!(test_input().co2_scrubber_rating(), 10);
        assert_eq!(actual_input().oxygen_generator_rating() * actual_input().co2_scrubber_rating(), 2784375);
    }
}
