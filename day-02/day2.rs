use std::env;
use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;

fn main() {
    let args: Vec<String> = env::args().collect();
    let filename = &args[1];
    let file = File::open(filename).expect("input file to be found");
    let input = &parse_input(read_input(file));

    let mut pos = Position { x: 0, depth: 0 };
    for cmd in input {
        if cmd.cmd == "forward" {
            pos.x += cmd.val;
        } else if cmd.cmd == "up" {
            pos.depth -= cmd.val;
        } else if cmd.cmd == "down" {
            pos.depth += cmd.val;
        }
    }
    println!("{}", pos.x * pos.depth);

    let mut pos2 = PositionWithAim { x: 0, depth: 0, aim: 0 };
    for cmd in input {
        if cmd.cmd == "forward" {
            pos2.x += cmd.val;
            pos2.depth += pos2.aim * cmd.val
        } else if cmd.cmd == "up" {
            pos2.aim -= cmd.val;
        } else if cmd.cmd == "down" {
            pos2.aim += cmd.val;
        }
    }
    println!("{}", pos2.x * pos2.depth);
}

#[derive(Debug)]
struct Command {
    cmd: String,
    val: i32,
}

#[derive(Debug)]
struct Position {
    x: i32,
    depth: i32,
}

#[derive(Debug)]
struct PositionWithAim {
    x: i32,
    depth: i32,
    aim: i32,
}

fn read_input(file: File) -> Vec<String> {
    let reader = BufReader::new(file);
    reader.lines().map(|l| l.unwrap()).collect()
}

fn parse_input(input: Vec<String>) -> Vec<Command> {
    input.iter().map(|l| {
         let splits: Vec<&str> = l.split(' ').collect();
         Command {
             cmd: splits[0].to_string(),
             val: splits[1].parse::<i32>().unwrap(),
         }
    }).collect()
}
