use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;

fn main() {
    let filename = "input.txt";
    let file = File::open(filename).expect("input file to be found");
    let reader = BufReader::new(file);

    let lines: Vec<i32> = reader.lines().map(|l| l.unwrap().parse::<i32>().unwrap()).collect();

    let count = count_increases(&lines);
    println!("{}", count);

    let mut windows: Vec<i32> = Vec::new();
    for i in 0..(lines.len()-2) {
        windows.push(lines[i] + lines[i+1] + lines[i+2]);
    }
    let window_count = count_increases(&windows);
    println!("{}", window_count);
}

fn count_increases(v: &Vec<i32>) -> i32 {
    let mut count = 0;
    for i in 0..(v.len()-1) {
        if v[i+1] > v[i] {
            count += 1;
        }
    }
    count
}
