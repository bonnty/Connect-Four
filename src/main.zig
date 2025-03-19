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
            .grid = [_][BoardWidth]u8{[_]u8{' '} ** BoardWidth} ** BoardHeight, // TODO: understand this
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

        // Print the bottom
        std.debug.print("+", .{});
        for (0..BoardWidth) |_| {
            std.debug.print("-+", .{});
        }
        std.debug.print("\n", .{});
    }

    pub fn makeMove(self: *GameBoard, column: usize) !bool {
        if (column >= BoardWidth) {
            return error.InvalidColumn;
        }

        // Find the first empty row in the selected column
        var row: i8 = BoardHeight - 1;

        while (row >= 0) {
            if (self.grid[@intCast(row)][column] == ' ') {
                self.grid[@intCast(row)][column] = if (self.currentPlayer == Player.Alice) 'X' else 'O';
                self.movesPlayed += 1;
                self.currentPlayer = if (self.currentPlayer == Player.Alice) Player.Bob else Player.Alice;
                return true;
            }
            row -= 1;
        }

        // Column is full
        return false;
    }
};

pub fn main() !void {
    var gameBoard = GameBoard.init();
    gameBoard.display();
    _ = try gameBoard.makeMove(1); // 1
    _ = try gameBoard.makeMove(1); // 2
    _ = try gameBoard.makeMove(1); // 3
    _ = try gameBoard.makeMove(1); // 4
    _ = try gameBoard.makeMove(1); // 5
    _ = try gameBoard.makeMove(1); // 6
    // should be false now
    const success = try gameBoard.makeMove(1);
    if (!success) {
        std.debug.print("{any}\n", .{success});
    }

    gameBoard.display();
}
