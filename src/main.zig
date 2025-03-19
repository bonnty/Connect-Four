const std = @import("std");

const BoardWidth = 7;
const BoardHeight = 6;
const Player = enum { Alice, Bob };

const GameState = enum {
    InProgress,
    Player1Win,
    Player2Win,
    Draw,
};

const GameBoard = struct {
    // "" for empty, "X" for player 1, "O" for player 2
    grid: [BoardHeight][BoardWidth]u8,
    currentPlayer: Player,
    movesPlayed: usize,
    state: GameState,

    pub fn init() GameBoard {
        var board = GameBoard{
            .grid = undefined,
            .currentPlayer = Player.Alice,
            .movesPlayed = 0,
            .state = GameState.InProgress,
        };

        // Initialize empty board
        for (0..BoardHeight) |row| {
            for (0..BoardWidth) |col| {
                board.grid[row][col] = ' ';
            }
        }
        return board;
    }

    pub fn display(self: *const GameBoard) void {
        for (0..BoardHeight) |row| {
            std.debug.print("|", .{});
            for (0..BoardWidth) |col| {
                std.debug.print("{c}", .{self.grid[row][col]});
                std.debug.print("|", .{});
            }
            std.debug.print("\n", .{});
        }
    }
};

pub fn main() !void {
    var gameBoard = GameBoard.init();
    gameBoard.display();
}
