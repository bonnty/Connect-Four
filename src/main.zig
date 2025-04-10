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
            .grid = [_][BoardWidth]u8{[_]u8{' '} ** BoardWidth} ** BoardHeight,
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
                self.updateGameState(@intCast(row), column);
                self.currentPlayer = if (self.currentPlayer == Player.Alice) Player.Bob else Player.Alice;
                return true;
            }
            row -= 1;
        }

        // Column is full
        return false;
    }

    fn updateGameState(self: *GameBoard, row: usize, col: usize) void {
        const playerPiece: u8 = if (self.currentPlayer == Player.Alice) 'X' else 'O';

        // Check for a win
        if (self.checkWin(row, col, playerPiece)) {
            self.state = if (self.currentPlayer == Player.Alice)
                GameState.Player1Win
            else
                GameState.Player2Win;
            return;
        }

        // Check for a draw
        if (self.movesPlayed >= BoardWidth * BoardHeight) {
            self.state = GameState.Draw;
        }
    }

    fn checkWin(self: *const GameBoard, row: usize, col: usize, piece: u8) bool {
        // Check directions: horizontal, vertical, diagonal up-right, diagonal up-left
        const directions = [_][2]isize{
            [_]isize{ 0, 1 }, // horizontal
            [_]isize{ 1, 0 }, // vertical
            [_]isize{ 1, 1 }, // diagonal up-right
            [_]isize{ 1, -1 }, // diagonal up-left
        };

        for (directions) |dir| {
            var count: usize = 1; // Start with 1 for the piece just placed

            // Check in the positive direction
            count += self.countConsecutive(row, col, dir[0], dir[1], piece);

            // Check in the negative direction
            count += self.countConsecutive(row, col, -dir[0], -dir[1], piece);

            if (count >= 4) {
                return true;
            }
        }

        return false;
    }

    fn countConsecutive(self: *const GameBoard, row: usize, col: usize, dRow: isize, dCol: isize, piece: u8) usize {
        var count: usize = 0;
        var r: isize = @as(isize, @intCast(row)) + dRow;
        var c: isize = @as(isize, @intCast(col)) + dCol;

        while (r >= 0 and r < BoardHeight and c >= 0 and c < BoardWidth) {
            if (self.grid[@intCast(r)][@intCast(c)] != piece) {
                break;
            }
            count += 1;
            r += dRow;
            c += dCol;
        }

        return count;
    }
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var buffer: [100]u8 = undefined;

    std.debug.print("Welcome to Connect Four!\n", .{});
    std.debug.print("Player 1: X, Player 2: O\n", .{});

    var gameBoard = GameBoard.init();

    while (gameBoard.state == GameState.InProgress) {
        gameBoard.display();

        const currentPlayerSymbol = if (gameBoard.currentPlayer == Player.Alice) "X" else "O";
        std.debug.print("\nPlayer {s}'s turn. Enter column (1-{d}): ", .{ currentPlayerSymbol, BoardWidth });

        if (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) |input| {
            // Parse column number (1-based to 0-based)
            const trimmed = std.mem.trim(u8, input, &std.ascii.whitespace);

            const column = std.fmt.parseInt(usize, trimmed, 10) catch {
                std.debug.print("Invalid input! Please enter a number between 1 and {d}.\n", .{BoardWidth});
                continue;
            };

            if (column < 1 or column > BoardWidth) {
                std.debug.print("Invalid column! Please enter a number between 1 and {d}.\n", .{BoardWidth});
                continue;
            }

            // Make the move (adjust to 0-based indexing)
            if (!try gameBoard.makeMove(column - 1)) {
                std.debug.print("Column {d} is full! Try another column.\n", .{column});
                continue;
            }
        } else {
            break; // EOF encountered
        }
    }

    // Game over, display final board and result
    gameBoard.display();

    switch (gameBoard.state) {
        .Player1Win => std.debug.print("\nPlayer X wins! Congratulations!\n", .{}),
        .Player2Win => std.debug.print("\nPlayer O wins! Congratulations!\n", .{}),
        .Draw => std.debug.print("\nThe game ended in a draw!\n", .{}),
        else => {},
    }
}
