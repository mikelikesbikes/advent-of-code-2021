use std::env;
use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;
use std::str::FromStr;
use std::convert::Infallible;

fn main() {
    let args: Vec<String> = env::args().collect();
    let filename = &args[1];
    let file = File::open(filename).expect("input file to be found");
    let input = &parse_input(read_input(file));

    let mut pos = Position { x: 0, depth: 0 };
    pos.navigate(input);
    println!("{}", pos.x * pos.depth);

    let mut pos2 = PositionWithAim { x: 0, depth: 0, aim: 0 };
    pos2.navigate(input);
    println!("{}", pos2.x * pos2.depth);
}

#[derive(Debug, Clone, Copy)]
enum CommandType {
    Forward,
    Up,
    Down,
}

impl FromStr for CommandType {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "forward" => Ok(CommandType::Forward),
            "up" => Ok(CommandType::Up),
            "down" => Ok(CommandType::Down),
            _ => Err(()),
        }
    }
}

#[derive(Debug)]
struct Command {
    ctype: CommandType,
    val: i32,
}

impl FromStr for Command {
    type Err = Infallible;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
         let splits: Vec<&str> = s.split(' ').collect();
         Ok(
             Command {
                 ctype: splits[0].parse::<CommandType>().unwrap(),
                 val: splits[1].parse::<i32>().unwrap(),
             }
         )
    }
}

trait Nav {
    fn step(&mut self, cmd: &Command);
    fn navigate(&mut self, cmds: &Vec<Command>) {
        for cmd in cmds {
            self.step(&cmd);
        }
    }
}

#[derive(Debug)]
struct Position {
    x: i32,
    depth: i32,
}

impl Nav for Position {
    fn step(&mut self, cmd: &Command) {
        match cmd.ctype {
            CommandType::Forward => self.x += cmd.val,
            CommandType::Up => self.depth -= cmd.val,
            CommandType::Down => self.depth += cmd.val,
        }
    }
}

#[derive(Debug)]
struct PositionWithAim {
    x: i32,
    depth: i32,
    aim: i32,
}

impl Nav for PositionWithAim {
    fn step(&mut self, cmd: &Command) {
        match cmd.ctype {
            CommandType::Forward => {
                self.x += cmd.val;
                self.depth += self.aim * cmd.val;
            },
            CommandType::Up => self.aim -= cmd.val,
            CommandType::Down => self.aim += cmd.val,
        }
    }
}

fn read_input(file: File) -> Vec<String> {
    let reader = BufReader::new(file);
    reader.lines().map(|l| l.unwrap()).collect()
}

fn parse_input(input: Vec<String>) -> Vec<Command> {
    input.iter().map(|l| {
        l.parse::<Command>().unwrap()
    }).collect()
}
