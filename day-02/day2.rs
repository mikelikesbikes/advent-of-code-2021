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
    pos.navigate(input);
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

trait Nav {
    fn get_x(&self) -> i32;
    fn get_depth(&self) -> i32;
    fn set_x(&mut self, val: i32);
    fn set_depth(&mut self, val: i32);

    fn navigate(&mut self, cmds: &Vec<Command>) {
        for cmd in cmds {
            self.step(&cmd);
        }
    }

    fn step(&mut self, cmd: &Command) {
        if cmd.cmd == "forward" {
            self.set_x(self.get_x() + cmd.val);
        } else if cmd.cmd == "up" {
            self.set_depth(self.get_depth() - cmd.val);
        } else if cmd.cmd == "down" {
            self.set_depth(self.get_depth() + cmd.val);
        }
    }
}

#[derive(Debug)]
struct Position {
    x: i32,
    depth: i32,
}

impl Nav for Position {
    fn get_x(&self) -> i32 {
        self.x
    }
    fn get_depth(&self) -> i32 {
        self.depth
    }
    fn set_x(&mut self, val: i32) {
        self.x = val;
    }
    fn set_depth(&mut self, val: i32) {
        self.depth = val;
    }
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
