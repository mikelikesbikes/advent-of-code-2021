use std::env;
use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;
use std::str::FromStr;
use std::collections::HashMap;
use std::cmp::Ordering;
//use std::convert::Infallible;

fn main() {
    let args: Vec<String> = env::args().collect();
    let mut filename = "input.txt";
    if args.len() > 1 {
        filename = &args[1];
    }
    let file = File::open(filename).expect("input file to be found");
    let input = &parse_input(read_input(file));

    println!("{}", danger_count(input, false));
    println!("{}", danger_count(input, true));
}

fn read_input(file: File) -> Vec<String> {
    let reader = BufReader::new(file);
    reader.lines().map(|l| l.unwrap()).collect()
}

fn parse_input(input: Vec<String>) -> Vec<Line> {
    input.iter().map(|l| {
        l.parse().unwrap()
    }).collect()
}

#[derive(Debug, PartialEq, Eq, Hash, Copy, Clone)]
struct Point {
    x: isize,
    y: isize,
}

impl FromStr for Point {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let splits: Vec<&str> = s.split(',').collect();
        Ok(Self{x: splits[0].parse().unwrap(), y: splits[1].parse().unwrap()})
    }
}

impl Point {
    fn delta(&self, other: &Point) -> (isize, isize) {
        let dx;
        let dy;
        match other.x.cmp(&self.x) {
            Ordering::Less => dx = -1,
            Ordering::Equal => dx = 0,
            Ordering::Greater => dx = 1,
        }
        match other.y.cmp(&self.y) {
            Ordering::Less => dy = -1,
            Ordering::Equal => dy = 0,
            Ordering::Greater => dy = 1,
        }
        (dx, dy)
    }
}

#[derive(Debug)]
struct Line {
    start: Point,
    end: Point,
}

impl FromStr for Line {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let splits: Vec<&str> = s.split(" -> ").collect();
        Ok(Self{start: splits[0].parse().unwrap(), end: splits[1].parse().unwrap()})
    }
}

impl Line {
    fn points(&self) -> Vec<Point> {
        let (dx, dy) = self.start.delta(&self.end);
        let mut points = vec![self.start];
        let mut last = self.start;
        while last != self.end {
            last = Point{x: last.x + dx, y: last.y + dy};
            points.push(last);
        }
        points
    }

    fn is_diagonal(&self) -> bool {
        let (dx, dy) = self.start.delta(&self.end);
        dx != 0 && dy != 0
    }
}

fn danger_count(lines: &Vec<Line>, include_diagonals: bool) -> usize {
    lines
        .iter()
        .filter(|l| include_diagonals || !l.is_diagonal() )
        .flat_map(|l| l.points() )
        .fold(HashMap::new(), |mut map, point| {
            *map.entry(point).or_insert(0) += 1;
            map
        })
        .values()
        .filter(|&&i| i > 1)
        .count()
}

#[cfg(test)]
mod aoc_tests {
    use super::*;

    fn test_input() -> Vec<Line> {
        let filename = "test.txt";
        let file = File::open(filename).expect("input file to be found");
        parse_input(read_input(file))
    }

    fn actual_input() -> Vec<Line> {
        let filename = "input.txt";
        let file = File::open(filename).expect("input file to be found");
        parse_input(read_input(file))
    }

    #[test]
    fn test_part1() {
        assert_eq!(danger_count(&test_input(), false), 5);
        assert_eq!(danger_count(&actual_input(), false), 5608);
    }

    #[test]
    fn test_part2() {
        assert_eq!(danger_count(&test_input(), true), 12);
        assert_eq!(danger_count(&actual_input(), true), 20299);
    }
}
